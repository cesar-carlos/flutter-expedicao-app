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

  /// Cancela um carrinho
  ///
  /// [params] - Parâmetros para cancelamento
  ///
  /// Retorna [Result<CancelCartSuccess>] com sucesso ou falha
  Future<Result<CancelCartSuccess>> call(CancelCartParams params) async {
    try {
      // 1. Validar parâmetros
      if (!params.isValid) {
        final errors = params.validationErrors;
        return failure(CancelCartFailure.invalidParams('Parâmetros inválidos: ${errors.join(', ')}'));
      }

      // 2. Buscar carrinho
      final cartInternshipRoute = await _findCartInternshipRoute(params: params);
      if (cartInternshipRoute == null) {
        return failure(CancelCartFailure.cartNotFound());
      }

      // 3. Verificar se pode ser cancelado
      if (!_cancelCartInternshipRoute(cartInternshipRoute)) {
        return failure(
          CancelCartFailure.cartNotInSeparatingStatus(
            'Carrinho não pode ser cancelado. Status atual: ${cartInternshipRoute.situacao.description}',
          ),
        );
      }

      // 4. Obter usuário atual da sessão
      final appUser = await _userSessionService.loadUserSession();
      if (appUser?.userSystemModel == null) {
        return failure(CancelCartFailure.userNotFound());
      }

      // 5. Criar registro de cancelamento
      final cancellation = await _createCancellation(
        cartInternshipRoute: cartInternshipRoute,
        userSystem: appUser!.userSystemModel!,
      );

      // 6. Verificar se o cancelamento foi criado
      if (cancellation == null) {
        return failure(CancelCartFailure.cancellationFailed('Falha ao criar cancelamento'));
      }

      // 7. Atualizar status carrinho percurso
      final updatedCartInternshipRoute = await _updateCartInternshipRouteStatus(
        cartInternshipRoute: cartInternshipRoute,
      );

      if (updatedCartInternshipRoute == null) {
        return failure(CancelCartFailure.updateFailed('Falha ao atualizar status do carrinho percurso'));
      }

      // 8. Atualizar status do carrinho
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

  /// Busca o carrinho a ser cancelado
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

  ///busca o carrinho
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

  /// Verifica se o carrinho pode ser cancelado
  bool _cancelCartInternshipRoute(ExpeditionCartRouteInternshipModel cartInternshipRoute) {
    return cartInternshipRoute.situacao == ExpeditionSituation.separando;
  }

  /// Cria o registro de cancelamento
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

  /// Atualiza o status do carrinho percurso para CANCELADA
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

  /// Atualiza o status do carrinho para LIBERADO
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
