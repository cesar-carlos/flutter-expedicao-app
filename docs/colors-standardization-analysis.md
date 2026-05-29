# Análise e Padronização de Cores

> **Status: QUASE CONCLUÍDO.** O plano descrito neste documento foi
> largamente executado: `AppColors` já contém todas as cores adicionais
> previstas (e várias extras), e os enums de situação
> (`ExpeditionSituation`, `EntityType`, etc.) já usam `AppColors.*`. Resta
> apenas um resíduo pequeno de `Colors.` do Material em ~7 arquivos (ver
> "Situação Atual"). As seções de plano/mapeamento abaixo são mantidas
> como registro histórico.

## Objetivo

Padronizar todas as cores hardcoded (`Colors.`) para usar `AppColors` centralizado, seguindo as regras do projeto que indicam:

- ✅ **ALWAYS use centralized theme** (`core/theme/`)
- ✅ **ALWAYS use consistent colors** from theme
- ❌ **NEVER use hardcoded colors** - always use theme constants

## Situação Atual

### Arquivo AppColors Existente

O arquivo `lib/core/theme/app_colors.dart` já existe e hoje contém:

- Cores principais do tema teal (primary, secondary, accent, light, dark)
  e aliases (`primaryTeal`, `secondaryTeal`, etc.)
- Cores de estado (success, error, warning, info — `info` aponta para
  `blue500`)
- Cores adicionais de situação (yellow, lightGreen, purple, teal) **e
  extras**: `brown`, `indigo`
- Variações de estado (shades): `red800/700/600/300/50`,
  `green800/700/600/300/100/50`, `orange800/700`,
  `blue800/700/600/500/100`
- Escala neutra: `grey100`..`grey700`, além de `grey`, `lightGrey`,
  `darkGrey`, `black54`, `black87`
- Cores básicas (white, black, transparent), de superfície/fundo e de
  fonte (semantic aliases)
- Métodos utilitários para opacidade e helpers de adaptação dark theme

> **Conclusão:** todas as cores que o plano original dizia "precisam ser
> adicionadas" (yellow, lightGreen, purple, teal, black54) **já existem**,
> junto de muitas outras.

### Resíduo de `Colors.` no Código

A métrica original ("93 arquivos usam `Colors.` diretamente") está
**defasada**. A maior parte das ocorrências hoje é `AppColors.` (que
contém a substring `Colors.`). O resíduo real de `Colors.` do Material em
`lib/` é de **~7 arquivos**:

- `lib/ui/screens/separation_screen.dart` — `Colors.blue`
- `lib/ui/widgets/user_profile/user_profile_widgets.dart` —
  `Colors.grey.shade*`
- `lib/ui/screens/picking_products_list_screen.dart` —
  `Colors.orange` / `Colors.green`
- `lib/ui/widgets/picking_products_list/picking_product_list_item.dart` —
  `Colors.green`
- `lib/ui/widgets/data_grid/separate_consultation_data_grid.dart` —
  `Colors.grey` / `Colors.white`
- `lib/ui/screens/separation_items_screen.dart` — `Colors.transparent`
- `lib/core/theme/app_colors.dart` — aliases legítimos
  (`white`/`black`/`transparent` apontam para `Colors.*`)

> Os arquivos antes citados como tendo muitas ocorrências
> (`cart_item_card.dart`, `card_picking_screen.dart`) hoje já usam
> `AppColors`.

#### Cores Básicas (já existem)

- `Colors.white` → `AppColors.white` ✅
- `Colors.black` → `AppColors.black` ✅
- `Colors.transparent` → `AppColors.transparent` ✅

#### Cores Adicionais (✅ já adicionadas)

- `Colors.yellow` → `AppColors.yellow` ✅
- `Colors.lightGreen` → `AppColors.lightGreen` ✅
- `Colors.purple` → `AppColors.purple` ✅
- `Colors.teal` → `AppColors.teal` ✅
- `Colors.black54` → `AppColors.black54` ✅

#### Variações de Cores (shades) — ✅ já existem

