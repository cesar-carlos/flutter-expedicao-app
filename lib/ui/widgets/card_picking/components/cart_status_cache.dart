import 'package:exp/domain/viewmodels/card_picking_viewmodel.dart';

/// Cache inteligente para status do carrinho com TTL (Time-To-Live)
///
/// Otimiza verificações de status do carrinho evitando chamadas
/// excessivas ao ViewModel através de cache temporizado.
class CartStatusCache {
  final CardPickingViewModel viewModel;

  bool? _cachedStatus;
  DateTime? _lastCheck;

  /// TTL de 200ms para verificações mais frequentes e status mais atualizado
  static const Duration _cacheTtl = Duration(milliseconds: 200);

  CartStatusCache({required this.viewModel});

  /// Obtém o status do carrinho com cache para otimização
  ///
  /// Retorna o valor em cache se ainda estiver válido (dentro do TTL),
  /// caso contrário, busca o valor atualizado do ViewModel.
  bool isCartInSeparationStatus() {
    if (_isCacheValid) {
      return _cachedStatus!;
    }

    return _updateCache();
  }

  /// Verifica se o cache ainda é válido
  bool get _isCacheValid {
    if (_cachedStatus == null || _lastCheck == null) {
      return false;
    }

    final now = DateTime.now();
    final timeSinceLastCheck = now.difference(_lastCheck!);
    return timeSinceLastCheck < _cacheTtl;
  }

  /// Atualiza o cache com o valor atual do ViewModel
  bool _updateCache() {
    _cachedStatus = viewModel.isCartInSeparationStatus;
    _lastCheck = DateTime.now();
    return _cachedStatus!;
  }

  /// Invalida o cache forçando uma nova verificação na próxima chamada
  void invalidateCache() {
    _cachedStatus = null;
    _lastCheck = null;
  }

  /// Força uma verificação imediata do status (ignora cache)
  bool forceCheckCartStatus() {
    _cachedStatus = viewModel.isCartInSeparationStatus;
    _lastCheck = DateTime.now();
    return _cachedStatus!;
  }

  /// Limpa completamente o cache (alias para invalidateCache)
  void clear() => invalidateCache();
}
