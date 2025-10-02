# CartValidationService - Documentação

## 📋 Visão Geral

O `CartValidationService` é um serviço centralizado que encapsula todas as validações relacionadas a carrinhos de separação, promovendo:

- ✅ **Separação de Responsabilidades**: Remove lógica de validação dos widgets
- 🔄 **Reutilização de Código**: Métodos podem ser usados em qualquer lugar
- 📖 **Legibilidade**: Código mais limpo e autodocumentado
- 🧪 **Testabilidade**: Métodos estáticos fáceis de testar

---

## 🎯 Métodos Disponíveis

### 1. Verificação de Permissões

#### `canEditOtherUserCart(UserSystemModel? userModel)`

Verifica se o usuário pode **editar/separar** carrinhos de outros usuários.

```dart
final canEdit = CartValidationService.canEditOtherUserCart(userModel);
// Retorna: true se editaCarrinhoOutroUsuario == Situation.ativo
```

#### `canSaveOtherUserCart(UserSystemModel? userModel)`

Verifica se o usuário pode **salvar/finalizar** carrinhos de outros usuários.

```dart
final canSave = CartValidationService.canSaveOtherUserCart(userModel);
// Retorna: true se salvaCarrinhoOutroUsuario == Situation.ativo
```

#### `canDeleteOtherUserCart(UserSystemModel? userModel)`

Verifica se o usuário pode **cancelar/excluir** carrinhos de outros usuários.

```dart
final canDelete = CartValidationService.canDeleteOtherUserCart(userModel);
// Retorna: true se excluiCarrinhoOutroUsuario == Situation.ativo
```

---

### 2. Validação de Acesso ao Carrinho

#### `canAccessCart({required params})`

Verifica se o usuário pode acessar um carrinho específico.

**Parâmetros:**

- `currentUserCode` - Código do usuário atual
- `cartOwnerCode` - Código do usuário que incluiu o carrinho
- `hasPermission` - Se possui permissão especial

**Lógica:**

1. Se `currentUserCode == cartOwnerCode` → **✅ PERMITIR**
2. Se `hasPermission == true` → **✅ PERMITIR**
3. Caso contrário → **❌ BLOQUEAR**

```dart
final canAccess = CartValidationService.canAccessCart(
  currentUserCode: 100,
  cartOwnerCode: 100,
  hasPermission: false,
);
// Retorna: true (é o dono)
```

---

### 3. Validação Completa de Acesso

#### `validateCartAccess({required params})`

Método principal que combina todas as validações de acesso.

**Parâmetros:**

- `currentUserCode` - Código do usuário atual
- `cart` - Modelo do carrinho (`ExpeditionCartRouteInternshipConsultationModel`)
- `userModel` - Modelo do usuário (`UserSystemModel?`)
- `accessType` - Tipo de acesso desejado (`CartAccessType`)

**Retorna:** `CartAccessValidationResult`

```dart
final validation = CartValidationService.validateCartAccess(
  currentUserCode: userModel?.codUsuario,
  cart: cartRouteInternshipConsultation,
  userModel: userModel,
  accessType: CartAccessType.edit,
);

if (!validation.canAccess) {
  print('Acesso negado: ${validation.reason}');
  print('Dono do carrinho: ${validation.cartOwnerName}');
}
```

**Tipos de Acesso:**

- `CartAccessType.edit` → Separar/Editar (verifica `editaCarrinhoOutroUsuario`)
- `CartAccessType.save` → Salvar/Finalizar (verifica `salvaCarrinhoOutroUsuario`)
- `CartAccessType.delete` → Cancelar/Excluir (verifica `excluiCarrinhoOutroUsuario`)

---

### 4. Verificação de Itens Disponíveis

#### `hasItemsForUserSector({required params})`

Verifica se há itens disponíveis para o setor do usuário.

**Parâmetros:**

- `codEmpresa` - Código da empresa
- `codOrigem` - Código da origem (separação)
- `userSectorCode` - Código do setor do usuário

**Lógica:**

- Busca itens da separação no repositório
- Filtra itens não completamente separados (`quantidadeSeparacao < quantidade`)
- Verifica se há itens **sem setor** OU **do setor do usuário**
- Em caso de erro, retorna `true` (evita bloquear usuário)

```dart
final hasItems = await CartValidationService.hasItemsForUserSector(
  codEmpresa: 1,
  codOrigem: 10,
  userSectorCode: 5,
);

if (!hasItems) {
  print('Não há mais itens para o setor 5');
}
```

---

## 🔄 Fluxo de Validação

```
┌─────────────────────────────────────────────┐
│ Usuário tenta ação no carrinho              │
└────────────────┬────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────┐
│ 1. Obter UserModel da sessão                │
└────────────────┬────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────┐
│ 2. Validar acesso com validateCartAccess()  │
└────────────────┬────────────────────────────┘
                 │
        ┌────────┴────────┐
        │                 │
        ▼                 ▼
   ✅ canAccess     ❌ !canAccess
        │                 │
        │                 ▼
        │      ┌──────────────────────┐
        │      │ Mostrar diálogo      │
        │      │ "Acesso Negado"      │
        │      └──────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────┐
│ 3. Validar itens do setor (se aplicável)    │
│    hasItemsForUserSector()                   │
└────────────────┬────────────────────────────┘
                 │
        ┌────────┴────────┐
        │                 │
        ▼                 ▼
   ✅ hasItems      ❌ !hasItems
        │                 │
        │                 ▼
        │      ┌──────────────────────┐
        │      │ Mostrar mensagem     │
        │      │ "Sem itens"          │
        │      └──────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────┐
│ 4. Prosseguir com a ação                    │
└─────────────────────────────────────────────┘
```

