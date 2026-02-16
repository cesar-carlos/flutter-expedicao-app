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
import 'package:data7_expedicao/domain/usecases/check_separation_user_sector_completion/check_separation_user_sector_completion_usecase.dart';
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

  static const int _maxRetries = 3;

  static const String _fieldCodEmpresa = 'CodEmpresa';
  static const String _fieldCodUsuario = 'CodUsuario';
  static const String _fieldCodSetorEstoque = 'CodSetorEstoque';
  static const String _fieldSituacao = 'SepararEstoqueSituacao';
  static const String _fieldQuantidadeItensSetor = 'QuantidadeItensSetor';
  static const String _fieldQuantidadeItensSeparacaoSetor = 'QuantidadeItensSeparacaoSetor';
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

      if (separation == null) return success(NextSeparationUserSuccess.notFound());

      return success(NextSeparationUserSuccess.found(separation));
    } on DataError catch (e) {
      final msg = e.message.trim().toLowerCase();
      if (msg.contains('socket') && msg.contains('conectado')) {
        return failure(NextSeparationUserFailure.socketDisconnected());
      }
      if (msg.contains('fetch') || msg.contains('sql') || msg.contains('statement')) {
        return failure(NextSeparationUserFailure.serverError(e.message));
      }
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
    // PRIORIDADE 1: Buscar separação do usuário (no setor) com itens pendentes ou carrinhos abertos
    try {
      final existingSeparation = await _findExistingSeparationWithPendingItems(params);
      if (existingSeparation != null) return existingSeparation;
    } on DataError catch (e) {
      final msg = e.message.trim().toLowerCase();
      if (_isSqlError(msg)) {
        AppLogger.warning('Erro SQL ao buscar separação existente, tentando sem paginação: $msg');
        return await _findExistingSeparationWithPendingItemsNoPagination(params);
      }
      rethrow;
    }

    // PRIORIDADE 2: Buscar nova separação disponível (CodUsuario IS NULL)
    try {
      final newSeparation = await _findNewSeparation(params);
      if (newSeparation != null) {
        final registrationResult = await _registerUserSectorAssignment(params, newSeparation);
        if (registrationResult.isError()) {
          AppLogger.warning('Atribuição falhou, buscando próxima separação (tentativa 1/$_maxRetries)...');
          return await _findNextSeparationWithRetry(params, retryCount: 1);
        }
        return newSeparation.copyWith(codUsuario: params.codUsuario, nomeUsuario: params.userSystemModel?.nomeUsuario);
      }
      return newSeparation;
    } on DataError catch (e) {
      final msg = e.message.trim().toLowerCase();
      if (_isSqlError(msg)) {
        AppLogger.warning('Erro SQL ao buscar nova separação, tentando sem paginação: $msg');
        return await _findNewSeparationNoPagination(params);
      }
      rethrow;
    }
  }

  bool _isSqlError(String message) {
    return message.contains('fetch') ||
        message.contains('sql') ||
        message.contains('statement') ||
        message.contains('offset') ||
        message.contains('next');
  }

  static const int _queryLimitExisting = 100;
  static const int _queryLimitNew = 50;

  /// PRIORIDADE 1: Busca separação já atribuída ao usuário (no setor) com itens pendentes ou carrinhos abertos
  /// Critérios:
  /// - CodUsuario = usuário atual, CodSetorEstoque = setor do usuário
  /// - Situacao NOT IN (CANCELADA, SEPARADO, EM PAUSA, BLOQUEADA)
  /// - QuantidadeItensSetor > QuantidadeItensSeparacaoSetor OU CarrinhosAbertosUsuario = 'S'
  Future<SeparationUserSectorConsultationModel?> _findExistingSeparationWithPendingItems(
    NextSeparationUserParams params,
  ) async {
    final baseQuery = _buildBaseQuery(params);
    _addExcludedSituations(baseQuery);
    _addStandardOrderBy(baseQuery);
    baseQuery.paginate(limit: _queryLimitExisting, offset: 0, page: 1);

    final results = await _separationUserSectorConsultationRepository.selectConsultation(baseQuery);

    final separation = results.where(CheckSeparationUserSectorCompletionUseCase.hasPendingItems).firstOrNull;
    return separation;
  }

  Future<SeparationUserSectorConsultationModel?> _findNewSeparation(NextSeparationUserParams params) async {
    final query = QueryBuilder()
      ..equals(_fieldCodEmpresa, params.codEmpresa)
      ..equals(_fieldCodSetorEstoque, params.codSetorEstoque!)
      ..fieldGreaterThan(_fieldQuantidadeItensSetor, _fieldQuantidadeItensSeparacaoSetor)
      ..addParam(_fieldCodUsuario, null, operator: 'IS');

    _addExcludedSituations(query);
    _addStandardOrderBy(query);
    query.paginate(limit: _queryLimitNew, offset: 0, page: 1);

    return await _executeQuery(query);
  }

  /// Fallback sem paginação para erro SQL no servidor
  Future<SeparationUserSectorConsultationModel?> _findExistingSeparationWithPendingItemsNoPagination(
    NextSeparationUserParams params,
  ) async {
    final baseQuery = _buildBaseQuery(params);
    _addExcludedSituations(baseQuery);
    _addStandardOrderBy(baseQuery);
    // Não adiciona paginação

    final results = await _separationUserSectorConsultationRepository.selectConsultation(baseQuery);

    return results.where(CheckSeparationUserSectorCompletionUseCase.hasPendingItems).firstOrNull;
  }

  /// Fallback sem paginação para erro SQL no servidor
  Future<SeparationUserSectorConsultationModel?> _findNewSeparationNoPagination(NextSeparationUserParams params) async {
    final query = QueryBuilder()
      ..equals(_fieldCodEmpresa, params.codEmpresa)
      ..equals(_fieldCodSetorEstoque, params.codSetorEstoque!)
      ..fieldGreaterThan(_fieldQuantidadeItensSetor, _fieldQuantidadeItensSeparacaoSetor)
      ..addParam(_fieldCodUsuario, null, operator: 'IS');

    _addExcludedSituations(query);
    _addStandardOrderBy(query);
    // Não adiciona paginação

    return await _executeQuery(query);
  }

  Future<SeparationUserSectorConsultationModel?> _findNextSeparationWithRetry(
    NextSeparationUserParams params, {
    int retryCount = 0,
  }) async {
    if (retryCount >= _maxRetries) {
      AppLogger.warning('Máximo de tentativas ($_maxRetries) atingido ao buscar próxima separação');
      return null;
    }

    final newSeparation = await _findNewSeparation(params);
    if (newSeparation == null) return null;

    final registrationResult = await _registerUserSectorAssignment(params, newSeparation);
    if (registrationResult.isError()) {
      AppLogger.warning(
        'Atribuição falhou (tentativa ${retryCount + 1}/$_maxRetries), '
        'buscando próxima separação após delay...',
      );

      final delayMs = Duration(milliseconds: 100 * (retryCount + 1));
      await Future.delayed(delayMs);

      return await _findNextSeparationWithRetry(params, retryCount: retryCount + 1);
    }

    return newSeparation.copyWith(codUsuario: params.codUsuario, nomeUsuario: params.userSystemModel?.nomeUsuario);
  }

  QueryBuilder _buildBaseQuery(NextSeparationUserParams params) {
    final query = QueryBuilder()
      ..equals(_fieldCodEmpresa, params.codEmpresa)
      ..equals(_fieldCodUsuario, params.codUsuario);
    if (params.hasValidSector) {
      query.equals(_fieldCodSetorEstoque, params.codSetorEstoque!);
    }
    return query;
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
