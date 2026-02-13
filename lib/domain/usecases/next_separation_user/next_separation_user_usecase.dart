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
import 'package:data7_expedicao/domain/usecases/register_separation_user_sector/register_separation_user_sector_success.dart';
import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/core/utils/i_logger.dart';

class NextSeparationUserUseCase {
  final BasicConsultationRepository<SeparationUserSectorConsultationModel> _separationUserSectorConsultationRepository;
  final RegisterSeparationUserSectorUseCase Function() _getRegisterUseCase;
  final ILogger _logger;

  NextSeparationUserUseCase({
    required BasicConsultationRepository<SeparationUserSectorConsultationModel> separationUserSectorRepository,
    required RegisterSeparationUserSectorUseCase Function() getRegisterUseCase,
    required ILogger logger,
  }) : _separationUserSectorConsultationRepository = separationUserSectorRepository,
       _getRegisterUseCase = getRegisterUseCase,
       _logger = logger;

  static const String _blockedSituation = 'BLOQUEADA';

  static const String _cartOpenValue = 'S';

  static const String _fieldCodEmpresa = 'CodEmpresa';
  static const String _fieldCodUsuario = 'CodUsuario';
  static const String _fieldCodSetorEstoque = 'CodSetorEstoque';
  static const String _fieldSituacao = 'SepararEstoqueSituacao';
  static const String _fieldQuantidadeItensSetor = 'QuantidadeItensSetor';
  static const String _fieldQuantidadeItensSeparacaoSetor = 'QuantidadeItensSeparacaoSetor';
  static const String _fieldCarrinhosAbertos = 'CarrinhosAbertosUsuario';
  static const String _fieldPrioridade = 'Prioridade';
  static const String _fieldCodSepararEstoque = 'CodSepararEstoque';

  static final List<String> _excludedSituations = [
    ExpeditionSituation.cancelada.code,
    ExpeditionSituation.separado.code,
    ExpeditionSituation.emPausa.code,
    _blockedSituation,
  ];

