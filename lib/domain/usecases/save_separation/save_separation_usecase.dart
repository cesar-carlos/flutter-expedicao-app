import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/usecases/save_separation/save_separation_params.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:data7_expedicao/domain/usecases/save_separation/save_separation_success.dart';
import 'package:data7_expedicao/domain/usecases/save_separation/save_separation_failure.dart';
import 'package:data7_expedicao/domain/models/separate_progress_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/models/separate_model.dart';
import 'package:data7_expedicao/core/errors/app_error.dart';

class SaveSeparationUseCase {
  final BasicConsultationRepository<SeparateProgressConsultationModel> _separateProgressRepository;
  final BasicRepository<ExpeditionCartRouteModel> _cartRouteRepository;
  final BasicRepository<SeparateModel> _separateRepository;

  SaveSeparationUseCase({
    required BasicConsultationRepository<SeparateProgressConsultationModel> separateProgressRepository,
    required BasicRepository<ExpeditionCartRouteModel> cartRouteRepository,
    required BasicRepository<SeparateModel> separateRepository,
  }) : _separateProgressRepository = separateProgressRepository,
       _cartRouteRepository = cartRouteRepository,
       _separateRepository = separateRepository;

  Future<Result<SaveSeparationSuccess>> call(SaveSeparationParams params) async {
    try {
      if (!params.isValid) {
        final errors = params.validationErrors;
        return failure(ValidationFailure.fromErrors(errors));
      }

      final separateModel = await _findSeparateModel(params);
      if (separateModel == null) {
        return failure(
          DataFailure.notFound(
            'Separação para CodEmpresa: ${params.codEmpresa}, CodSepararEstoque: ${params.codSepararEstoque}',
          ),
        );
      }

      if (separateModel.situacao.code != ExpeditionSituation.separando.code) {
        return failure(
          BusinessFailure.invalidState(
            'Separação deve estar com situação "SEPARANDO", mas está: ${separateModel.situacao.description}',
          ),
        );
      }

      final separateProgress = await _findSeparateProgress(params);
      if (separateProgress == null) {
        return failure(
          DataFailure.notFound(
            'Progresso da separação para CodEmpresa: ${params.codEmpresa}, CodSepararEstoque: ${params.codSepararEstoque}',
          ),
        );
      }

      final validationResult = _validateSeparationProgress(separateProgress);
      if (validationResult != null) {
        return failure(BusinessFailure.invalidState(validationResult.message));
      }

      final cartRoute = await _findCartRoute(params);
      if (cartRoute == null) {
        return failure(
          DataFailure.notFound(
            'Carrinho percurso para CodEmpresa: ${params.codEmpresa}, CodOrigem: ${params.codSepararEstoque}, Origem: ${ExpeditionOrigem.separacaoEstoque.code}',
          ),
        );
      }

      return await _executeTransactionalOperation(separateModel, cartRoute);
    } on DataError catch (e) {
      return failure(NetworkFailure(message: 'Erro de rede: ${e.message}'));
    } on Exception catch (e) {
      return failure(UnknownFailure.fromException(e));
    }
  }

  Future<SeparateModel?> _findSeparateModel(SaveSeparationParams params) async {
    try {
      final query = QueryBuilder()
        ..equals('CodEmpresa', params.codEmpresa)
        ..equals('CodSepararEstoque', params.codSepararEstoque);

      final separateModels = await _separateRepository.select(query);
      return separateModels.isNotEmpty ? separateModels.first : null;
    } catch (e) {
      rethrow;
    }
  }

  Future<SeparateProgressConsultationModel?> _findSeparateProgress(SaveSeparationParams params) async {
    try {
      final query = QueryBuilder()
        ..equals('CodEmpresa', params.codEmpresa)
        ..equals('CodSepararEstoque', params.codSepararEstoque);

      final separateProgresses = await _separateProgressRepository.selectConsultation(query);
      return separateProgresses.isNotEmpty ? separateProgresses.first : null;
    } catch (e) {
      rethrow;
    }
  }

  SaveSeparationFailure? _validateSeparationProgress(SeparateProgressConsultationModel separateProgress) {
    if (separateProgress.processoSeparacao.code != 'N') {
      return SaveSeparationFailure.processoSeparacaoNotN(separateProgress.processoSeparacao.code);
    }

    if (separateProgress.situacao != ExpeditionSituation.separando) {
      return SaveSeparationFailure.situacaoNotSeparando(separateProgress.situacao.description);
    }

    return null;
  }

  Future<ExpeditionCartRouteModel?> _findCartRoute(SaveSeparationParams params) async {
    try {
      final query = QueryBuilder()
        ..equals('CodEmpresa', params.codEmpresa)
        ..equals('CodOrigem', params.codSepararEstoque)
        ..equals('Origem', ExpeditionOrigem.separacaoEstoque.code);

      final cartRoutes = await _cartRouteRepository.select(query);
      return cartRoutes.isNotEmpty ? cartRoutes.first : null;
    } catch (e) {
      rethrow;
    }
  }

  Future<Result<SaveSeparationSuccess>> _executeTransactionalOperation(
    SeparateModel separateModel,
    ExpeditionCartRouteModel cartRoute,
  ) async {
    try {
      final updatedCartRoute = cartRoute.copyWith(situacao: ExpeditionCartSituation.separado);
      final updatedCartRoutes = await _cartRouteRepository.update(updatedCartRoute);

      if (updatedCartRoutes.isEmpty) {
        return failure(DataFailure(message: 'Falha ao atualizar situação do carrinho percurso'));
      }

      final updatedSeparateModel = separateModel.copyWith(situacao: ExpeditionSituation.separado);
      final updatedSeparateModels = await _separateRepository.update(updatedSeparateModel);

      if (updatedSeparateModels.isEmpty) {
        return failure(DataFailure(message: 'Falha ao atualizar situação da separação'));
      }

      return success(
        SaveSeparationSuccess.create(
          updatedCartRoute: updatedCartRoutes.first,
          message:
              'Separação salva com sucesso. Carrinho percurso ${cartRoute.codCarrinhoPercurso} e separação ${separateModel.codSepararEstoque} atualizados para SEPARADO.',
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}
