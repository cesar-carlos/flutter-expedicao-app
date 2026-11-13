# Integracao HTTP e Socket.IO neste coletor

A fonte do contrato e o servidor:

`D:\Developer\Node\data7-api-pix Campo\docs`

Leia nesta ordem:

1. `docs/comunicacao.md`
2. `docs/socket/protecoes-cliente.md`
3. `docs/expedicao/regras.md` (26 e 27)
4. `docs/socket/listen.md` e `docs/socket/escuta.md`
5. `docs/feature/protecao-base-e-emergencia.md` — o que o Node ja fez
   (Fase 0) e o que ainda e trabalho nos coletores (Fase 1)

Esta pagina registra a aplicacao do contrato no `exp` e as melhorias
pendentes. Revisao documental e de codigo em 2026-11-13; nao comprova o
estado do APK instalado nem do servidor em execucao.

Para HTTP, consulte tambem `docs/contratos/consulta-http.md` e
`docs/http/usuario-consulta.md` no servidor. Para consultas Socket.IO,
consulte `docs/contratos/consulta-socket.md`, `where.md` e `paginacao.md`.
Nao duplique aqui o catalogo completo de eventos ou as regras do banco.

## Canais e envelopes

HTTP e Socket.IO usam o mesmo host/porta do Node. HTTP atende login e
usuarios; carrinho, separacao e conferencia usam Socket.IO. As rotas
HTTP `/expedicao/separacao` e `/expedicao/conferir`, sem `/notify`,
respondem 501: nao sao fallback para falha do socket.

`DioConfig` compartilha o cliente HTTP (10 s para conectar, 30 s para
enviar/receber). `SocketRequestHelper` aguarda 30 s por pedido, alem da
espera de prontidao da conexao. Sao limites diferentes; nao aumentar
timeouts para esconder consulta lenta ou carregamento sem fim.

- pedido Socket.IO: JSON string em `${socket.id} <evento>`, com
  `Session` e `ResponseIn` UUID; resposta no UUID
- consulta responde `Data`; mutacao responde `Mutation`; erro usa
  `Error`, com `Code` e `RequestId` opcionais
- `SocketRequestHelper` aceita string ou Map e remove o listener do
  UUID no encerramento da espera, inclusive por erro/timeout
- broadcasts usam o nome literal `*.listen`, sem prefixo de sessao;
  o cliente apenas escuta, nao emite esses canais
- `GET /health` comprova resposta HTTP, nao saude do SQL Server;
  socket conectado tambem nao comprova sucesso de uma consulta

## HTTP: limites relevantes para o app

Login e consulta de login usam `/expedicao/login-app`; cadastro usa
`/expedicao/create-login-app`. Nao existe `/expedicao/consult-login-app`.
Lista retorna `data: []`; consulta por chave retorna `data: {}` e pode
omitir metadados de pagina. Ausencia por chave retorna 404.

Senha nao diferencia maiusculas de minusculas: esta e uma regra de
negocio confirmada para o exp. Preserve o envio em minusculas no login,
cadastro e atualizacao de senha, sem migrar hashes ou tentar uma segunda
autenticacao com outra capitalizacao. O maximo e 20 caracteres, conforme
o servidor; o minimo de 4 ja adotado no app permanece. Nao truncar a
senha para atender ao limite. O cadastro preserva a mensagem e os
detalhes de validacao HTTP sem mostrar o payload bruto.

Em `/usuarios`, a busca por nome usa `NomeUsuario`. O servidor aplica
somente o primeiro filtro nesta prioridade: `CodUsuario`, `NomeUsuario`,
`CodEmpresa`, `Ativo=S`. Nao assumir que nome, empresa e situacao sao
combinados. `Ativo=N` sozinho retorna a lista geral no contrato atual.

`Offset` HTTP e ajustado ao inicio da pagina que o contem; envie
multiplos de `Limit`. `total` pode ficar limitado a 1500, mesmo com mais
registros: nao representa necessariamente a contagem integral da base.
Essas limitacoes sao do servidor documentado, nao regras novas de
selecao de usuario no app. Pendencias locais estao no fim desta pagina.