  Future<Result<NextSeparationUserSuccess>> call(NextSeparationUserParams params) async {
    try {
      final validationError = _validateParams(params);
      if (validationError != null) {
        return failure(validationError);
      }

      final separation = await _findNextSeparation(params);

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

  Future<SeparationUserSectorConsultationModel?> _findNextSeparation(NextSeparationUserParams params) async {
    // PRIORIDADE 1: Buscar separação 100% completada pelo usuário atual
    // (todos itens do setor separados E todos carrinhos salvos)
    final completedSeparation = await _findCompletedSeparationByUser(params);
    if (completedSeparation != null) return completedSeparation;

    // PRIORIDADE 2: Buscar separação do usuário com itens pendentes no setor
    final existingSeparation = await _findExistingSeparationWithPendingItems(params);
    if (existingSeparation != null) return existingSeparation;

    // PRIORIDADE 3: Buscar nova separação disponível (CodUsuario IS NULL)
    final newSeparation = await _findNewSeparation(params);
    if (newSeparation != null) {
      final registrationResult = await _registerUserSectorAssignment(params, newSeparation);
      if (registrationResult.isError()) {
        // Tentar buscar outra separação em vez de desistir
        AppLogger.warning('Atribuição falhou, buscando próxima separação (tentativa 1/3)...');
        return await _findNextSeparationWithRetry(params, retryCount: 1);
      }
    }

    return newSeparation;
  }

  /// PRIORIDADE 1: Busca separação 100% completada pelo usuário atual
  /// Critérios:
  /// - Situacao = 'SEPARANDO'
  /// - CodUsuario = usuário atual
  /// - QuantidadeItensSetor = QuantidadeItensSeparacaoSetor (todos itens do setor separados)
  /// - CarrinhosAbertosUsuario != 'S' (todos carrinhos salvos)
  Future<SeparationUserSectorConsultationModel?> _findCompletedSeparationByUser(NextSeparationUserParams params) async {
    final baseQuery = _buildBaseQuery(params); // CodUsuario = usuário atual
    baseQuery
      ..equals(_fieldSituacao, ExpeditionSituation.separando.code)
      ..fieldEquals(_fieldQuantidadeItensSetor, _fieldQuantidadeItensSeparacaoSetor) // Setor 100% separado
      ..notEquals(_fieldCarrinhosAbertos, _cartOpenValue); // Sem carrinhos abertos

    _addStandardOrderBy(baseQuery);

    return await _executeQuery(baseQuery);
  }

  /// PRIORIDADE 2: Busca separação do usuário com itens pendentes no setor
  /// Critérios:
  /// - CodUsuario = usuário atual
  /// - Situacao NOT IN (CANCELADA, SEPARADO, EM PAUSA, BLOQUEADA)
  /// - QuantidadeItensSetor > QuantidadeItensSeparacaoSetor (ainda há itens no setor)
  Future<SeparationUserSectorConsultationModel?> _findExistingSeparationWithPendingItems(
    NextSeparationUserParams params,
  ) async {
    final baseQuery = _buildBaseQuery(params);
    _addExcludedSituations(baseQuery);

    final baseWhere = baseQuery.buildSqlWhere();
    final orCondition =
        '($_fieldQuantidadeItensSetor > $_fieldQuantidadeItensSeparacaoSetor '
        'OR $_fieldCarrinhosAbertos = \'$_cartOpenValue\')';
    final completeWhere = '$baseWhere AND $orCondition';

    return await _executeRawQuery(completeWhere);
  }

  Future<SeparationUserSectorConsultationModel?> _findNewSeparation(NextSeparationUserParams params) async {
    final baseQuery = QueryBuilder()
      ..equals(_fieldCodEmpresa, params.codEmpresa)
      ..equals(_fieldCodSetorEstoque, params.codSetorEstoque!)
      ..fieldGreaterThan(_fieldQuantidadeItensSetor, _fieldQuantidadeItensSeparacaoSetor);

    _addExcludedSituations(baseQuery);

    final baseWhere = baseQuery.buildSqlWhere();
    final completeWhere = '$baseWhere AND $_fieldCodUsuario IS NULL';

    return await _executeRawQuery(completeWhere);
  }

  /// Busca próxima separação com mecanismo de retry
  Future<SeparationUserSectorConsultationModel?> _findNextSeparationWithRetry(
    NextSeparationUserParams params, {
    int retryCount = 0,
    int maxRetries = 3,
  }) async {
    if (retryCount >= maxRetries) {
      AppLogger.warning('Máximo de tentativas ($maxRetries) atingido ao buscar próxima separação');
      return null;
    }

    final newSeparation = await _findNewSeparation(params);
    if (newSeparation == null) return null;

    final registrationResult = await _registerUserSectorAssignment(params, newSeparation);
    if (registrationResult.isError()) {
      AppLogger.warning(
        'Atribuição falhou (tentativa ${retryCount + 1}/$maxRetries), '
        'buscando próxima separação após delay...',
      );

      // Delay exponencial entre tentativas
      final delayMs = Duration(milliseconds: 100 * (retryCount + 1));
      await Future.delayed(delayMs);

      return await _findNextSeparationWithRetry(params, retryCount: retryCount + 1, maxRetries: maxRetries);
    }

    return newSeparation;
  }

  QueryBuilder _buildBaseQuery(NextSeparationUserParams params) {
    return QueryBuilder()
      ..equals(_fieldCodEmpresa, params.codEmpresa)
      ..equals(_fieldCodUsuario, params.codUsuario);
  }

  void _addExcludedSituations(QueryBuilder query) {
    for (final situation in _excludedSituations) {
      query.notEquals(_fieldSituacao, situation);
    }
  }

  void _addStandardOrderBy(QueryBuilder query) {
    query
      ..orderByAsc(_fieldCodEmpresa)
      ..orderByAsc(_fieldPrioridade)
      ..orderByAsc(_fieldCodSepararEstoque);
  }

  Future<SeparationUserSectorConsultationModel?> _executeQuery(QueryBuilder query) async {
    final results = await _separationUserSectorConsultationRepository.selectConsultation(query);
    return results.isNotEmpty ? results.first : null;
  }

  Future<SeparationUserSectorConsultationModel?> _executeRawQuery(String whereClause) async {
    final query = QueryBuilder()..addParam('where', whereClause, operator: 'RAW');
    _addStandardOrderBy(query);
    return await _executeQuery(query);
  }

  Future<Result<RegisterSeparationUserSectorSuccess>> _registerUserSectorAssignment(
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

      final registerUseCase = _getRegisterUseCase();
      final result = await registerUseCase(registerParams);

      if (result.isError()) {
        final failure = result.exceptionOrNull();
        _logger.error(
          'Falha ao registrar atribuição de usuario ${params.codUsuario} '
          'à separação ${separation.codSepararEstoque}: ${failure?.toString()}',
        );
        return result;
      }

      _logger.info(
        'Usuario ${params.codUsuario} (${params.userSystemModel!.nomeUsuario}) '
        'atribuído com sucesso à separação ${separation.codSepararEstoque}',
      );
      return result;
    } catch (e) {
      AppLogger.error('Erro inesperado ao registrar atribuição: $e');
      return failure(UnknownFailure.fromException(e));
    }
  }
}
