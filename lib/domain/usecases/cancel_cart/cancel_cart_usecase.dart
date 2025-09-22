import 'package:exp/core/utils/app_helper.dart';

import 'package:exp/domain/models/user_system_models.dart';
import 'package:exp/domain/models/expedition_cart_model.dart';
import 'package:exp/domain/repositories/basic_repository.dart';
import 'package:exp/domain/usecases/cancel_cart/cancel_cart_result.dart';
import 'package:exp/domain/usecases/cancel_cart/cancel_cart_success.dart';
import 'package:exp/domain/usecases/cancel_cart/cancel_cart_failure.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_model.dart';
import 'package:exp/domain/usecases/cancel_cart/cancel_cart_params.dart';
import 'package:exp/domain/models/expedition_cart_situation_model.dart';
import 'package:exp/domain/models/expedition_cancellation_model.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/data/services/user_session_service.dart';
import 'package:exp/core/errors/app_error.dart';

/// Use case para cancelar um carrinho
///
/// Este use case é responsável por:
/// - Validar parâmetros de entrada
/// - Buscar o carrinho a ser cancelado
/// - Verificar se o carrinho pode ser cancelado
/// - Criar registro de cancelamento
/// - Atualizar status do carrinho para CANCELADA
class CancelCartUseCase {
  final BasicRepository<ExpeditionCartModel> _cartRepository;
  final BasicRepository<ExpeditionCancellationModel> _cancellationRepository;
  final BasicRepository<ExpeditionCartRouteInternshipModel> _cartRouteRepository;
  final UserSessionService _userSessionService;

  CancelCartUseCase({
    required BasicRepository<ExpeditionCartModel> cartRepository,
    required BasicRepository<ExpeditionCancellationModel> cancellationRepository,
    required BasicRepository<ExpeditionCartRouteInternshipModel> cartRouteRepository,
    required UserSessionService userSessionService,
  }) : _cartRepository = cartRepository,
       _cancellationRepository = cancellationRepository,
       _cartRouteRepository = cartRouteRepository,
       _userSessionService = userSessionService;

  /// Cancela um carrinho
  ///
  /// [params] - Parâmetros para cancelamento
  ///
  /// Retorna [CancelCartResult] com sucesso ou falha
  Future<CancelCartResult> call(CancelCartParams params) async {
    try {
      // 1. Validar parâmetros
      if (!params.isValid) {
        final errors = params.validationErrors;
        return CancelCartFailure.invalidParams('Parâmetros inválidos: ${errors.join(', ')}');
      }

      // 2. Buscar carrinho
      final cartRoute = await _findCartRoute(params: params);
      if (cartRoute == null) {
        return CancelCartFailure.cartNotFound();
      }

      // 3. Verificar se pode ser cancelado
      if (!_canCancelCart(cartRoute)) {
        return CancelCartFailure.cartNotInSeparatingStatus(
          'Carrinho não pode ser cancelado. Status atual: ${cartRoute.situacao.description}',
        );
      }

      // 4. Obter usuário atual da sessão
      final appUser = await _userSessionService.loadUserSession();
      if (appUser?.userSystemModel == null) {
        return CancelCartFailure.userNotFound();
      }

      // 5. Criar registro de cancelamento
      final cancellation = await _createCancellation(cartRoute: cartRoute, userSystem: appUser!.userSystemModel!);
      if (cancellation == null) {
        return CancelCartFailure.cancellationFailed('Falha ao criar cancelamento');
      }

      // 5. Atualizar status carrinho percurso
      final updatedCartRoute = await _updateCartRouteStatus(cartRoute: cartRoute);
      if (updatedCartRoute == null) {
        return CancelCartFailure.updateFailed('Falha ao atualizar status do carrinho');
      }

      // 6. Atualizar status do carrinho
      final cart = await _findCart(codEmpresa: params.codEmpresa, codCarrinho: params.codCarrinho);
      final updatedCart = await _updateCartStatus(cart: cart!);
      if (updatedCart == null) {
        return CancelCartFailure.updateFailed('Falha ao atualizar status do carrinho');
      }

      return CancelCartSuccess.create(cancellation: cancellation, updatedCartRoute: updatedCartRoute);
    } on DataError catch (e) {
      return CancelCartFailure.networkError(e.message, Exception(e.message));
    } on Exception catch (e) {
      return CancelCartFailure.unknown(e.toString(), e);
    }
  }

  /// Busca o carrinho a ser cancelado
  Future<ExpeditionCartRouteInternshipModel?> _findCartRoute({required CancelCartParams params}) async {
    try {
      final cartRoute = await _cartRouteRepository.select(
        QueryBuilder()
            .equals('CodEmpresa', params.codEmpresa)
            .equals('CodOrigem', params.codOrigem)
            .equals('CodCarrinho', params.codCarrinho)
            .equals('Origem', params.origem.code)
            .notEquals('Situacao', ExpeditionCartSituation.cancelada.code),
      );

      return cartRoute.isNotEmpty ? cartRoute.first : null;
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
  bool _canCancelCart(ExpeditionCartRouteInternshipModel cartRoute) {
    // Só pode cancelar carrinhos em status de separação
    return cartRoute.situacao == ExpeditionCartSituation.separando ||
        cartRoute.situacao == ExpeditionCartSituation.emSeparacao;
  }

  /// Cria o registro de cancelamento
  Future<ExpeditionCancellationModel?> _createCancellation({
    required ExpeditionCartRouteInternshipModel cartRoute,
    required UserSystemModel userSystem,
  }) async {
    try {
      final now = DateTime.now();
      final horaCancelamento = AppHelper.formatTime(now);

      final cancellation = ExpeditionCancellationModel(
        codEmpresa: cartRoute.codEmpresa,
        codCancelamento: 0,
        origem: cartRoute.origem,
        codOrigem: cartRoute.codOrigem,
        itemOrigem: cartRoute.codCarrinho.toString(),
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
  Future<ExpeditionCartRouteInternshipModel?> _updateCartRouteStatus({
    required ExpeditionCartRouteInternshipModel cartRoute,
  }) async {
    try {
      final updatedCartRoute = cartRoute.copyWith(situacao: ExpeditionCartSituation.cancelada);
      await _cartRouteRepository.update(updatedCartRoute);
      return updatedCartRoute;
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

  /// Verifica se um carrinho pode ser cancelado (método público)
  Future<bool> canCancelCart(CancelCartParams params) async {
    try {
      if (!params.isValid) return false;
      final cartRoute = await _findCartRoute(params: params);
      return cartRoute != null && _canCancelCart(cartRoute);
    } catch (e) {
      return false;
    }
  }
}