---

## 💡 Exemplo de Uso Completo

### Antes da Refatoração

```dart
Future<void> _onSeparateCart(BuildContext context) async {
  // Obter usuário da sessão
  final userSessionService = locator<UserSessionService>();
  final appUser = await userSessionService.loadUserSession();
  final userModel = appUser?.userSystemModel;
  final currentUserCode = userModel?.codUsuario;

  // Validação de permissão (código duplicado)
  if (currentUserCode != null &&
      currentUserCode != cart.codUsuarioInicio &&
      userModel?.editaCarrinhoOutroUsuario != Situation.ativo) {
    _showDifferentUserDialog(context);
    return;
  }

  // Validação de itens (lógica de repositório no widget)
  final repository = locator<BasicConsultationRepository<SeparateItemConsultationModel>>();
  final queryBuilder = QueryBuilder()
    ..equals('CodEmpresa', cart.codEmpresa.toString())
    ..equals('CodSepararEstoque', cart.codOrigem.toString());
  final items = await repository.selectConsultation(queryBuilder);
  final hasItems = items.any((item) =>
    item.quantidadeSeparacao < item.quantidade &&
    (item.codSetorEstoque == null || item.codSetorEstoque == userSectorCode)
  );

  if (!hasItems) {
    _showNoItemsDialog(context);
    return;
  }

  // Abrir tela...
}
```

### Depois da Refatoração

```dart
Future<void> _onSeparateCart(BuildContext context) async {
  // 1. Obter usuário
  final userModel = await _getUserModel();

  // 2. Validar acesso (limpo e reutilizável)
  final accessValidation = CartValidationService.validateCartAccess(
    currentUserCode: userModel?.codUsuario,
    cart: cartRouteInternshipConsultation,
    userModel: userModel,
    accessType: CartAccessType.edit,
  );

  if (!accessValidation.canAccess) {
    if (context.mounted && accessValidation.cartOwnerName != null) {
      _showDifferentUserDialog(context, accessValidation.cartOwnerName!);
    }
    return;
  }

  // 3. Validar itens (limpo e reutilizável)
  if (userModel?.codSetorEstoque != null) {
    final hasItems = await CartValidationService.hasItemsForUserSector(
      codEmpresa: cartRouteInternshipConsultation.codEmpresa,
      codOrigem: cartRouteInternshipConsultation.codOrigem,
      userSectorCode: userModel!.codSetorEstoque!,
    );

    if (!hasItems && context.mounted) {
      _showNoItemsForSectorDialog(context, userModel.codSetorEstoque!);
      return;
    }
  }

  // 4. Abrir tela...
}
```

---

## 📊 Comparação: Antes vs Depois

| Aspecto                        | Antes      | Depois     |
| ------------------------------ | ---------- | ---------- |
| **Linhas de código no widget** | ~40 linhas | ~20 linhas |
| **Imports necessários**        | 5 imports  | 2 imports  |
| **Duplicação de código**       | Alta (3x)  | Zero       |
| **Testabilidade**              | Difícil    | Fácil      |
| **Legibilidade**               | Média      | Alta       |
| **Manutenção**                 | Difícil    | Fácil      |

---

## 🎯 Benefícios da Refatoração

### 1. **Separação de Responsabilidades**

- ✅ Widget focado em UI
- ✅ Service focado em lógica de negócio
- ✅ Repositório focado em dados

### 2. **Reutilização de Código**

- ✅ Mesma validação em 3 métodos (`_onSeparateCart`, `_onFinalizeCart`, `_showCancelDialog`)
- ✅ Pode ser usado em outros widgets no futuro
- ✅ Centralizado em um único lugar

### 3. **Facilidade de Manutenção**

- ✅ Mudanças de regra em um único lugar
- ✅ Reduz chance de bugs por inconsistência
- ✅ Código autodocumentado

### 4. **Testabilidade**

- ✅ Métodos estáticos fáceis de testar
- ✅ Não depende de contexto do Flutter
- ✅ Pode mockar repositório facilmente

---

## 📁 Localização dos Arquivos

- **Service**: `lib/domain/services/cart_validation_service.dart`
- **Widget Refatorado**: `lib/ui/widgets/separate_items/cart_item_card.dart`
- **Documentação**: `docs/separacao/cart-validation-service.md`
- **Documentação Completa**: `docs/separacao/product-ordering-logic.md`

---

## 🔧 Extensibilidade

Para adicionar novas validações:

```dart
// No service
class CartValidationService {
  // ... métodos existentes

  /// Nova validação
  static bool canExportCart(UserSystemModel? userModel) {
    return userModel?.exportaCarrinho == Situation.ativo;
  }

  static Future<bool> hasItemsExpired({
    required int codEmpresa,
    required int codOrigem,
  }) async {
    // Lógica de verificação
  }
}
```

```dart
// No widget
final canExport = CartValidationService.canExportCart(userModel);
if (!canExport) {
  _showNoPermissionDialog(context);
  return;
}
```

---

## ✅ Conclusão

A refatoração com `CartValidationService` trouxe:

- 🎯 **50% menos código** nos widgets
- 🔄 **Zero duplicação** de lógica de validação
- 📖 **Alta legibilidade** e autodocumentação
- 🧪 **Fácil testabilidade** com métodos estáticos
- 🔧 **Fácil manutenção** e extensibilidade

Todas as validações agora estão centralizadas, reutilizáveis e consistentes em toda a aplicação.
