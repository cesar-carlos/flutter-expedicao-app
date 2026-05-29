# Guia de Migração para Result Pattern (result_dart)

Este documento explica como migrar código que usa `throw Exception` para o padrão `Result` usando `result_dart`.

> **Status: MIGRAÇÃO PARCIAL ⏳**
>
> A infraestrutura do padrão `Result` está pronta e em uso, mas a
> migração da base de código ainda não está completa. Veja a seção
> [Estado da Migração](#estado-da-migração) para o detalhamento do que
> já foi CONCLUÍDO e do que ainda está PENDENTE.

## Estado da Migração

### ✅ Concluído (infraestrutura pronta)

- ✅ Hierarquia de failures em `lib/core/results/app_failure.dart`:
  `ValidationFailure`, `NetworkFailure`, `AuthFailure`, `DataFailure`,
  `BusinessFailure`, `UnknownFailure` (base `AppFailure`).
- ✅ Helpers em `lib/core/results/app_result.dart`: `success`, `failure`,
  `validationFailure`, `networkFailure`, `dataFailure`, `businessFailure`,
  `authFailure`, `unknownFailure`, `safeCall`, `safeCallSync`,
  `safeHttpCall`, `handleDioException`.
- ✅ Export central em `lib/core/results/index.dart`.
- ✅ Contrato base `UseCase<T, Params>` com `Future<Result<T>> call(...)`
  (e `SyncUseCase<T, Params>`) em `lib/domain/usecases/base_usecase.dart`.
- ✅ Nenhum uso de `Either`/`dartz` no projeto (correto — o padrão é
  `result_dart`).
- ✅ ~20 use cases já retornam `Future<Result<...>>`.
- ✅ Duas interfaces de repositório do domain já retornam `Result`:
  `i_app_update_repository.dart` e `i_thermal_printer_repository.dart`.
- ✅ ViewModels que já consomem `Result` via `fold`: `AddCartViewModel`
  (`lib/presentation/viewmodels/add_cart_viewmodel.dart`) e telas de
  separação.

### ⏳ Pendente (ainda usa `throw`/exceções)

- ⏳ Interface `lib/domain/repositories/user_repository.dart` ainda
  retorna `Future<LoginResponse>` (sem `Result`).
- ⏳ Implementações em `lib/data/repositories/` ainda usam `throw`
  (ex.: `user_repository_impl`, `user_system_repository_impl`,
  `expedition_item_print_consultation_repository_impl`). `safeHttpCall`
  **não** é usado em `lib/data/` — está apenas definido em
  `lib/core/results/app_result.dart`.
- ⏳ Dois use cases legados ainda usam `LegacyUseCase` + exceções:
  `LoginUserUseCase` e `RegisterUserUseCase`
  (`lib/domain/usecases/legacy_usecase.dart`,
  `lib/domain/usecases/user/login_user_usecase.dart`,
  `lib/domain/usecases/user/register_user_usecase.dart`).
- ⏳ `AuthViewModel` ainda usa `try/catch` + `UserApiException` no login
  (`lib/domain/viewmodels/auth_viewmodel.dart` ~111-144).
- ⏳ Interfaces de repositório que **ainda não** usam `Result`:
  `UserRepository`, `BasicRepository`, `IPrinterPreferencesRepository`.

## Por que usar Result?

- ✅ **Tratamento centralizado de erros**: Todos os erros são tratados de forma consistente
- ✅ **Type safety**: O compilador força o tratamento de erros
- ✅ **Sem try/catch espalhados**: Erros são parte do tipo de retorno
- ✅ **Código mais limpo**: Menos aninhamento e mais legibilidade

## Estrutura de Failures

O projeto já possui uma hierarquia de failures em `lib/core/results/app_failure.dart`:

- `AppFailure` (base)
  - `ValidationFailure` - Erros de validação
  - `NetworkFailure` - Erros de rede/conexão
  - `AuthFailure` - Erros de autenticação/autorização
  - `DataFailure` - Erros de dados/repositório
  - `BusinessFailure` - Erros de regra de negócio
  - `UnknownFailure` - Erros desconhecidos

## Helpers Disponíveis

### Criar Results

```dart
import 'package:data7_expedicao/core/results/index.dart';

// Sucesso
Result<String> result = success('valor');

// Falhas
Result<String> result = validationFailure(['Erro 1', 'Erro 2']);
Result<String> result = networkFailure('Erro de conexão', statusCode: 500);
Result<String> result = authFailure('Credenciais inválidas');
Result<String> result = dataFailure('Erro ao processar dados');
Result<String> result = businessFailure('Operação não permitida');
Result<String> result = unknownFailure(exception);
```

### Executar Operações com Tratamento Automático

```dart
// Operação assíncrona genérica
Future<Result<T>> result = await safeCall(() async {
  return await algumaOperacao();
});

// Operação HTTP (trata DioException automaticamente)
Future<Result<T>> result = await safeHttpCall(() async {
  return await dio.get('/endpoint');
});

// Operação síncrona
Result<T> result = safeCallSync(() {
  return algumaOperacao();
});
```

## Exemplo de Migração

### ❌ ANTES (usando throw)

```dart
Future<LoginResponse> login(String nome, String senha) async {
  try {
    final loginDto = LoginDto(nome: nome, senha: senha);
    final url = '$_baseUrl/expedicao/login-app';
    final response = await _dio.post(url, data: loginDto.toApiRequest());

    if (response.statusCode == 200) {
      final loginResponseDto = LoginResponseDto.fromJson(response.data);
      return loginResponseDto.toDomain();
    } else {
      throw UserApiException('Erro inesperado no login', statusCode: response.statusCode);
    }
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      throw UserApiException('Credenciais inválidas', statusCode: 401);
    }
    throw UserApiException('Erro de conexão', statusCode: e.response?.statusCode);
  } catch (e) {
    throw UserApiException('Erro interno: $e', statusCode: 500);
  }
}
```

### ✅ DEPOIS (usando Result)

```dart
Future<Result<LoginResponse>> login(String nome, String senha) async {
  return await safeHttpCall(() async {
    final loginDto = LoginDto(nome: nome, senha: senha);
    final url = '$_baseUrl/expedicao/login-app';
    final response = await _dio.post(url, data: loginDto.toApiRequest());

    if (response.statusCode == 200) {
      final loginResponseDto = LoginResponseDto.fromJson(response.data);
      return loginResponseDto.toDomain();
    } else {
      throw Exception('Erro inesperado no login: Status ${response.statusCode}');
    }
  });
}
```

**Ou com tratamento mais específico:**

```dart
Future<Result<LoginResponse>> login(String nome, String senha) async {
  try {
    final loginDto = LoginDto(nome: nome, senha: senha);
    final url = '$_baseUrl/expedicao/login-app';
    final response = await _dio.post(url, data: loginDto.toApiRequest());

    if (response.statusCode == 200) {
      final loginResponseDto = LoginResponseDto.fromJson(response.data);
      return success(loginResponseDto.toDomain());
    } else {
      return networkFailure('Erro inesperado no login', statusCode: response.statusCode);
    }
  } on DioException catch (e) {
    return handleDioException<LoginResponse>(e);
  } catch (e) {
    return dataFailure('Erro ao processar resposta: ${e.toString()}', exception: e);
  }
}
```

## Como Usar Result no Código

### Tratamento com fold()

```dart
final result = await repository.login('usuario', 'senha');

result.fold(
  (loginResponse) {
    // Sucesso
    print('Login realizado: ${loginResponse.user.nome}');
  },
  (failure) {
    // Falha
    print('Erro: ${failure.userMessage}');
  },
);
```

> **Este é o padrão adotado no projeto** (sucesso primeiro, falha
> depois), conforme o uso em
> `lib/presentation/viewmodels/add_cart_viewmodel.dart` e nas extensões
> de `lib/core/results/result_extensions.dart`.

### Tratamento com getOrNull()

```dart
final loginResponse = await repository.login('usuario', 'senha')
    .getOrNull();

if (loginResponse != null) {
  // Usar loginResponse
} else {
  // Tratar erro
}
```

### Verificação de sucesso/falha

```dart
final result = await repository.login('usuario', 'senha');

if (result.isSuccess()) {
  final loginResponse = result.getOrNull();
  // Usar loginResponse
} else {
  final failure = result.exceptionOrNull();
  // Tratar failure
}
```

## Migração de Interfaces

### Atualizar Interface do Repositório

```dart
// ❌ ANTES
abstract class UserRepository {
  Future<LoginResponse> login(String nome, String senha);
}

// ✅ DEPOIS
abstract class UserRepository {
  Future<Result<LoginResponse>> login(String nome, String senha);
}
```

## Checklist de Migração

Infraestrutura e contratos base:

- [x] Criar hierarquia de failures (`AppFailure` e variantes)
- [x] Criar helpers (`success`, `failure`, `safeCall`, `safeCallSync`,
  `safeHttpCall`, `handleDioException`, etc.)
- [x] Definir contrato base `UseCase<T, Params>` retornando `Result<T>`
- [x] Garantir ausência de `Either`/`dartz` no projeto

Migração por área (parcial):

- [x] Maioria dos use cases retornando `Result<T>` (~20)
- [x] Algumas interfaces de repositório do domain usando `Result`
  (`IAppUpdateRepository`, `IThermalPrinterRepository`)
- [x] ViewModels de separação consumindo `Result` via `fold`
  (`AddCartViewModel`)
- [ ] Atualizar `UserRepository` (domain) para retornar `Result<T>`
- [ ] Atualizar `BasicRepository` e `IPrinterPreferencesRepository` para
  usar `Result`
- [ ] Migrar implementações em `lib/data/repositories/` de `throw` para
  `Result` (usar `safeHttpCall`/`handleDioException`)
- [ ] Migrar use cases legados (`LoginUserUseCase`, `RegisterUserUseCase`)
  de `LegacyUseCase` + exceções para `UseCase` + `Result`
- [ ] Migrar `AuthViewModel` (login) de `try/catch` + `UserApiException`
  para tratamento via `Result`/`fold`

## Próximos Passos

1. Migrar implementações de repositório em `lib/data/repositories/`
   (substituir `throw` por `Result`, usando `safeHttpCall`)
2. Atualizar interfaces restantes no Domain (`UserRepository`,
   `BasicRepository`, `IPrinterPreferencesRepository`)
3. Migrar use cases legados (`LoginUserUseCase`, `RegisterUserUseCase`)
   para o contrato `UseCase` com `Result`
4. Atualizar `AuthViewModel` para tratar `Result` via `fold`
5. Atualizar UI para exibir erros de forma amigável
