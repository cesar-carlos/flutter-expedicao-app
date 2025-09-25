import 'package:flutter/foundation.dart';

import 'package:exp/core/results/index.dart';
import 'package:exp/domain/usecases/add_cart/add_cart_params.dart';
import 'package:exp/domain/usecases/add_cart/add_cart_usecase.dart';
import 'package:exp/domain/repositories/basic_consultation_repository.dart';
import 'package:exp/domain/models/expedition_cart_consultation_model.dart';
import 'package:exp/domain/models/expedition_cart_situation_model.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';
import 'package:exp/di/locator.dart';

class AddCartViewModel extends ChangeNotifier {
  final int codEmpresa;
  final int codSepararEstoque;

  // Repositórios e UseCases
  final AddCartUseCase _addCartUseCase;
  final BasicConsultationRepository<ExpeditionCartConsultationModel> _cartConsultationRepository;
  // Estado
  bool _isScanning = false;
  bool _isAdding = false;
  ExpeditionCartConsultationModel? _scannedCart;
  String? _errorMessage;

  AddCartViewModel({required this.codEmpresa, required this.codSepararEstoque})
    : _addCartUseCase = locator<AddCartUseCase>(),
      _cartConsultationRepository = locator<BasicConsultationRepository<ExpeditionCartConsultationModel>>();

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
      final carts = await _cartConsultationRepository.selectConsultation(
        QueryBuilder().equals('codigoBarras', barcode),
      );

      if (carts.isNotEmpty) {
        _scannedCart = carts.first;
        // Não define erro aqui - deixa o CartActionsWidget mostrar o status
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

      return result.fold((success) => true, (failure) {
        final message = failure is AppFailure ? failure.userMessage : failure.toString();
        _setError(message);
        return false;
      });
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
