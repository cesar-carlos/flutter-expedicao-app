import 'package:flutter/foundation.dart';

import 'package:exp/di/locator.dart';
import 'package:exp/domain/models/expedition_cart_consultation_model.dart';
import 'package:exp/domain/repositories/expedition_cart_consultation_repository.dart';
import 'package:exp/domain/models/expedition_cart_situation_model.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';
import 'package:exp/domain/usecases/add_cart/index.dart';

class AddCartViewModel extends ChangeNotifier {
  final int codEmpresa;
  final int codSepararEstoque;

  // Repositórios e UseCases
  final ExpeditionCartConsultationRepository _cartConsultationRepository;
  final AddCartUseCase _addCartUseCase;

  // Estado
  bool _isScanning = false;
  bool _isAdding = false;
  ExpeditionCartConsultationModel? _scannedCart;
  String? _errorMessage;

  AddCartViewModel({required this.codEmpresa, required this.codSepararEstoque})
    : _cartConsultationRepository = locator<ExpeditionCartConsultationRepository>(),
      _addCartUseCase = locator<AddCartUseCase>();

  // Getters
  bool get isScanning => _isScanning;
  bool get isAdding => _isAdding;
  bool get hasCartData => _scannedCart != null;
  bool get hasError => _errorMessage != null;
  bool get canAddCart => _scannedCart?.situacao == ExpeditionCartSituation.liberado;

  ExpeditionCartConsultationModel? get scannedCart => _scannedCart;
  String? get errorMessage => _errorMessage;

  /// Escaneia código de barras e busca informações do carrinho
  Future<void> scanBarcode(String barcode) async {
    if (barcode.isEmpty) return;

    _setScanning(true);
    _clearError();

    try {
      // Buscar carrinho pelo código de barras
      final cart = await _cartConsultationRepository.getCartByBarcode(codEmpresa: codEmpresa, codigoBarras: barcode);

      if (cart != null) {
        _scannedCart = cart;

        // Verificar se o carrinho pode ser adicionado
        if (!canAddCart) {
          _setError(
            'Carrinho deve estar na situação LIBERADO para ser adicionado. '
            'Situação atual: ${cart.situacaoDescription}',
          );
        }
      } else {
        _setError('Carrinho não encontrado com o código de barras informado.');
      }
    } catch (e) {
      _setError('Erro ao buscar carrinho: ${e.toString()}');
    } finally {
      _setScanning(false);
    }
  }

  /// Adiciona o carrinho à separação usando o UseCase
  Future<bool> addCartToSeparation() async {
    if (_scannedCart == null) {
      _setError('Nenhum carrinho foi escaneado.');
      return false;
    }

    _setAdding(true);
    _clearError();

    try {
      final params = AddCartParams(
        codEmpresa: codEmpresa,
        origem: ExpeditionOrigem.separacaoEstoque,
        codOrigem: codSepararEstoque,
        codCarrinho: _scannedCart!.codCarrinho,
      );

      final result = await _addCartUseCase.call(params);

      if (result is AddCartSuccess) {
        return true;
      } else if (result is AddCartFailure) {
        _setError(result.message);
        return false;
      }

      return false;
    } catch (e) {
      _setError('Erro inesperado: ${e.toString()}');
      return false;
    } finally {
      _setAdding(false);
    }
  }

  /// Limpa os dados escaneados
  void clearScannedData() {
    _scannedCart = null;
    _clearError();
    notifyListeners();
  }

  void _setScanning(bool scanning) {
    _isScanning = scanning;
    notifyListeners();
  }

  void _setAdding(bool adding) {
    _isAdding = adding;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
