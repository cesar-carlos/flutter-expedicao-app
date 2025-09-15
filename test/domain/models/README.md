# Testes do QueryBuilder

Este diretório contém os testes unitários para a classe `QueryBuilder`, que é responsável por construir consultas complexas com parâmetros, paginação e ordenação.

## Arquivo de Teste

- `query_builder_test.dart` - Testes completos para a classe QueryBuilder

## Cobertura de Testes

Os testes cobrem todas as funcionalidades principais do QueryBuilder:

### 1. Operações Básicas de Parâmetros

- ✅ Adição de parâmetros com operador padrão (`=`)
- ✅ Adição de parâmetros com operador customizado
- ✅ Encadeamento de múltiplas adições de parâmetros
- ✅ Retorno da instância para method chaining

### 2. Métodos de Operadores Específicos

- ✅ `equals()` - operador de igualdade (`=`)
- ✅ `notEquals()` - operador de diferença (`!=`)
- ✅ `like()` - operador LIKE para busca de texto
- ✅ `greaterThan()` - operador maior que (`>`)
- ✅ `lessThan()` - operador menor que (`<`)
- ✅ `inList()` - operador IN para listas de valores

### 3. Funcionalidades de Paginação

- ✅ Adição de paginação com valores padrão
- ✅ Adição de paginação com valores customizados
- ✅ Encadeamento de métodos de paginação

### 4. Funcionalidades de Ordenação

- ✅ `orderBy()` com direção padrão (ASC)
- ✅ `orderBy()` com direção customizada (DESC)
- ✅ `orderByAsc()` para ordenação ascendente
- ✅ `orderByDesc()` para ordenação descendente
- ✅ `orderByMultiple()` para múltiplas ordenações
- ✅ Encadeamento de múltiplas operações de ordenação

### 5. Construção de Queries

- ✅ `buildQuery()` - construção de string de parâmetros
- ✅ `buildPagination()` - construção de string de paginação
- ✅ `buildOrderBySql()` - construção de ORDER BY para SQL
- ✅ `buildOrderByQuery()` - construção de ORDER BY para query parameters
- ✅ `buildCompleteQuery()` - construção de query completa

### 6. Getters e Propriedades

- ✅ Lista de parâmetros imutável
- ✅ Objeto de paginação quando definido
- ✅ Null quando paginação não definida
- ✅ Lista de cláusulas ORDER BY imutável

### 7. Operações de Limpeza

- ✅ `clear()` - limpeza de todos os componentes
- ✅ Adição de parâmetros após limpeza

### 8. Formatação de Valores

- ✅ Strings com aspas simples
- ✅ DateTime com formato ISO
- ✅ Números sem aspas
- ✅ Booleanos sem aspas

### 9. Representação String

- ✅ `toString()` com contadores descritivos
- ✅ `toString()` com contadores zerados

### 10. Casos Extremos e Validações

- ✅ Valores null em parâmetros
- ✅ Strings vazias
- ✅ Caracteres especiais em strings
- ✅ Strings muito longas
- ✅ Números negativos
- ✅ Valores zero
- ✅ Números grandes

### 11. Cenários Complexos

- ✅ Query complexa com todas as funcionalidades
- ✅ Múltiplos parâmetros com mesma chave
- ✅ Múltiplas ordenações com mesmo campo

## Executando os Testes

Para executar os testes do QueryBuilder:

```bash
flutter test test/domain/models/query_builder_test.dart
```

Para executar todos os testes:

```bash
flutter test
```

## Estatísticas dos Testes

- **Total de testes**: 56
- **Cobertura**: 100% das funcionalidades públicas
- **Status**: ✅ Todos os testes passando

## Estrutura dos Testes

Os testes estão organizados em grupos lógicos usando `group()`:

1. **Basic Parameter Operations** - Operações básicas de parâmetros
2. **Specific Operator Methods** - Métodos de operadores específicos
3. **Pagination** - Funcionalidades de paginação
4. **Order By Operations** - Operações de ordenação
5. **Query Building** - Construção de queries
6. **Getters and Properties** - Getters e propriedades
7. **Clear Operations** - Operações de limpeza
8. **Value Formatting** - Formatação de valores
9. **ToString** - Representação string
10. **Edge Cases and Validation** - Casos extremos e validações
11. **Complex Scenarios** - Cenários complexos

Cada grupo contém múltiplos testes que verificam diferentes aspectos da funcionalidade, garantindo uma cobertura completa e robusta da classe QueryBuilder.
