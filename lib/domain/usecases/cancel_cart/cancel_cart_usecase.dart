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
import 'package:data7_expedicao/data/services/user_session_service.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/core/errors/app_error.dart';

class CancelCartUseCase {
  final BasicRepository<ExpeditionCartModel> _cartRepository;
  final BasicRepository<ExpeditionCancellationModel> _cancellationRepository;
  final BasicRepository<ExpeditionCartRouteInternshipModel> _cartInternshipRouteRepository;
  final UserSessionService _userSessionService;

  CancelCartUseCase({
    required BasicRepository<ExpeditionCartModel> cartRepository,
    required BasicRepository<ExpeditionCancellationModel> cancellationRepository,
    required BasicRepository<ExpeditionCartRouteInternshipModel> cartInternshipRouteRepository,
    required UserSessionService userSessionService,
  }) : _cartRepository = cartRepository,
       _cancellationRepository = cancellationRepository,
       _cartInternshipRouteRepository = cartInternshipRouteRepository,
       _userSessionService = userSessionService;

  Future<Result<CancelCartSuccess>> call(CancelCartParams params) async {
    try {
      if (!params.isValid) {
        final errors = params.validationErrors;
        return failure(CancelCartFailure.invalidParams('Parâmetros inválidos: ${errors.join(', ')}'));
      }

      final cartInternshipRoute = await _findCartInternshipRoute(params: params);
      if (cartInternshipRoute == null) {
        return failure(CancelCartFailure.cartNotFound());
      }

      if (!_cancelCartInternshipRoute(cartInternshipRoute)) {
        return failure(
          CancelCartFailure.cartNotInSeparatingStatus(
            'Carrinho não pode ser cancelado. Status atual: ${cartInternshipRoute.situacao.description}',
          ),
        );
      }

      final appUser = await _userSessionService.loadUserSession();
      if (appUser?.userSystemModel == null) {
        return failure(CancelCartFailure.userNotFound());
      }

      final cancellation = await _createCancellation(
        cartInternshipRoute: cartInternshipRoute,
        userSystem: appUser!.userSystemModel!,
      );

      if (cancellation == null) {
        return failure(CancelCartFailure.cancellationFailed('Falha ao criar cancelamento'));
      }

      final updatedCartInternshipRoute = await _updateCartInternshipRouteStatus(
        cartInternshipRoute: cartInternshipRoute,
      );

      if (updatedCartInternshipRoute == null) {
        return failure(CancelCartFailure.updateFailed('Falha ao atualizar status do carrinho percurso'));
      }

      final cart = await _findCart(
        codEmpresa: updatedCartInternshipRoute.codEmpresa,
        codCarrinho: updatedCartInternshipRoute.codCarrinho,
      );
      final updatedCart = await _updateCartStatus(cart: cart!);
      if (updatedCart == null) {
        return failure(CancelCartFailure.updateFailed('Falha ao atualizar status do carrinho'));
      }

      return success(
        CancelCartSuccess.create(cancellation: cancellation, updatedCartInternshipRoute: updatedCartInternshipRoute),
      );
    } on DataError catch (e) {
      return failure(CancelCartFailure.networkError(e.message, Exception(e.message)));
    } on Exception catch (e) {
      return failure(CancelCartFailure.unknown(e.toString(), e));
    }
  }

  Future<ExpeditionCartRouteInternshipModel?> _findCartInternshipRoute({required CancelCartParams params}) async {
    try {
      final cartRouteInternship = await _cartInternshipRouteRepository.select(
        QueryBuilder()
            .equals('CodEmpresa', params.codEmpresa)
            .equals('CodCarrinhoPercurso', params.codCarrinhoPercurso)
            .equals('Item', params.item),
      );

      return cartRouteInternship.isNotEmpty ? cartRouteInternship.first : null;
    } catch (e) {
      rethrow;
    }
  }

  Future<ExpeditionCartModel?> _findCart({required int codEmpresa, required int codCarrinho}) async {
    try {
      final cart = await _cartRepository.select(
        QueryBuilder().equals('CodEmpresa', codEmpresa).equals('CodCarrinho', codCarrinho),
      );
      return cart.isNotEmpty ? cart.first : null;
    } catch (e) {
      rethrow;
    }
  }

  bool _cancelCartInternshipRoute(ExpeditionCartRouteInternshipModel cartInternshipRoute) {
    return cartInternshipRoute.situacao == ExpeditionSituation.separando;
  }

  Future<ExpeditionCancellationModel?> _createCancellation({
    required ExpeditionCartRouteInternshipModel cartInternshipRoute,
    required UserSystemModel userSystem,
  }) async {
    try {
      final now = DateTime.now();
      final horaCancelamento = AppHelper.formatTime(now);

      final cancellation = ExpeditionCancellationModel(
        codEmpresa: cartInternshipRoute.codEmpresa,
        codCancelamento: 0,
        origem: ExpeditionOrigem.carrinhoPercursoEstagio,
        codOrigem: cartInternshipRoute.codCarrinhoPercurso,
        itemOrigem: cartInternshipRoute.item,
        dataCancelamento: now,
        horaCancelamento: horaCancelamento,
        codUsuarioCancelamento: userSystem.codUsuario,
        nomeUsuarioCancelamento: userSystem.nomeUsuario,
        observacaoCancelamento: 'Cancelamento via app',
      );

      final results = await _cancellationRepository.insert(cancellation);
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      rethrow;
    }
  }

  Future<ExpeditionCartRouteInternshipModel?> _updateCartInternshipRouteStatus({
    required ExpeditionCartRouteInternshipModel cartInternshipRoute,
  }) async {
    try {
      final updatedCartInternshipRoute = cartInternshipRoute.copyWith(situacao: ExpeditionSituation.cancelada);
      await _cartInternshipRouteRepository.update(updatedCartInternshipRoute);
      return updatedCartInternshipRoute;
    } catch (e) {
      rethrow;
    }
  }

  Future<ExpeditionCartModel?> _updateCartStatus({required ExpeditionCartModel cart}) async {
    try {
      final updatedCart = cart.copyWith(situacao: ExpeditionCartSituation.liberado);
      await _cartRepository.update(updatedCart);
      return updatedCart;
    } catch (e) {
      rethrow;
    }
  }
}
