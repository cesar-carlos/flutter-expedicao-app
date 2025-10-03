import 'package:exp/core/results/index.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';
import 'package:exp/domain/models/expedition_cart_route_model.dart';
import 'package:exp/domain/models/situation/expedition_situation_model.dart';
import 'package:exp/domain/usecases/save_separation/save_separation_params.dart';
import 'package:exp/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:exp/domain/usecases/save_separation/save_separation_success.dart';
import 'package:exp/domain/usecases/save_separation/save_separation_failure.dart';
import 'package:exp/domain/models/separate_progress_consultation_model.dart';
import 'package:exp/domain/repositories/basic_consultation_repository.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/domain/repositories/basic_repository.dart';
import 'package:exp/domain/models/separate_model.dart';
import 'package:exp/core/errors/app_error.dart';

/// Use case para salvar separação
///
/// Este use case é responsável por:
/// - Validar parâmetros de entrada
/// - Consultar SeparateModel para validar se a separação está com situacao = 'SEPARANDO'
/// - Consultar SeparateProgressConsultationModel para validar processoSeparacao = 'N' e situacao = 'SEPARANDO'
/// - Consultar ExpeditionCartRouteModel por CodEmpresa, CodOrigem, Origem
/// - Validar se o resultado não é vazio
/// - Atualizar situacao do ExpeditionCartRouteModel para SEPARADO
/// - Atualizar situacao do SeparateModel para SEPARADO
class SaveSeparationUseCase {
  final BasicConsultationRepository<SeparateProgressConsultationModel> _separateProgressRepository;
  final BasicRepository<SeparateModel> _separateRepository;
  final BasicRepository<ExpeditionCartRouteModel> _cartRouteRepository;

  SaveSeparationUseCase({
    required BasicConsultationRepository<SeparateProgressConsultationModel> separateProgressRepository,
    required BasicRepository<SeparateModel> separateRepository,
    required BasicRepository<ExpeditionCartRouteModel> cartRouteRepository,
  }) : _separateProgressRepository = separateProgressRepository,
       _separateRepository = separateRepository,
       _cartRouteRepository = cartRouteRepository;

  /// Salva uma separação
  ///
  /// [params] - Parâmetros para salvar a separação
  ///
  /// Retorna [Result<SaveSeparationSuccess>] com sucesso ou falha
  Future<Result<SaveSeparationSuccess>> call(SaveSeparationParams params) async {
    try {
      // 1. Validar parâmetros
      if (!params.isValid) {
        final errors = params.validationErrors;
        return failure(ValidationFailure.fromErrors(errors));
      }

      // 2. Consultar SeparateModel para validar se a separação está com situacao = 'SEPARANDO'
      final separateModel = await _findSeparateModel(params);
      if (separateModel == null) {
        return failure(
          DataFailure.notFound(
            'Separação para CodEmpresa: ${params.codEmpresa}, CodSepararEstoque: ${params.codSepararEstoque}',
          ),
        );
      }

      // 3. Validar se a separação está com situacao = 'SEPARANDO'
      if (separateModel.situacao != ExpeditionSituation.separando) {
        return failure(
          BusinessFailure.invalidState(
            'Separação deve estar com situação "SEPARANDO", mas está: ${separateModel.situacao.description}',
          ),
        );
      }

      // 4. Consultar SeparateProgressConsultationModel
      final separateProgress = await _findSeparateProgress(params);
      if (separateProgress == null) {
        return failure(
          DataFailure.notFound(
            'Progresso da separação para CodEmpresa: ${params.codEmpresa}, CodSepararEstoque: ${params.codSepararEstoque}',
          ),
        );
      }

      // 5. Validar processoSeparacao = 'N' e situacao = 'SEPARANDO'
      final validationResult = _validateSeparationProgress(separateProgress);
      if (validationResult != null) {
        return failure(BusinessFailure.invalidState(validationResult.message));
      }

      // 6. Consultar ExpeditionCartRouteModel
      final cartRoute = await _findCartRoute(params);
      if (cartRoute == null) {
        return failure(
          DataFailure.notFound(
            'Carrinho percurso para CodEmpresa: ${params.codEmpresa}, CodOrigem: ${params.codSepararEstoque}, Origem: ${ExpeditionOrigem.separacaoEstoque.code}',
          ),
        );
      }

      // 7. Executar operação transacional: UPDATE carrinho percurso + UPDATE separação
      return await _executeTransactionalOperation(separateModel, cartRoute);
    } on DataError catch (e) {
      return failure(NetworkFailure(message: 'Erro de rede: ${e.message}'));
    } on Exception catch (e) {
      return failure(UnknownFailure.fromException(e));
    }
  }

  /// Busca a separação
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

  /// Busca o progresso da separação
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

  /// Valida o progresso da separação
  SaveSeparationFailure? _validateSeparationProgress(SeparateProgressConsultationModel separateProgress) {
    // Validar processoSeparacao = 'N'
    if (separateProgress.processoSeparacao.code != 'N') {
      return SaveSeparationFailure.processoSeparacaoNotN(separateProgress.processoSeparacao.code);
    }

    // Validar situacao = 'SEPARANDO'
    if (separateProgress.situacao != ExpeditionSituation.separando) {
      return SaveSeparationFailure.situacaoNotSeparando(separateProgress.situacao.description);
    }

    return null; // Validação passou
  }

  /// Busca o carrinho percurso
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

  /// Executa a operação transacional de UPDATE + UPDATE
  Future<Result<SaveSeparationSuccess>> _executeTransactionalOperation(
    SeparateModel separateModel,
    ExpeditionCartRouteModel cartRoute,
  ) async {
    try {
      // UPDATE 1: Atualizar situação do carrinho percurso para SEPARADO
      final updatedCartRoute = cartRoute.copyWith(situacao: ExpeditionCartSituation.separado);
      final updatedCartRoutes = await _cartRouteRepository.update(updatedCartRoute);

      if (updatedCartRoutes.isEmpty) {
        return failure(DataFailure(message: 'Falha ao atualizar situação do carrinho percurso'));
      }

      // UPDATE 2: Atualizar situação da separação para SEPARADO
      final updatedSeparateModel = separateModel.copyWith(situacao: ExpeditionSituation.separado);
      final updatedSeparateModels = await _separateRepository.update(updatedSeparateModel);

      if (updatedSeparateModels.isEmpty) {
        // ROLLBACK: Em caso de falha no UPDATE da separação, idealmente deveríamos desfazer o UPDATE do carrinho
        // Por limitação da arquitetura atual, apenas retornamos erro
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
