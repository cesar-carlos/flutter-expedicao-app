# Login System - Cadastro via QR Code

## Visão Geral

O **Login System** é uma funcionalidade que permite aos usuários se cadastrarem no aplicativo escaneando um QR Code gerado pelo sistema administrativo. Todos os dados necessários para o cadastro são fornecidos no QR Code, tornando o processo rápido e automático.

## Arquitetura

A implementação segue os princípios de Clean Architecture:

```
┌─────────────────────────────────────────────────────┐
│                   UI Layer                          │
│  - QRCodeLoginScreen                                │
│  - LoginForm (botão "Login System")                 │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────┐
│                Domain Layer                         │
│  - RegisterViaQRCodeUseCase                         │
│  - SystemQRCodeData (modelo)                        │
│  - ScanBarcodeUseCase (integração)                  │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────┐
│                 Data Layer                          │
│  - UserRepository                                   │
│  - UserSessionService                               │
│  - BarcodeScannerRepository (mobile_scanner)        │
└─────────────────────────────────────────────────────┘
```

## Fluxo de Funcionamento

1. **Acesso**: Na tela de login, o usuário clica no botão "Login System"
2. **Navegação**: O app abre a `QRCodeLoginScreen`
3. **Scanner**: Usuário clica em "Escanear QR Code"
4. **Leitura**: A câmera abre e lê o QR Code
5. **Parse**: O JSON do QR Code é parseado e validado
6. **Cadastro**: O usuário é cadastrado localmente com os dados do sistema
7. **Login**: Login automático é realizado
8. **Navegação**: Usuário é redirecionado para a home

## Formato do QR Code

O QR Code deve conter um JSON com os seguintes campos:

```json
{
  "CodUsuario": 123,
  "NomeUsuario": "João Silva",
  "SenhaUsuario": "senha123",
  "Ativo": "S",
  "CodEmpresa": 1,
  "NomeEmpresa": "Empresa ABC",
  "CodVendedor": 10,
  "NomeVendedor": "Vendedor X",
  "CodLocalArmazenagem": 5,
  "NomeLocalArmazenagem": "Armazém Principal",
  "CodContaFinanceira": "001",
  "NomeContaFinanceira": "Conta Principal",
  "NomeCaixaOperador": "Caixa 01",
  "CodSetorEstoque": 1,
  "NomeSetorEstoque": "Setor A",
  "PermiteSepararForaSequencia": "S",
  "VisualizaTodasSeparacoes": "N",
  "CodSetorConferencia": 2,
  "NomeSetorConferencia": "Conferência Central",
  "PermiteConferirForaSequencia": "S",
  "VisualizaTodasConferencias": "N",
  "CodSetorArmazenagem": 3,
  "NomeSetorArmazenagem": "Armazenagem Principal",
  "PermiteArmazenarForaSequencia": "N",
  "VisualizaTodasArmazenagem": "S",
  "EditaCarrinhoOutroUsuario": "N",
  "SalvaCarrinhoOutroUsuario": "N",
  "ExcluiCarrinhoOutroUsuario": "N",
  "ExpedicaoEntregaBalcaoPreVenda": "S"
}
```

### Campos Obrigatórios

- `CodUsuario` (int)
- `NomeUsuario` (string)
- `SenhaUsuario` (string)
- `CodEmpresa` (int)
- `NomeEmpresa` (string)

### Campos Opcionais

Todos os outros campos são opcionais e podem ser `null`. Campos de permissão (`PermiteSepararForaSequencia`, etc.) têm valor padrão `"N"` se não fornecidos.

## Componentes

### 1. SystemQRCodeData

**Localização**: `lib/domain/models/user/system_qrcode_data.dart`

Modelo que representa os dados do QR Code.

**Métodos principais**:

- `fromJson()`: Parse de JSON
- `fromQRCodeString()`: Parse seguro com validação
- `toUserSystemModel()`: Conversão para `UserSystemModel`

**Exemplo**:

```dart
final result = SystemQRCodeData.fromQRCodeString(qrCodeContent);

result.fold(
  (data) => print('QR Code válido: ${data.nomeUsuario}'),
  (failure) => print('QR Code inválido: ${failure.message}'),
);
```

### 2. RegisterViaQRCodeUseCase

**Localização**: `lib/domain/usecases/user/register_via_qrcode_usecase.dart`

UseCase responsável por registrar o usuário a partir dos dados do QR Code.

**Parâmetros**: `RegisterViaQRCodeParams`

- `qrCodeData`: Instância de `SystemQRCodeData`

**Retorno**: `Result<RegisterViaQRCodeSuccess>`

**Exemplo**:

