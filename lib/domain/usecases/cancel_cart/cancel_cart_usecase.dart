import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/utils/app_helper.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_failure.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_model.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_success.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_params.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cancellation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';

class CancelCartUseCase {
  final BasicRepository<ExpeditionCartModel> _cartRepository;
  final BasicRepository<ExpeditionCancellationModel> _cancellationRepository;
  final BasicRepository<ExpeditionCartRouteInternshipModel> _cartInternshipRouteRepository;
  final IUserSessionService _userSessionService;

  CancelCartUseCase({
    required BasicRepository<ExpeditionCartModel> cartRepository,
    required BasicRepository<ExpeditionCancellationModel> cancellationRepository,
    required BasicRepository<ExpeditionCartRouteInternshipModel> cartInternshipRouteRepository,
    required IUserSessionService userSessionService,
  }) : _cartRepository = cartRepository,
       _cancellationRepository = cancellationRepository,
       _cartInternshipRouteRepository = cartInternshipRouteRepository,
       _userSessionService = userSessionService;

  /// Confirma que o estágio existe, está `SEPARANDO` e o carrinho físico
  /// ainda pode ser localizado — sem gravar nada.
  Future<Result<ExpeditionCartRouteInternshipModel>> ensureCanCancel(CancelCartParams params) async {
    try {
      final prepared = await _prepare(params);
      if (prepared.isError()) {
        return Failure(prepared.exceptionOrNull()!);
      }
      return success(prepared.getOrNull()!.route);
    } on DataError catch (e) {
      return failure(AppFailure.fromCaught(e));
    } on Exception catch (e) {
      return failure(CancelCartFailure.unknown(e.toString(), e));
    } catch (e) {
      return failure(CancelCartFailure.unknown('Erro inesperado: $e', Exception(e.toString())));
    }
  }

  Future<Result<CancelCartSuccess>> call(CancelCartParams params) async {
    _CancelCartPrepared? prepared;
    ExpeditionCancellationModel? cancellation;
    try {
      final preparedResult = await _prepare(params);
      if (preparedResult.isError()) {
        return Failure(preparedResult.exceptionOrNull()!);
      }
      prepared = preparedResult.getOrNull()!;

      cancellation = await _createCancellation(cartInternshipRoute: prepared.route, userSystem: prepared.user);
      if (cancellation == null) {
        return failure(CancelCartFailure.cancellationFailed('Falha ao criar cancelamento'));
      }

      final updatedRoute = await _updateCartInternshipRouteStatus(prepared.route);
      if (updatedRoute == null) {
        await _rollback(originalRoute: prepared.route, originalCart: prepared.cart, cancellation: cancellation);
        return failure(CancelCartFailure.updateFailed('Falha ao atualizar status do carrinho percurso'));
      }

      final updatedCart = await _updateCartStatus(prepared.cart);
      if (updatedCart == null) {
        await _rollback(originalRoute: prepared.route, originalCart: prepared.cart, cancellation: cancellation);
        return failure(CancelCartFailure.updateFailed('Falha ao atualizar status do carrinho'));
      }

      return success(CancelCartSuccess.create(cancellation: cancellation, updatedCartInternshipRoute: updatedRoute));
    } on DataError catch (e) {
      await _rollbackAfterFailure(prepared: prepared, cancellation: cancellation);
      return failure(AppFailure.fromCaught(e));
    } on Exception catch (e) {
      await _rollbackAfterFailure(prepared: prepared, cancellation: cancellation);
      return failure(CancelCartFailure.unknown(e.toString(), e));
    } catch (e) {
      await _rollbackAfterFailure(prepared: prepared, cancellation: cancellation);
      return failure(CancelCartFailure.unknown('Erro inesperado: $e', Exception(e.toString())));
    }
  }

  Future<Result<_CancelCartPrepared>> _prepare(CancelCartParams params) async {
    if (!params.isValid) {
      final errors = params.validationErrors;
      return failure(CancelCartFailure.invalidParams('Parâmetros inválidos: ${errors.join(', ')}'));
    }

    final (route, user) = await (_findCartInternshipRoute(params), _userSessionService.loadUserSession()).wait;

    if (route == null) {
      return failure(CancelCartFailure.cartNotFound());
    }

    if (route.situacao != ExpeditionSituation.separando) {
      return failure(
        CancelCartFailure.cartNotInSeparatingStatus(
          'Carrinho não pode ser cancelado. Status atual: ${route.situacao.description}',
        ),
      );
    }

    if (user?.userSystemModel == null) {
      return failure(CancelCartFailure.userNotFound());
    }

    final cart = await _findCart(codEmpresa: route.codEmpresa, codCarrinho: route.codCarrinho);
    if (cart == null) {
      return failure(CancelCartFailure.cartNotFound());
    }

    return success(_CancelCartPrepared(route: route, cart: cart, user: user!.userSystemModel!));
  }