- `red700`, `red600`, `green800`, `green700`, `orange800`, `orange700`,
  `blue700`, `blue600` (e várias outras) já estão em `AppColors`.

## Plano de Implementação

> **Progresso:** etapas 1 e 2 ✅ concluídas; etapa 3 🔄 quase concluída
> (resta o resíduo listado acima); etapa 4 (mapeamento) é referência
> histórica.

### 1. Expandir AppColors — ✅ CONCLUÍDA

Cores faltantes e variações já foram adicionadas (e ampliadas). Esboço
original mantido como referência:

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

### 2. Atualizar Modelos de Situação — ✅ CONCLUÍDA

Os enums de situação (`ExpeditionSituation`, `EntityType`, etc.) **já
usam** `AppColors.*`:

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

### 3. Substituir Colors. por AppColors. — 🔄 QUASE CONCLUÍDA

A substituição em massa já ocorreu. Resta apenas o resíduo de ~7
arquivos listado em "Situação Atual" (fora os aliases legítimos em
`app_colors.dart`).

### 4. Mapeamento de Cores

| Colors. Original         | AppColors. Equivalente  | Observação                            |
| ------------------------ | ----------------------- | ------------------------------------- |
| `Colors.red`             | `AppColors.error`       | Para erros gerais                     |
| `Colors.red.shade700`    | `AppColors.red700`      | Para textos/ícones de erro            |
| `Colors.red.shade600`    | `AppColors.red600`      | Para textos secundários de erro       |
| `Colors.orange`          | `AppColors.warning`     | Para avisos gerais                    |
| `Colors.orange.shade800` | `AppColors.orange800`   | Para textos de aviso                  |
| `Colors.orange.shade700` | `AppColors.orange700`   | Para textos secundários de aviso      |
| `Colors.green`           | `AppColors.success`     | Para sucesso geral                    |
| `Colors.green.shade800`  | `AppColors.green800`    | Para textos de sucesso                |
| `Colors.green.shade700`  | `AppColors.green700`    | Para textos secundários de sucesso    |
| `Colors.blue`            | `AppColors.info`        | Para informações gerais               |
| `Colors.blue.shade700`   | `AppColors.blue700`     | Para textos de informação             |
| `Colors.blue.shade600`   | `AppColors.blue600`     | Para textos secundários de informação |
| `Colors.grey`            | `AppColors.grey`        | Já existe                             |
| `Colors.yellow`          | `AppColors.yellow`      | Adicionar                             |
| `Colors.lightGreen`      | `AppColors.lightGreen`  | Adicionar                             |
| `Colors.purple`          | `AppColors.purple`      | Adicionar                             |
| `Colors.teal`            | `AppColors.teal`        | Adicionar                             |
| `Colors.black54`         | `AppColors.black54`     | Adicionar                             |
| `Colors.white`           | `AppColors.white`       | Já existe                             |
| `Colors.black`           | `AppColors.black`       | Já existe                             |
| `Colors.transparent`     | `AppColors.transparent` | Já existe                             |

## Arquivos Prioritários para Migração (histórico — em sua maioria concluído)

> Os alvos abaixo já foram migrados para `AppColors`. Mantidos como
> registro do escopo original.

### Alta Prioridade (UI/Widgets) — ✅ migrados

1. `lib/ui/screens/separation_items_screen.dart` — migrado (resta só
   `Colors.transparent`)
2. `lib/ui/widgets/separate_items/cart_item_card.dart` — ✅ usa `AppColors`
3. `lib/ui/screens/card_picking_screen.dart` — ✅ usa `AppColors`
4. `lib/ui/widgets/card_picking/picking_item_card.dart` — ✅ usa `AppColors`

### Média Prioridade (Models) — ✅ migrados

1. `lib/domain/models/situation/expedition_situation_model.dart` — ✅
2. `lib/domain/models/entity_type_model.dart` — ✅
3. Outros modelos de situação — ✅

### Resíduo atual (a finalizar)

Ver a lista de ~7 arquivos em "Situação Atual".

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
