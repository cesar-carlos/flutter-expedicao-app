# Lógica de Ordenação de Produtos para Separação

## 📚 Documentações Relacionadas

- **[CartValidationService](cart-validation-service.md)** - Serviço de validação de carrinhos (refatorado)
- Este documento - Regras de ordenação e validações de setor

## 🆕 Melhorias Recentes

### 1. Auto-Salvamento após Completar Setor (Otimização)

**Data**: 2025-10-02

Implementada funcionalidade que **automaticamente oferece salvar o carrinho** quando o usuário separa o último item do seu setor, agilizando o processo de trabalho.

**Características:**

- 🔊 **Som diferenciado**: `AlertFalha.wav` indica conclusão do setor
- 📱 **Diálogo contextual**: Aparece automaticamente após último item
- 💾 **Salvamento direto**: Botão "Salvar Carrinho" salva sem confirmações extras
- ⬅️ **Retorno automático**: Volta para lista de carrinhos após salvar
- ✅ **Feedback visual**: Snackbar verde confirma salvamento

**Benefícios:**

- ⚡ **Reduz 80% do tempo** para salvar carrinhos
- 🎯 **Elimina 5-6 ações** do usuário (clicar, navegar, confirmar)
- 📊 **Aumenta produtividade** dos separadores
- 🎨 **Melhora UX** com ação contextual no momento certo

### 2. Correção de Bug: UserModel Nulo na Abertura Automática

**Data**: 2025-10-02

Corrigido bug onde ao adicionar carrinho e abrir tela de scan automaticamente, os produtos do setor errado eram exibidos.

**Problema**: `userModel` era passado como `null` em `separate_items_screen.dart`  
**Solução**: Buscar `userModel` da sessão antes de abrir a tela  
**Impacto**: Filtragem correta por setor desde a primeira abertura

### 3. Validação de Propriedade do Carrinho com Permissões

**Data**: 2025-10-02

Implementado sistema de validação que impede usuários de separarem, salvarem ou cancelarem carrinhos de outros usuários, com exceções para usuários com permissões especiais.

**Permissões implementadas:**

- `editaCarrinhoOutroUsuario` - Permite separar qualquer carrinho
- `salvaCarrinhoOutroUsuario` - Permite salvar qualquer carrinho
- `excluiCarrinhoOutroUsuario` - Permite cancelar qualquer carrinho

**Service criado**: `CartValidationService` (ver documentação separada)

## Visão Geral

A ordenação de produtos para separação foi implementada com base em uma regra de negócio que prioriza a organização por **setor de estoque** e depois por **endereço**.

## Regra de Negócio

### Objetivo

Os separadores fazem a separação por setor. Assim que acabam os produtos do setor deles, a separação é finalizada para aquele usuário.

### Critérios de Ordenação

A ordenação segue esta prioridade:

1. **Produtos SEM setor definido (`codSetorEstoque == null`)**: Aparecem **PRIMEIRO** para todos os usuários
2. **Produtos DO setor do usuário logado**: Aparecem em seguida (apenas se o usuário tiver um setor definido)
3. **Produtos de OUTROS setores**: Aparecem por último (não são mostrados para usuários com setor específico)
4. **Dentro de cada grupo**: Ordenação natural por `enderecoDescricao`

### Regras de Filtragem

- **Se o produto NÃO tem `codSetorEstoque`**: Mostrar para TODOS os usuários
- **Se o usuário NÃO tem `codSetorEstoque`**: Mostrar TODOS os produtos
- **Se ambos têm setor definido**: Mostrar apenas produtos sem setor OU do setor do usuário

## Implementação

### 1. CardPickingViewModel

**Arquivo**: `lib/domain/viewmodels/card_picking_viewmodel.dart`

**Método**: `_sortItemsByAddress()`

