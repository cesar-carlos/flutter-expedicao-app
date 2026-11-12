# Release v2.1.7+8

## Resumo

Versao **2.1.7** (build **+8**) evita o travamento do Android ao abrir a
separacao, mostra a falha real do servidor no coletor e deixa o
cancelamento do carrinho alinhado com as regras do servidor.

## Estabilidade

- O player de som nao inicializa mais no clique da separacao. No Android
  isso bloqueava a UI e abria o dialogo de ANR.
- Falha `[SQL-CONN]` nao entra em retry. O coletor informa que o banco
  do servidor esta indisponivel.

## Socket e erros

- Envelope `[50014]` e prefixos do servidor passam a aparecer na
  mensagem do coletor.
- Consultas paginadas e retry so repetem erros recuperaveis.

## Carrinho

- Cancelamento recusa situacao invalida antes de chamar o servidor.
- Fluxo de consistencia alinhado com as regras de situacao do carrinho.

## Homologacao sugerida

1. **Separacao**: abrir `/home/separation` e confirmar que a tela
   responde sem o dialogo "isn't responding".
2. **SQL-CONN**: com o banco do servidor fora, confirmar a mensagem
   amigavel e que a consulta nao fica tentando para sempre.
3. **Carrinho**: cancelar em situacao valida e recusar nas invalidas.
4. **Auto-update**: instalar a `v2.1.6+7` e confirmar a deteccao da
   `v2.1.7+8`.
