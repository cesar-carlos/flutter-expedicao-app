# Sistema de Auto Update - Documentação Técnica

Este documento explica em detalhes como funciona o sistema de atualização automática do aplicativo, incluindo arquitetura, fluxo de dados e componentes.

## Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura](#arquitetura)
3. [Componentes](#componentes)
4. [Fluxo de Funcionamento](#fluxo-de-funcionamento)
5. [Estrutura de Código](#estrutura-de-código)
6. [Detalhes de Implementação](#detalhes-de-implementação)
7. [Configuração](#configuração)
   - [Criando Releases](#criando-releases)

## Visão Geral

O sistema de auto update permite que o aplicativo:

- Verifique automaticamente se há novas versões disponíveis no GitHub
- Baixe o APK do release mais recente
- Instale automaticamente a atualização
- Gerencie o processo completo com feedback visual para o usuário

O sistema segue os princípios de **Clean Architecture** e **SOLID**, organizando o código em camadas bem definidas.

## Arquitetura

O sistema está organizado em camadas seguindo Clean Architecture:

```
┌─────────────────────────────────────────────────────────┐
│              Presentation Layer                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │  AppUpdateDialog / AppUpdateProgressDialog       │  │
│  │  (UI Components)                                 │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │  AppUpdateViewModel                              │  │
│  │  (State Management - Provider)                   │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│              Application Layer                            │
│  ┌──────────────────────────────────────────────────┐  │
│  │  CheckAppUpdateUseCase                           │  │
│  │  DownloadAppUpdateUseCase                        │  │
│  │  InstallAppUpdateUseCase                         │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│              Domain Layer                                │
│  ┌──────────────────────────────────────────────────┐  │
│  │  IAppUpdateRepository (Interface)                │  │
│  │  AppVersion / GitHubRelease (Models)              │  │
│  │  AppUpdateFailure (Errors)                       │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│              Infrastructure Layer                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │  AppUpdateRepositoryImpl                         │  │
│  │  GitHubApiService                                │  │
│  │  GitHubReleaseJsonAdapter                         │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│              External Services                           │
│  ┌──────────────────────────────────────────────────┐  │
│  │  GitHub API (REST)                                │  │
│  │  Dio (HTTP Client)                                │  │
│  │  OpenFilex (APK Installer)                        │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Componentes

### 1. Presentation Layer

#### AppUpdateViewModel
**Localização**: `lib/domain/viewmodels/app_update_viewmodel.dart`

Gerencia o estado da UI e coordena as operações de atualização.

**Responsabilidades**:
- Gerenciar estado de verificação, download e instalação
- Notificar mudanças de estado via `ChangeNotifier`
- Coordenar chamadas aos use cases
- Tratar erros e exibir feedback ao usuário

**Estados gerenciados**:
- `isChecking`: Verificando atualizações
- `isDownloading`: Baixando APK
- `isInstalling`: Instalando APK
- `downloadProgress`: Progresso do download (0.0 a 1.0)
- `updateAvailable`: Release disponível (se houver)
- `error`: Erro ocorrido (se houver)

**Métodos principais**:
- `checkForUpdate()`: Verifica se há atualização disponível
- `downloadAndInstall()`: Baixa e instala a atualização
- `cancelDownload()`: Cancela o download em andamento
- `clearError()`: Limpa erros

#### AppUpdateDialog
**Localização**: `lib/ui/widgets/app_update_dialog.dart`

Diálogo que exibe informações sobre a atualização disponível.

**Exibe**:
- Versão nova disponível
- Notas do release
- Botões: "Depois" e "Atualizar Agora"

#### AppUpdateProgressDialog
**Localização**: `lib/ui/widgets/app_update_progress_dialog.dart`

Diálogo que exibe o progresso do download e instalação.

**Exibe**:
- Barra de progresso durante download
- Indicador de carregamento durante instalação
- Botão "Cancelar" (apenas durante download)

### 2. Application Layer

#### CheckAppUpdateUseCase
**Localização**: `lib/domain/usecases/check_app_update/check_app_update_usecase.dart`

Use case responsável por verificar se há atualização disponível.

**Fluxo**:
1. Obtém versão atual do app
2. Busca último release no GitHub
3. Compara versões
4. Retorna release se houver atualização

**Retorna**: `Result<GitHubRelease>`

#### DownloadAppUpdateUseCase
**Localização**: `lib/domain/usecases/download_app_update/download_app_update_usecase.dart`

Use case responsável por baixar o APK.

**Fluxo**:
1. Recebe URL do APK e nome do arquivo
2. Baixa o arquivo com progresso
3. Retorna caminho do arquivo baixado

**Retorna**: `Result<String>` (caminho do APK)

#### InstallAppUpdateUseCase
**Localização**: `lib/domain/usecases/install_app_update/install_app_update_usecase.dart`

Use case responsável por instalar o APK.

**Fluxo**:
1. Recebe caminho do APK
2. Abre o instalador do Android
3. Retorna sucesso/falha

**Retorna**: `Result<void>`

### 3. Domain Layer

#### IAppUpdateRepository
**Localização**: `lib/domain/repositories/i_app_update_repository.dart`

Interface que define o contrato para acesso a dados de atualização.

**Métodos**:
- `getCurrentVersion()`: Obtém versão atual do app
- `getReleases(owner, repo)`: Lista todos os releases
- `getLatestRelease(owner, repo)`: Obtém último release
- `downloadApk(url, fileName, onProgress, isCancelled)`: Baixa APK
- `installApk(apkPath)`: Instala APK

#### AppVersion
**Localização**: `lib/domain/models/app_version.dart`

Modelo que representa uma versão do app.

**Propriedades**:
- `version`: String semântica (ex: "1.0.2")
- `buildNumber`: Número do build (ex: 3)
- `releaseDate`: Data do release (opcional)

**Métodos**:
- `isNewerThan(other)`: Compara se esta versão é mais nova
- `compareTo(other)`: Compara versões

#### GitHubRelease
**Localização**: `lib/domain/models/github_release.dart`

Modelo que representa um release do GitHub.

**Propriedades**:
- `tagName`: Tag do release (ex: "v1.0.2")
- `name`: Nome do release
- `body`: Notas do release
- `publishedAt`: Data de publicação
- `assets`: Lista de assets (APKs, etc.)

**Métodos**:
- `getVersion()`: Extrai versão da tag
- `getApkAsset()`: Obtém asset APK do release

#### AppUpdateFailure
**Localização**: `lib/domain/models/app_update_failure.dart`

Modelo de erro específico para atualizações.

**Tipos de erro**:
- `noUpdateAvailable`: Nenhuma atualização disponível
- `downloadFailed`: Falha ao baixar
- `installFailed`: Falha ao instalar
- `versionCheckFailed`: Falha ao verificar versão
- `invalidRelease`: Release inválido
- `noApkFound`: APK não encontrado
- `networkError`: Erro de rede

### 4. Infrastructure Layer

#### AppUpdateRepositoryImpl
**Localização**: `lib/data/repositories/app_update_repository_impl.dart`

Implementação do repositório de atualização.

**Dependências**:
- `GitHubApiService`: Para buscar releases do GitHub
- `Dio`: Para download de APKs
- `OpenFilex`: Para instalar APKs
- `PackageInfo`: Para obter versão atual

**Implementação**:
- `getCurrentVersion()`: Usa `PackageInfo.fromPlatform()`
- `getReleases()`: Usa `GitHubApiService.getReleases()`
- `getLatestRelease()`: Usa `GitHubApiService.getLatestRelease()`
- `downloadApk()`: Usa `Dio.download()` com progresso
- `installApk()`: Usa `OpenFilex.open()` para abrir instalador

#### GitHubApiService
**Localização**: `lib/data/services/github_api_service.dart`

Serviço para comunicação com GitHub API.

**Métodos**:
- `getReleases(owner, repo)`: Lista releases
- `getLatestRelease(owner, repo)`: Obtém último release

**Configuração**:
- Base URL: `https://api.github.com`
- Headers: Aceita token de autenticação (opcional)
- Timeout: 30 segundos

#### GitHubReleaseJsonAdapter
**Localização**: `lib/infrastructure/services/github_release_json_adapter.dart`

Adaptador para converter GitHub Releases para formato JSON.

**Funcionalidades**:
- Converte releases para JSON compatível com flutter_autoupdate
- Calcula SHA512 checksum dos assets
- Cria arquivo JSON temporário

**Nota**: Atualmente não está sendo usado, mas está disponível para uso futuro.

## Fluxo de Funcionamento

### 1. Verificação de Atualização

```
┌─────────────┐
│   App Start │
└──────┬──────┘
       │
       ▼
┌─────────────────────────┐
│  AppUpdateViewModel       │
│  checkForUpdate()        │
└──────┬───────────────────┘
       │
       ▼
┌─────────────────────────┐
│  CheckAppUpdateUseCase │
└──────┬──────────────────┘
       │
       ├──────────────────────────┐
       │                          │
       ▼                          ▼
┌──────────────────┐    ┌──────────────────┐
│ getCurrentVersion│    │ getLatestRelease │
│ (Repository)     │    │ (Repository)     │
└──────┬───────────┘    └──────┬───────────┘
       │                        │
       │                        ▼
       │              ┌──────────────────┐
       │              │ GitHubApiService │
       │              │ (GitHub API)     │
       │              └──────────────────┘
       │
       ▼
┌──────────────────┐
│ Compare Versions │
└──────┬───────────┘
       │
       ├─── Há atualização? ───┐
       │                        │
       ▼                        ▼
┌──────────────┐      ┌──────────────┐
│ Return       │      │ Return       │
│ GitHubRelease│      │ NoUpdate     │
└──────────────┘      └──────────────┘
```

### 2. Download e Instalação

```
┌──────────────────────┐
│ User clicks          │
│ "Atualizar Agora"    │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────────┐
│ AppUpdateViewModel       │
│ downloadAndInstall()     │
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────┐
│ DownloadAppUpdateUseCase │
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────┐
│ AppUpdateRepositoryImpl  │
│ downloadApk()            │
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────┐
│ Dio.download()           │
│ (with progress callback) │
└──────────┬───────────────┘
           │
           ├─── Progress ───► Update UI
           │
           ▼
┌──────────────────────────┐
│ APK saved to             │
│ /data/app/.../           │
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────┐
│ InstallAppUpdateUseCase  │
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────┐
│ AppUpdateRepositoryImpl  │
│ installApk()             │
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────┐
│ OpenFilex.open()         │
│ (Opens Android Installer)│
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────┐
│ User confirms            │
│ installation in Android   │
└──────────────────────────┘
```

## Estrutura de Código

### Organização de Arquivos

```
lib/
├── domain/
│   ├── models/
│   │   ├── app_version.dart
│   │   ├── github_release.dart
│   │   ├── release_asset.dart
│   │   └── app_update_failure.dart
│   ├── repositories/
│   │   └── i_app_update_repository.dart
│   ├── usecases/
│   │   ├── check_app_update/
│   │   │   ├── check_app_update_usecase.dart
│   │   │   └── check_app_update_params.dart
│   │   ├── download_app_update/
│   │   │   ├── download_app_update_usecase.dart
│   │   │   └── download_app_update_params.dart
│   │   └── install_app_update/
│   │       ├── install_app_update_usecase.dart
│   │       └── install_app_update_params.dart
│   └── viewmodels/
│       └── app_update_viewmodel.dart
│
├── data/
│   ├── repositories/
│   │   └── app_update_repository_impl.dart
│   ├── services/
│   │   └── github_api_service.dart
│   └── dtos/
│       └── github_release_dto.dart
│
├── infrastructure/
│   └── services/
│       └── github_release_json_adapter.dart
│
└── ui/
    └── widgets/
        ├── app_update_dialog.dart
        └── app_update_progress_dialog.dart
```

## Detalhes de Implementação

### Comparação de Versões

O sistema compara versões usando lógica semântica:

1. **Extrai versão da tag**:
   - Padrão: `(\d+\.\d+\.\d+)` (ex: "1.0.2")
   - Build number opcional: `\+(\d+)` (ex: "+3")

2. **Compara versão semântica**:
   - Compara major, minor e patch separadamente
   - Se versão do release > versão atual → há atualização

3. **Compara build number** (se versões iguais):
   - Se build do release > build atual → há atualização

**Exemplo**:
```dart
// App atual: 1.0.2+3
// Release: v1.0.3
// Resultado: Há atualização (1.0.3 > 1.0.2)

// App atual: 1.0.2+3
// Release: v1.0.2+5
// Resultado: Há atualização (build 5 > build 3)

// App atual: 1.0.2+3
// Release: v1.0.2+2
// Resultado: Não há atualização (build 2 < build 3)
```

### Download com Progresso

O download usa `Dio` com callback de progresso:

```dart
await dio.download(
  downloadUrl,
  savePath,
  onReceiveProgress: (received, total) {
    // Calcula progresso: received / total
    onProgress(received, total);
  },
);
```

O progresso é atualizado em tempo real e refletido na UI através do `AppUpdateViewModel`.

### Instalação de APK

A instalação usa `OpenFilex` para abrir o instalador do Android:

```dart
final result = await OpenFilex.open(apkPath);
```

O Android exibirá o diálogo nativo de instalação, onde o usuário deve confirmar.

### Tratamento de Erros

Todos os erros são tratados usando o padrão `Result<T>` do `result_dart`:

```dart
Future<Result<GitHubRelease>> getLatestRelease(...) async {
  try {
    // Operação
    return success(release);
  } catch (e) {
    return failure(AppUpdateFailure.versionCheckFailed(e.toString()));
  }
}
```

Os erros são propagados através das camadas e exibidos na UI.

### Verificação Automática

A verificação é acionada automaticamente no `main.dart`:

```dart
if (kReleaseMode) {
  Future.delayed(const Duration(seconds: 2), () async {
    await appUpdateViewModel.checkForUpdate();
  });
}
```

**Nota**: A verificação só ocorre em modo release (`kReleaseMode`).

## Configuração

### Variáveis de Ambiente

Configure no arquivo `.env`:

```env
GITHUB_OWNER=seu-usuario-github
GITHUB_REPO=nome-do-repositorio
GITHUB_TOKEN=seu-token-opcional
```

### Permissões Android

O `AndroidManifest.xml` já está configurado com:

```xml
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
```

### FileProvider

O FileProvider está configurado em:
- `android/app/src/main/res/xml/file_paths.xml`
- `android/app/src/main/AndroidManifest.xml`

### Dependency Injection

As dependências são registradas no `locator.dart`:

```dart
locator.registerLazySingleton<IAppUpdateRepository>(
  () => AppUpdateRepositoryImpl(),
);

locator.registerLazySingleton<CheckAppUpdateUseCase>(
  () => CheckAppUpdateUseCase(locator<IAppUpdateRepository>()),
);

// ... outros use cases
```

### Criando Releases

Para criar um novo release no GitHub:

1. **Atualize a versão no `pubspec.yaml`**:
   ```yaml
   version: 1.0.7+2
   ```

2. **Crie as notas de release**:
   - Sempre salve as notas de release em `docs/release/RELEASE_NOTES_v{versão}.md`
   - Exemplo: `docs/release/RELEASE_NOTES_v1.0.7+2.md`
   - Inclua novidades, melhorias, correções e instruções de uso

3. **Crie a tag Git**:
   ```bash
   git tag -a v1.0.7+2 -m "Release v1.0.7+2 - Descrição do release"
   git push origin v1.0.7+2
   ```

4. **Gere o APK**:
   ```bash
   flutter build apk --release
   ```
   O APK será gerado em `build/app/outputs/flutter-apk/app-release.apk`

5. **Crie o release no GitHub**:
   - Acesse: https://github.com/{GITHUB_OWNER}/{GITHUB_REPO}/releases/new
   - Selecione a tag criada
   - Cole o conteúdo do arquivo de notas de release de `docs/release/`
   - Faça upload do APK gerado
   - Publique o release

**Importante**: Sempre mantenha as notas de release organizadas em `docs/release/` para facilitar a referência e o histórico de versões.

## Fluxo Completo de Exemplo

1. **App inicia** (modo release)
   - `main.dart` aguarda 2 segundos
   - Chama `appUpdateViewModel.checkForUpdate()`

2. **Verificação**
   - ViewModel chama `CheckAppUpdateUseCase`
   - Use case obtém versão atual e último release
   - Compara versões
   - Se houver atualização, retorna `GitHubRelease`

3. **Exibição de Diálogo**
   - `main.dart` detecta `hasUpdate == true`
   - Exibe `AppUpdateDialog` com informações do release

4. **Usuário confirma atualização**
   - ViewModel chama `downloadAndInstall()`
   - Exibe `AppUpdateProgressDialog`

5. **Download**
   - ViewModel chama `DownloadAppUpdateUseCase`
   - Repository baixa APK usando Dio
   - Progresso é atualizado em tempo real

6. **Instalação**
   - Após download, ViewModel chama `InstallAppUpdateUseCase`
   - Repository abre instalador do Android
   - Usuário confirma instalação no sistema

7. **Conclusão**
   - APK é instalado
   - App é reiniciado com nova versão

## Considerações Técnicas

### Segurança

- Comunicação com GitHub via HTTPS
- APK baixado diretamente do GitHub (fonte confiável)
- Usuário deve confirmar instalação no Android
- Verificação de integridade pode ser adicionada (SHA512)

### Performance

- Verificação assíncrona não bloqueia UI
- Download com progresso em tempo real
- Cancelamento de download suportado

### Robustez

- Tratamento de erros em todas as camadas
- Fallback para erros de rede
- Não bloqueia uso do app em caso de falha

### Testabilidade

- Clean Architecture facilita testes unitários
- Interfaces permitem mocks
- Use cases isolados e testáveis

## Referências

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
- [GitHub Releases API](https://docs.github.com/en/rest/releases/releases)
- [Semantic Versioning](https://semver.org/)
- [Result Pattern](https://pub.dev/packages/result_dart)