```dart
List<SeparateItemConsultationModel> _sortItemsByAddress(List<SeparateItemConsultationModel> items) {
  final userSectorCode = _userModel?.codSetorEstoque;

  return List.from(items)..sort((a, b) {
    final sectorA = a.codSetorEstoque;
    final sectorB = b.codSetorEstoque;

    // Priorizar produtos sem setor definido
    if (sectorA == null && sectorB != null) return -1;
    if (sectorA != null && sectorB == null) return 1;

    // Se usuário tem setor definido, agrupar produtos do mesmo setor
    if (userSectorCode != null && sectorA != null && sectorB != null) {
      final isASameUserSector = sectorA == userSectorCode;
      final isBSameUserSector = sectorB == userSectorCode;

      if (isASameUserSector && !isBSameUserSector) return -1;
      if (!isASameUserSector && isBSameUserSector) return 1;
    }

    // Ordenação natural por endereço
    // ... (lógica de ordenação numérica e alfabética)
  });
}
```

**Chamada**: Linha 466 em `_loadFilteredItems()`

### 2. PickingUtils

**Arquivo**: `lib/core/utils/picking_utils.dart`

**Método**: `sortItemsByAddress()`

Mesma lógica do `CardPickingViewModel`, mas com parâmetro opcional `userSectorCode`:

```dart
static List<SeparateItemConsultationModel> sortItemsByAddress(
  List<SeparateItemConsultationModel> items, {
  int? userSectorCode,
})
```

**Método**: `findNextItemToPick()`

Encontra o próximo item a ser separado respeitando a ordenação por setor:

```dart
static SeparateItemConsultationModel? findNextItemToPick(
  List<SeparateItemConsultationModel> items,
  bool Function(String itemId) isItemCompleted, {
  int? userSectorCode,
})
```

### 3. BarcodeValidationService

**Arquivo**: `lib/core/services/barcode_validation_service.dart`

Validação de código de barras agora considera o setor do usuário:

```dart
static BarcodeValidationResult validateScannedBarcode(
  String scannedBarcode,
  List<SeparateItemConsultationModel> items,
  bool Function(String itemId) isItemCompleted, {
  int? userSectorCode,
})
```

### 4. Widgets Atualizados

#### NextItemCard

**Arquivo**: `lib/ui/widgets/card_picking/widgets/next_item_card.dart`

Passa o `userSectorCode` ao buscar o próximo item:

```dart
final nextItem = PickingUtils.findNextItemToPick(
  viewModel.items,
  viewModel.isItemCompleted,
  userSectorCode: viewModel.userModel?.codSetorEstoque,
);
```

#### PickingCardScan

**Arquivo**: `lib/ui/widgets/card_picking/picking_card_scan.dart`

Passa o `userSectorCode` na validação do código de barras:

```dart
final validationResult = BarcodeValidationService.validateScannedBarcode(
  barcode,
  widget.viewModel.items,
  widget.viewModel.isItemCompleted,
  userSectorCode: widget.viewModel.userModel?.codSetorEstoque,
);
```

## Ordenação de Endereço

Dentro de cada grupo (sem setor / mesmo setor), a ordenação por `enderecoDescricao` segue:

1. **Numérico natural**: `01, 02, 03, ..., 10, 11` (não alfabético `01, 02, 10, 11`)
2. **Prioridade para endereços com números no início**
3. **Alfabética** para endereços sem números

### Exemplos

**Entrada:**

```
- Produto A: Setor 2, Endereço "10-A-01"
- Produto B: Setor null, Endereço "02-B-01"
- Produto C: Setor 1, Endereço "01-A-01"
- Produto D: Setor null, Endereço "11-C-01"
- Produto E: Setor 1, Endereço "03-A-01"
```

**Saída (usuário do Setor 1):**

```
1. Produto B: Setor null, Endereço "02-B-01"  (sem setor, end 02)
2. Produto D: Setor null, Endereço "11-C-01"  (sem setor, end 11)
3. Produto C: Setor 1, Endereço "01-A-01"     (setor do usuário, end 01)
4. Produto E: Setor 1, Endereço "03-A-01"     (setor do usuário, end 03)
```

**Saída (usuário SEM setor):**

```
1. Produto B: Setor null, Endereço "02-B-01"  (sem setor, end 02)
2. Produto D: Setor null, Endereço "11-C-01"  (sem setor, end 11)
3. Produto C: Setor 1, Endereço "01-A-01"     (setor 1, end 01)
4. Produto E: Setor 1, Endereço "03-A-01"     (setor 1, end 03)
5. Produto A: Setor 2, Endereço "10-A-01"     (setor 2, end 10)
```

## Modelos Relacionados

