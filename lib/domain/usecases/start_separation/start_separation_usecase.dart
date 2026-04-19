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
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';

class StartSeparationUseCase {
  final BasicRepository<SeparateModel> _separateRepository;
  final BasicRepository<ExpeditionCartRouteModel> _cartRouteRepository;
  final IUserSessionService _userSessionService;

  StartSeparationUseCase({
    required BasicRepository<SeparateModel> separateRepository,
    required BasicRepository<ExpeditionCartRouteModel> cartRouteRepository,
    required IUserSessionService userSessionService,
  }) : _separateRepository = separateRepository,
       _cartRouteRepository = cartRouteRepository,
       _userSessionService = userSessionService;

  Future<Result<StartSeparationSuccess>> call(StartSeparationParams params) async {
    try {
      if (!params.isValid) {
        final errors = params.validationErrors;
        return failure(StartSeparationFailure.invalidParams('Parâmetros inválidos: ${errors.join(', ')}'));
      }

      await _verifyUserSession();

      final separation = await _findSeparation(params);
      if (separation == null) {
        return failure(
          StartSeparationFailure.separationNotFound(params.codEmpresa, params.origem.code, params.codOrigem),
        );
      }

      if (separation.situacao != ExpeditionSituation.aguardando) {
        return failure(StartSeparationFailure.separationNotInAwaitingStatus(separation.situacaoDescription));
      }

      final existingCartRoute = await _findExistingCartRoute(params);
      if (existingCartRoute != null) {
        return failure(StartSeparationFailure.separationAlreadyStarted(existingCartRoute.codCarrinhoPercurso));
      }

      return await _executeTransactionalOperation(params, separation);
    } on DataError catch (e) {
      return failure(StartSeparationFailure.networkError(e.message, Exception(e.message)));
    } on Exception catch (e) {
      return failure(StartSeparationFailure.unknown(e.toString(), e));
    } catch (e) {
      // Bug J: catch generico para `Error`s (NullCheckOperator, etc.).
      return failure(StartSeparationFailure.unknown('Erro inesperado: $e', Exception(e.toString())));
    }
  }

  Future<void> _verifyUserSession() async {
    final appUser = await _userSessionService.loadUserSession();
    if (appUser?.userSystemModel == null) {
      throw Exception('Usuário não autenticado');
    }
  }

  Future<SeparateModel?> _findSeparation(StartSeparationParams params) async {
    try {
      final separations = await _separateRepository.select(
        QueryBuilder().equals('CodEmpresa', params.codEmpresa).equals('CodSepararEstoque', params.codOrigem),
      );

      return separations.isNotEmpty ? separations.first : null;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao buscar separação existente',
        tag: 'StartSeparationUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<ExpeditionCartRouteModel?> _findExistingCartRoute(StartSeparationParams params) async {
    try {
      final cartRoutes = await _cartRouteRepository.select(
        QueryBuilder()
            .equals('CodEmpresa', params.codEmpresa)
            .equals('Origem', params.origem.code)
            .equals('CodOrigem', params.codOrigem)
            .notEquals('Situacao', ExpeditionCartRouterSituation.cancelada.code),
      );

      return cartRoutes.isNotEmpty ? cartRoutes.first : null;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao buscar carrinho percurso existente',
        tag: 'StartSeparationUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<Result<StartSeparationSuccess>> _executeTransactionalOperation(
    StartSeparationParams params,
    SeparateModel separation,
  ) async {
    try {
      final newCartRoute = _createCartRoute(params);
      final createdCartRoutes = await _cartRouteRepository.insert(newCartRoute);

      if (createdCartRoutes.isEmpty) {
        return failure(StartSeparationFailure.insertCartRouteFailed('Falha ao inserir carrinho percurso'));
      }

      final updatedSeparation = separation.copyWith(situacao: ExpeditionSituation.separando);
      try {
        final updatedSeparations = await _separateRepository.update(updatedSeparation);

        if (updatedSeparations.isEmpty) {
          // Bug I: rollback do cartRoute inserido se update da separacao
          // falhar — sem isso, ficava uma rota orfa apontando para uma
          // separacao que ainda esta AGUARDANDO.
          await _rollbackCartRouteInsertion(createdCartRoutes.first);
          return failure(StartSeparationFailure.updateSeparateFailed('Falha ao atualizar situação da separação'));
        }

        return success(
          StartSeparationSuccess.create(
            createdCartRoute: createdCartRoutes.first,
            updatedSeparation: updatedSeparations.first,
          ),
        );
      } catch (e) {
        // Bug I: rollback se a segunda etapa lancar
        await _rollbackCartRouteInsertion(createdCartRoutes.first);
        rethrow;
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao executar operação transacional de início de separação',
        tag: 'StartSeparationUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Bug I: rollback best-effort — deleta a rota recém-inserida se a
  /// atualização da separação para SEPARANDO falhar. Erros silenciados
  /// (só logam) para não mascarar o erro original.
  Future<void> _rollbackCartRouteInsertion(ExpeditionCartRouteModel insertedRoute) async {
    try {
      await _cartRouteRepository.delete(insertedRoute);
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Falha no rollback da inserção de cartRoute durante startSeparation — estado pode estar inconsistente',
        tag: 'StartSeparationUseCase',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  ExpeditionCartRouteModel _createCartRoute(StartSeparationParams params) {
    final now = DateTime.now();

    return ExpeditionCartRouteModel(
      codEmpresa: params.codEmpresa,
      codCarrinhoPercurso: 0,
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
