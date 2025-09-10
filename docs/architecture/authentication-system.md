# Sistema de Autenticação com Splash

## ✅ **Implementação Completa**

### 1. **Arquivos Criados**

#### **ViewModels:**

- `lib/domain/viewmodels/auth_viewmodel.dart` - Gerencia estado de autenticação

#### **Screens:**

- `lib/ui/screens/splash_screen.dart` - Tela de splash animada
- `lib/ui/screens/login_screen.dart` - Tela de login completa
- `lib/ui/screens/auth_wrapper.dart` - Gerenciador de rotas por autenticação

### 2. **Fluxo de Autenticação**

```
App Start → SplashScreen → LoginScreen → HomeScreen (Scanner)
    ↓           ↓              ↓              ↓
 Initial    Loading      Unauthenticated  Authenticated
```

### 3. **Estados de Autenticação**

```dart
enum AuthStatus {
  initial,        // Estado inicial
  loading,        // Carregando (splash/login)
  authenticated,  // Usuário logado
  unauthenticated,// Usuário não logado
  error,         // Erro de autenticação
}
```

### 4. **Funcionalidades do AuthViewModel**

**Métodos Principais:**

- `checkAuthStatus()` - Verifica se usuário já está logado (splash)
- `login(username, password)` - Realiza login
- `logout()` - Realiza logout
- `clearError()` - Limpa mensagens de erro

**Propriedades:**

- `status` - Status atual da autenticação
- `isLoading` - Se está carregando
- `isAuthenticated` - Se está autenticado
- `errorMessage` - Mensagem de erro atual
- `username` - Nome do usuário logado

### 5. **Tela de Splash**

**Características:**

- Animação de logo (scale + fade)
- Loading indicator
- Duração de 2 segundos
- Design com cores do tema Data7
- Verifica automaticamente status de auth

### 6. **Tela de Login**

**Características:**

- Formulário com validação
- Campo usuário e senha
- Botão mostrar/ocultar senha
- Loading state durante login
- Mensagens de erro estilizadas
- Credenciais de demo visíveis
- Design responsivo

**Credenciais de Demonstração:**

- **Usuário:** `admin`
- **Senha:** `123456`

### 7. **AuthWrapper**

**Responsabilidade:**

- Gerencia navegação baseada no estado de auth
- Redireciona para tela correta automaticamente
- Wrapper reativo que responde a mudanças de estado

### 8. **HomeScreen**

**Funcionalidades:**

- AppBar com menu de logout
- Integra a ScannerScreen
- Dialog de confirmação de logout
- Mantém contexto do usuário logado

### 9. **Configuração no Main.dart**

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ScannerViewModel()),
    ChangeNotifierProvider(create: (_) => AuthViewModel()),
  ],
  child: MaterialApp(
    home: const AuthWrapper(),
  ),
)
```

## 🎨 **Design System**

### **Splash Screen:**

- Background com cor primária
- Logo animado com shadow
- Tipografia hierarquizada
- Loading indicator suave

### **Login Screen:**

- Layout centralizado e responsivo
- Campos com validação visual
- Botões com estados de loading
- Card de informações de demo
- Tratamento de erros elegante

### **Animações:**

- Fade in/out suaves
- Scale animation no logo
- Loading states reativos
- Transições automáticas

## 🔧 **Como Usar**

1. **Inicialização:** App abre na splash screen
2. **Auto-check:** Verifica se usuário já está logado
3. **Login:** Tela de login com credenciais de demo
4. **Acesso:** Após login, acesso ao scanner
5. **Logout:** Menu na AppBar permite sair

## 🚀 **Próximos Passos**

1. **Persistência:** Salvar token/sessão
2. **API Integration:** Conectar com backend real
3. **Biometria:** Login com digital/face
4. **Recuperação:** Esqueci minha senha
5. **Múltiplos usuários:** Perfis diferentes

## ✨ **Resultado Final**

Sistema completo de autenticação com:

- ✅ Splash screen animada
- ✅ Login funcional com validação
- ✅ Gerenciamento de estado reativo
- ✅ Navegação automática
- ✅ Logout com confirmação
- ✅ Design consistente com identidade Data7
- ✅ Arquitetura escalável com Provider