  Future<void> _rollbackAfterFailure({
    required _CancelCartPrepared? prepared,
    required ExpeditionCancellationModel? cancellation,
  }) async {
    if (prepared == null) {
      if (cancellation != null) {
        await _deleteCancellation(cancellation);
      }
      return;
    }
    await _rollback(originalRoute: prepared.route, originalCart: prepared.cart, cancellation: cancellation);
  }

  Future<void> _rollback({
    required ExpeditionCartRouteInternshipModel originalRoute,
    required ExpeditionCartModel originalCart,
    required ExpeditionCancellationModel? cancellation,
  }) async {
    await _restore('carrinho físico', () async {
      await _cartRepository.update(originalCart);
    });
    await _restore('rota do carrinho', () async {
      await _cartInternshipRouteRepository.update(originalRoute);
    });
    if (cancellation != null) {
      await _deleteCancellation(cancellation);
    }
  }

  Future<void> _deleteCancellation(ExpeditionCancellationModel cancellation) async {
    await _restore('cancelamento', () async {
      await _cancellationRepository.delete(cancellation);
    });
  }

  Future<void> _restore(String label, Future<void> Function() action) async {
    try {
      await action();
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Falha no rollback de $label durante cancelamento — estado pode estar inconsistente',
        tag: 'CancelCartUseCase',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<ExpeditionCartRouteInternshipModel?> _findCartInternshipRoute(CancelCartParams params) async {
    final cartRouteInternship = await _cartInternshipRouteRepository.select(
      QueryBuilder()
          .equals('CodEmpresa', params.codEmpresa)
          .equals('CodCarrinhoPercurso', params.codCarrinhoPercurso)
          .equals('Item', params.item),
    );
    return cartRouteInternship.isNotEmpty ? cartRouteInternship.first : null;
  }

  Future<ExpeditionCartModel?> _findCart({required int codEmpresa, required int codCarrinho}) async {
    final cart = await _cartRepository.select(
      QueryBuilder().equals('CodEmpresa', codEmpresa).equals('CodCarrinho', codCarrinho),
    );
    return cart.isNotEmpty ? cart.first : null;
  }

  Future<ExpeditionCancellationModel?> _createCancellation({
    required ExpeditionCartRouteInternshipModel cartInternshipRoute,
    required UserSystemModel userSystem,
  }) async {
    final now = DateTime.now();
    final cancellation = ExpeditionCancellationModel(
      codEmpresa: cartInternshipRoute.codEmpresa,
      codCancelamento: 0,
      origem: ExpeditionOrigem.carrinhoPercursoEstagio,
      codOrigem: cartInternshipRoute.codCarrinhoPercurso,
      itemOrigem: cartInternshipRoute.item,
      dataCancelamento: now,
      horaCancelamento: AppHelper.formatTime(now),
      codUsuarioCancelamento: userSystem.codUsuario,
      nomeUsuarioCancelamento: userSystem.nomeUsuario,
      observacaoCancelamento: 'Cancelamento via app',
    );

    final results = await _cancellationRepository.insert(cancellation);
    return results.isNotEmpty ? results.first : null;
  }

  Future<ExpeditionCartRouteInternshipModel?> _updateCartInternshipRouteStatus(
    ExpeditionCartRouteInternshipModel cartInternshipRoute,
  ) async {
    final updatedCartInternshipRoute = cartInternshipRoute.copyWith(situacao: ExpeditionSituation.cancelada);
    final results = await _cartInternshipRouteRepository.update(updatedCartInternshipRoute);
    return results.isNotEmpty ? results.first : null;
  }

  Future<ExpeditionCartModel?> _updateCartStatus(ExpeditionCartModel cart) async {
    final updatedCart = cart.copyWith(situacao: ExpeditionCartSituation.liberado);
    final results = await _cartRepository.update(updatedCart);
    return results.isNotEmpty ? results.first : null;
  }
}

class _CancelCartPrepared {
  final ExpeditionCartRouteInternshipModel route;
  final ExpeditionCartModel cart;
  final UserSystemModel user;

  const _CancelCartPrepared({required this.route, required this.cart, required this.user});
}
