# Análise da implementação App Update vs regras do projeto

## O que está alinhado às regras

- **Use cases**: SRP (um caso de uso por operação), dependem apenas de `IAppUpdateRepository`, usam `call()`, retornam `Result<T>`, recebem params via objetos (`CheckAppUpdateParams`, etc.). **domain_layer** ✓
- **`IAppUpdateRepository`**: Interface no domain, prefixo `I`, métodos retornam `Result<>`. **clean_architecture**, **domain_layer** ✓
- **`AppUpdateRepositoryImpl`**: Em `data/`, implementa a interface, usa Dio (padrão do projeto). **dependencies_patterns** ✓
- **`result_dart`**: Uso de `Result`, `fold`, `Success`, `Failure` em use cases e repositório. **dependencies_patterns** ✓
- **`get_it`** para DI, **Provider** para estado (ViewModel no MultiProvider). **dependencies_patterns** ✓
- **Nomenclatura**: `CheckAppUpdateUseCase`, `DownloadAppUpdateParams`, etc. **coding_conventions** ✓
- **`AppUpdateFailure`**: Em `domain/models/`, estende `AppFailure`, factories específicas. **domain_layer** (errors) ✓
- **Código autoexplicativo**: Poucos comentários nos use cases / viewmodel / repo. **general_rules** ✓

---

## Violações identificadas

### 1. Core importando Domain (**clean_architecture**)

**Regra**: *Core → Não importa de outras camadas de negócio.*

**Onde**: `lib/core/results/result_extensions.dart` importa `domain/models/app_update_failure.dart`.

**Motivo**: `mapFailureToAppUpdate` e `ResultVoidAppUpdateExtensions` são específicos de app-update e usam `AppUpdateFailure`. Lógica de feature em `core` quebra a independência do core.

**Correção**: Mover `mapFailureToAppUpdate` (e a extensão para `Result<void>`) para o **domain** (ex.: `domain/extensions/result_app_update_extensions.dart`). Manter em `core` apenas extensões genéricas (`get`, `getError`, `getErrorMessageOrDefault`, `ResultVoidExtensions.getError`) que não dependem de domain.

**Feito**: `lib/domain/extensions/result_app_update_extensions.dart` criado com `mapFailureToAppUpdate`; `core/results/result_extensions.dart` sem import de domain; use cases de download/install passam a importar as extensões do domain.

---

### 2. Domain importando Data (**clean_architecture**)

**Regra**: *Domain → NUNCA importar de application, infrastructure ou presentation.*

**Onde**: `lib/domain/viewmodels/app_update_viewmodel.dart` importa `data/datasources/update_cache_service.dart`.

**Motivo**: ViewModel está no domain mas depende de serviço de dados (cache com `SharedPreferences`). Domain não deve depender de camada de dados.

**Correção (estrutural)**: Introduzir interface no domain (ex.: `IUpdateCheckCache`) com `shouldCheckForUpdates()` e `markAsChecked()`. Implementação em `data/` (`UpdateCacheService`). ViewModel depender da interface, não do serviço concreto. Opcionalmente mover ViewModels para `ui/` (ou `presentation/`), já que lidam com estado de UI e Flutter; as regras colocam *controllers/providers* na camada de apresentação.

---

### 3. Domain importando Flutter (**domain_layer**)

**Regra**: *Domain → NUNCA importar Flutter, HTTP ou frameworks.*

**Onde**: `AppUpdateViewModel` importa `package:flutter/foundation.dart` (`ChangeNotifier`).

**Motivo**: ViewModel no domain usa tipo do Flutter para notificação de estado.

**Correção**: Ver ponto 2. Ao mover ViewModels para a camada de UI/presentation, o uso de `ChangeNotifier` passa a ser aceitável. Alternativa: manter ViewModels no domain só se abstrairmos a notificação (ex.: interface `Listenable` / callback puro), o que tende a ser desproporcional.

---

### 4. Lógica específica de feature em Core

**Regra**: *Core = componentes centrais compartilhados.*

**Onde**: `mapFailureToAppUpdate` e `ResultVoidAppUpdateExtensions` em `core/results/result_extensions.dart`.

**Motivo**: São específicos do fluxo de app update, não utilitários genéricos.

**Correção**: Mesma do item 1 — mover para `domain/extensions/` (ou junto ao feature de app update no domain).

---

### 5. Documentação automática (**general_rules**)

**Regra**: *Não criar documentação (///, README, etc.) automaticamente; apenas quando solicitado.*

**Onde**:  
- `UpdateCacheService`: vários `///` em classes e métodos.  
- `core/results/index.dart`: comentários de módulo.

**Correção**: Remover `///` e comentários de módulo não solicitados, mantendo o código autoexplicativo.

---

### 6. Uso de `Navigator` (**dependencies_patterns**)

**Regra**: *SEMPRE usar `go_router` para navegação; NUNCA usar `Navigator.push`.*

**Onde**: `AppUpdateDialog` usa `Navigator.of(context).pop()` para fechar o diálogo.

**Observação**: A regra cita explicitamente `Navigator.push`. `pop()` em diálogo modal é um caso limite (fechar overlay vs. rota). Mantém-se aderente ao *spirit* do projeto priorizando `go_router` para rotas; para modais, `pop` é uso comum e pode ser aceito como exceção, a menos que o projeto padronize outro mecanismo para fechar diálogos.

---

## Reflexão

- **Estrutura real vs. regras**: O projeto usa `data/` e `ui/` em vez de `infrastructure/` e `presentation/`. ViewModels estão em `domain/`. As regras sugerem *controllers/providers* em *presentation*. O desvio importante não é o nome da pasta, e sim **ViewModel no domain dependendo de data + Flutter**, o que fere Clean Architecture e **domain_layer**.

- **Prioridade de ajustes**:  
  1. **Core → Domain**: Mover extensões de app-update para o domain (impacto baixo, alinha com regras).  
  2. **Domain → Data/Flutter**: Abstrair cache (`IUpdateCheckCache`) e, se possível, mover ViewModels para UI; isso exige refactor maior mas corrige a inversão de dependências.

- **Migration gradual**: As regras incentivam migração incremental. Corrigir primeiro o que está em `core` (item 1) e, em seguida, planejar a abstração do cache e a realocação dos ViewModels (itens 2 e 3) evita mudanças bruscas e mantém o ritmo de entrega.
