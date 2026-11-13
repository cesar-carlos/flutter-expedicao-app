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
import 'package:data7_expedicao/domain/models/pagination/query_order_by.dart';
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
  static const String _fieldCodPrioridade = 'CodPrioridade';
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

      final separationResult = await _findNextSeparation(params);
      if (separationResult.failure != null) {
        return failure(separationResult.failure!);
      }
      if (separationResult.separation == null) {
        return success(NextSeparationUserSuccess.notFound());
      }
      return success(NextSeparationUserSuccess.found(separationResult.separation!));
    } on DataError catch (e) {
      final mapped = AppFailure.fromCaught(e);
      if (mapped is NetworkFailure) {
        final msg = e.message.trim().toLowerCase();
        if (msg.contains('socket') && msg.contains('conect')) {
          return failure(NextSeparationUserFailure.socketDisconnected());
        }
      }
      return failure(mapped);
    } on Exception catch (e) {
      return failure(NextSeparationUserFailure.unknown(e.toString(), e));
    } catch (e) {
      // Bug H: catch generico para `Error`s nao capturados por `on Exception`.
      return failure(NextSeparationUserFailure.unknown('Erro inesperado: $e', Exception(e.toString())));
    }
  }

  NextSeparationUserFailure? _validateParams(NextSeparationUserParams params) {
    if (!params.isValid) {
      final errors = params.validationErrors;
      return NextSeparationUserFailure.invalidParams(errors.join(', '));
    }

    if (!params.hasValidSector) return NextSeparationUserFailure.userWithoutSector();
    return null;
  }

  Future<_NextSeparationLookupResult> _findNextSeparation(NextSeparationUserParams params) async {
    final existingSeparation = await _findExistingSeparationWithPendingItems(params);
    if (existingSeparation != null) {
      return _NextSeparationLookupResult.found(existingSeparation);
    }

    return _findAndAssignNewSeparationPaged(params);
  }

  static const int _queryLimitExisting = 20;
  static const int _queryLimitNew = 20;

  /// PRIORIDADE 1: Busca separação já atribuída ao usuário (no setor) com itens pendentes ou carrinhos abertos
  /// Critérios:
  /// - CodUsuario = usuário atual, CodSetorEstoque = setor do usuário
  /// - Situacao NOT IN (CANCELADA, SEPARADO, EM PAUSA, BLOQUEADA)
  /// - QuantidadeItensSetor > QuantidadeItensSeparacaoSetor OU CarrinhosAbertosUsuario = 'S'
  Future<SeparationUserSectorConsultationModel?> _findExistingSeparationWithPendingItems(
    NextSeparationUserParams params,
  ) async {
    for (var pageIndex = 0; ; pageIndex++) {
      final query = _buildExistingSeparationQuery(params)
        ..paginate(limit: _queryLimitExisting, offset: pageIndex * _queryLimitExisting, page: pageIndex + 1);

      final results = await _separationUserSectorConsultationRepository.selectConsultation(query);
      final separation = results.where(CheckSeparationUserSectorCompletionUseCase.hasPendingItems).firstOrNull;
      if (separation != null) {
        return separation;
      }

      if (results.length < _queryLimitExisting) {
        return null;
      }
    }
  }

  Future<_NextSeparationLookupResult> _findAndAssignNewSeparationPaged(
    NextSeparationUserParams params, {
    int pageIndex = 0,
  }) async {
    var currentPageIndex = pageIndex;
    var assignmentAttempts = 0;
    AppFailure? lastAssignmentFailure;
    final attemptedSeparations = <String>{};

    while (assignmentAttempts < _maxRetries) {
      final query = _buildNewSeparationQuery(params)
        ..paginate(limit: _queryLimitNew, offset: currentPageIndex * _queryLimitNew, page: currentPageIndex + 1);
      final results = await _separationUserSectorConsultationRepository.selectConsultation(query);
      if (results.isEmpty) {
        break;
      }

      final candidates = results.where(_hasPendingSectorQuantity).toList();
      var processedCandidateOnPage = false;

      for (final candidate in candidates) {
        final candidateKey = _buildSeparationAttemptKey(candidate);
        if (!attemptedSeparations.add(candidateKey)) {
          continue;
        }

        processedCandidateOnPage = true;
        final registrationResult = await _registerUserSectorAssignment(params, candidate);
        if (registrationResult.isSuccess()) {
          return _NextSeparationLookupResult.found(_withAssignedUser(candidate, params));
        }

        assignmentAttempts++;
        final registrationFailure = registrationResult.exceptionOrNull();
        if (registrationFailure is AppFailure) {
          lastAssignmentFailure = registrationFailure;
        }

        AppLogger.warning(
          'Atribuição falhou para separação ${candidate.codSepararEstoque} '
          '(tentativa $assignmentAttempts/$_maxRetries)',
        );

        if (assignmentAttempts >= _maxRetries) {
          return _NextSeparationLookupResult.failure(
            _buildAssignmentFailure(lastAssignmentFailure, candidate, assignmentAttempts),
          );
        }
      }

      if (results.length < _queryLimitNew) {
        break;
      }

      if (!processedCandidateOnPage && candidates.isNotEmpty) {
        break;
      }

      currentPageIndex++;
    }

    if (lastAssignmentFailure != null) {
      return _NextSeparationLookupResult.failure(
        _buildAssignmentFailure(lastAssignmentFailure, null, assignmentAttempts),
      );
    }

    return const _NextSeparationLookupResult.notFound();
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

  QueryBuilder _buildExistingSeparationQuery(NextSeparationUserParams params) {
    final query = _buildBaseQuery(params);
    _addExcludedSituations(query);
    _addStandardOrderBy(query);
    return query;
  }

  QueryBuilder _buildNewSeparationQuery(NextSeparationUserParams params) {
    final query = QueryBuilder()
      ..equals(_fieldCodEmpresa, params.codEmpresa)
      ..equals(_fieldCodSetorEstoque, params.codSetorEstoque!)
      ..isNull(_fieldCodUsuario);

    _addExcludedSituations(query);
    _addStandardOrderBy(query);
    return query;
  }

  /// O servidor não compara coluna com coluna em `>`. A pendência do setor
  /// é aplicada depois da consulta, no mesmo critério de `hasPendingItems`.
  static bool _hasPendingSectorQuantity(SeparationUserSectorConsultationModel item) {
    return item.quantidadeItensSetor > item.quantidadeItensSeparacaoSetor;
  }

  void _addExcludedSituations(QueryBuilder query) {
    for (final situation in _excludedSituations) {
      query.notEquals(_fieldSituacao, situation);
    }
  }

  void _addStandardOrderBy(QueryBuilder query) {
    query
      ..orderBy(_fieldCodEmpresa, direction: OrderDirection.asc)
      ..orderBy(_fieldCodPrioridade, direction: OrderDirection.asc)
      ..orderBy(_fieldCodSepararEstoque, direction: OrderDirection.asc);
  }

  SeparationUserSectorConsultationModel _withAssignedUser(
    SeparationUserSectorConsultationModel separation,
    NextSeparationUserParams params,
  ) {
    return separation.copyWith(codUsuario: params.codUsuario, nomeUsuario: params.userSystemModel?.nomeUsuario);
  }

  String _buildSeparationAttemptKey(SeparationUserSectorConsultationModel separation) {
    return '${separation.codEmpresa}-${separation.codSetorEstoque}-${separation.codSepararEstoque}';
  }

  NextSeparationUserFailure _buildAssignmentFailure(
    AppFailure? failure,
    SeparationUserSectorConsultationModel? separation,
    int attempts,
  ) {
    final separationDetails = separation != null ? 'Separação ${separation.codSepararEstoque}' : 'separação disponível';
    final reason = failure?.userMessage ?? failure?.message ?? 'Falha ao registrar atribuição';
    final details =
        '$separationDetails não pôde ser atribuída após $attempts tentativa${attempts == 1 ? '' : 's'}. $reason';

    final exception = failure?.exception;
    return NextSeparationUserFailure.assignmentFailed(details, exception: exception is Exception ? exception : null);
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

class _NextSeparationLookupResult {
  const _NextSeparationLookupResult.found(SeparationUserSectorConsultationModel this.separation) : failure = null;

  const _NextSeparationLookupResult.notFound() : separation = null, failure = null;

  const _NextSeparationLookupResult.failure(NextSeparationUserFailure this.failure) : separation = null;

  final SeparationUserSectorConsultationModel? separation;
  final NextSeparationUserFailure? failure;
}
