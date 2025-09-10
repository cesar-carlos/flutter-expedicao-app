# Sistema de Temas - Theme Toggle

## Funcionalidade Implementada ✅

### **Botão de Alternância de Tema no Menu Drawer**

- 📍 **Localização**: Canto superior direito do drawer
- 🎨 **Design**: Ícone que muda conforme o tema selecionado
- 🔄 **Funcionalidade**: Alterna entre Light → Dark → Sistema → Light...

## Arquivos Criados/Modificados

### 1. **ThemeViewModel** (`lib/domain/viewmodels/theme_viewmodel.dart`)

```dart
class ThemeViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => // lógica
  IconData get themeIcon => // ícone apropriado
  String get themeTooltip => // texto do tooltip

  // Métodos
  void toggleTheme() => // alterna tema
  void setThemeMode(ThemeMode mode) => // define tema específico
}
```

### 2. **Main.dart** - Integração com Provider

```dart
// Inicialização
final themeViewModel = ThemeViewModel();
await themeViewModel.initialize();

// Providers
ChangeNotifierProvider.value(value: themeViewModel),

// Consumer
Consumer2<AuthViewModel, ThemeViewModel>(
  builder: (context, authViewModel, themeViewModel, child) {
    return MaterialApp.router(
      themeMode: themeViewModel.themeMode, // ← Tema dinâmico
      // ...
    );
  },
)
```

### 3. **AppDrawer** - Botão de Tema

```dart
// Stack no DrawerHeader
Stack(
  children: [
    // Botão de tema no canto superior direito
    Positioned(
      top: 0,
      right: 0,
      child: IconButton(
        onPressed: () => themeViewModel.toggleTheme(),
        icon: Icon(themeViewModel.themeIcon),
        tooltip: themeViewModel.themeTooltip,
      ),
    ),
    // Conteúdo principal...
  ],
)
```

## Estados do Tema

### **Light Mode** 🌞

- **Ícone**: `Icons.light_mode`
- **Tooltip**: "Modo Claro"
- **Próximo**: Dark Mode

### **Dark Mode** 🌙

- **Ícone**: `Icons.dark_mode`
- **Tooltip**: "Modo Escuro"
- **Próximo**: Sistema

### **System Mode** 🔄

- **Ícone**: `Icons.brightness_auto`
- **Tooltip**: "Tema do Sistema"
- **Próximo**: Light Mode

## Temas Disponíveis

### **Light Theme** (`AppTheme.lightTheme`)

- Background claro
- Textos escuros
- Cores primárias vibrantes
- Elevação com sombras sutis

### **Dark Theme** (`AppTheme.darkTheme`)

- Background escuro
- Textos claros
- Cores primárias adaptadas
- Elevação com sombras pronunciadas

## Como Usar

### **Para o usuário:**

1. Abrir o menu lateral (drawer)
2. Tocar no ícone de tema no canto superior direito
3. O tema alterna automaticamente: Light → Dark → Sistema → Light...

### **Para desenvolvedores:**

```dart
// Acessar o tema atual
final themeViewModel = context.watch<ThemeViewModel>();
final isDark = themeViewModel.isDarkMode;

// Definir tema programaticamente
themeViewModel.setThemeMode(ThemeMode.dark);

// Alternar tema
themeViewModel.toggleTheme();
```

## Benefícios da Implementação

### **UX Melhorada:**

- ✅ Acesso rápido e visual ao alternador de tema
- ✅ Feedback visual imediato da mudança
- ✅ Ícone intuitivo que representa o estado atual
- ✅ Tooltip informativo para orientar o usuário

### **Arquitetura Robusta:**

- ✅ Estado gerenciado centralmente via ViewModel
- ✅ Integração com Provider pattern
- ✅ Preparado para persistência futura
- ✅ Reutilizável em qualquer parte da aplicação

### **Compatibilidade:**

- ✅ Suporte nativo a tema do sistema
- ✅ Funciona com Material Design 3
- ✅ Adaptação automática de cores e componentes
- ✅ Preserva acessibilidade

## Próximos Passos (Melhorias Futuras)

### **Persistência de Preferências:**

```dart
// Adicionar shared_preferences ao pubspec.yaml
dependencies:
  shared_preferences: ^2.x.x

// Implementar salvamento automático
Future<void> _saveThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('theme_mode', _themeMode.index);
}
```

### **Animações de Transição:**

```dart
// Adicionar AnimatedTheme para transições suaves
AnimatedTheme(
  data: themeViewModel.isDarkMode ? darkTheme : lightTheme,
  duration: Duration(milliseconds: 300),
  child: MaterialApp.router(...),
)
```

### **Temas Personalizados:**

- Implementar múltiplas variações de cores
- Permitir temas personalizados pelo usuário
- Sincronização com configurações do servidor

## Integração Completa ✅

O sistema está **totalmente funcional** e integrado:

- ✅ **ViewModel**: Gerencia estado do tema
- ✅ **UI**: Botão acessível no drawer
- ✅ **Aplicação**: Aplica tema dinamicamente
- ✅ **UX**: Ciclo intuitivo Light→Dark→Sistema
- ✅ **Feedback**: Ícones e tooltips informativos
