# Analise da implementacao do sistema de picking

## Visao geral

A feature esta organizada em camadas coerentes e hoje o fluxo principal
passa por:

- UI de tela e widgets em `lib/ui/**`
- estado e orquestracao em
  `lib/presentation/viewmodels/card_picking_viewmodel.dart`
- regras utilitarias e services em `lib/core/**` e `lib/domain/**`
- persistencia por use cases e repositories

## Componentes centrais

### Tela e layout

- `lib/ui/screens/card_picking_screen.dart`
- `lib/ui/widgets/card_picking/picking_card_scan.dart`
- `lib/ui/widgets/card_picking/components/picking_screen_layout.dart`

`card_picking_screen.dart` monta a tela e, no corpo, renderiza
`PickingCardScan`. O `PickingScreenLayout` nao e usado diretamente pela
tela: ele e montado DENTRO de `picking_card_scan.dart`, que distribui
widgets como proximo item, scanner e seletor de quantidade.

### ViewModel

`lib/presentation/viewmodels/card_picking_viewmodel.dart`

Responsabilidades principais:

- carregar itens do carrinho
- aplicar ordenacao e filtros
- manter progresso, caches e pendencias
- processar scans via resolver
- adicionar itens com atualizacao otimista
- salvar, cancelar e sincronizar carrinho

### Captura e tratamento do scan

- `lib/ui/widgets/card_picking/picking_card_scan.dart`
- `lib/ui/widgets/card_picking/components/scan_input_processor.dart`
- `lib/ui/widgets/card_picking/components/scan_ui_controller.dart`

Essas pecas dividem a experiencia de scan em:

- captura do input
- feedback sonoro e tatil
- exibicao de erros e dialogs

### Resolucao de negocio do scan

- `lib/presentation/viewmodels/controllers/picking_scan_resolver.dart`
- `lib/core/services/barcode_validation_service.dart`
- `lib/core/utils/picking_utils.dart`

Aqui ficam as regras para decidir:

- qual item e esperado
- se o barcode e valido
- se ha erro de setor, produto, prateleira ou quantidade

### Conclusao e salvamento

- `lib/ui/widgets/card_picking/components/picking_flow_controller.dart`
- `lib/domain/services/cart_validation_service.dart`
- `lib/domain/usecases/save_separation_cart/**`

Essas pecas cuidam da validacao de acesso, oferta de salvamento apos
concluir o setor e persistencia final do carrinho.

## Fluxo atual do scan ate a gravacao

### 1. Leitura

`PickingCardScan` recebe o codigo do scanner e encaminha para o
ViewModel.

### 2. Resolucao

`CardPickingViewModel.processScan(...)` delega para
`PickingScanResolver`, que usa:

- `PickingUtils.findNextItemToPick(...)` apenas como fallback, quando o
  `nextItem` recebido e `null`
- `BarcodeValidationService.validateScannedBarcode(...)`

O proximo item esperado em si nao vem de `findNextItemToPick` direto no
ViewModel: o cache do `CardPickingViewModel` e mantido por
`_findNextItemFromCurrentOrder()`, que itera sobre `_items` (ja
ordenados) e retorna o primeiro incompleto.

### 3. Reacao da UI

`ScanUiController` decide como responder ao resultado:

- sucesso
- produto errado
- setor errado
- prateleira errada
- excesso de quantidade

### 4. Gravacao do item

Em caso de sucesso, `CardPickingViewModel.addScannedItem(...)`:

- monta os parametros de adicao
- aplica update otimista local
- dispara a persistencia em background

O use case de adicao grava a separacao do item. O salvamento do carrinho
nao substitui essa gravacao; ele acontece depois, em outro momento do
fluxo.

### 5. Feedback do scan

`ScanInputProcessor.handleSuccessfulItemAddition(...)` aplica o feedback
atual:

- scan parcial correto: `playBarcodeScan()`
- scan que completa o item: `playItemCompleted()`

Depois disso, ele dispara a checagem assincrona de conclusao do setor.

### 6. Conclusao do setor

`PickingFlowController.checkAndShowSaveCartModal()` verifica se todos os
itens sem setor ou do setor do usuario foram concluidos.

Se sim:

- toca `playAlertComplete()`
- mostra o dialogo de salvamento

### 7. Finalizacao do carrinho

Se o usuario confirma no dialogo, `PickingFlowController.finishPicking()`
faz o restante:

- valida estado do socket
- exibe o dialogo de confirmacao "Finalizar Separação"
  (`_showFinishConfirmationDialog`) antes do loading; esse dialogo
  bloqueia a confirmacao enquanto houver operacoes de sync pendentes
  (`pendingOps == 0`)
- chama `viewModel.stopCartEventMonitoring()` antes de salvar
- abre loading
- chama `viewModel.saveCart()`
- toca `playSuccess()`
- retorna `'save_cart'`

Ou seja, apos concluir o setor o usuario passa por dois dialogos:
"Setor Concluído!" e, em seguida, "Finalizar Separação".

`CartItemCard` recebe esse retorno, mostra snackbar e navega para
`AppRouter.separation`.

## Pontos fortes atuais

- A ordenacao esta centralizada em `PickingUtils.sortItemsByAddress`; o
  proximo item do ViewModel deriva dessa lista ja ordenada via
  `_findNextItemFromCurrentOrder()`, e `PickingUtils.findNextItemToPick`
  serve como fallback no resolver.
- O service de validacao de carrinho esta separado do widget.
- O fluxo de feedback sonoro esta mais explicito por tipo de evento.
- O `AudioService` atual corrige repeticao consecutiva do mesmo som em
  dispositivos Android.
- O `saveCart()` bloqueia salvamento quando ainda existem operacoes
  pendentes de sincronizacao.

## Pontos de atencao

- `PickingCardScan` ainda concentra bastante coordenacao de scanner,
  foco, fluxo de prateleira e interacao com UI.
- A feature depende de cooperacao entre varios controllers e services,
  entao pequenas mudancas de UX tendem a atravessar varios arquivos.
- Documentacao baseada em numero de linha envelhece rapido aqui; prefira
  registrar responsabilidades por arquivo e metodo.

## Regra pratica para manutencao

Se a mudanca envolver scan, confira sempre estes quatro pontos em
conjunto:

1. `PickingCardScan`
2. `ScanInputProcessor`
3. `PickingFlowController`
4. `AudioService`

Se a mudanca envolver permissao ou salvamento, confira tambem:

1. `CartValidationService`
2. `CardPickingViewModel.saveCart()`
3. `SaveSeparationCartUseCase`
