# Análise e Padronização de Cores

## Objetivo

Padronizar todas as cores hardcoded (`Colors.`) para usar `AppColors` centralizado, seguindo as regras do projeto que indicam:
- ✅ **ALWAYS use centralized theme** (`core/theme/`)
- ✅ **ALWAYS use consistent colors** from theme
- ❌ **NEVER use hardcoded colors** - always use theme constants

## Situação Atual

### Arquivo AppColors Existente

O arquivo `lib/core/theme/app_colors.dart` já existe e contém:
- Cores principais do tema (primary, secondary, accent, light, dark)
- Cores de estado (success, error, warning, info)
- Cores neutras (grey, lightGrey, darkGrey)
- Cores básicas (white, black, transparent)
- Cores de superfície e fundo
- Cores de fonte
- Métodos utilitários para opacidade

### Cores Encontradas no Código

Análise de 93 arquivos que usam `Colors.` diretamente:

#### Cores Básicas (já existem)
- `Colors.white` → `AppColors.white` ✅
- `Colors.black` → `AppColors.black` ✅
- `Colors.transparent` → `AppColors.transparent` ✅

#### Cores de Estado (precisam mapeamento)
- `Colors.red` → `AppColors.error` (mas pode precisar variações)
- `Colors.orange` → `AppColors.warning` (mas pode precisar variações)
- `Colors.green` → `AppColors.success` (mas pode precisar variações)
- `Colors.blue` → `AppColors.info` (mas pode precisar variações)
- `Colors.grey` → `AppColors.grey` ✅

#### Cores Adicionais Encontradas (precisam ser adicionadas)
- `Colors.yellow` - usado em `ExpeditionSituation.emPausa`
- `Colors.lightGreen` - usado em `ExpeditionSituation.separado` e `conferido`
- `Colors.purple` - usado em `ExpeditionSituation.conferindo`
- `Colors.teal` - usado em `ExpeditionSituation.embalando` e `embalado`
- `Colors.black54` - usado para opacidade

#### Variações de Cores (shades)
- `Colors.red.shade700`, `Colors.red.shade600` - precisam de constantes
- `Colors.green.shade800`, `Colors.green.shade700` - precisam de constantes
- `Colors.orange.shade800`, `Colors.orange.shade700` - precisam de constantes
- `Colors.blue.shade700`, `Colors.blue.shade600` - precisam de constantes

## Plano de Implementação

### 1. Expandir AppColors

Adicionar cores faltantes e variações:

```dart
// Cores adicionais para situações
static const Color yellow = Color(0xFFFFEB3B);
static const Color lightGreen = Color(0xFF8BC34A);
static const Color purple = Color(0xFF9C27B0);
static const Color teal = Color(0xFF009688);

// Variações de cores de estado (shades)
static const Color red700 = Color(0xFFD32F2F);
static const Color red600 = Color(0xFFE53935);
static const Color green800 = Color(0xFF2E7D32);
static const Color green700 = Color(0xFF388E3C);
static const Color orange800 = Color(0xFFE65100);
static const Color orange700 = Color(0xFFF57C00);
static const Color blue700 = Color(0xFF1976D2);
static const Color blue600 = Color(0xFF1E88E5);

// Opacidades comuns
static const Color black54 = Color(0x8A000000);
```

### 2. Atualizar Modelos de Situação

Os enums de situação (`ExpeditionSituation`, `EntityType`, etc.) devem usar `AppColors`:

```dart
// Antes
enum ExpeditionSituation {
  aguardando('AGUARDANDO', 'Aguardando', Colors.grey),
  // ...
}

// Depois
enum ExpeditionSituation {
  aguardando('AGUARDANDO', 'Aguardando', AppColors.grey),
  // ...
}
```

### 3. Substituir Colors. por AppColors.

Substituir em todos os 93 arquivos identificados, priorizando:
1. Arquivos de UI/widgets
2. Arquivos de screens
3. Arquivos de models (situações)
4. Outros arquivos

### 4. Mapeamento de Cores

| Colors. Original | AppColors. Equivalente | Observação |
|-----------------|----------------------|------------|
| `Colors.red` | `AppColors.error` | Para erros gerais |
| `Colors.red.shade700` | `AppColors.red700` | Para textos/ícones de erro |
| `Colors.red.shade600` | `AppColors.red600` | Para textos secundários de erro |
| `Colors.orange` | `AppColors.warning` | Para avisos gerais |
| `Colors.orange.shade800` | `AppColors.orange800` | Para textos de aviso |
| `Colors.orange.shade700` | `AppColors.orange700` | Para textos secundários de aviso |
| `Colors.green` | `AppColors.success` | Para sucesso geral |
| `Colors.green.shade800` | `AppColors.green800` | Para textos de sucesso |
| `Colors.green.shade700` | `AppColors.green700` | Para textos secundários de sucesso |
| `Colors.blue` | `AppColors.info` | Para informações gerais |
| `Colors.blue.shade700` | `AppColors.blue700` | Para textos de informação |
| `Colors.blue.shade600` | `AppColors.blue600` | Para textos secundários de informação |
| `Colors.grey` | `AppColors.grey` | Já existe |
| `Colors.yellow` | `AppColors.yellow` | Adicionar |
| `Colors.lightGreen` | `AppColors.lightGreen` | Adicionar |
| `Colors.purple` | `AppColors.purple` | Adicionar |
| `Colors.teal` | `AppColors.teal` | Adicionar |
| `Colors.black54` | `AppColors.black54` | Adicionar |
| `Colors.white` | `AppColors.white` | Já existe |
| `Colors.black` | `AppColors.black` | Já existe |
| `Colors.transparent` | `AppColors.transparent` | Já existe |

## Arquivos Prioritários para Migração

### Alta Prioridade (UI/Widgets)
1. `lib/ui/screens/separation_items_screen.dart` - 5 ocorrências
2. `lib/ui/widgets/separate_items/cart_item_card.dart` - 40 ocorrências
3. `lib/ui/screens/card_picking_screen.dart` - 14 ocorrências
4. `lib/ui/widgets/card_picking/picking_item_card.dart` - 11 ocorrências

### Média Prioridade (Models)
1. `lib/domain/models/situation/expedition_situation_model.dart` - 14 ocorrências
2. `lib/domain/models/entity_type_model.dart` - 3 ocorrências
3. Outros modelos de situação

### Baixa Prioridade (Outros)
- Arquivos de configuração
- Arquivos de teste
- Arquivos de erro/diálogos

## Benefícios

1. **Consistência**: Todas as cores centralizadas em um único lugar
2. **Manutenibilidade**: Mudanças de tema em um único arquivo
3. **Conformidade**: Segue as regras do projeto
4. **Flexibilidade**: Fácil adicionar temas dark/light
5. **Rastreabilidade**: Fácil identificar onde cores são usadas

## Considerações

- Manter compatibilidade com código existente durante migração
- Testar visualmente após cada substituição
- Documentar novas cores adicionadas
- Considerar criar um script de migração automática (futuro)
