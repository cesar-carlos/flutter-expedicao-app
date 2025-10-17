import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/usecases/next_separation_user/next_separation_user_params.dart';
import 'package:data7_expedicao/domain/usecases/next_separation_user/next_separation_user_success.dart';
import 'package:data7_expedicao/domain/usecases/next_separation_user/next_separation_user_failure.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/usecases/register_separation_user_sector/register_separation_user_sector_usecase.dart';
import 'package:data7_expedicao/domain/usecases/register_separation_user_sector/register_separation_user_sector_params.dart';
import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';

/// UseCase para buscar a próxima separação disponível para um usuário
///
/// Este use case busca separações em 3 etapas sequenciais:
/// 1. Separações finalizadas pelo usuário mas não salvas (SEPARANDO completo)
/// 2. Separações em andamento pelo usuário
/// 3. Novas separações disponíveis no setor do usuário
///
/// Quando uma nova separação é atribuída ao usuário (Query 3), registra a vinculação
/// na tabela de usuário/setor para rastreamento.
///
/// Retorna a primeira separação encontrada ou Success.notFound() se não houver
class NextSeparationUserUseCase {
  final BasicConsultationRepository<SeparationUserSectorConsultationModel> _separationUserSectorConsultationRepository;
  final RegisterSeparationUserSectorUseCase Function() _getRegisterUseCase;

  NextSeparationUserUseCase({
    required BasicConsultationRepository<SeparationUserSectorConsultationModel> separationUserSectorRepository,
    required RegisterSeparationUserSectorUseCase Function() getRegisterUseCase,
  }) : _separationUserSectorConsultationRepository = separationUserSectorRepository,
       _getRegisterUseCase = getRegisterUseCase;

  // === CONSTANTES ===

  /// Situação "BLOQUEADA" que não está no enum ExpeditionSituation
  static const String _blockedSituation = 'BLOQUEADA';

  /// Valor que indica carrinhos abertos
  static const String _cartOpenValue = 'S';

  /// Nomes dos campos para queries SQL
  static const String _fieldCodEmpresa = 'CodEmpresa';
  static const String _fieldCodUsuario = 'CodUsuario';
  static const String _fieldCodSetorEstoque = 'CodSetorEstoque';
  static const String _fieldSituacao = 'SepararEstoqueSituacao';
  static const String _fieldQuantidadeItens = 'QuantidadeItens';
  static const String _fieldQuantidadeItensSeparacao = 'QuantidadeItensSeparacao';
  static const String _fieldQuantidadeItensSetor = 'QuantidadeItensSetor';
  static const String _fieldQuantidadeItensSeparacaoSetor = 'QuantidadeItensSeparacaoSetor';
  static const String _fieldCarrinhosAbertos = 'CarrinhosAbertosUsuario';
  static const String _fieldPrioridade = 'Prioridade';
  static const String _fieldCodSepararEstoque = 'CodSepararEstoque';

  /// Situações que devem ser excluídas das buscas de separação ativa
  static final List<String> _excludedSituations = [
    ExpeditionSituation.cancelada.code,
    ExpeditionSituation.separado.code,
    ExpeditionSituation.emPausa.code,
    _blockedSituation,
  ];

  /// Busca a próxima separação disponível para o usuário
  ///
  /// [params] - Parâmetros contendo codUsuario, codEmpresa e codSetorEstoque
  ///
  /// Retorna [Result<NextSeparationUserSuccess>] com a separação encontrada ou mensagem de "não encontrado"
  Future<Result<NextSeparationUserSuccess>> call(NextSeparationUserParams params) async {
    try {
      // 1. Validar parâmetros
      final validationError = _validateParams(params);
      if (validationError != null) {
        return failure(validationError);
      }

      // 2. Buscar separação em ordem de prioridade
      final separation = await _findNextSeparation(params);

      // 3. Se não encontrou nenhuma separação
      if (separation == null) {
        return success(NextSeparationUserSuccess.notFound());
      }

      return success(NextSeparationUserSuccess.found(separation));
    } on DataError catch (e) {
      return failure(NextSeparationUserFailure.networkError(e.message, Exception(e.message)));
    } on Exception catch (e) {
      return failure(NextSeparationUserFailure.unknown(e.toString(), e));
    }
  }

