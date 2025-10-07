/// Exemplo demonstrando a correção do filtro inList
///
/// PROBLEMA IDENTIFICADO:
/// O método inList() não estava formatando corretamente os valores para o operador SQL IN.
///
/// ANTES:
/// - QueryBuilder.inList('Situacao', ['AGUARDANDO', 'SEPARANDO'])
/// - Gerava: Situacao IN ''AGUARDANDO','SEPARANDO'' (aspas duplas incorretas)
///
/// DEPOIS:
/// - QueryBuilder.inList('Situacao', ['AGUARDANDO', 'SEPARANDO'])
/// - Gera: Situacao IN ('AGUARDANDO','SEPARANDO') (formato SQL correto)
///
/// CORREÇÕES IMPLEMENTADAS:
///
/// 1. No QueryBuilder.inList():
///    - Adicionado parênteses ao redor dos valores: (valor1,valor2,valor3)
///    - Adicionado verificação para lista vazia
///    - Uso direto do QueryParam.createWithOperator para evitar formatação dupla
///
/// 2. No QueryParam._formatValue() e _formatSqlValue():
///    - Adicionada verificação para valores pré-formatados (com parênteses)
///    - Evita adicionar aspas extras quando o valor já está no formato correto
///
/// EXEMPLO DE USO:
library;

import 'package:exp/core/utils/app_logger.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';

void main() {
  // Exemplo 1: Filtro de situações
  final query1 = QueryBuilder()..inList('Situacao', ['AGUARDANDO', 'SEPARANDO', 'FINALIZADA']);

AppLogger.debug('Exemplo 1 - Filtro de Situações:', tag: 'QueryExample');
    AppLogger.debug('SQL WHERE: ${query1.buildSqlWhere()}', tag: 'QueryExample');
    AppLogger.debug('Esperado: Situacao IN (\'AGUARDANDO\',\'SEPARANDO\',\'FINALIZADA\')', tag: 'QueryExample');
    AppLogger.debug('', tag: 'QueryExample');

  // Exemplo 2: Filtro com lista vazia (não deve adicionar condição)
  final query2 = QueryBuilder()
    ..equals('Origem', 'VENDA')
    ..inList('Situacao', []); // Lista vazia

  AppLogger.debug('Exemplo 2 - Lista Vazia:', tag: 'QueryExample');
    AppLogger.debug('SQL WHERE: ${query2.buildSqlWhere()}', tag: 'QueryExample');
    AppLogger.debug('Esperado: Origem = \'VENDA\' (sem condição IN)', tag: 'QueryExample');
    AppLogger.debug('', tag: 'QueryExample');

  // Exemplo 3: Filtro combinado
  final query3 = QueryBuilder()
    ..equals('CodEmpresa', '1')
    ..inList('Situacao', ['AGUARDANDO', 'SEPARANDO'])
    ..orderByDesc('DataEmissao')
    ..paginate(limit: 20, offset: 0);

  AppLogger.debug('Exemplo 3 - Filtro Combinado:', tag: 'QueryExample');
    AppLogger.debug('SQL WHERE: ${query3.buildSqlWhere()}', tag: 'QueryExample');
    AppLogger.debug('ORDER BY: ${query3.buildOrderBySql()}', tag: 'QueryExample');
    AppLogger.debug('PAGINATION: ${query3.buildPagination()}', tag: 'QueryExample');
    AppLogger.debug('', tag: 'QueryExample');

  // Exemplo 4: Query completa para separações
  final query4 = QueryBuilder()
    ..equals('CodEmpresa', '1')
    ..inList('Situacao', ['AGUARDANDO', 'SEPARANDO', 'EM PAUSA'])
    ..greaterThan('CodSepararEstoque', '100000')
    ..orderByDesc('CodSepararEstoque')
    ..paginate(limit: 20, offset: 0, page: 1);

  AppLogger.debug('Exemplo 4 - Query Completa:', tag: 'QueryExample');
    AppLogger.debug('SQL WHERE: ${query4.buildSqlWhere()}', tag: 'QueryExample');
    AppLogger.debug('Complete Query: ${query4.buildCompleteQuery()}', tag: 'QueryExample');
}

/// IMPACTO DA CORREÇÃO:
/// 
/// - ✅ Filtro por situação agora funciona corretamente na tela de separação
/// - ✅ Suporte adequado para múltiplas situações selecionadas
/// - ✅ Query SQL gerada está no formato correto para o backend
/// - ✅ Compatível com outros filtros (origem, data, código, etc)
/// 
/// ARQUIVOS MODIFICADOS:
/// - lib/domain/models/pagination/query_builder.dart
/// - lib/domain/models/pagination/query_param.dart

