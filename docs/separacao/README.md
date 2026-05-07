# Sistema de separacao por setor

Esta pasta concentra a documentacao tecnica da feature de separacao.
Os arquivos abaixo foram revisados para refletir a implementacao atual
do app.

## Documentos

### [product-ordering-logic.md](product-ordering-logic.md)

Explica como os itens sao filtrados e ordenados para o picking, como o
proximo item e calculado e quais feedbacks de scan estao ativos hoje.

### [cart-validation-service.md](cart-validation-service.md)

Descreve o `CartValidationService` atual, incluindo permissao de acesso
ao carrinho, validacao por setor e o formato orientado a instancia com
repositorio injetado.

### [auto-save-implementation.md](auto-save-implementation.md)

Documenta o fluxo atual de oferta de salvamento apos concluir o setor.
Apesar do nome do arquivo, o comportamento atual nao e um
"auto-save" silencioso: o usuario recebe um dialogo e escolhe se quer
salvar naquele momento.

### [picking-implementation-analysis.md](picking-implementation-analysis.md)

Resume a arquitetura da tela de picking, o fluxo completo do scan ate a
gravacao e os principais pontos de extensao da feature.

## Verdades atuais da implementacao

- A ordenacao final dos itens acontece em
  `lib/core/utils/picking_utils.dart`, via
  `PickingUtils.sortItemsByAddress(...)`.
- O proximo item esperado vem de
  `PickingUtils.findNextItemToPick(...)`.
- O scan bem-sucedido grava a separacao do item no momento da leitura;
  `saveCart()` e usado depois para finalizar o carrinho.
- O feedback sonoro esta separado por evento:
  - scan correto parcial: `AudioService.playBarcodeScan()`
  - scan correto que completa o item:
    `AudioService.playItemCompleted()`
  - conclusao dos itens do setor:
    `AudioService.playAlertComplete()`
- A oferta de salvamento apos concluir o setor e coordenada por
  `lib/ui/widgets/card_picking/components/picking_flow_controller.dart`.
- `lib/ui/widgets/separate_items/cart_item_card.dart` apenas reage ao
  retorno `'save_cart'`, mostra snackbar e navega para
  `AppRouter.separation`.
- `CartValidationService` nao e mais uma API estatica. Hoje ele e
  instanciado com
  `BasicConsultationRepository<SeparateItemConsultationModel>`.

## Onde procurar no codigo

- Tela principal: `lib/ui/screens/card_picking_screen.dart`
- ViewModel: `lib/presentation/viewmodels/card_picking_viewmodel.dart`
- Ordenacao e proximo item: `lib/core/utils/picking_utils.dart`
- Validacao de barcode: `lib/core/services/barcode_validation_service.dart`
- Processamento de sucesso/erro do scan:
  `lib/ui/widgets/card_picking/components/scan_input_processor.dart`
- Fluxo de conclusao e salvamento:
  `lib/ui/widgets/card_picking/components/picking_flow_controller.dart`

## Observacoes

- Os arquivos antigos desta pasta misturavam comportamento atual com
  referencias a uma implementacao anterior.
- Esta revisao prioriza o fluxo que esta em producao hoje, sem manter
  exemplos que apontavam para paths, metodos ou responsabilidades que
  nao existem mais no codigo.