```dart
final useCase = locator<RegisterViaQRCodeUseCase>();
final params = RegisterViaQRCodeParams(qrCodeData: qrCodeData);
final result = await useCase(params);

result.fold(
  (success) => print('Usuário cadastrado: ${success.user.nome}'),
  (failure) => print('Erro: ${failure.userMessage}'),
);
```

### 3. QRCodeLoginScreen

**Localização**: `lib/ui/screens/qrcode_login_screen.dart`

Tela completa para o fluxo de cadastro via QR Code.

**Funcionalidades**:

- Interface amigável com instruções
- Botão para iniciar o scanner
- Indicador de loading durante processamento
- Exibição de erros
- Som de feedback (sucesso/erro)
- Login automático após cadastro
- Navegação automática para home

## Tratamento de Erros

### Erros de Parse

- **QR Code inválido**: JSON mal formado
- **Campos ausentes**: Campos obrigatórios faltando

### Erros de Registro

- **Usuário já existe**: Usuário com mesmo nome já cadastrado
- **Falha no cadastro**: Erro na criação do usuário
- **Erro de rede**: Problemas de comunicação

### Erros de Scanner

- **Scan cancelado**: Usuário fechou o scanner
- **Código vazio**: Nenhum código detectado
- **Permissão negada**: Câmera não autorizada

## Integração com Scanner

A feature utiliza o `ScanBarcodeUseCase` para integração com o scanner de código de barras (QR Code).

**Package utilizado**: `mobile_scanner: ^5.2.3`

**Permissões necessárias** (já configuradas em `AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
```

## Rotas

### Nova Rota Adicionada

**Path**: `/qrcode-login`
**Nome**: `qrcode-login`
**Screen**: `QRCodeLoginScreen`

### Acesso Permitido

A rota é acessível para usuários não autenticados, assim como `/login`, `/register` e `/config`.

## Dependency Injection

### Registros no Locator

```dart
// lib/di/locator.dart

locator.registerLazySingleton<RegisterViaQRCodeUseCase>(
  () => RegisterViaQRCodeUseCase(
    userRepository: locator<UserRepository>(),
    userSystemRepository: locator<UserSystemRepository>(),
    userSessionService: locator<UserSessionService>(),
  ),
);
```

## UI/UX

### Tela de Login

Um novo botão foi adicionado à tela de login:

```dart
CustomFlatButton(
  text: 'Login System',
  onPressed: () => context.go('/qrcode-login'),
  icon: Icons.qr_code_scanner,
  textColor: Theme.of(context).colorScheme.secondary,
  backgroundColor: Colors.transparent,
  borderColor: Colors.transparent,
  padding: const EdgeInsets.symmetric(vertical: 12),
  borderRadius: 6,
)
```

### QRCodeLoginScreen

- **Ícone grande** de QR Code
- **Título** explicativo
- **Descrição** do processo
- **Botão principal** para escanear
- **Card informativo** com instruções passo a passo
- **Feedback visual** de loading
- **Mensagens de erro** claras

## Teste

### Teste Manual

1. Gerar um QR Code com o JSON de exemplo
2. Abrir o app
3. Na tela de login, clicar em "Login System"
4. Clicar em "Escanear QR Code"
5. Apontar para o QR Code
6. Verificar cadastro e login automático

### QR Code de Teste

Você pode gerar um QR Code de teste em sites como:

- https://www.qr-code-generator.com/
- https://www.the-qrcode-generator.com/

Use o JSON de exemplo fornecido acima.

## Considerações de Segurança

1. **Senha**: A senha é transmitida no QR Code. O QR Code deve ser gerado de forma segura e exibido apenas para o usuário correto.

2. **Validação**: Todos os dados são validados antes do cadastro.

3. **Sessão**: A sessão é salva localmente após o cadastro bem-sucedido.

## Melhorias Futuras

- [ ] Criptografia da senha no QR Code
- [ ] Validação de data de validade do QR Code
- [ ] Limite de usos do QR Code
- [ ] Log de cadastros via QR Code
- [ ] Sincronização de foto de perfil
- [ ] Suporte para atualização de dados existentes

## Arquivos Criados

1. `lib/domain/models/user/system_qrcode_data.dart`
2. `lib/domain/usecases/user/register_via_qrcode_usecase.dart`
3. `lib/ui/screens/qrcode_login_screen.dart`
4. `docs/qrcode-login-system.md`

## Arquivos Modificados

1. `lib/ui/widgets/auth/login_form.dart` - Adicionado botão "Login System"
2. `lib/core/routing/app_router.dart` - Adicionada rota `/qrcode-login`
3. `lib/di/locator.dart` - Registrado `RegisterViaQRCodeUseCase`

## Conclusão

O **Login System** fornece uma maneira rápida e conveniente de cadastrar usuários no aplicativo, eliminando a necessidade de digitação manual de dados. A implementação segue os padrões de Clean Architecture do projeto e se integra perfeitamente com o sistema de scanner existente.
