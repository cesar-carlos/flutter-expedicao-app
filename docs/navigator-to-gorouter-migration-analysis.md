# Análise: Migração de Navigator para go_router

## Objetivo
Migrar todas as navegações que usam `Navigator.push()` com `MaterialPageRoute` para usar `go_router` (`context.push()`), mantendo compatibilidade e seguindo as regras de codificação do projeto.

## Situação Atual

### Rotas já configuradas no go_router
- ✅ `cardPicking` (`/home/card-picking`) - `CardPickingScreen`
- ✅ `pickingProductsList` (`/home/picking-products-list`) - `PickingProductsListScreen`
- ✅ Todas as outras rotas principais já estão configuradas

### Navegações que precisam ser migradas

#### 1. `separation_items_screen.dart` (linha 313)
**Atual:**
```dart
final result = await Navigator.of(context).push<bool>(
  MaterialPageRoute(
    builder: (context) => AddCartScreen(
      codEmpresa: viewModel.separation?.codEmpresa ?? 1,
      codSepararEstoque: viewModel.separation?.codSepararEstoque ?? 0,
    ),
  ),
);
```

**Ação:** Criar rota para `AddCartScreen` e migrar para `context.push()`

#### 2. `separation_items_screen.dart` (linha 432)
**Atual:**
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => ChangeNotifierProvider(
      create: (_) => CardPickingViewModel(),
      child: CardPickingScreen(cart: newestCart, userModel: userModel),
    ),
  ),
);
```

**Ação:** Migrar para `context.push()` usando rota existente `cardPicking`

#### 3. `cart_item_card.dart` (linhas 864 e 883)
**Atual:**
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => ChangeNotifierProvider.value(
      value: tempViewModel,
      child: PickingProductsListScreen(...),
    ),
  ),
);
```

**Ação:** Migrar para `context.push()` usando rota existente `pickingProductsList`

#### 4. `barcode_scanner_repository_mobile_impl.dart` (linha 27)
**Atual:**
```dart
final result = await Navigator.of(
  _context!,
).push<String>(MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()));
```

**Ação:** Este é um caso especial - repositório de infraestrutura. Pode manter como está ou criar rota. **Decisão:** Manter como está por enquanto, pois é usado internamente pelo repositório.

## Navegações que NÃO devem ser migradas

### ✅ Manter `Navigator.pop()` para:
- Fechar diálogos (`showDialog`, `showModalBottomSheet`)
- Fechar Drawer
- Fechar modais
- Retornar valores de telas modais

**Justificativa:** `Navigator.pop()` é o método correto para fechar diálogos/modais que não são rotas do go_router.

## Plano de Implementação

### Fase 1: Adicionar rota para AddCartScreen
1. Adicionar constante de rota em `AppRouter`
2. Adicionar `GoRoute` em `app_router.dart`
3. Configurar parâmetros via `state.extra`

### Fase 2: Migrar navegações
1. `separation_items_screen.dart` - Migrar `AddCartScreen` e `CardPickingScreen`
2. `cart_item_card.dart` - Migrar `PickingProductsListScreen`

### Fase 3: Verificações
1. Testar fluxo completo de navegação
2. Verificar que valores de retorno funcionam corretamente
3. Verificar que parâmetros são passados corretamente
4. Verificar que não há quebras de funcionalidade

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

## Arquivos a Modificar

1. `lib/core/routing/app_router.dart` - Adicionar rota `addCart`
2. `lib/ui/screens/separation_items_screen.dart` - Migrar 2 navegações
3. `lib/ui/widgets/separate_items/cart_item_card.dart` - Migrar 2 navegações

## Benefícios

1. **Consistência**: Todas as navegações usam o mesmo sistema
2. **Manutenibilidade**: Rotas centralizadas em um único lugar
3. **Testabilidade**: Mais fácil testar navegação
4. **Deep Linking**: Suporte nativo a deep links
5. **Navegação Declarativa**: Rotas definidas de forma declarativa