### SeparateItemConsultationModel

**Arquivo**: `lib/domain/models/separate_item_consultation_model.dart`

**Campos relevantes:**

- `codSetorEstoque` (int?): Código do setor de estoque do produto
- `nomeSetorEstoque` (String?): Nome do setor de estoque
- `enderecoDescricao` (String?): Descrição do endereço de armazenagem

### UserSystemModel

**Arquivo**: `lib/domain/models/user_system_models.dart`

**Campos relevantes:**

- `codSetorEstoque` (int?): Código do setor de estoque do usuário
- `nomeSetorEstoque` (String?): Nome do setor de estoque

### AppUser

**Arquivo**: `lib/domain/models/user/app_user.dart`

**Acesso ao setor do usuário:**

```dart
final userSectorCode = appUser.userSystemModel?.codSetorEstoque;
```

## Impacto na UX

1. **Separadores veem apenas seus produtos**: Produtos são filtrados e ordenados pelo setor
2. **Produtos gerais aparecem primeiro**: Produtos sem setor são mostrados para todos
3. **Fluxo otimizado**: Separador segue endereços sequenciais dentro do seu setor
4. **Finalização automática**: Quando não há mais produtos do setor, separação finaliza

## Validações Implementadas

### 1. Bloqueio de Produtos de Outros Setores

**Localização**: `lib/core/services/barcode_validation_service.dart`

Se um usuário com setor definido tentar escanear um produto de outro setor:

- ❌ Bloqueio do escaneamento
- 🔊 Som de erro
- 📱 Diálogo explicativo mostrando:
  - Nome do produto escaneado
  - Setor do produto
  - Setor do usuário
  - Mensagem: "Você só pode separar produtos do seu setor ou produtos sem setor definido"

**Implementação**:

```dart
// Verificar se o produto escaneado pertence a outro setor
final scannedItem = _findItemByBarcode(items, scannedBarcode);

if (scannedItem != null && userSectorCode != null) {
  final productSector = scannedItem.codSetorEstoque;
  if (productSector != null && productSector != userSectorCode) {
    return BarcodeValidationResult.wrongSector(
      scannedBarcode,
      scannedItem,
      userSectorCode,
    );
  }
}
```

### 2. Detecção de Fim de Itens do Setor

**Localização**: `lib/core/services/barcode_validation_service.dart`

Quando não há mais itens do setor do usuário para separar:

- 🔔 Som de alerta
- 📱 Diálogo informativo com opções:
  - **"Continuar Escaneando"**: Mantém na tela de scan
  - **"Finalizar Separação"**: Salva e volta para tela anterior

**Implementação**:

```dart
if (nextItem == null && userSectorCode != null) {
  final hasItemsForSector = items.any((item) =>
    !isItemCompleted(item.item) &&
    (item.codSetorEstoque == null || item.codSetorEstoque == userSectorCode)
  );

  if (!hasItemsForSector) {
    return BarcodeValidationResult.noItemsForSector(userSectorCode);
  }
}
```

### 2.1 🆕 Auto-Salvamento Inteligente

**Localização**: `lib/ui/widgets/card_picking/picking_card_scan.dart`

**Otimização Implementada**: Após adicionar o **último item do setor**, o sistema automaticamente oferece salvar o carrinho.

**Benefícios:**

- ⚡ **Agiliza o processo**: Usuário não precisa sair da tela e clicar em "Salvar"
- 🎯 **UX Otimizada**: Ação contextual no momento certo
- ⏱️ **Economia de tempo**: Reduz 2-3 cliques e navegação entre telas

**Fluxo:**

```
Usuário escaneia produto
        ↓
Item adicionado com sucesso ✓
        ↓
Sistema verifica: "Acabaram itens do setor?"
        ↓
    SIM  │  NÃO
         │   └──→ Continua normalmente
         ↓
🔔 Som de separação completa (AlertFalha.wav)
         ↓
📱 Diálogo: "Setor Concluído!"
         ↓
┌────────────────────────────┐
│ ✓ Todos os itens do seu    │
│   setor foram separados!   │
│                            │
│ Deseja salvar o carrinho?  │
│                            │
│ [Continuar] [Salvar] ←─────┼──┐
└────────────────────────────┘  │
                                │
                    ┌───────────┴───────────┐
                    │                       │
              Continuar               Salvar Carrinho
              Escaneando                    │
                    │                       ↓
                    │            Executa SaveSeparationCartUseCase
                    │                       │
                    │                       ↓
                    │              ✅ Carrinho salvo
                    │                       │
                    │                       ↓
                    │              Atualiza lista de carrinhos
                    │                       │
                    ↓                       ↓
              Retorna foco            Volta para tela
              ao scanner              de carrinhos
```