  // === VALIDAÇÃO ===

  /// Valida os parâmetros de entrada
  NextSeparationUserFailure? _validateParams(NextSeparationUserParams params) {
    if (!params.isValid) {
      final errors = params.validationErrors;
      return NextSeparationUserFailure.invalidParams(errors.join(', '));
    }

    if (!params.hasValidSector) {
      return NextSeparationUserFailure.userWithoutSector();
    }

    return null;
  }

  // === LÓGICA PRINCIPAL ===

  /// Busca a próxima separação seguindo a ordem de prioridade
  ///
  /// 1. Separação finalizada mas não salva
  /// 2. Separação em andamento
  /// 3. Nova separação disponível (com registro de atribuição)
  Future<SeparationUserSectorConsultationModel?> _findNextSeparation(NextSeparationUserParams params) async {
    // Query 1: Separação que o usuário finalizou mas não salvou
    final pendingSeparation = await _findPendingCompletedSeparation(params);
    if (pendingSeparation != null) return pendingSeparation;

    // Query 2: Separação em andamento pelo usuário
    final existingSeparation = await _findExistingSeparation(params);
    if (existingSeparation != null) return existingSeparation;

    // Query 3: Nova separação disponível no setor
    final newSeparation = await _findNewSeparation(params);
    if (newSeparation != null) {
      // Registrar que o usuário pegou esta separação/setor usando o use case dedicado
      await _registerUserSectorAssignment(params, newSeparation);
    }

    return newSeparation;
  }

  // === QUERIES DE BUSCA ===

  /// Query 1: Busca separação que o usuário finalizou mas não salvou
  ///
  /// Condições:
  /// - SepararEstoqueSituacao = SEPARANDO
  /// - QuantidadeItens = QuantidadeItensSeparacao (todos itens separados)
  /// - CodUsuario = params.codUsuario
  Future<SeparationUserSectorConsultationModel?> _findPendingCompletedSeparation(
    NextSeparationUserParams params,
  ) async {
    final query = _buildBaseQuery(params)
      ..equals(_fieldSituacao, ExpeditionSituation.separando.code)
      ..fieldEquals(_fieldQuantidadeItens, _fieldQuantidadeItensSeparacao);

    _addStandardOrderBy(query);

    return await _executeQuery(query);
  }

  /// Query 2: Busca separação em andamento pelo usuário
  ///
  /// Condições:
  /// - SepararEstoqueSituacao NOT IN (CANCELADA, SEPARADO, PAUSADA, BLOQUEADA)
  /// - (QuantidadeItensSetor > QuantidadeItensSeparacaoSetor OR CarrinhosAbertosUsuario = 'S')
  /// - CodUsuario = params.codUsuario
  Future<SeparationUserSectorConsultationModel?> _findExistingSeparation(NextSeparationUserParams params) async {
    final baseQuery = _buildBaseQuery(params);
    _addExcludedSituations(baseQuery);

    // Condição com OR precisa ser adicionada como RAW ao WHERE existente
    // Usa parênteses para agrupar a condição OR corretamente
    final baseWhere = baseQuery.buildSqlWhere();
    final orCondition =
        '($_fieldQuantidadeItensSetor > $_fieldQuantidadeItensSeparacaoSetor '
        'OR $_fieldCarrinhosAbertos = \'$_cartOpenValue\')';
    final completeWhere = '$baseWhere AND $orCondition';

    return await _executeRawQuery(completeWhere);
  }

