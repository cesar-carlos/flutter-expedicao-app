# Oferta de salvamento apos concluir o setor

## Importante

O nome deste arquivo foi mantido por compatibilidade com referencias
anteriores, mas o comportamento atual nao e um auto-save silencioso.
Hoje o sistema oferece o salvamento ao usuario quando ele conclui os
itens do seu setor.

## Resumo do comportamento atual

1. Cada scan correto grava a separacao do item.
2. Depois da gravacao, o app verifica se os itens do setor acabaram.
3. Se acabaram, toca um som de conclusao do setor.
4. O usuario recebe um dialogo para decidir se quer salvar o carrinho.
5. Se confirmar, o fluxo chama `saveCart()` e retorna `'save_cart'`.
6. A lista de carrinhos mostra snackbar e navega para a tela principal
   de separacao.

## Onde a regra vive hoje

### Scan bem-sucedido

`lib/ui/widgets/card_picking/components/scan_input_processor.dart`

O `ScanInputProcessor` e responsavel por:

- resetar a quantidade temporaria
- invalidar cache local do scan
- tocar o audio correto do scan
- disparar a verificacao assincrona de conclusao do setor

Regras atuais de audio:

- scan correto parcial: `playBarcodeScan()`
- scan correto que completa o item: `playItemCompleted()`

### Conclusao do setor

`lib/ui/widgets/card_picking/components/picking_flow_controller.dart`

O `PickingFlowController` coordena o passo seguinte:

```dart
Future<void> checkAndShowSaveCartModal() async
```

Esse metodo:

1. le o `userSectorCode`
2. monta o subconjunto de itens sem setor ou do setor do usuario
3. confirma se o subconjunto nao esta vazio
4. verifica se todos esses itens foram concluidos
5. toca `playAlertComplete()`
6. abre o dialogo de salvamento

Hoje essa responsabilidade nao fica mais documentada como sendo do
`picking_card_scan.dart`.

### Confirmacao de salvamento

Ainda no `PickingFlowController`, o fluxo de confirmacao passa por:

```dart
Future<void> finishPicking() async
```

O metodo atual:

- evita double-submit com `_isFinishing`
- valida estado do socket
- abre loading
- chama `viewModel.saveCart()`
- toca `playSuccess()` quando salva
- faz `GoRouter.of(context).pop('save_cart')`

### Reacao na lista de carrinhos

`lib/ui/widgets/separate_items/cart_item_card.dart`

O `CartItemCard` nao salva mais o carrinho por conta propria nesse
fluxo. Ele apenas reage ao retorno:

```dart
if (result == 'save_cart' && context.mounted) {
  ScaffoldMessenger.of(context).showSnackBar(...);
  context.go(AppRouter.separation);
}
```

## Fluxo atualizado

```text
scan correto
  -> adiciona item na separacao
  -> toca som do scan
  -> verifica se o setor foi concluido
  -> se nao concluiu, continua
  -> se concluiu:
       -> toca AlertFalha.wav
       -> mostra dialogo
       -> usuario decide
       -> se salvar:
            -> finishPicking()
            -> viewModel.saveCart()
            -> pop('save_cart')
            -> snackbar + retorno para separacao
```

## Audio relevante para esse fluxo

- `AudioService.playBarcodeScan()`
  - sucesso parcial de scan
- `AudioService.playItemCompleted()`
  - ultimo scan necessario para completar o item
- `AudioService.playAlertComplete()`
  - todos os itens do setor foram concluidos
- `AudioService.playSuccess()`
  - carrinho salvo com sucesso

## Observacao importante sobre repeticao de som

O `AudioService` atual trata um problema real de Android em que repetir
o mesmo asset no mesmo player low-latency podia deixar os scans
seguintes mudos. Para isso, quando o mesmo `SoundType` sera repetido em
sequencia, o service executa `stop()` antes de `play()`.

Isso garante que:

- scans corretos consecutivos do mesmo item continuam emitindo som
- erros continuam com seus sons proprios
- a mudanca de produto nao depende mais de outro som intermediario para
  "destravar" o player

## Diferencas em relacao a documentacao antiga

- Nao documentar `_onFinalizeCart(skip=true)` como fluxo principal.
- Nao documentar `picking_card_scan.dart` como dono do dialogo de
  salvamento.
- Nao chamar o comportamento de "auto-save" se ele depende de escolha do
  usuario.
- Nao assumir que todo scan correto usa o mesmo som; hoje o ultimo scan
  do item usa um som proprio.
