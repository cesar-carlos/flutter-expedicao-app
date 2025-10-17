# Sistema de Strings da Aplicação

## Visão Geral

O arquivo `lib/core/constants/app_strings.dart` centraliza todas as strings/textos utilizados na aplicação Data7 Expedição. Isso facilita:

- **Manutenção**: Alterar textos em um local único
- **Consistência**: Garantir que textos similares sejam iguais
- **Tradução**: Facilitar futura implementação de internacionalização (i18n)
- **Reusabilidade**: Evitar duplicação de strings

## Estrutura das Constantes

### 📱 **Geral**

- `appName`: Nome da aplicação
- `appDescription`: Descrição da aplicação

### 🧭 **Navegação**

- `back`, `cancel`, `save`, `edit`, `delete`
- `confirm`, `close`, `ok`

### 🔐 **Login/Autenticação**

- `loginTitle`: Título da tela de login
- `username`, `password`: Labels dos campos
- `usernameHint`, `passwordHint`: Textos de ajuda
- `loginButton`, `logout`: Botões

### ✅ **Validações de Login**

- `usernameRequired`: Mensagem quando usuário não preenchido
- `passwordRequired`: Mensagem quando senha não preenchida
- `passwordMinLength`: Validação de tamanho mínimo da senha

### ⚙️ **Configurações**

- `configTitle`, `configSubtitle`: Títulos da tela
- `apiUrl`, `apiPort`: Labels dos campos
- `apiUrlHint`, `apiPortHint`: Exemplos de preenchimento
- `useHttps`, `testConnection`: Opções e botões
- `previewUrl`, `saveConfig`: Funcionalidades

### 🔍 **Validações de Configuração**

- `urlRequired`, `portRequired`: Campos obrigatórios
- `portInvalid`: Validação de porta

### 🎉 **Mensagens de Sucesso**

- `configSaved`: Configuração salva
- `connectionSuccess`: Teste de conexão bem-sucedido

### ❌ **Mensagens de Erro**

- `connectionError`: Erro ao conectar
- `configError`: Erro ao salvar
- `loginError`: Erro de login
- `genericError`, `networkError`, `timeoutError`: Erros gerais

### ⏳ **Loading/Carregamento**

- `loading`, `connecting`, `saving`, `testing`: Estados de carregamento

### 🚀 **Splash Screen**

- `loadingApp`, `initializing`: Textos da tela inicial

### 🔘 **Botões e Ações**

- `settings`, `refresh`, `retry`
- `search`, `filter`, `clear`

### 📡 **Status**

- `online`, `offline`, `connected`, `disconnected`

### 💡 **Tooltips**

- `settingsTooltip`, `backTooltip`, `refreshTooltip`

## Como Usar

### 1. **Importar o arquivo:**

```dart
import 'package:data7_expedicao/core/constants/app_strings.dart';
```

### 2. **Usar as constantes:**

```dart
Text(AppStrings.appName)
Text(AppStrings.loginTitle)
labelText: AppStrings.username
```

### 3. **Em widgets:**

```dart
AppHeader(
  title: AppStrings.appName,
  subtitle: AppStrings.loginTitle,
)
```

## Arquivos Atualizados

✅ **Já usam AppStrings:**

- `lib/ui/screens/login_screen.dart`
- `lib/ui/widgets/login_form.dart`
- `lib/ui/screens/config_screen.dart` (parcialmente)

🔄 **Para atualizar futuramente:**

- `lib/ui/screens/splash_screen.dart`
- `lib/ui/screens/auth_wrapper.dart`
- Outros widgets que contenham strings hard-coded

## Benefícios Implementados

### ✅ **Tela de Login**

- Título e subtítulo centralizados
- Labels e hints dos campos padronizados
- Mensagens de validação consistentes
- Botão de login com texto padrão

### ✅ **Formulário de Login**

- Campos de usuário e senha padronizados
- Validações com mensagens centralizadas
- Botão com texto consistente

### ✅ **Tela de Configuração**

- Título e descrição padronizados
- Labels dos campos de API centralizados
- Mensagens de validação consistentes

## Próximos Passos

1. **Completar migração**: Atualizar todas as telas restantes
2. **Adicionar novas strings**: Conforme novos textos surgirem
3. **Implementar i18n**: Usar como base para tradução
4. **Validar consistência**: Revisar se todos os textos similares usam as mesmas constantes

## Exemplo de Uso Completo

```dart
// ❌ Antes (strings espalhadas)
Text('Data7 Expedição')
labelText: 'Digite seu usuário'
return 'Por favor, digite seu usuário';

// ✅ Depois (strings centralizadas)
Text(AppStrings.appName)
labelText: AppStrings.usernameHint
return AppStrings.usernameRequired;
```
