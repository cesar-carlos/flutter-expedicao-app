# Logica de ordenacao de produtos para separacao

## Objetivo

O picking prioriza produtos sem setor e produtos do setor do usuario
logado, mantendo a navegacao por endereco de forma previsivel.

## Regra de filtragem

- Produto sem `codSetorEstoque`: aparece para todos os usuarios.
- Usuario sem `codSetorEstoque`: recebe todos os produtos.
- Usuario com `codSetorEstoque`: recebe apenas produtos sem setor ou do
  proprio setor.

Essa filtragem comeca na carga dos itens, em
`lib/presentation/viewmodels/card_picking_viewmodel.dart`.
Quando o usuario tem setor, a query atual usa:

```dart
..rawWhere('(CodSetorEstoque = $codSetorEstoqueUsuario OR CodSetorEstoque IS NULL)')
```

Depois da busca, filtros locais ainda podem ser aplicados pelo
`PickingFiltersController`.

## Regra de ordenacao

A ordenacao final fica centralizada em
`lib/core/utils/picking_utils.dart`, no metodo:

```dart
PickingUtils.sortItemsByAddress(...)
```

A prioridade usada hoje e:

1. Itens sem setor.
2. Itens do setor do usuario, quando houver setor definido.
3. Dentro de cada grupo, ordenacao natural por endereco.

O ViewModel apenas delega a ordenacao:

```dart
_items = PickingUtils.sortItemsByAddress(
  items,
  userSectorCode: _userModel?.codSetorEstoque,
);
```

## Calculo do proximo item

O proximo item esperado tambem e centralizado em
`lib/core/utils/picking_utils.dart`, no metodo:

```dart
PickingUtils.findNextItemToPick(...)
```

Ele recebe:

- a lista atual de itens
- um callback `isItemCompleted`
- o `userSectorCode` opcional

O `CardPickingViewModel` usa esse helper para manter o cache do proximo
item e para resolver o item atual esperado durante o scan.

## Validacao do barcode

A validacao do scan nao depende mais de logica espalhada pela UI. O
fluxo atual passa por:

1. `PickingCardScan` captura a leitura.
2. `CardPickingViewModel.processScan(...)` delega para o resolver.
3. `PickingScanResolver` usa:
   - `PickingUtils.findNextItemToPick(...)`
   - `BarcodeValidationService.validateScannedBarcode(...)`

O resultado classifica cenarios como:

- produto correto
- produto de outro setor
- produto errado
- prateleira errada
- quantidade excedida
- ausencia de itens pendentes para o setor

## Feedback sonoro atual

O comportamento de audio mudou e precisa ser lido assim:

- scan correto parcial: `AudioService.playBarcodeScan()`
- scan correto que completa a quantidade do item:
  `AudioService.playItemCompleted()`
- conclusao de todos os itens do setor:
  `AudioService.playAlertComplete()`

O primeiro e o segundo feedback sao disparados por
`lib/ui/widgets/card_picking/components/scan_input_processor.dart`.
O terceiro e disparado por
`lib/ui/widgets/card_picking/components/picking_flow_controller.dart`.

## Conclusao do setor

Depois de um scan bem-sucedido, o fluxo atual faz uma checagem
assincrona para descobrir se todos os itens do setor foram concluido.
Essa regra fica em:

```dart
PickingFlowController.checkAndShowSaveCartModal()
```

Hoje a verificacao:

- pega itens sem setor ou do setor do usuario
- interrompe se esse subconjunto estiver vazio
- testa se todos estao completos
- toca `playAlertComplete()`
- abre o dialogo de salvamento

Isso substitui a documentacao antiga que atribuia essa responsabilidade
ao `picking_card_scan.dart`.

## Exemplo pratico

Usuario do setor 3, com estes itens:

- item A: setor null, endereco `01-A-01`
- item B: setor 3, endereco `02-A-01`
- item C: setor 5, endereco `03-A-01`

Resultado esperado:

1. O usuario ve e separa A.
2. Depois ve e separa B.
3. O item C nao entra na lista desse usuario.
4. Quando A e B estiverem completos, o sistema oferece salvar o
   carrinho.

## Diferencas em relacao a versoes antigas da doc

- O path correto do ViewModel e
  `lib/presentation/viewmodels/card_picking_viewmodel.dart`.
- A ordenacao nao fica mais em um metodo privado do ViewModel.
- A conclusao do setor nao depende de retorno para `_onFinalizeCart`.
- O feedback sonoro do scan agora diferencia:
  - sucesso parcial
  - conclusao do item
  - conclusao do setor
