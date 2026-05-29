# Análise: Migração de Navigator para go_router

> **Status: CONCLUÍDA ✅**
>
> A migração de telas de `Navigator.push()`/`MaterialPageRoute` para
> `go_router` (`context.push()`) está concluída. Não há mais nenhuma
> ocorrência de `Navigator.push`, `Navigator.pushNamed` ou
> `MaterialPageRoute` em arquivos `.dart` do projeto.
>
> `Navigator.pop()` continua válido e em uso para diálogos, drawer e
> modais (ver seção "Navegações que NÃO devem ser migradas").
>
> O conteúdo abaixo é mantido como registro do que foi migrado e como
> guia de orientação para futuras navegações.

## Objetivo

Migrar todas as navegações que usavam `Navigator.push()` com `MaterialPageRoute` para usar `go_router` (`context.push()`), mantendo compatibilidade e seguindo as regras de codificação do projeto.

## Situação Atual

### Rotas configuradas no go_router

- ✅ `cardPicking` (`/home/card-picking`) - `CardPickingScreen`
- ✅ `pickingProductsList` (`/home/picking-products-list`) - `PickingProductsListScreen`
- ✅ `addCart` (`/home/add-cart`) - `AddCartScreen` (rota adicionada na migração)
- ✅ `cameraBarcodeScanner` (`/camera-barcode-scanner`) - leitura de código de barras por câmera
- ✅ Todas as outras rotas principais já estão configuradas

A configuração de rotas fica em `lib/core/routing/app_router.dart`.

### Navegações migradas (registro)

#### 1. `separation_items_screen.dart` — abertura do `AddCartScreen`

**Concluído ✅** Migrado para `context.push()` usando a rota `AppRouter.addCart`,
com os códigos passados via `state.extra`.

```dart
final result = await context.push<AddCartSuccess?>(
  AppRouter.addCart,
  extra: {
    'codEmpresa': viewModel.separation?.codEmpresa ?? 1,
    'codSepararEstoque': viewModel.separation?.codSepararEstoque ?? 0,
  },
);
```

(`lib/ui/screens/separation_items_screen.dart` ~679)

#### 2. `separation_items_screen.dart` — abertura do `CardPickingScreen`

**Concluído ✅** Migrado para `context.push()` usando a rota existente
`AppRouter.cardPicking`, com o carrinho e o usuário passados via `state.extra`.

```dart
context.push<Object?>(
  AppRouter.cardPicking,
  extra: {'cart': addedCart, 'userModel': userModel},
).then((result) { /* ... */ });
```

(`lib/ui/screens/separation_items_screen.dart` ~788)

#### 3. `cart_item_card.dart` — `CardPickingScreen` e `PickingProductsListScreen`

**Concluído ✅** Migrado para `context.push()` usando as rotas existentes
`AppRouter.cardPicking` e `AppRouter.pickingProductsList`.

```dart
// Abertura do CardPickingScreen (~684)
final result = await context.push(
  AppRouter.cardPicking,
  extra: {'cart': currentCart, 'userModel': userModel},
);

// Abertura do PickingProductsListScreen (~996-1008)
context.push(
  AppRouter.pickingProductsList,
  extra: {'filterType': 'completed', 'cart': widget.cartRouteInternshipConsultation},
);
```

(`lib/ui/widgets/separate_items/cart_item_card.dart` ~684, ~996-1008)

#### 4. Leitura de código de barras por câmera

**Concluído ✅** O antigo `barcode_scanner_repository_mobile_impl.dart` não existe
mais. O fluxo atual está em `CameraBarcodeScanService`, que usa
`GoRouter.of(context).push(AppRouter.cameraBarcodeScanner)`:

```dart
final router = GoRouter.of(context);
final result = await router.push<Result<String>>(AppRouter.cameraBarcodeScanner);
```

(`lib/ui/services/camera_barcode_scan_service.dart` ~15-22)

## Navegações que NÃO devem ser migradas

### ✅ Manter `Navigator.pop()` para:

- Fechar diálogos (`showDialog`, `showModalBottomSheet`)
- Fechar Drawer
- Fechar modais
- Retornar valores de telas modais

**Justificativa:** `Navigator.pop()` é o método correto para fechar diálogos/modais que não são rotas do go_router.

## Plano de Implementação (executado)

### Fase 1: Adicionar rota para AddCartScreen ✅

1. ✅ Constante de rota adicionada em `AppRouter`: `addCart = '/home/add-cart'`
2. ✅ `GoRoute` adicionado em `lib/core/routing/app_router.dart` (~295-315)
3. ✅ Parâmetros configurados via `state.extra`

### Fase 2: Migrar navegações ✅

1. ✅ `separation_items_screen.dart` - `AddCartScreen` e `CardPickingScreen` migrados
2. ✅ `cart_item_card.dart` - `CardPickingScreen` e `PickingProductsListScreen` migrados

### Fase 3: Verificações ✅

1. ✅ Fluxo completo de navegação validado
2. ✅ Valores de retorno funcionam corretamente
3. ✅ Parâmetros são passados corretamente via `state.extra`
4. ✅ Nenhuma ocorrência remanescente de `Navigator.push`/`MaterialPageRoute`

## Considerações Importantes

### 1. Parâmetros e Dados

- Usar `state.extra` para passar objetos complexos
- Usar `context.push()` para navegação com retorno
- Usar `context.go()` para navegação sem retorno (substituição)

### 2. Valores de Retorno

- `context.push()` retorna `Future<T?>` similar a `Navigator.push()`
- Usar `context.pop(result)` para retornar valores

### 3. ViewModels e Providers

- Manter `ChangeNotifierProvider` nas rotas quando necessário
- Usar `ChangeNotifierProvider.value` quando ViewModel já existe

### 4. Regras de Codificação

- ✅ Seguir padrão de `go_router` (já estabelecido no projeto)
- ✅ Usar constantes de `AppRouter` para rotas
- ✅ Manter tratamento de erros e validações
- ✅ Verificar `context.mounted` antes de navegação

## Arquivos Modificados (registro)

1. `lib/core/routing/app_router.dart` - Rota `addCart` adicionada
2. `lib/ui/screens/separation_items_screen.dart` - 2 navegações migradas
3. `lib/ui/widgets/separate_items/cart_item_card.dart` - 2 navegações migradas
4. `lib/ui/services/camera_barcode_scan_service.dart` - leitura por câmera via `GoRouter.of(context).push`

## Benefícios

1. **Consistência**: Todas as navegações usam o mesmo sistema
2. **Manutenibilidade**: Rotas centralizadas em um único lugar
3. **Testabilidade**: Mais fácil testar navegação
4. **Deep Linking**: Suporte nativo a deep links
5. **Navegação Declarativa**: Rotas definidas de forma declarativa
