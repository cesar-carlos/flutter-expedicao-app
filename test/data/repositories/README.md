# Testes de Integração - Repositórios

Este diretório contém os testes de integração para os repositórios do sistema.

## Estrutura

- `separate_repository_integration_test.dart` - Testes para SeparateRepositoryImpl
- `separate_item_repository_integration_test.dart` - Testes para SeparateItemRepositoryImpl
- `separation_item_repository_integration_test.dart` - Testes para SeparationItemRepositoryImpl
- `user_system_repository_integration_test.dart` - Testes para UserSystemRepositoryImpl

## Pré-requisitos

Para executar os testes de integração, você precisa:

1. **Servidor de desenvolvimento rodando** na porta 3001
2. **Socket.IO configurado** e funcionando
3. **Banco de dados** com dados de teste

## Como Executar

### Executar todos os testes de integração:
```bash
flutter test test/data/repositories/
```

### Executar um teste específico:
```bash
flutter test test/data/repositories/user_system_repository_integration_test.dart
```

### Executar com verbose para ver logs detalhados:
```bash
flutter test test/data/repositories/ --verbose
```

## Configuração do Ambiente de Teste

Os testes usam a seguinte configuração padrão:

```dart
ApiConfig(
  apiUrl: 'localhost',
  apiPort: 3001,
  useHttps: false,
  lastUpdated: DateTime.now(),
)
```

## Testes Disponíveis

### UserSystemRepositoryImpl

- **getUserById**: Testa busca de usuário por ID
- **getUserSystemInfo**: Testa retorno de informações como Map
- **getUsers**: Testa listagem com paginação e filtros
- **searchUsersByName**: Testa busca por nome
- **Error Handling**: Testa tratamento de erros e timeouts

### Padrões dos Testes

1. **setUpAll**: Configura conexão Socket.IO
2. **setUp**: Inicializa repositório
3. **tearDownAll**: Desconecta Socket.IO
4. **Timeout**: 2 minutos para operações de rede
5. **Validações**: Verificam tipos, valores e estruturas de dados

## Dados de Teste

Os testes usam dados mockados que são criados dinamicamente com timestamps únicos para evitar conflitos.

## Troubleshooting

### Erro de Conexão
Se os testes falharem com erro de conexão, verifique:
- Servidor rodando na porta 3001
- Socket.IO configurado corretamente
- Firewall não bloqueando a conexão

### Timeout
Se os testes falharem por timeout:
- Verifique a latência da rede
- Aumente o timeout nos testes se necessário
- Verifique se o servidor está respondendo rapidamente

### Dados Inconsistentes
Se os testes falharem por dados inconsistentes:
- Verifique se o banco de dados tem dados de teste
- Limpe dados antigos se necessário
- Verifique se os IDs de teste existem no sistema
