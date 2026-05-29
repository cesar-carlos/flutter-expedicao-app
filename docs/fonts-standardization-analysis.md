# Análise de Padronização de Fontes

> **Status: CONCLUÍDO (histórico).** A padronização de fontes descrita
> neste documento já foi implementada (abordagem híbrida — ver
> "Situação Atual"). O `AppTheme` define um `textTheme` completo via
> `AppFonts.getTextTheme(...)`, existem `AppFonts` e `AppTextStyles`, e a
> família primária passou a usar `google_fonts` (Inter). As seções de
> "Recomendações" e "Plano de Migração" abaixo são mantidas como
> registro histórico do raciocínio; recomendações já implementadas estão
> marcadas como concluídas. Resíduos pontuais (alguns `fontSize` /
> `FontWeight` literais) ainda existem e estão listados como observação.

## Situação Atual

### O que existe (estado atual do código):

1. **UIConstants** (`lib/core/constants/ui_constants.dart`):
   - Define a escala de tamanhos de fonte, hoje ampliada:
     - `extraSmallFontSize = 10.0`
     - `tinyFontSize = 11.0`
     - `smallFontSize = 12.0`
     - `defaultFontSize = 14.0`
     - `mediumFontSize = 16.0`
     - `largeFontSize = 18.0`
     - `xLargeFontSize = 20.0`
     - `extraLargeFontSize = 24.0`
     - `hugeFontSize = 25.0`
     - `xxLargeFontSize = 32.0`
     - `extraHugeFontSize = 48.0`
   - Essas constantes agora são consumidas pelo `textTheme` central
     (ver `AppFonts.getTextTheme`).

2. **AppTheme** (`lib/core/theme/app_theme.dart`):
   - Define um `textTheme` customizado **completo** em ambos os temas
     (light e dark) via `AppFonts.getTextTheme(baseColor: ..., brightness: ...)`.
   - O `appBarTheme.titleTextStyle` usa `AppFonts.inter(...)` com
     `UIConstants.xLargeFontSize`.

3. **AppFonts** (`lib/core/theme/app_fonts.dart`):
   - Centraliza a tipografia com `google_fonts` (família primária
     **Inter**, exposta em `primaryFontFamily`).
   - `getTextTheme(...)` monta o `TextTheme` completo usando
     `GoogleFonts.interTextTheme` + `UIConstants` para os tamanhos.
     Destaques: `headlineLarge` usa `xxLargeFontSize` (32) e
     `labelSmall` usa `tinyFontSize` (11).
   - `code(BuildContext)` provê a fonte monospace via
     `GoogleFonts.robotoMono` (substitui o antigo `fontFamily: 'monospace'`).
   - Helpers: `inter(...)`, `interSmall/Default/Medium/Large/XLarge`.

4. **AppTextStyles** (`lib/core/theme/app_text_styles.dart`):
   - Estilos customizados específicos: `code(context)`,
     `button(context)` e `custom(...)`, todos apoiados em `AppFonts`.

5. **Fontes no pubspec.yaml**:
   - **Não há** seção `fonts:` (a família vem de `google_fonts`).

### Problemas Identificados (originais — em sua maioria resolvidos):

1. **TextStyle hardcoded em muitos lugares** — em grande parte migrado
   para `theme.textTheme.*` / `AppFonts`. Restam resíduos pontuais (ver
   observação abaixo).

2. **FontWeight hardcoded** — reduzido; ainda há ocorrências pontuais.

3. **FontFamily hardcoded**:
   - `fontFamily: 'monospace'` — **0 ocorrências** hoje. A fonte
     monospace passou a usar `GoogleFonts.robotoMono` em `AppFonts.code()`.

4. **Falta de padronização** — **resolvido**: existe um sistema
   centralizado (`AppFonts` + `AppTextStyles` + `textTheme` no
   `AppTheme`), análogo ao `AppColors`.

### Observação — resíduos ainda existentes

- Ainda há alguns `fontSize` / `FontWeight` literais espalhados. Por
  exemplo, `lib/ui/screens/splash_screen.dart` usa
  `AppFonts.inter(fontSize: 16, ...)`. São casos pontuais e não
  comprometem a padronização geral.

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

### Abordagem 3: Híbrida (Recomendada para este projeto) — ✅ IMPLEMENTADA

> Esta foi a abordagem efetivamente adotada. O `textTheme` completo vive
> no `AppTheme` (via `AppFonts.getTextTheme`), os estilos especiais ficam
> em `AppTextStyles`/`AppFonts.code()`, e os tamanhos vêm de
> `UIConstants`. Diferença em relação ao esboço abaixo: a fonte monospace
> usa `GoogleFonts.robotoMono` em vez de `fontFamily: 'monospace'`.

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

### Fase 1: Configurar textTheme no AppTheme — ✅ CONCLUÍDA

1. ✅ `textTheme` completo adicionado em `AppTheme.lightTheme` e
   `AppTheme.darkTheme` (via `AppFonts.getTextTheme`)
2. ✅ Tamanhos de fonte vindos de `UIConstants`
3. ✅ Cores de texto vindas de `AppColors` (`fontDark`/`fontLight`)

### Fase 2: Criar AppTextStyles para casos especiais — ✅ CONCLUÍDA

1. ✅ `AppTextStyles` criado para estilos customizados (`code`,
   `button`, `custom`); a fonte monospace usa `GoogleFonts.robotoMono`
2. ✅ Métodos helper adicionados em `AppFonts` (`interSmall`, etc.)

### Fase 3: Migrar widgets gradualmente — 🔄 LARGAMENTE CONCLUÍDA

1. ✅ Widgets mais usados migrados para `theme.textTheme.*` / `AppFonts`
2. ✅ `TextStyle` hardcoded substituído na maioria dos casos
3. ✅ `AppTextStyles` usado para casos especiais
4. 🔄 Resíduos pontuais ainda usam literais (ex.: `splash_screen.dart`)

### Fase 4: Validação — ✅ CONCLUÍDA

1. ✅ Consistência visual verificada
2. ✅ Testado em light e dark theme
3. 🔄 Quase todos os tamanhos usam o sistema padronizado (resíduos
   pontuais documentados na observação acima)

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
