import 'dart:developer' as developer;

import 'package:data7_expedicao/domain/models/event_model/basic_event_model.dart';
import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/separate_cart_internship_event_repository.dart';

/// Controller responsável por escutar eventos remotos do carrinho
/// (mudanças de status, etc.) e propagar atualizações relevantes.
///
/// Extraído de [CardPickingViewModel] (refator F2) para isolar a
/// integração com `SeparateCartInternshipEventRepository` e simplificar
/// testes (callbacks puros, sem dependência de ChangeNotifier).
///
/// Uso:
/// ```dart
/// final ctrl = CartEventListenerController(
///   eventRepository: locator<SeparateCartInternshipEventRepository>(),
///   onCartUpdated: (cart) => _handleCartUpdate(cart),
///   onProcessingError: (msg) => _setError(msg),
/// );
/// ctrl.start(currentCart);
/// // ... durante a vida da tela
/// ctrl.stop();
/// ```
class CartEventListenerController {
  static const String _cartUpdateListenerId = 'card_picking_viewmodel_cart_update';

  final SeparateCartInternshipEventRepository _eventRepository;
  final void Function(ExpeditionCartRouteInternshipConsultationModel cart) _onCartUpdated;
  final void Function(String message)? _onProcessingError;

  ExpeditionCartRouteInternshipConsultationModel? _currentCart;
  bool _registered = false;
  bool _disposed = false;

  CartEventListenerController({
    required SeparateCartInternshipEventRepository eventRepository,
    required void Function(ExpeditionCartRouteInternshipConsultationModel cart) onCartUpdated,
    void Function(String message)? onProcessingError,
  })  : _eventRepository = eventRepository,
        _onCartUpdated = onCartUpdated,
        _onProcessingError = onProcessingError;

  bool get isListening => _registered;

  /// Inicia a escuta de eventos para o `cart` informado.
  /// Chame `stop()` antes de trocar de cart.
  void start(ExpeditionCartRouteInternshipConsultationModel cart) {
    if (_disposed || _registered) return;
    _currentCart = cart;
    try {
      _eventRepository.addListener(
        EventListenerModel(
          id: _cartUpdateListenerId,
          event: Event.update,
          callback: _onEvent,
          allEvent: false,
        ),
      );
      _registered = true;
    } catch (e) {
      developer.log('Failed to register cart event listener', error: e);
    }
  }

  /// Para de escutar eventos. Idempotente.
  void stop() {
    if (!_registered) return;
    try {
      _eventRepository.removeListener(_cartUpdateListenerId);
    } catch (e) {
      developer.log('Failed to unregister cart event listener', error: e);
    } finally {
      _registered = false;
    }
  }

  /// Atualiza a referência do cart corrente sem recriar a subscription.
  /// Útil quando o ViewModel recebe atualização do mesmo cart e quer que
  /// validações de "is same cart" passem a usar os novos campos.
  void updateCurrentCart(ExpeditionCartRouteInternshipConsultationModel cart) {
    _currentCart = cart;
  }

  void dispose() {
    _disposed = true;
    stop();
  }

  void _onEvent(BasicEventModel event) {
    if (_disposed || _currentCart == null) return;
    try {
      _processEventData(event);
    } catch (e) {
      developer.log('Failed to process cart event', error: e);
      _onProcessingError?.call('Erro ao atualizar carrinho. Toque em atualizar para recarregar os dados.');
    }
  }

  void _processEventData(BasicEventModel event) {
    final data = event.data;
    if (data == null) return;

    try {
      final mutationsRaw = data['Mutation'];
      if (mutationsRaw is List) {
        for (final mutation in mutationsRaw) {
          if (mutation is Map<String, dynamic>) {
            final cartData = ExpeditionCartRouteInternshipConsultationModel.fromJson(mutation);
            _dispatchIfMatch(cartData);
          }
        }
      } else {
        final cartData = ExpeditionCartRouteInternshipConsultationModel.fromJson(data);
        _dispatchIfMatch(cartData);
      }
    } catch (e) {
      developer.log('Failed to process cart event data', error: e);
    }
  }

  void _dispatchIfMatch(ExpeditionCartRouteInternshipConsultationModel cartData) {
    final current = _currentCart;
    if (current == null) return;
    if (!_isSameCart(cartData, current)) return;
    _onCartUpdated(cartData);
  }

  bool _isSameCart(
    ExpeditionCartRouteInternshipConsultationModel a,
    ExpeditionCartRouteInternshipConsultationModel b,
  ) {
    return a.codEmpresa == b.codEmpresa && a.codCarrinhoPercurso == b.codCarrinhoPercurso && a.item == b.item;
  }
}
