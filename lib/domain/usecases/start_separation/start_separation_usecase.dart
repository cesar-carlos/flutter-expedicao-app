import 'package:data7_expedicao/core/utils/app_helper.dart';
import 'package:data7_expedicao/domain/models/separate_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:data7_expedicao/domain/usecases/start_separation/start_separation_params.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_router_situation_model.dart';
import 'package:data7_expedicao/domain/usecases/start_separation/start_separation_success.dart';
import 'package:data7_expedicao/domain/usecases/start_separation/start_separation_failure.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/data/services/user_session_service.dart';
import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/results/index.dart';

/// Use case para iniciar uma separação de estoque
///
/// Este use case é responsável por:
/// - Validar parâmetros de entrada
/// - Buscar separação existente
/// - Verificar se não existe separação já em andamento
/// - Validar se a separação está aguardando
/// - Criar registro de carrinho percurso com situação EM SEPARACAO
/// - Atualizar situação da separação para SEPARANDO
class StartSeparationUseCase {
  final BasicRepository<SeparateModel> _separateRepository;
  final BasicRepository<ExpeditionCartRouteModel> _cartRouteRepository;
  final UserSessionService _userSessionService;

  StartSeparationUseCase({
    required BasicRepository<SeparateModel> separateRepository,
    required BasicRepository<ExpeditionCartRouteModel> cartRouteRepository,
    required UserSessionService userSessionService,
  }) : _separateRepository = separateRepository,
       _cartRouteRepository = cartRouteRepository,
       _userSessionService = userSessionService;

  /// Inicia uma separação
  ///
  /// [params] - Parâmetros para iniciar a separação
  ///
  /// Retorna [Result<StartSeparationSuccess>] com sucesso ou falha
  Future<Result<StartSeparationSuccess>> call(StartSeparationParams params) async {
    try {
      // 1. Validar parâmetros
      if (!params.isValid) {
        final errors = params.validationErrors;
        return failure(StartSeparationFailure.invalidParams('Parâmetros inválidos: ${errors.join(', ')}'));
      }

      // 2. Verificar usuário autenticado
      await _verifyUserSession();

      // 3. Buscar separação
      final separation = await _findSeparation(params);
      if (separation == null) {
        return failure(
          StartSeparationFailure.separationNotFound(params.codEmpresa, params.origem.code, params.codOrigem),
        );
      }

      // 4. Validar se a separação está com situação AGUARDANDO
      if (separation.situacao != ExpeditionSituation.aguardando) {
        return failure(StartSeparationFailure.separationNotInAwaitingStatus(separation.situacaoDescription));
      }

      // 5. Verificar se não existe separação já iniciada (não cancelada)
      final existingCartRoute = await _findExistingCartRoute(params);
      if (existingCartRoute != null) {
        return failure(StartSeparationFailure.separationAlreadyStarted(existingCartRoute.codCarrinhoPercurso));
      }

      // 6. Executar operação transacional: INSERT carrinho percurso + UPDATE separação
      return await _executeTransactionalOperation(params, separation);
    } on DataError catch (e) {
      return failure(StartSeparationFailure.networkError(e.message, Exception(e.message)));
    } on Exception catch (e) {
      return failure(StartSeparationFailure.unknown(e.toString(), e));
    }
  }

  /// Verifica se o usuário está autenticado
  Future<void> _verifyUserSession() async {
    final appUser = await _userSessionService.loadUserSession();
    if (appUser?.userSystemModel == null) {
      throw Exception('Usuário não autenticado');
    }
  }

  /// Busca a separação correspondente aos parâmetros
  Future<SeparateModel?> _findSeparation(StartSeparationParams params) async {
    try {
      final separations = await _separateRepository.select(
        QueryBuilder().equals('CodEmpresa', params.codEmpresa).equals('CodSepararEstoque', params.codOrigem),
      );

      return separations.isNotEmpty ? separations.first : null;
    } catch (e) {
      rethrow;
    }
  }

  /// Busca um carrinho percurso existente para a origem (que não esteja cancelado)
  Future<ExpeditionCartRouteModel?> _findExistingCartRoute(StartSeparationParams params) async {
    try {
      final cartRoutes = await _cartRouteRepository.select(
        QueryBuilder()
            .equals('CodEmpresa', params.codEmpresa)
            .equals('Origem', params.origem.code)
            .equals('CodOrigem', params.codOrigem)
            .notEquals('Situacao', ExpeditionCartRouterSituation.cancelada.code),
      );

      // Retorna apenas se existir um carrinho não cancelado
      // (assumindo que não há situação "CANCELADO" no ExpeditionCartSituation)
      return cartRoutes.isNotEmpty ? cartRoutes.first : null;
    } catch (e) {
      rethrow;
    }
  }

  /// Executa a operação transacional de INSERT + UPDATE
  Future<Result<StartSeparationSuccess>> _executeTransactionalOperation(
    StartSeparationParams params,
    SeparateModel separation,
  ) async {
    try {
      // INSERT: Criar e inserir novo carrinho percurso
      final newCartRoute = _createCartRoute(params);
      final createdCartRoutes = await _cartRouteRepository.insert(newCartRoute);

      if (createdCartRoutes.isEmpty) {
        return failure(StartSeparationFailure.insertCartRouteFailed('Falha ao inserir carrinho percurso'));
      }

      // UPDATE: Atualizar situação da separação para SEPARANDO
      final updatedSeparation = separation.copyWith(situacao: ExpeditionSituation.separando);
      final updatedSeparations = await _separateRepository.update(updatedSeparation);

      if (updatedSeparations.isEmpty) {
        // ROLLBACK: Em caso de falha no UPDATE, idealmente deveríamos desfazer o INSERT
        // Por limitação da arquitetura atual, apenas retornamos erro
        return failure(StartSeparationFailure.updateSeparateFailed('Falha ao atualizar situação da separação'));
      }

      return success(
        StartSeparationSuccess.create(
          createdCartRoute: createdCartRoutes.first,
          updatedSeparation: updatedSeparations.first,
        ),
      );
    } catch (e) {
      rethrow; // Permitir que o catch externo trate a exceção
    }
  }

  /// Cria um novo carrinho percurso
  ExpeditionCartRouteModel _createCartRoute(StartSeparationParams params) {
    final now = DateTime.now();

    return ExpeditionCartRouteModel(
      codEmpresa: params.codEmpresa,
      codCarrinhoPercurso: 0, // Será gerado pelo banco
      origem: params.origem,
      codOrigem: params.codOrigem,
      situacao: ExpeditionCartSituation.emSeparacao,
      dataInicio: now,
      horaInicio: AppHelper.formatTime(now),
      dataFinalizacao: null,
      horaFinalizacao: null,
    );
  }
}
