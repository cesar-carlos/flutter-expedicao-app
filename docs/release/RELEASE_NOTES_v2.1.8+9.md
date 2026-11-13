# Release v2.1.8+9

## Resumo

Versao **2.1.8** (build **+9**) evita o travamento do Android ao
clicar em Separar, escuta o canal de emergencia do servidor e
preserva o foco do scanner no picking.

## Estabilidade

- Clique em Separar usa os itens ja carregados na tela. Nao dispara
  outra consulta `separar.item.consulta` so para validar o setor.
- Decode do socket cede um frame em vez de abrir isolate no isolate
  de UI. Isso eliminava o ANR com a tela em "Carregando dados do
  picking...".
- Logger do app nao liga `Level.ALL` no root. O `socket_io_client`
  deixava de despejar o JSON inteiro no isolate de UI.
- `hierarchicalLoggingEnabled` fica ativo no bootstrap. O hot restart
  nao cai mais com `UnsupportedError` ao ajustar o logger do app.

## Picking e scanner

- Modo manual/scan e o foco dos modais permanecem ao abrir o carrinho.
- Conversao de unidades e o carregamento paginado cedem o isolate de
  UI entre paginas.
- Extra do GoRouter no picking e serializado. Rota invalida abre tela
  de erro em vez de derrubar o app.

## Socket

- Canal `servidor.emergencia.listen` na conexao, com aviso na UI.
- `Acao=desconectar` pausa o auto-reconnect e pede acao do usuario.
- Timeout de connect nao vaza na Zone.

## Homologacao sugerida

1. **Separar**: no Card Picking, abrir o carrinho e confirmar que a
   tela responde sem o dialogo "isn't responding".
2. **Scanner**: modo manual, scan e foco dos modais de quantidade.
3. **Emergencia**: aviso `Acao=nenhuma` e corte `Acao=desconectar`.
4. **Auto-update**: instalar a `v2.1.7+8` e confirmar a deteccao da
   `v2.1.8+9`.
