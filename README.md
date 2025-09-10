# EXP - Expedição App

Uma aplicação Flutter para gerenciamento de expedição com scanner QR/código de barras e identidade visual Data7.

## ✨ Funcionalidades

- 📱 **Scanner QR/Código de Barras**: Leitura rápida de códigos usando a câmera
- 📋 **Histórico**: Visualização de códigos lidos anteriormente
- 🎨 **Tema Data7**: Interface personalizada com as cores da marca
- 🔐 **Sistema de Autenticação**: Login seguro com splash screen animado
- 🧭 **Navegação GoRouter**: Roteamento moderno com proteção de rotas
- 🖼️ **Assets Integrados**: Sistema completo de imagens e ícones Data7
- 🎯 **Ícones Customizados**: Launcher icons automáticos para todas as plataformas
- 📱 **UI Responsiva**: Interface adaptativa para diferentes tamanhos de tela

## 🏗️ Arquitetura

- **MVVM Pattern**: Separação clara entre lógica e apresentação
- **Provider**: Gerenciamento de estado reativo
- **Clean Architecture**: Camadas bem definidas (UI, Domain, Data, Core)
- **GoRouter**: Navegação declarativa e type-safe
- **Assets System**: Gestão centralizada de recursos visuais

## 🚀 Como Executar

1. **Clone o repositório**

```bash
git clone <url-do-repositorio>
cd exp
```

2. **Instale as dependências**

```bash
flutter pub get
```

3. **Gere os ícones do launcher (primeira vez)**

```bash
# Windows - execute o script
generate_launcher_icons.bat

# OU manualmente
dart run flutter_launcher_icons
```

4. **Execute o projeto**

```bash
flutter run
```

## 📱 Credenciais de Teste

- **Usuário**: `admin`
- **Senha**: `123456`

## 🎨 Tema Data7

A aplicação utiliza a identidade visual da Data7:

- **Primary**: `#1A7A8A` (Teal)
- **Secondary**: `#4FB3C1` (Light Teal)
- **Accent**: `#0A5A6B` (Dark Teal)
- **Background**: `#B8E6EA` (Very Light Teal)

## 📂 Estrutura do Projeto

```
lib/
├── core/                 # Configurações centrais
│   ├── constants/        # Constantes (cores, assets)
│   ├── routing/         # Configuração do GoRouter
│   └── theme/           # Tema customizado
├── data/                # Camada de dados
│   ├── datasources/     # Fontes de dados
│   ├── dtos/           # Data Transfer Objects
│   └── repositories/    # Implementação dos repositórios
├── di/                  # Dependency Injection
├── domain/              # Regras de negócio
│   ├── models/         # Modelos de domínio
│   ├── usecases/       # Casos de uso
│   └── viewmodels/     # ViewModels (Provider)
└── ui/                 # Interface do usuário
    ├── screens/        # Telas da aplicação
    └── widgets/        # Widgets reutilizáveis
```

## 📦 Dependências Principais

- `provider: ^6.1.2` - Gerenciamento de estado
- `go_router: ^14.8.1` - Navegação
- `get_it: ^8.2.0` - Dependency Injection
- `cupertino_icons: ^1.0.8` - Ícones iOS

## 🖼️ Assets & Ícones

O projeto possui um sistema robusto de assets com:

- 15 arquivos de imagens e ícones Data7
- Constantes type-safe em `AppAssets`
- Widget `ProductImage` com fallback automático
- Suporte a imagens locais e de rede
- **Launcher icons automáticos** para Android, iOS, Web, Windows e macOS

## 📚 Documentação

- [Arquitetura](docs/architecture/architecture.md)
- [Sistema de Autenticação](docs/architecture/authentication-system.md)
- [Implementação do GoRouter](docs/architecture/go-router-implementation.md)
- [Implementação do Provider](docs/architecture/provider-implementation.md)
- [Sistema de Assets](docs/architecture/assets-implementation.md)
- [Sistema de Logo Adaptativo](docs/architecture/adaptive-logo-system.md)
- [Configuração dos Launcher Icons](docs/architecture/launcher-icons-setup.md)

## 🤝 Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.