  /// Query 3: Busca nova separação disponível no setor
  ///
  /// Condições:
  /// - SepararEstoqueSituacao NOT IN (CANCELADA, SEPARADO, PAUSADA, BLOQUEADA)
  /// - QuantidadeItensSetor > QuantidadeItensSeparacaoSetor
  /// - CodSetorEstoque = params.codSetorEstoque
  /// - CodUsuario IS NULL
  Future<SeparationUserSectorConsultationModel?> _findNewSeparation(NextSeparationUserParams params) async {
    final baseQuery = QueryBuilder()
      ..equals(_fieldCodEmpresa, params.codEmpresa)
      ..equals(_fieldCodSetorEstoque, params.codSetorEstoque!)
      ..fieldGreaterThan(_fieldQuantidadeItensSetor, _fieldQuantidadeItensSeparacaoSetor);

    _addExcludedSituations(baseQuery);

    // Condição IS NULL precisa ser adicionada como RAW ao WHERE existente
    final baseWhere = baseQuery.buildSqlWhere();
    final completeWhere = '$baseWhere AND $_fieldCodUsuario IS NULL';

    return await _executeRawQuery(completeWhere);
  }

  // === MÉTODOS AUXILIARES DE QUERY ===

  /// Cria query base com CodEmpresa e CodUsuario
  QueryBuilder _buildBaseQuery(NextSeparationUserParams params) {
    return QueryBuilder()
      ..equals(_fieldCodEmpresa, params.codEmpresa)
      ..equals(_fieldCodUsuario, params.codUsuario);
  }

  /// Adiciona as situações que devem ser excluídas (NOT IN)
  void _addExcludedSituations(QueryBuilder query) {
    for (final situation in _excludedSituations) {
      query.notEquals(_fieldSituacao, situation);
    }
  }

  /// Adiciona a ordenação padrão (CodEmpresa, Prioridade, CodSepararEstoque)
  void _addStandardOrderBy(QueryBuilder query) {
    query
      ..orderByAsc(_fieldCodEmpresa)
      ..orderByAsc(_fieldPrioridade)
      ..orderByAsc(_fieldCodSepararEstoque);
  }

  /// Executa uma query e retorna o primeiro resultado ou null
  Future<SeparationUserSectorConsultationModel?> _executeQuery(QueryBuilder query) async {
    final results = await _separationUserSectorConsultationRepository.selectConsultation(query);
    return results.isNotEmpty ? results.first : null;
  }

  /// Executa uma query RAW e retorna o primeiro resultado ou null
  Future<SeparationUserSectorConsultationModel?> _executeRawQuery(String whereClause) async {
    final query = QueryBuilder()..addParam('where', whereClause, operator: 'RAW');
    _addStandardOrderBy(query);
    return await _executeQuery(query);
  }

  // === REGISTRO DE ATRIBUIÇÃO ===

  /// Registra a atribuição do usuário à separação/setor
  ///
  /// Delega o registro para o RegisterSeparationUserSectorUseCase.
  /// Em caso de erro, apenas registra no log mas não interrompe o fluxo,
  /// pois o importante é retornar a separação encontrada.
  Future<void> _registerUserSectorAssignment(
    NextSeparationUserParams params,
    SeparationUserSectorConsultationModel separation,
  ) async {
    try {
      final registerParams = RegisterSeparationUserSectorParams(
        codEmpresa: params.codEmpresa,
        codSepararEstoque: separation.codSepararEstoque,
        codSetorEstoque: separation.codSetorEstoque,
        codUsuario: params.codUsuario,
        nomeUsuario: params.userSystemModel!.nomeUsuario,
      );

      // Obter use case do locator (lazy loading)
      final registerUseCase = _getRegisterUseCase();
      await registerUseCase(registerParams);
    } catch (e) {
      // Logar erro mas não falhar o usecase
      AppLogger.error('Erro inesperado ao registrar atribuição: $e');
    }
  }
}