## Ja alinhado

| Pedido do servidor | Neste coletor |
| --- | --- |
| `CodSetorEstoque =` na lista de separar | `SeparationFiltersController` |
| `DataEmissao` por intervalo, nao `LIKE` | `>=` dia e `<` dia seguinte |
| `Where` como lista `{ key, value }` | `QueryBuilder.buildWhereParams()` via `SocketRequestHelper` |
| Nao disparar outra `separar.consulta` no tick do listen | `SeparationEventCoordinator` aplica o `Data` |
| Listen de negocio com nome literal e `allEvent: true` | insert/update/delete, `separar.consulta.listen`, `separar.update.listen` |
| `[SQL-CONN]` sem retry em loop | `isRetriableSocketError` recusa; UI reescreve a mensagem |
| Handshake sem token | `SocketConfig` so usa `websocket` |
| Esperar socket frio em vez de falhar no primeiro clique | `SocketReadyGate` (ate 8 s: conectado + `sessionId`) |
| Timeout de connect sem vazar na Zone | `waitForSocketConnect` (15 s) em `SocketConfig.connect` |
| Canal `servidor.emergencia.listen` | `ServidorEmergenciaService` na conexao, `allEvent: true` |

Nao voltar `LIKE` em `CodSetoresEstoque` nem em `DataEmissao`. O servidor
ainda reescreve build antigo; o cliente novo nao deve mandar isso.

Picking com setor do usuario: duas consultas (`CodSetorEstoque =` e
`CodSetorEstoque IS NULL`) mescladas em `PickingItemLoader`. Nao usar
`rawWhere` com `OR`.

Pagina de lista em `allRows()` usa `Pagination.fetchPageSize` (200). O
servidor, sem `LIMIT` do cliente, pagina 1500. Nao usar
`Pagination.unbounded()` em lista de producao.

Dedup de `*.consulta` iguais no mesmo socket e trabalho do servidor.
O coletor nao precisa (nem deve) cancelar o segundo pedido.
Isso nao cobre mutacoes nem garante idempotencia de gravacao.

## Paginas e atualizacoes parciais

`allRows()` faz varias consultas; nao cria um snapshot transacional.
Use ordem deterministica com desempate por chave ao paginar. Sem
`OrderBy` valido, o servidor usa `ORDER BY (SELECT NULL)`, que nao
garante continuidade entre paginas. Mudancas concorrentes ainda podem
deslocar registros entre paginas.

`separar.consulta.listen` entrega uma pagina global, nao a lista inteira
filtrada do usuario: padrao 20 registros e intervalo de 8 s apos cada
ciclo. O servidor suprime payload repetido e aplica backoff em falhas.
Ausencia de evento nao comprova desconexao, nem exclusao de registros.
A entrada de um cliente nao garante novo broadcast: manter a consulta
inicial e aplicar as linhas recebidas sem apagar registros ausentes
daquela pagina nem consultar novamente a cada tick.

`separar.update.listen` pode chegar com `Mutation` (com ou sem `Session`)
ou `Data`, conforme a origem. Preserve os caminhos CRUD e snapshot do
`SeparationEventCoordinator`; nao unifique envelopes sem migracao.

A trigger que gera conferencia ao finalizar a separacao nao emite
`conferir.insert.listen` nem `conferir.item.insert.listen`. Tambem nao
existe `conferir.consulta.listen` periodico. Nao inventar esses eventos
nem repetir `conferir.insert` para compensar a ausencia de notificacao;
uma atualizacao dessa lista exige consulta explicita no fluxo apropriado.

## Canal de emergencia

Canal `servidor.emergencia.listen` — so servidor para o cliente,
familia `{ Data }`, sem `Session`.

O `exp` escuta na conexao (`ServidorEmergenciaService` +
`ServidorEmergenciaViewModel`), com nome literal e `allEvent: true`.
A UI mostra `Mensagem` sem embrulhar em `Erro ao X:`.

Se `Acao == desconectar`:

- `SocketService.pauseForServerDisconnect()` para consultas/mutacao e
  o auto-reconnect (1 s … 30 s, ate 10 tentativas)
