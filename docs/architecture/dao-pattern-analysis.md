# Análise e Implementação do Padrão DAO

## 1. Objetivo

Este documento analisa a estrutura atual do projeto e propõe a implementação do padrão DAO (Data Access Object) para melhorar a separação de responsabilidades entre acesso direto aos dados e composição de objetos complexos.

## 2. Problema Identificado

### Estrutura Atual

- **`domain/repositories/`** - Interfaces dos repositórios
- **`data/repositories/`** - Implementações que fazem acesso direto às APIs/Socket
- **`data/services/`** - Serviços que às vezes apenas fazem proxy para repositórios
- **`data/datasources/`** - Poucos datasources (config e preferences)

### Problemas

- Repositórios fazem acesso direto aos dados (API/Socket)
- Código duplicado quando é necessário compor objetos complexos
- Dificuldade para reutilizar lógica de acesso específica
- Mistura de responsabilidades (acesso + composição)

## 3. Proposta de Solução: Padrão DAO

### Conceito

- **DAO (Data Access Object)**: Responsável pelo acesso direto e específico aos dados
- **Repository**: Responsável pela composição e orquestração de múltiplos DAOs

### Estrutura Proposta

```
lib/
├── data/
│   ├── daos/                    # Nova pasta para DAOs
│   │   ├── api/                 # DAOs para APIs REST
│   │   │   ├── user_dao.dart
│   │   │   ├── stock_dao.dart
│   │   │   ├── expedition_dao.dart
│   │   │   └── ...
│   │   ├── socket/              # DAOs para Socket
│   │   │   ├── separate_item_dao.dart
│   │   │   ├── separation_dao.dart
│   │   │   ├── expedition_cart_dao.dart
│   │   │   └── ...
│   │   └── local/               # DAOs para dados locais
│   │       ├── preferences_dao.dart
│   │       ├── config_dao.dart
│   │       └── cache_dao.dart
│   ├── repositories/            # Repositórios para composição
│   │   ├── user_repository_impl.dart
│   │   ├── separate_item_repository_impl.dart
│   │   └── ...
│   ├── datasources/             # Manter como está (pode ser migrado)
│   ├── dtos/                    # Manter como está
│   └── services/                # Pode ser simplificado
```

## 4. Implementação Detalhada

### 4.1 DAOs - Acesso Direto aos Dados

#### DAO para API REST

```dart
// lib/data/daos/api/user_dao.dart
abstract class UserDao {
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData);
  Future<Map<String, dynamic>> getUserById(int id);
  Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> data);
  Future<bool> validatePassword(String nome, String senha);
}

class UserApiDao implements UserDao {
  final Dio _dio;
  final String _baseUrl;

  UserApiDao(this._dio, this._baseUrl);

  @override
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    final url = '$_baseUrl/expedicao/create-login-app';
    final response = await _dio.post(url, data: userData);
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getUserById(int id) async {
    final url = '$_baseUrl/expedicao/consult-login-app';
    final response = await _dio.get(url, queryParameters: {'CodLoginApp': id});
    return response.data;
  }

  // ... outros métodos
}
```

#### DAO para Socket

```dart
// lib/data/daos/socket/separate_item_dao.dart
abstract class SeparateItemDao {
  Future<List<Map<String, dynamic>>> getItems(QueryBuilder query);
  Future<Map<String, dynamic>> insertItem(Map<String, dynamic> item);
  Future<Map<String, dynamic>> updateItem(Map<String, dynamic> item);
  Future<Map<String, dynamic>> deleteItem(Map<String, dynamic> item);
}

class SeparateItemSocketDao implements SeparateItemDao {
  final Socket _socket;
  final Uuid _uuid;

  SeparateItemSocketDao(this._socket, this._uuid);

  @override
  Future<List<Map<String, dynamic>>> getItems(QueryBuilder query) async {
    final event = '${_socket.id} separar.item.select';
    final completer = Completer<List<Map<String, dynamic>>>();
    final responseId = _uuid.v4();

    final send = SendQuerySocketDto(
      session: _socket.id!,
      responseIn: responseId,
      where: query.buildSqlWhere().isEmpty ? null : query.buildSqlWhere(),
      pagination: query.buildPagination().isEmpty ? null : query.buildPagination(),
    );

    _socket.emit(event, jsonEncode(send.toJson()));

    _socket.on(responseId, (receiver) {
      final response = jsonDecode(receiver);
      final data = response?['Data'] ?? [];
      completer.complete(List<Map<String, dynamic>>.from(data));
      _socket.off(responseId);
    });

    return completer.future;
  }

  // ... outros métodos
}
```

