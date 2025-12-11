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
    } catch (e) {
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
    } catch (e) {
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
      final updatedSeparations = await _separateRepository.update(updatedSeparation);

      if (updatedSeparations.isEmpty) {
        return failure(StartSeparationFailure.updateSeparateFailed('Falha ao atualizar situação da separação'));
      }

      return success(
        StartSeparationSuccess.create(
          createdCartRoute: createdCartRoutes.first,
          updatedSeparation: updatedSeparations.first,
        ),
      );
    } catch (e) {
      rethrow;
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