- depois do corte, dialogo de sessao encerrada; reconectar so com
  acao do usuario (`reconnectAfterServerEnd`)

`Acao == nenhuma` so avisa; o socket permanece.

O coletor nao chama `POST /internal/sockets/emergencia`.

Os documentos `comunicacao.md`, `socket/listen.md` e
`socket/protecoes-cliente.md` do servidor ainda descrevem o listener do
`exp` como ausente. Isso esta desatualizado em relacao ao codigo local.
O bloqueio de trafego e a pausa de reconexao ja existem; o cancelamento
do debounce e da fila de resync do picking tambem foi implementado.

Kick automatico de quem trava a base **ainda nao** esta ligado no
servidor. Quando existir, o aviso sai neste canal antes do
`disconnect`. Plano: `docs/feature/protecao-base-e-emergencia.md`.

## Erros

Prefixo `[identificador] mensagem` chega em `DataError.message`.
Nao embrulhar com `Exception('Erro ao X: $e')`.

| Prefixo | Neste coletor |
| --- | --- |
| `[SQL-CONN]` | Sem retry; mensagem de banco indisponivel |
| `[SQL-1222]` | Parseia `SQL-*`; tratar como "registro em uso, tente de novo" (nao e payload invalido) |
| `[INVALID_PAYLOAD]` | `ValidationFailure` |
| `[50014]` … | `BusinessFailure` |

Timeout ou perda de conexao depois de enviar uma mutacao nao comprova
rollback. O servidor documenta autocommit; dedup de consulta e UUID de
resposta nao tornam um INSERT idempotente. Antes de reenviar, reconciliar
o estado persistido pela chave de negocio e preservar as validacoes do
fluxo. Nao aplicar retry generico de rede a gravacoes indiscriminadamente.

Erro de carga deve encerrar o estado de loading e oferecer uma acao
clara. Registrar erro e stack trace; nao transformar falha de parse ou
de transporte em lista vazia de sucesso. Resposta `Data: []` valida,
por outro lado, e sucesso sem registros.

Nos pedidos Socket.IO, `Data` (consulta) e `Mutation` (gravacao) devem
estar presentes e ser listas, inclusive quando vazias. Campo ausente ou
`null` falha explicitamente no helper; essa validacao nao altera as
familias de broadcast `*.listen`.

## Correcoes de integracao no coletor

Correcoes aplicadas apos a revisao do contrato, com testes locais sem
servidor real:

| Ponto | Estado local |
| --- | --- |
| Busca de usuarios | Envia `NomeUsuario`, mantendo empresa, situacao e pagina. A prioridade de filtros do servidor permanece inalterada. |
| Erros HTTP | `BaseApiService` preserva mensagem, codigo, status e mensagens de validacao; corpo ausente/invalido usa fallback. |
| Diagnostico Socket.IO | `SocketErrorInfo` e `DataError` preservam `RequestId` e linhas adicionais separadas da mensagem apresentada. |
| Emergencia no picking | `CardPickingViewModel` recebe a porta de socket, cancela debounce e fila de resync na pausa, impede novo resync e remove o listener no dispose. Nao cancela nem reenvia mutacoes em andamento. |
| Lista parcial de usuarios | Servico e repositorio propagam a contagem de itens invalidos; a selecao avisa sobre resultado parcial e considera as linhas recebidas na pagina. Se nenhum item recebido for valido, retorna erro claro; lista realmente vazia continua sucesso. |

Validar futuras correcoes com testes de contrato (string/Map,
Data/Mutation/Error, timeout, disconnect, paginas e filtros), usando
fakes ou ambiente controlado. Nao confirmar, cancelar ou reenviar
mutacoes de documentos reais para validar a documentacao.

## Ainda nao no servidor

Nao inventar no cliente: token obrigatorio no handshake, teto de `LIMIT`
explicito, recusa de `LIKE`, `transacao: true`. Quando o servidor ligar
kick por lock, o aviso sai em `servidor.emergencia.listen` antes do
`disconnect`.