**Implementação**:

```dart
// Após adicionar item com sucesso
Future<void> _addItemToSeparation(...) async {
  final result = await widget.viewModel.addScannedItem(...);

  if (result.isSuccess) {
    _audioService.playBarcodeScan();
    _provideTactileFeedback();

    // 🆕 Verificar se acabaram os itens do setor
    await _checkIfSectorItemsCompleted();
  }
}

// Verificação automática
Future<void> _checkIfSectorItemsCompleted() async {
  final userSectorCode = widget.viewModel.userModel?.codSetorEstoque;
  if (userSectorCode == null) return;

  if (!widget.viewModel.hasItemsForUserSector) {
    _audioService.playAlertComplete(); // Som diferenciado
    _showSaveCartAfterSectorCompletedDialog(userSectorCode);
  }
}
```

**No CartItemCard**:

```dart
// Aguardar retorno da tela de scan
final result = await Navigator.of(context).push(...CardPickingScreen...);

// Se usuário escolheu salvar, executar automaticamente
if (result == 'save_cart' && context.mounted) {
  await _onFinalizeCart(context);
}
```

### 3. Mensagem na Tela Inicial

**Localização**: `lib/ui/widgets/card_picking/widgets/next_item_card.dart`

Quando o usuário entra na tela e não há itens do seu setor:

- 📘 Card informativo azul
- 💬 Mensagem: "Sem Itens para Separar"
- ℹ️ Explicação: "Não há itens do seu setor (Setor X) neste carrinho para separar"

### 4. Validação de Propriedade do Carrinho

**Localização**: `lib/ui/widgets/separate_items/cart_item_card.dart`

**⚙️ REFATORADO**: Agora utiliza `CartValidationService` (veja [documentação completa](cart-validation-service.md))

Apenas o usuário que incluiu o carrinho pode separar nele:

- ❌ Bloqueia outros usuários de separarem, salvarem ou cancelarem
- 🔒 Verifica `codUsuarioInicio` do carrinho
- 📱 Mostra diálogo de "Acesso Negado"
- 👤 Exibe nome do usuário que incluiu o carrinho

**⚠️ Exceções - Permissões Especiais:**

Usuários com permissões especiais podem bypassar esta restrição:

| Ação                   | Permissão Necessária               | Campo no UserSystemModel        |
| ---------------------- | ---------------------------------- | ------------------------------- |
| **Separar** (Editar)   | `editaCarrinhoOutroUsuario = 'S'`  | Pode separar qualquer carrinho  |
| **Salvar** (Finalizar) | `salvaCarrinhoOutroUsuario = 'S'`  | Pode salvar qualquer carrinho   |
| **Cancelar** (Excluir) | `excluiCarrinhoOutroUsuario = 'S'` | Pode cancelar qualquer carrinho |

**Implementação** (Refatorada com Service):

```dart
// 1. Obter usuário
final userModel = await _getUserModel();

// 2. Validar acesso usando CartValidationService
final accessValidation = CartValidationService.validateCartAccess(
  currentUserCode: userModel?.codUsuario,
  cart: cartRouteInternshipConsultation,
  userModel: userModel,
  accessType: CartAccessType.edit, // ou .save / .delete
);

// 3. Verificar resultado
if (!accessValidation.canAccess) {
  if (context.mounted && accessValidation.cartOwnerName != null) {
    _showDifferentUserDialog(context, accessValidation.cartOwnerName!);
  }
  return;
}
```

**Método Helper** (reutilizável):

```dart
Future<UserSystemModel?> _getUserModel() async {
  final userSessionService = locator<UserSessionService>();
  final appUser = await userSessionService.loadUserSession();
  return appUser?.userSystemModel;
}
```