#### DAO para Dados Locais

```dart
// lib/data/daos/local/preferences_dao.dart
abstract class PreferencesDao {
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> saveBool(String key, bool value);
  Future<bool?> getBool(String key);
}

class SharedPreferencesDao implements PreferencesDao {
  final SharedPreferences _prefs;

  SharedPreferencesDao(this._prefs);

  @override
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  // ... outros métodos
}
```

### 4.2 Repositories - Composição e Orquestração

```dart
// lib/data/repositories/user_repository_impl.dart
class UserRepositoryImpl implements UserRepository {
  final UserDao _userDao;
  final UserProfileDao _profileDao; // Exemplo de composição

  UserRepositoryImpl(this._userDao, this._profileDao);

  @override
  Future<User> getUserWithProfile(int userId) async {
    // Busca dados do usuário
    final userData = await _userDao.getUserById(userId);

    // Busca perfil do usuário separadamente
    final profileData = await _profileDao.getProfileByUserId(userId);

    // Compõe o objeto final
    return User.fromJson({
      ...userData,
      'profile': profileData,
    });
  }

  @override
  Future<CreateUserResponse> createUser({
    required String nome,
    required String senha,
    File? profileImage
  }) async {
    // Validação de dados
    if (nome.isEmpty || senha.isEmpty) {
      throw UserApiException('Dados inválidos', statusCode: 400);
    }

    // Preparação dos dados
    final userData = {
      'nome': nome,
      'senha': senha,
      'profileImage': profileImage,
    };

    // Acesso direto via DAO
    final responseData = await _userDao.createUser(userData);

    // Transformação para modelo de domínio
    return CreateUserResponse.fromJson(responseData);
  }
}
```

## 5. Vantagens da Implementação

### ✅ Separação Clara de Responsabilidades

- DAO: Acesso direto e específico aos dados
- Repository: Composição e orquestração de múltiplos DAOs

### ✅ Reutilização de DAOs

- Um DAO pode ser usado por múltiplos repositórios
- Evita duplicação de código de acesso

### ✅ Facilita Composição de Objetos Complexos

- Repository pode combinar dados de múltiplas fontes
- Exemplo: Usuário + Perfil + Preferências

### ✅ Mantém Compatibilidade

- Arquitetura Clean Architecture preservada
- Interfaces de domínio inalteradas

### ✅ Permite Evolução Gradual

- Migração um repositório por vez
- Não quebra funcionalidades existentes

## 6. Plano de Migração

### Fase 1: Estrutura Base

1. Criar pasta `lib/data/daos/`
2. Criar subpastas `api/`, `socket/`, `local/`
3. Definir interfaces base para cada tipo de DAO

### Fase 2: Migração Gradual

1. **Migrar UserRepository** (mais simples)

   - Criar `UserApiDao`
   - Refatorar `UserRepositoryImpl` para usar DAO
   - Testar funcionalidade

2. **Migrar SeparateItemRepository** (Socket)

   - Criar `SeparateItemSocketDao`
   - Refatorar implementação
   - Testar funcionalidade

3. **Migrar outros repositórios**
   - Seguir mesmo padrão
   - Um por vez para evitar quebras

### Fase 3: Otimização

1. Identificar DAOs que podem ser reutilizados
2. Simplificar serviços que apenas fazem proxy
3. Migrar datasources para DAOs locais

## 7. Exemplo Prático: Composição Complexa

