# Contrato Socket.IO neste coletor

A fonte do contrato e o servidor:

`D:\Developer\Node\data7-api-pix Campo\docs`

Leia nesta ordem:

1. `docs/comunicacao.md`
2. `docs/socket/protecoes-cliente.md`
3. `docs/expedicao/regras.md` (26 e 27)
4. `docs/socket/listen.md` e `docs/socket/escuta.md`
5. `docs/feature/protecao-base-e-emergencia.md` — o que o Node ja fez
   (Fase 0) e o que ainda e trabalho nos coletores (Fase 1)

Esta pagina so registra o que o `exp` ja cumpre e o que ainda falta.
Nao copie o guia do servidor para ca.

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

## Ainda nao no servidor

Nao inventar no cliente: token obrigatorio no handshake, teto de `LIMIT`
explicito, recusa de `LIKE`, `transacao: true`. Quando o servidor ligar
kick por lock, o aviso sai em `servidor.emergencia.listen` antes do
`disconnect`.