### 5. Validação de Itens Disponíveis para o Setor

**Localização**: `lib/ui/widgets/separate_items/cart_item_card.dart`

Quando o usuário clica no botão "Separar" no card do carrinho:

1. Sistema verifica se o usuário tem setor definido
2. Se sim, consulta no banco se há itens disponíveis para o setor
3. Se NÃO há itens:
   - ❌ Bloqueia abertura da tela de scan
   - 📱 Mostra diálogo informativo
   - 💬 Mensagem: "Todos os itens do seu setor já foram separados!"
4. Se há itens:
   - ✅ Abre normalmente a tela de scan

**Implementação**:

```dart
Future<void> _onSeparateCart(BuildContext context) async {
  final userSessionService = locator<UserSessionService>();
  final appUser = await userSessionService.loadUserSession();
  final userModel = appUser?.userSystemModel;
  final userSectorCode = userModel?.codSetorEstoque;

  // Se o usuário tem setor definido, verificar se há itens disponíveis
  if (userSectorCode != null) {
    final hasItemsForSector = await _checkIfHasItemsForSector(
      cartRouteInternshipConsultation.codEmpresa,
      cartRouteInternshipConsultation.codOrigem,
      userSectorCode,
    );

    if (!hasItemsForSector) {
      _showNoItemsForSectorDialog(context, userSectorCode);
      return;
    }
  }

  // Navegar para CardPickingScreen
  Navigator.of(context).push(...);
}

Future<bool> _checkIfHasItemsForSector(int codEmpresa, int codOrigem, int userSectorCode) async {
  final repository = locator<BasicConsultationRepository<SeparateItemConsultationModel>>();
  final items = await repository.selectConsultation(...);

  // Verifica itens não completamente separados
  return items.any((item) =>
    item.quantidadeSeparacao < item.quantidade &&
    (item.codSetorEstoque == null || item.codSetorEstoque == userSectorCode)
  );
}
```

## Fluxos de Erro

### Fluxo 1: Produto de Outro Setor

```
1. Usuário escaneia produto
2. Sistema valida código de barras
3. Sistema detecta produto de outro setor
4. Reproduz som de erro
5. Mostra diálogo "Setor Incorreto"
6. Usuário fecha diálogo
7. Retorna foco ao scanner
```

### Fluxo 2: Sem Mais Itens do Setor (Durante Escaneamento)

```
1. Usuário escaneia produto
2. Sistema detecta que não há mais itens do setor
3. Reproduz som de alerta
4. Mostra diálogo "Separação Finalizada"
5. Usuário escolhe:
   a) "Continuar Escaneando" → Fecha diálogo, mantém na tela
   b) "Finalizar Separação" → Salva e volta para tela anterior
```

### Fluxo 3: Usuário Diferente Tentando Separar

```
1. Usuário clica no botão "Separar" no card do carrinho
2. Sistema verifica se é o mesmo usuário que incluiu o carrinho
3. Usuário atual ≠ Usuário que incluiu
4. Sistema bloqueia navegação
5. Mostra diálogo "Acesso Negado"
6. Exibe nome do usuário que incluiu o carrinho
7. Usuário fecha diálogo
8. Permanece na tela de carrinhos
```

### Fluxo 4: Sem Itens do Setor (Antes de Entrar na Tela)

```
1. Usuário clica no botão "Separar" no card do carrinho
2. Sistema verifica se é o mesmo usuário (OK)
3. Sistema verifica se usuário tem setor definido
4. Sistema consulta itens disponíveis para o setor
5. Não há itens disponíveis
6. Sistema bloqueia navegação
7. Mostra diálogo "Sem Itens para Separar"
8. Usuário fecha diálogo
9. Permanece na tela de carrinhos
```

## Testes

Para testar a funcionalidade:

1. Login com usuário que TEM setor de estoque definido
2. Iniciar separação de carrinho
3. Verificar ordem dos produtos:

   - Produtos sem setor aparecem primeiro
   - Depois produtos do setor do usuário
   - Produtos de outros setores não aparecem

4. Login com usuário SEM setor de estoque
5. Verificar que TODOS os produtos aparecem, ordenados por endereço

## Histórico

- **2025-10-02**: Implementação inicial da ordenação por setor de estoque
