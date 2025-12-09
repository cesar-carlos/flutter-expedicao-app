# Guia de Migração para Result Pattern (result_dart)

Este documento explica como migrar código que usa `throw Exception` para o padrão `Result` usando `result_dart`.

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

### Tratamento com getOrElse()

```dart
final loginResponse = await repository.login('usuario', 'senha')
    .getOrElse((failure) => LoginResponse.empty());

if (loginResponse != LoginResponse.empty()) {
  // Usar loginResponse
}
```

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

- [ ] Atualizar interface do repositório para retornar `Result<T>`
- [ ] Substituir `throw Exception` por `return failure(...)`
- [ ] Substituir `return value` por `return success(value)`
- [ ] Usar `safeHttpCall` ou `handleDioException` para erros HTTP
- [ ] Atualizar código que chama o método para tratar o Result
- [ ] Remover try/catch desnecessários
- [ ] Testar todos os cenários de erro

## Próximos Passos

1. Migrar repositórios da camada Infrastructure
2. Atualizar interfaces no Domain
3. Atualizar Use Cases para trabalhar com Result
4. Atualizar ViewModels para tratar Results
5. Atualizar UI para exibir erros de forma amigável
