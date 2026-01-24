# Data7 Expedição

Aplicativo Flutter para gestão de expedição e separação de pedidos, desenvolvido seguindo os princípios de **Clean Architecture** e **Domain Driven Design (DDD)**.

## 📋 Índice

- [Sobre o Projeto](#sobre-o-projeto)
- [Tecnologias](#tecnologias)
- [Arquitetura](#arquitetura)
- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Configuração](#configuração)
- [Executando o Projeto](#executando-o-projeto)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Funcionalidades](#funcionalidades)
- [Testes](#testes)
- [Build e Release](#build-e-release)
- [Contribuindo](#contribuindo)

## 🎯 Sobre o Projeto

O **Data7 Expedição** é um aplicativo mobile desenvolvido em Flutter para gerenciar processos de expedição e separação de pedidos. O aplicativo oferece funcionalidades como:

- **Separação de Pedidos**: Sistema completo para separação de itens de pedidos
- **Scanner de Código de Barras**: Leitura de códigos de barras para identificação de produtos
- **Autenticação via QR Code**: Login rápido e seguro através de QR Code
- **Comunicação em Tempo Real**: Integração com Socket.IO para atualizações instantâneas
- **Sistema de Auto-Update**: Atualização automática via releases do GitHub
- **Temas Claro/Escuro**: Suporte a temas claro e escuro
- **Internacionalização**: Suporte a português (pt-BR) e inglês (en-US)

## 🛠 Tecnologias

### Principais Dependências

- **Flutter SDK**: ^3.9.0
- **get_it**: ^9.2.0 - Injeção de dependências
- **provider**: ^6.1.5+1 - Gerenciamento de estado
- **go_router**: ^17.0.0 - Navegação e rotas
- **dio**: ^5.7.0 - Cliente HTTP
- **socket_io_client**: ^3.1.3 - Comunicação em tempo real
- **hive**: ^2.2.3 - Banco de dados local
- **mobile_scanner**: ^7.1.3 - Scanner de código de barras
- **brasil_fields**: ^1.18.0 - Formatação de campos brasileiros
- **result_dart**: ^2.1.1 - Tratamento de erros
- **zard**: ^0.0.23 - Validação de tipos
- **flutter_dotenv**: ^6.0.0 - Variáveis de ambiente
- **uuid**: ^4.5.1 - Geração de UUIDs

### Dependências de Desenvolvimento

- **flutter_lints**: ^6.0.0 - Linting
- **flutter_launcher_icons**: ^0.14.1 - Geração de ícones
- **hive_generator**: ^2.0.1 - Geração de adapters Hive
- **build_runner**: ^2.4.13 - Geração de código
- **mockito**: ^5.4.4 - Mocking para testes

## 🏗 Arquitetura

O projeto segue os princípios de **Clean Architecture** e **Domain Driven Design (DDD)**, organizando o código em camadas bem definidas:

```
lib/
├── domain/              # Domain Layer (Lógica de Negócio Pura)
│   ├── models/          # Modelos de domínio
│   ├── repositories/    # Interfaces de repositórios
│   ├── services/        # Serviços de domínio
│   ├── usecases/        # Casos de uso
│   └── viewmodels/      # ViewModels
│
├── data/                # Data Layer (Implementações)
│   ├── datasources/     # Fontes de dados
│   ├── dtos/            # Data Transfer Objects
│   ├── models/          # Modelos de dados
│   ├── repositories/    # Implementações de repositórios
│   └── services/        # Serviços de dados
│
├── infrastructure/      # Infrastructure Layer
│   └── services/        # Serviços de infraestrutura
│
├── core/                # Core Components (Compartilhados)
│   ├── constants/       # Constantes
│   ├── extensions/      # Extensões
│   ├── metrics/         # Coleta de métricas
│   ├── network/         # Configuração de rede
│   ├── routing/         # Rotas (go_router)
│   ├── theme/           # Tema da aplicação
│   └── utils/           # Utilitários
│
├── ui/                  # Presentation Layer (UI)
│   ├── screens/         # Telas da aplicação
│   ├── widgets/         # Componentes reutilizáveis
│   └── wrappers/        # Wrappers de navegação
│
├── di/                  # Dependency Injection (GetIt)
│   └── locator.dart     # Configuração do GetIt
│
├── l10n/                # Internacionalização
│   └── app_*.arb        # Arquivos de tradução
│
└── main.dart            # Ponto de entrada
```

### Princípios Aplicados

- **SOLID**: Todos os princípios SOLID são aplicados
- **Dependency Inversion**: Dependências apontam para dentro (camadas externas dependem de internas)
- **Separation of Concerns**: Cada camada tem responsabilidade única
- **Testability**: Lógica de negócio testável sem dependências externas

## 📦 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- **Flutter SDK** (versão 3.9.0 ou superior)
- **Dart SDK** (incluído no Flutter)
- **Android Studio** ou **VS Code** com extensões Flutter
- **Git**
- **Android SDK** (para desenvolvimento Android)
- **Xcode** (para desenvolvimento iOS - apenas macOS)

## 🚀 Instalação

1. **Clone o repositório**

```bash
git clone <url-do-repositorio>
cd exp
```

2. **Instale as dependências**

```bash
flutter pub get
```

3. **Gere os adapters do Hive** (se necessário)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Gere os ícones do aplicativo** (se necessário)

```bash
flutter pub run flutter_launcher_icons
```

## ⚙️ Configuração

### Variáveis de Ambiente

1. **Copie o arquivo de exemplo**

```bash
cp .env.exemple .env
```

2. **Configure as variáveis no arquivo `.env`**

```env
APP_VERSION=1.0.7
API_SERVER=localhost
API_PORT=3001

GITHUB_OWNER=seu-usuario-github
GITHUB_REPO=nome-do-repositorio
GITHUB_TOKEN=seu-token-opcional
```

### Configuração do Android

Certifique-se de que o `AndroidManifest.xml` está configurado corretamente com as permissões necessárias:

- Internet
- Câmera (para scanner)
- Armazenamento (para downloads)

### Configuração do iOS

Configure as permissões no `Info.plist`:

- `NSCameraUsageDescription` - Para uso da câmera no scanner
- `NSPhotoLibraryUsageDescription` - Para acesso à galeria

## ▶️ Executando o Projeto

### Modo Desenvolvimento

```bash
flutter run
```

### Modo Release

```bash
flutter run --release
```

### Executar em dispositivo específico

```bash
# Listar dispositivos disponíveis
flutter devices

# Executar em dispositivo específico
flutter run -d <device-id>
```

### Executar testes

```bash
# Todos os testes
flutter test

# Teste específico
flutter test test/domain/usecases/user/register_via_qrcode_usecase_test.dart
```

## 📁 Estrutura do Projeto

### Domain Layer

Contém a lógica de negócio pura, sem dependências de frameworks:

- **Models**: Entidades do domínio
- **Repositories**: Interfaces para acesso a dados
- **Use Cases**: Operações de negócio isoladas
- **ViewModels**: Gerenciamento de estado da UI

### Data Layer

Implementações concretas de acesso a dados:

- **Data Sources**: Fontes de dados (API, Local DB)
- **Repositories**: Implementações dos repositórios
- **DTOs**: Objetos de transferência de dados
- **Services**: Serviços de dados (API, Socket, etc.)

### Core

Componentes compartilhados:

- **Constants**: Constantes da aplicação
- **Extensions**: Extensões de classes
- **Network**: Configuração de rede (Dio, Socket.IO)
- **Routing**: Configuração de rotas (go_router)
- **Theme**: Tema da aplicação
- **Utils**: Funções utilitárias

### UI

Interface do usuário:

- **Screens**: Telas da aplicação
- **Widgets**: Componentes reutilizáveis
- **Wrappers**: Wrappers de navegação e autenticação

## ✨ Funcionalidades

### Autenticação

- Login tradicional com usuário e senha
- Login via QR Code para acesso rápido
- Gerenciamento de sessão do usuário

### Separação de Pedidos

- Visualização de pedidos para separação
- Adição de itens ao carrinho de separação
- Cancelamento de itens
- Consulta de separações realizadas
- Próximo usuário na fila de separação

### Scanner

- Leitura de código de barras para produtos
- Configuração de scanner
- Validação de códigos

### Configurações

- Configuração de servidor API
- Configuração de scanner
- Gerenciamento de tema (claro/escuro)
- Perfil do usuário

### Auto-Update

- Verificação automática de atualizações
- Download de novas versões via GitHub
- Instalação automática de atualizações
- Feedback visual do progresso

### Comunicação em Tempo Real

- Integração com Socket.IO
- Atualizações instantâneas de pedidos
- Notificações em tempo real

## 🧪 Testes

O projeto possui testes organizados seguindo a estrutura de Clean Architecture:

```
test/
├── core/                    # Testes de componentes core
├── data/                    # Testes de repositórios
├── domain/                  # Testes de domínio
│   ├── models/            # Testes de modelos
│   └── usecases/           # Testes de casos de uso
└── mocks/                   # Mocks para testes
```

### Executando Testes

```bash
# Todos os testes
flutter test

# Testes com cobertura
flutter test --coverage

# Teste específico
flutter test test/domain/usecases/user/register_via_qrcode_usecase_test.dart
```

## 📦 Build e Release

### Build Android (APK)

```bash
flutter build apk --release
```

### Build Android (App Bundle)

```bash
flutter build appbundle --release
```

### Build iOS

```bash
flutter build ios --release
```

### Script de Release

O projeto possui um script PowerShell para facilitar o processo de release:

```powershell
.\create-release.ps1
```

## 📚 Documentação Adicional

- [Sistema de Auto-Update](./docs/auto-update-system.md)
- [Arquitetura do Projeto](./.cursor/rules/architecture.mdc)
- [Padrões de Código](./.cursor/rules/coding_conventions.mdc)
- [Guia de Testes](./.cursor/rules/testing.mdc)

## 🤝 Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### Padrões de Código

O projeto segue padrões rigorosos de código definidos nas regras do Cursor (`.cursor/rules/`):

- Clean Architecture + DDD
- Princípios SOLID
- Null Safety
- Convenções de nomenclatura
- Tratamento de erros com `result_dart`

## 📄 Licença

Este projeto é privado e proprietário da Data7.

## 👥 Equipe

Desenvolvido pela equipe Data7.

---

**Versão**: 1.0.7+2

Para mais informações, consulte a documentação técnica nos arquivos `.md` na pasta `docs/`.
