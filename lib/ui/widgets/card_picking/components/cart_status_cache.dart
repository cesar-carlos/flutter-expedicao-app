import 'package:data7_expedicao/domain/viewmodels/card_picking_viewmodel.dart';

class CartStatusCache {
  final CardPickingViewModel viewModel;

  bool? _cachedStatus;
  DateTime? _lastCheck;

  static const Duration _cacheTtl = Duration(milliseconds: 200);

  CartStatusCache({required this.viewModel});

  bool isCartInSeparationStatus() {
    if (_isCacheValid) {
      return _cachedStatus!;
    }

    return _updateCache();
  }

  bool get _isCacheValid {
    if (_cachedStatus == null || _lastCheck == null) {
      return false;
    }

    final now = DateTime.now();
    final timeSinceLastCheck = now.difference(_lastCheck!);
    return timeSinceLastCheck < _cacheTtl;
  }

  bool _updateCache() {
    _cachedStatus = viewModel.isCartInSeparationStatus;
    _lastCheck = DateTime.now();
    return _cachedStatus!;
  }

  void invalidateCache() {
    _cachedStatus = null;
    _lastCheck = null;
  }

  bool forceCheckCartStatus() {
    _cachedStatus = viewModel.isCartInSeparationStatus;
    _lastCheck = DateTime.now();
    return _cachedStatus!;
  }

  void clear() => invalidateCache();
}
