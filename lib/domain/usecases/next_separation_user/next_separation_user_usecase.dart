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

class NextSeparationUserUseCase {
  final BasicConsultationRepository<SeparationUserSectorConsultationModel> _separationUserSectorConsultationRepository;
  final RegisterSeparationUserSectorUseCase Function() _getRegisterUseCase;

  NextSeparationUserUseCase({
    required BasicConsultationRepository<SeparationUserSectorConsultationModel> separationUserSectorRepository,
    required RegisterSeparationUserSectorUseCase Function() getRegisterUseCase,
  }) : _separationUserSectorConsultationRepository = separationUserSectorRepository,
       _getRegisterUseCase = getRegisterUseCase;

  static const String _blockedSituation = 'BLOQUEADA';

  static const String _cartOpenValue = 'S';

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
    final pendingSeparation = await _findPendingCompletedSeparation(params);
    if (pendingSeparation != null) return pendingSeparation;

    final existingSeparation = await _findExistingSeparation(params);
    if (existingSeparation != null) return existingSeparation;

    final newSeparation = await _findNewSeparation(params);
    if (newSeparation != null) {
      await _registerUserSectorAssignment(params, newSeparation);
    }

    return newSeparation;
  }

  Future<SeparationUserSectorConsultationModel?> _findPendingCompletedSeparation(
    NextSeparationUserParams params,
  ) async {
    final query = _buildBaseQuery(params)
      ..equals(_fieldSituacao, ExpeditionSituation.separando.code)
      ..fieldEquals(_fieldQuantidadeItens, _fieldQuantidadeItensSeparacao);

    _addStandardOrderBy(query);

    return await _executeQuery(query);
  }

  Future<SeparationUserSectorConsultationModel?> _findExistingSeparation(NextSeparationUserParams params) async {
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

      final registerUseCase = _getRegisterUseCase();
      await registerUseCase(registerParams);
    } catch (e) {
      AppLogger.error('Erro inesperado ao registrar atribuição: $e');
    }
  }
}