```dart
// Exemplo: Buscar dados completos de uma expedição
class ExpeditionRepositoryImpl implements ExpeditionRepository {
  final ExpeditionDao _expeditionDao;
  final ExpeditionCartDao _cartDao;
  final ExpeditionItemsDao _itemsDao;
  final ExpeditionRouteDao _routeDao;

  ExpeditionRepositoryImpl(
    this._expeditionDao,
    this._cartDao,
    this._itemsDao,
    this._routeDao,
  );

  @override
  Future<ExpeditionComplete> getExpeditionComplete(int expeditionId) async {
    // Busca dados básicos da expedição
    final expeditionData = await _expeditionDao.getById(expeditionId);

    // Busca carrinho da expedição
    final cartData = await _cartDao.getByExpeditionId(expeditionId);

    // Busca itens da expedição
    final itemsData = await _itemsDao.getByExpeditionId(expeditionId);

    // Busca rota da expedição
    final routeData = await _routeDao.getByExpeditionId(expeditionId);

    // Compõe objeto completo
    return ExpeditionComplete.fromJson({
      'expedition': expeditionData,
      'cart': cartData,
      'items': itemsData,
      'route': routeData,
    });
  }
}
```

## 8. Configuração de Dependências

### Atualização do DI Container

```dart
// lib/di/locator.dart
void setupDependencies() {
  // DAOs
  getIt.registerLazySingleton<UserDao>(() => UserApiDao(getIt<Dio>(), DioConfig.baseUrl));
  getIt.registerLazySingleton<SeparateItemDao>(() => SeparateItemSocketDao(getIt<Socket>(), getIt<Uuid>()));
  getIt.registerLazySingleton<PreferencesDao>(() => SharedPreferencesDao(getIt<SharedPreferences>()));

  // Repositories (usando DAOs)
  getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(
    getIt<UserDao>(),
    getIt<UserProfileDao>(),
  ));

  getIt.registerLazySingleton<SeparateItemRepository>(() => SeparateItemRepositoryImpl(
    getIt<SeparateItemDao>(),
  ));
}
```

## 9. Considerações de Teste

### Testes de DAO

```dart
// test/data/daos/user_dao_test.dart
class MockUserApiDao implements UserDao {
  @override
  Future<Map<String, dynamic>> getUserById(int id) async {
    return {'id': id, 'nome': 'Test User'};
  }
  // ... outros métodos mock
}
```

### Testes de Repository

```dart
// test/data/repositories/user_repository_test.dart
void main() {
  group('UserRepository', () {
    late UserRepository repository;
    late MockUserDao mockUserDao;
    late MockUserProfileDao mockProfileDao;

    setUp(() {
      mockUserDao = MockUserDao();
      mockProfileDao = MockUserProfileDao();
      repository = UserRepositoryImpl(mockUserDao, mockProfileDao);
    });

    test('should compose user with profile', () async {
      // Arrange
      when(() => mockUserDao.getUserById(1)).thenAnswer((_) async => {'id': 1, 'nome': 'User'});
      when(() => mockProfileDao.getProfileByUserId(1)).thenAnswer((_) async => {'avatar': 'avatar.jpg'});

      // Act
      final result = await repository.getUserWithProfile(1);

      // Assert
      expect(result.nome, 'User');
      expect(result.profile.avatar, 'avatar.jpg');
    });
  });
}
```

## 10. Conclusão

A implementação do padrão DAO oferece uma solução elegante para os problemas identificados na estrutura atual:

- **Separação clara** entre acesso direto aos dados e composição
- **Reutilização** de código de acesso específico
- **Facilita** composição de objetos complexos
- **Mantém** a arquitetura Clean Architecture
- **Permite** migração gradual sem quebrar funcionalidades

Esta abordagem se alinha perfeitamente com o objetivo de usar DAO para acesso direto e Repository para composição, mantendo a qualidade e organização do código existente.

---

**Data da Análise:** Janeiro 2025  
**Status:** Proposta de implementação  
**Próximos Passos:** Implementação da estrutura base e migração gradual
