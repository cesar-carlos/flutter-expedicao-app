# AppDrawer - Menu Lateral Reutilizável

## Descrição

O `AppDrawer` é um widget reutilizável que implementa o menu lateral da aplicação, inspirado em interfaces modernas de aplicativos móveis. Ele fornece navegação consistente e acesso a funcionalidades principais do app.

## Características

### 🎨 Design

- **Header gradiente** com informações do usuário
- **Avatar com iniciais** geradas automaticamente
- **Status de conexão** visível
- **Ícones consistentes** seguindo Material Design
- **Placeholders visuais** para funcionalidades futuras

### 📱 Funcionalidades Implementadas

- ✅ **Perfil do usuário** (header com avatar e nome)
- ✅ **Scanner QR** - Navegação direta
- ✅ **Configurações** - Acesso às configurações do app
- ✅ **Logout** - Com diálogo de confirmação
- 🚧 **Funcionalidades placeholder** para desenvolvimento futuro

### 🔧 Funcionalidades Placeholder

- Novo Grupo
- Contatos
- Chamadas
- Mensagens Salvas
- Convidar Contatos
- Recursos do Sistema

## Como Usar

### 1. Importação

```dart
import 'package:data7_expedicao/ui/widgets/app_drawer/index.dart';
```

### 2. Implementação em uma tela

```dart
class MinhaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Tela'),
      ),
      drawer: const AppDrawer(), // ← Adicione aqui
      body: // seu conteúdo
    );
  }
}
```

### 3. Telas que já implementam o drawer

- ✅ `HomeShell` (tela principal)
- ✅ `ConfigScreen` (configurações)

## Estrutura do Código

### Header do Drawer

```dart
DrawerHeader(
  child: Column(
    children: [
      CircleAvatar(...), // Avatar com iniciais
      Text(username),    // Nome do usuário
      Container(...)     // Badge de status
    ],
  ),
)
```

### Item de Menu

```dart
_buildMenuTile(
  context,
  icon: Icons.exemplo,
  title: 'Título',
  onTap: () => // ação,
  isPlaceholder: false, // true para funcionalidades futuras
)
```

## Personalizações

### Adicionar novo item de menu

```dart
_buildMenuTile(
  context,
  icon: Icons.nova_funcionalidade,
  title: 'Nova Funcionalidade',
  onTap: () {
    Navigator.pop(context);
    // Implementar navegação ou ação
  },
),
```

### Remover placeholder

1. Altere `isPlaceholder: false`
2. Implemente a lógica no `onTap`
3. Adicione navegação ou funcionalidade necessária

## Integração com Estado

### AuthViewModel

O drawer consome o `AuthViewModel` para:

- Exibir nome do usuário
- Gerar iniciais do avatar
- Implementar função de logout

### Navegação

Utiliza `GoRouter` para navegação:

```dart
context.go(AppRouter.config);           // Configurações
context.go('${AppRouter.home}/scanner'); // Scanner
```

## Temas e Cores

O drawer respeita automaticamente:

- ✅ **Theme colors** do Material Design
- ✅ **Dark/Light mode** automático
- ✅ **Color scheme** da aplicação
- ✅ **Gradientes** no header

## Próximos Passos

### Para adicionar novas funcionalidades:

1. **Remova** `isPlaceholder: true` do item desejado
2. **Implemente** a tela/funcionalidade correspondente
3. **Adicione** a rota no `AppRouter`
4. **Teste** a navegação

### Sugestões de implementação:

- 📝 **Perfil** → Tela de edição de perfil do usuário
- 👥 **Contatos** → Lista e gerenciamento de contatos
- 📞 **Chamadas** → Histórico e funcionalidades de chamada
- 💾 **Mensagens Salvas** → Favoritos/bookmarks
- 📊 **Recursos** → Estatísticas e informações do sistema

## Arquivos Relacionados

- `lib/ui/widgets/app_drawer.dart` - Widget principal
- `lib/ui/screens/home_shell.dart` - Implementação na home
- `lib/ui/screens/config_screen.dart` - Implementação nas configurações
- `lib/core/routing/app_router.dart` - Rotas de navegação
