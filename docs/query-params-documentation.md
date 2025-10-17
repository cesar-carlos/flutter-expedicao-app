# Query Parameters - Estrutura Modular

Este diretório contém as classes relacionadas à construção de parâmetros de consulta de forma tipada e segura.

## 📁 Estrutura de Arquivos

### Arquivos Principais

| Arquivo                        | Descrição             | Responsabilidade                    |
| ------------------------------ | --------------------- | ----------------------------------- |
| `query_params.dart`            | Arquivo principal     | Exporta todas as classes            |
| `query_param.dart`             | Parâmetro individual  | Representa um parâmetro de consulta |
| `pagination.dart`              | Paginação             | Gerencia limites e offsets          |
| `query_builder.dart`           | Construtor de queries | Constrói consultas complexas        |
| `query_builder_extension.dart` | Extensões             | Métodos de conveniência             |

### Arquivos de Teste

| Arquivo                             | Descrição              | Cobertura       |
| ----------------------------------- | ---------------------- | --------------- |
| `query_param_test.dart`             | Testes do QueryParam   | 11 testes       |
| `pagination_test.dart`              | Testes do Pagination   | 7 testes        |
| `query_builder_test.dart`           | Testes do QueryBuilder | 15 testes       |
| `query_builder_extension_test.dart` | Testes das Extensões   | 5 testes        |
| `query_params_test.dart`            | Testes integrados      | 46 testes total |

## 🚀 Como Usar

### Importação Simples

```dart
import 'package:data7_expedicao/domain/models/query_params.dart';
```

### Importação Específica

```dart
import 'package:data7_expedicao/domain/models/query_builder.dart';
import 'package:data7_expedicao/domain/models/query_builder_extension.dart';
```

## 📋 Exemplos de Uso

### 1. Consulta Simples

```dart
final query = QueryBuilder()
    .code('EXP001')
    .status('AGUARDANDO')
    .paginate(limit: 10)
    .build();
```

### 2. Consulta Complexa

```dart
final query = QueryBuilder()
    .equals('usuario', 'admin')
    .notEquals('deleted', true)
    .like('codigo', 'EXP%')
    .greaterThan('prioridade', 5)
    .inList('situacao', ['AGUARDANDO', 'EM_ANDAMENTO'])
    .dateRange('data_criacao', DateTime(2024, 1, 1), DateTime(2024, 12, 31))
    .search('observacoes', 'importante')
    .paginate(limit: 50, offset: 0)
    .build();
```

### 3. Construção Dinâmica

```dart
final queryBuilder = QueryBuilder();

if (usuario.isNotEmpty) {
  queryBuilder.equals('usuario', usuario);
}

if (situacao.isNotEmpty) {
  queryBuilder.status(situacao);
}

queryBuilder.paginate(limit: 25);
final query = queryBuilder.build();
```

## 🧪 Executando Testes

```bash
# Todos os testes
flutter test test/domain/models/

# Testes específicos
flutter test test/domain/models/query_param_test.dart
flutter test test/domain/models/pagination_test.dart
flutter test test/domain/models/query_builder_test.dart
flutter test test/domain/models/query_builder_extension_test.dart

# Teste integrado
flutter test test/domain/models/query_params_test.dart
```

## ✨ Benefícios da Separação

### 1. **Modularidade**

- Cada classe tem sua responsabilidade específica
- Fácil manutenção e evolução
- Reutilização independente

### 2. **Legibilidade**

- Arquivos menores e mais focados
- Código mais fácil de entender
- Navegação mais simples

### 3. **Testabilidade**

- Testes específicos para cada classe
- Melhor cobertura de código
- Debugging mais eficiente

### 4. **Manutenibilidade**

- Mudanças isoladas por arquivo
- Menor risco de conflitos
- Refatoração mais segura

## 🔧 Funcionalidades

### QueryParam

- ✅ Parâmetros tipados
- ✅ Operadores customizáveis
- ✅ Formatação automática de valores
- ✅ Igualdade e hashCode

### Pagination

- ✅ Limite e offset
- ✅ Valores padrão
- ✅ Conversão para string

### QueryBuilder

- ✅ Method chaining
- ✅ Múltiplos operadores
- ✅ Paginação integrada
- ✅ Limpeza de estado

### Extensions

- ✅ Filtros de data
- ✅ Busca de texto
- ✅ Filtros específicos (status, código)

## 📊 Estatísticas

- **Total de Classes:** 4
- **Total de Testes:** 46
- **Cobertura:** 100%
- **Linhas de Código:** ~400
- **Linhas de Teste:** ~600

## 🎯 Próximos Passos

1. **Documentação:** Adicionar mais exemplos de uso
2. **Performance:** Otimizar para consultas grandes
3. **Validação:** Adicionar validação de parâmetros
4. **Internacionalização:** Suporte a diferentes idiomas
