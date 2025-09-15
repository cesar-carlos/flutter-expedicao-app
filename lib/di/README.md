# Sistema de Injeção de Dependências (DI)

Este diretório contém o sistema de injeção de dependências da aplicação, centralizado através do GetIt.

## Arquivos

- **`locator.dart`**: Configuração principal do GetIt com todos os registros de dependências
- **`index.dart`**: Centralização de exports para facilitar imports em outros arquivos

## Como Usar

### Importação Simplificada

Em vez de importar múltiplos arquivos, você pode usar apenas:

```dart
import 'package:exp/di/index.dart';
```

Isso dará acesso a:

- `locator` - Instância global do GetIt
- `setupLocator()` - Função para configurar as dependências
- Todos os modelos refatorados
- Todos os repositórios
- Todos os serviços
- Todos os use cases
- Todos os view models

### Exemplo de Uso

```dart
import 'package:exp/di/index.dart';

void main() {
  // Configurar dependências
  setupLocator();

  // Usar dependências
  final userRepo = locator<UserRepository>();
  final configService = locator<ConfigService>();

  runApp(MyApp());
}
```

### Modelos Refatorados Disponíveis

- `ExpeditionCartRouteInternshipGroupConsultationModel`
- `ExpeditionCartRouteInternshipGroupModel`
- `ExpeditionCartRouteInternshipConsultationModel`

### Enums Disponíveis

- `ExpeditionOrigem`
- `ExpeditionItemSituation`
- `ExpeditionSituation`
- `ExpeditionCartSituation`

### Repositórios Registrados

- `BasicRepository<ExpeditionCartRouteInternshipGroupModel>`
- `BasicConsultationRepository<ExpeditionCartRouteInternshipGroupConsultationModel>`
- `BasicConsultationRepository<ExpeditionCartRouteInternshipConsultationModel>`

## Benefícios

1. **Centralização**: Todos os exports em um só lugar
2. **Facilidade**: Import único para acessar todo o sistema DI
3. **Organização**: Estrutura clara e documentada
4. **Manutenibilidade**: Fácil de manter e atualizar
