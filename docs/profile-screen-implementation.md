# Implementação da Tela de Perfil

Esta documentação descreve a implementação completa da tela de perfil do usuário, onde é possível alterar a foto de perfil e a senha.

## Arquivos Criados/Modificados

### 1. ProfileViewModel (`lib/domain/viewmodels/profile_viewmodel.dart`)

ViewModel responsável por gerenciar o estado da tela de perfil:

**Funcionalidades:**

- Gerenciamento de estado (idle, loading, success, error)
- Seleção e conversão de foto para base64
- Validação de senhas (atual, nova, confirmação)
- Integração com UserRepository para salvar alterações
- Atualização do usuário no AuthViewModel

**Estados:**

```dart
enum ProfileState { idle, loading, success, error }
```

**Métodos principais:**

- `setSelectedPhoto(File? photo)` - Define foto selecionada
- `setCurrentPassword(String? password)` - Define senha atual
- `setNewPassword(String? password)` - Define nova senha
- `setConfirmPassword(String? password)` - Define confirmação da senha
- `saveProfile()` - Salva alterações do perfil
- `_convertImageToBase64(File imageFile)` - Converte imagem para base64
- `_validatePasswords()` - Valida senhas informadas

### 2. ProfileScreen (`lib/ui/screens/profile_screen.dart`)

Tela de interface do usuário para edição do perfil:

**Componentes principais:**

- **Cabeçalho do usuário** com gradient e informações atuais
- **Seção de informações pessoais** com ProfilePhotoSelector
- **Seção de alteração de senha** (expansível)
- **Botão de salvar** com estado de loading

**Características:**

- Formulário com validação
- Seção de senha expansível/recolhível
- Feedback visual para estados de loading/sucesso/erro
- Integração com SnackBar e ErrorDialog

### 3. Strings Adicionais (`lib/core/constants/app_strings.dart`)

Adicionadas constantes para textos da tela de perfil:

```dart
// === PERFIL ===
static const String profileTitle = 'Meu Perfil';
static const String profileSubtitle = 'Gerencie suas informações pessoais';
static const String personalInfo = 'Informações Pessoais';
// ... e outras strings
```

### 4. Configuração de Rotas (`lib/core/routing/app_router.dart`)

Adicionada rota para a tela de perfil:

```dart
static const String profile = '/profile';

// Rota do Perfil
GoRoute(
  path: profile,
  name: 'profile',
  builder: (context, state) => ChangeNotifierProvider(
    create: (_) => ProfileViewModel(
      locator<UserRepository>(),
      Provider.of<AuthViewModel>(context, listen: false),
    ),
    child: const ProfileScreen(),
  ),
),
```

### 5. Injeção de Dependências (`lib/di/locator.dart`)

Registrado ProfileViewModel no service locator:

```dart
// Registrar ProfileViewModel
locator.registerFactory(() {
  // ... validações e criação do ProfileViewModel
});
```

### 6. Navegação no Drawer (`lib/ui/widgets/app_drawer.dart`)

Atualizado link do menu "Meu Perfil" para navegar para a tela:

```dart
onTap: () {
  Navigator.pop(context);
  context.go(AppRouter.profile);
},
```

## Como Usar

### 1. Navegação via GoRouter

```dart
context.go(AppRouter.profile);
```

### 2. Navegação Manual

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => ChangeNotifierProvider(
      create: (_) => ProfileViewModel(
        locator<UserRepository>(),
        Provider.of<AuthViewModel>(context, listen: false),
      ),
      child: const ProfileScreen(),
    ),
  ),
);
```

### 3. Integração Completa

A tela já está integrada no drawer do app e pode ser acessada através do menu lateral.

## Fluxo de Funcionamento

1. **Abertura da tela**: Usuario acessa via drawer ou navegação direta
2. **Carregamento de dados**: Informações atuais do usuário são exibidas
3. **Seleção de foto**:
   - Usuário toca no ProfilePhotoSelector
   - Opções: Câmera, Galeria, Remover foto
   - Foto é convertida automaticamente para base64
4. **Alteração de senha**:
   - Seção expansível com 3 campos
   - Validação: senha atual obrigatória se há nova senha
   - Confirmação deve coincidir com nova senha
5. **Salvamento**:
   - Validação do formulário
   - Chamada para `putAppUser` no repositório
   - Atualização do usuário no AuthViewModel
   - Feedback visual (success/error)

## Validações Implementadas

### Senha Atual

- Obrigatória apenas se há nova senha informada

### Nova Senha

- Mínimo 4 caracteres (se informada)

### Confirmação de Senha

- Deve coincidir com a nova senha

### Foto de Perfil

- Conversão automática para base64
- Tratamento de erros de processamento
- Mantém foto atual se não há nova seleção

## Estados da Tela

- **Idle**: Estado inicial, sem ações em andamento
- **Loading**: Salvando alterações (botão mostra loading)
- **Success**: Alterações salvas com sucesso (SnackBar verde)
- **Error**: Erro ao salvar (ErrorDialog com opção de retry)

## Integração com API

A tela utiliza o método `putAppUser` já existente no `UserRepositoryImpl`:

- **Endpoint**: `PUT /expedicao/login-app?CodLoginApp={codigo}`
- **Payload**: Dados do AppUser com foto em base64
- **Response**: AppUserConsultation atualizado

## Exemplo de Uso

Veja o arquivo `example/profile_screen_example.dart` para exemplos completos de:

- Como abrir a tela de perfil
- Demonstração das funcionalidades
- Exemplos de validação
- Integração com Provider

## Considerações Técnicas

1. **Performance**: Fotos são convertidas para base64, considerar limitações de tamanho
2. **Validação**: Senhas são validadas apenas no frontend por enquanto
3. **API**: Mudança de senha ainda não implementada no backend
4. **Estado**: ProfileViewModel é factory no locator, criado a cada uso
5. **Navegação**: Integrada no sistema de rotas do GoRouter

## Próximos Passos

1. Implementar mudança de senha no backend
2. Adicionar validação de força da senha
3. Considerar upload de foto em formato diferente de base64
4. Adicionar animações na interface
5. Implementar cache de fotos para melhor performance
