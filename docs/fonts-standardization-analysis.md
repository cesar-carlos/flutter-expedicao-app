# Análise de Padronização de Fontes

## Situação Atual

### O que existe:

1. **UIConstants** (`lib/core/constants/ui_constants.dart`):
   - Define constantes de tamanho de fonte:
     - `smallFontSize = 12.0`
     - `defaultFontSize = 14.0`
     - `mediumFontSize = 16.0`
     - `largeFontSize = 18.0`
     - `extraLargeFontSize = 24.0`
   - **Problema**: Essas constantes não são amplamente utilizadas no código

2. **AppTheme** (`lib/core/theme/app_theme.dart`):
   - Não define um `textTheme` customizado completo
   - Usa apenas os padrões do Material 3
   - Define apenas `titleTextStyle` no `appBarTheme` com valores hardcoded

3. **Uso de textTheme**:
   - Alguns widgets usam `theme.textTheme.*` mas frequentemente com `copyWith()` para sobrescrever propriedades
   - Exemplo: `theme.textTheme.labelSmall?.copyWith(color: statusColor, fontWeight: FontWeight.w600, fontSize: 11)`

### Problemas Identificados:

1. **TextStyle hardcoded em muitos lugares**:
   - `TextStyle(fontSize: 10, ...)` - 10 ocorrências
   - `TextStyle(fontSize: 11, ...)` - 5 ocorrências
   - `TextStyle(fontSize: 12, ...)` - 30+ ocorrências
   - `TextStyle(fontSize: 13, ...)` - 2 ocorrências
   - `TextStyle(fontSize: 14, ...)` - 20+ ocorrências
   - `TextStyle(fontSize: 16, ...)` - 15+ ocorrências
   - `TextStyle(fontSize: 18, ...)` - 10+ ocorrências
   - `TextStyle(fontSize: 20, ...)` - 5 ocorrências
   - `TextStyle(fontSize: 24, ...)` - 8 ocorrências
   - `TextStyle(fontSize: 32, ...)` - 2 ocorrências
   - `TextStyle(fontSize: 48, ...)` - 1 ocorrência

2. **FontWeight hardcoded**:
   - `FontWeight.bold` - 50+ ocorrências
   - `FontWeight.w500` - 20+ ocorrências
   - `FontWeight.w600` - 30+ ocorrências
   - `FontWeight.w700` - 10+ ocorrências
   - `FontWeight.w800` - 1 ocorrência

3. **FontFamily hardcoded**:
   - `fontFamily: 'monospace'` - 9 ocorrências (usado para códigos de barras, IDs, etc.)

4. **Falta de padronização**:
   - Não há um sistema centralizado similar ao `AppColors`
   - Cada widget define seus próprios estilos
   - Dificulta manutenção e consistência visual

## Recomendações

### Abordagem 1: Criar AppTextStyles (Similar ao AppColors)

**Vantagens:**

- Consistência com a abordagem de `AppColors`
- Fácil de usar: `AppTextStyles.headlineLarge`
- Centralizado e fácil de manter
- Não requer mudanças no `AppTheme`

**Desvantagens:**

- Não integra com o sistema de tema do Flutter
- Pode não respeitar mudanças de tema (light/dark)

**Estrutura proposta:**

```dart
class AppTextStyles {
  // Headlines
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  // Titles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  // Labels
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // Monospace (para códigos)
  static const TextStyle code = TextStyle(
    fontSize: 14,
    fontFamily: 'monospace',
    fontWeight: FontWeight.w500,
  );
}
```

### Abordagem 2: Configurar textTheme completo no AppTheme (Recomendado)

**Vantagens:**

- Integra com o sistema de tema do Flutter
- Respeita mudanças de tema (light/dark)
- Segue as melhores práticas do Flutter
- Usa `Theme.of(context).textTheme.*` naturalmente
- Pode usar `UIConstants` para tamanhos

**Desvantagens:**

- Requer atualização do `AppTheme`
- Pode precisar de ajustes em widgets existentes

**Estrutura proposta:**

```dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // ... existing code ...
      textTheme: TextTheme(
        // Headlines
        headlineLarge: TextStyle(
          fontSize: UIConstants.extraLargeFontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: AppColors.fontDark,
        ),
        headlineMedium: TextStyle(
          fontSize: UIConstants.extraLargeFontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.fontDark,
        ),
        headlineSmall: TextStyle(
          fontSize: UIConstants.largeFontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.fontDark,
        ),

        // Titles
        titleLarge: TextStyle(
          fontSize: UIConstants.extraLargeFontSize,
          fontWeight: FontWeight.w600,
          color: AppColors.fontDark,
        ),
        titleMedium: TextStyle(
          fontSize: UIConstants.mediumFontSize,
          fontWeight: FontWeight.w600,
          color: AppColors.fontDark,
        ),
        titleSmall: TextStyle(
          fontSize: UIConstants.defaultFontSize,
          fontWeight: FontWeight.w600,
          color: AppColors.fontDark,
        ),

        // Body
        bodyLarge: TextStyle(
          fontSize: UIConstants.mediumFontSize,
          fontWeight: FontWeight.normal,
          color: AppColors.fontDark,
        ),
        bodyMedium: TextStyle(
          fontSize: UIConstants.defaultFontSize,
          fontWeight: FontWeight.normal,
          color: AppColors.fontDark,
        ),
        bodySmall: TextStyle(
          fontSize: UIConstants.smallFontSize,
          fontWeight: FontWeight.normal,
          color: AppColors.fontDark,
        ),

        // Labels
        labelLarge: TextStyle(
          fontSize: UIConstants.defaultFontSize,
          fontWeight: FontWeight.w500,
          color: AppColors.fontDark,
        ),
        labelMedium: TextStyle(
          fontSize: UIConstants.smallFontSize,
          fontWeight: FontWeight.w500,
          color: AppColors.fontDark,
        ),
        labelSmall: TextStyle(
          fontSize: UIConstants.smallFontSize,
          fontWeight: FontWeight.w500,
          color: AppColors.fontDark,
        ),
      ),
    );
  }
}
```

### Abordagem 3: Híbrida (Recomendada para este projeto)

**Combinação das duas abordagens:**

1. **Configurar textTheme completo no AppTheme** para estilos padrão
2. **Criar AppTextStyles** para estilos customizados específicos (ex: monospace para códigos)
3. **Usar UIConstants** para tamanhos de fonte quando necessário

**Estrutura:**

```dart
// AppTheme com textTheme completo
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      textTheme: _buildTextTheme(AppColors.fontDark),
      // ... rest of theme
    );
  }

  static TextTheme _buildTextTheme(Color baseColor) {
    return TextTheme(
      // ... usando UIConstants
    );
  }
}

// AppTextStyles para estilos customizados
class AppTextStyles {
  // Monospace para códigos
  static TextStyle code(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontFamily: 'monospace',
      fontWeight: FontWeight.w500,
    ) ?? const TextStyle(fontFamily: 'monospace');
  }

  // Estilos específicos que não se encaixam no textTheme padrão
  static TextStyle button(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
    ) ?? const TextStyle();
  }
}
```

## Plano de Migração

### Fase 1: Configurar textTheme no AppTheme

1. Adicionar `textTheme` completo no `AppTheme.lightTheme` e `AppTheme.darkTheme`
2. Usar `UIConstants` para tamanhos de fonte
3. Usar `AppColors` para cores de texto

### Fase 2: Criar AppTextStyles para casos especiais

1. Criar `AppTextStyles` para estilos customizados (monospace, etc.)
2. Adicionar métodos helper quando necessário

### Fase 3: Migrar widgets gradualmente

1. Priorizar widgets mais usados
2. Substituir `TextStyle` hardcoded por `theme.textTheme.*`
3. Usar `AppTextStyles` para casos especiais
4. Manter `copyWith()` apenas quando necessário para variações específicas

### Fase 4: Validação

1. Verificar consistência visual
2. Testar em light e dark theme
3. Garantir que todos os tamanhos de fonte usem o sistema padronizado

## Benefícios da Padronização

1. **Consistência Visual**: Todos os textos seguem o mesmo padrão
2. **Manutenibilidade**: Mudanças centralizadas afetam toda a aplicação
3. **Acessibilidade**: Facilita ajustes de tamanho de fonte para acessibilidade
4. **Temas**: Suporte adequado para light/dark theme
5. **Performance**: Estilos reutilizáveis são mais eficientes
6. **Código Limpo**: Reduz duplicação e valores hardcoded

## Considerações

- **Material 3**: O projeto usa `useMaterial3: true`, então deve seguir as convenções do Material 3 para textTheme
- **Regras do Projeto**: Seguir as regras de não criar documentação automática, mas esta análise foi solicitada
- **Gradual**: A migração deve ser gradual, similar à padronização de cores
- **Compatibilidade**: Manter compatibilidade com código existente durante a migração
