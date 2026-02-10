import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/usecases/add_cart/add_cart_params.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_router_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:data7_expedicao/domain/usecases/start_separation/start_separation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/start_separation/start_separation_params.dart';
import 'package:data7_expedicao/domain/usecases/add_cart/add_cart_usecase.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/di/locator.dart';

class AddCartViewModel extends ChangeNotifier {
  final int codEmpresa;
  final int codSepararEstoque;

  final AddCartUseCase _addCartUseCase;
  final BasicConsultationRepository<ExpeditionCartConsultationModel> _cartConsultationRepository;
  final BasicRepository<ExpeditionCartRouteModel> _cartRouteRepository;
  final StartSeparationUseCase _startSeparationUseCase;
  final AudioService _audioService;

  bool _isScanning = false;
  bool _isAdding = false;
  ExpeditionCartConsultationModel? _scannedCart;
  String? _errorMessage;
  Timer? _autoAddTimer;
  int _countdownSeconds = 0;
  bool _disposed = false;

  AddCartViewModel({required this.codEmpresa, required this.codSepararEstoque})
    : _addCartUseCase = locator<AddCartUseCase>(),
      _cartConsultationRepository = locator<BasicConsultationRepository<ExpeditionCartConsultationModel>>(),
      _cartRouteRepository = locator<BasicRepository<ExpeditionCartRouteModel>>(),
      _startSeparationUseCase = locator<StartSeparationUseCase>(),
      _audioService = locator<AudioService>();

  bool get isScanning => _isScanning;
  bool get isAdding => _isAdding;
  bool get hasCartData => _scannedCart != null;
  bool get hasError => _errorMessage != null;
  bool get canAddCart => _scannedCart?.situacao == ExpeditionCartSituation.liberado;
  int get countdownSeconds => _countdownSeconds;
  bool get isCountdownActive => _autoAddTimer != null && _autoAddTimer!.isActive;

  ExpeditionCartConsultationModel? get scannedCart => _scannedCart;
  String? get errorMessage => _errorMessage;

  Future<void> scanBarcode(String barcode) async {
    if (barcode.isEmpty) return;

    _isScanning = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final query = QueryBuilder().equals('codigoBarras', barcode);

      final carts = await _cartConsultationRepository.selectConsultation(query);

      if (carts.isNotEmpty) {
        _scannedCart = carts.first;
        _audioService.playBarcodeScan();
        _startAutoAddCountdown();
      } else {
        _errorMessage = 'Carrinho não encontrado com o código de barras informado.';
        _audioService.playError();
      }
    } catch (e) {
      _errorMessage = 'Erro ao buscar carrinho: ${e.toString()}';
      _audioService.playError();
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<bool> addCartToSeparation() async {
    AppLogger.debug('addCartToSeparation: INÍCIO', tag: 'AddCartViewModel');

    if (_disposed) {
      AppLogger.debug('addCartToSeparation: ABORTADO - disposed', tag: 'AddCartViewModel');
      return false;
    }
    if (_scannedCart == null) {
      _setError('Nenhum carrinho foi escaneado.');
      AppLogger.debug('addCartToSeparation: ERRO - sem carrinho escaneado', tag: 'AddCartViewModel');
      return false;
    }

    if (_isAdding) {
      AppLogger.debug('addCartToSeparation: ABORTADO - já está adicionando', tag: 'AddCartViewModel');
      return false;
    }

    _stopAutoAddCountdown();
    _setAdding(true);
    _clearError();

    try {
      AppLogger.debug('addCartToSeparation: verificando rota existente', tag: 'AddCartViewModel');
      final existingCartRoute = await _checkExistingCartRoute();
      if (existingCartRoute == null) {
        AppLogger.debug('addCartToSeparation: iniciando separação', tag: 'AddCartViewModel');
        final startResult = await _startSeparation();
        if (!startResult) {
          AppLogger.debug('addCartToSeparation: FALHOU ao iniciar separação', tag: 'AddCartViewModel');
          return false;
        }
      }

      AppLogger.debug('addCartToSeparation: chamando UseCase', tag: 'AddCartViewModel');
      final params = AddCartParams(
        codEmpresa: codEmpresa,
        origem: ExpeditionOrigem.separacaoEstoque,
        codOrigem: codSepararEstoque,
        codCarrinho: _scannedCart!.codCarrinho,
        scannedCart: _scannedCart,
      );

      final result = await _addCartUseCase.call(params);
      return result.fold(
        (success) {
          AppLogger.debug('addCartToSeparation: SUCESSO - reproduzindo som', tag: 'AddCartViewModel');
          _audioService.playCartAddSuccess();
          notifyListeners();
          return true;
        },
        (failure) {
          final message = failure is AppFailure ? failure.userMessage : failure.toString();
          AppLogger.debug('addCartToSeparation: FALHOU - $message', tag: 'AddCartViewModel');
          _setError(message);
          _audioService.playError();
          return false;
        },
      );
    } catch (e) {
      AppLogger.debug('addCartToSeparation: ERRO - ${e.toString()}', tag: 'AddCartViewModel');
      _setError('Erro inesperado: ${e.toString()}');
      _audioService.playError();
      return false;
    } finally {
      _setAdding(false);
      AppLogger.debug('addCartToSeparation: FIM - isAdding=$_isAdding', tag: 'AddCartViewModel');
    }
  }

  Future<ExpeditionCartRouteModel?> _checkExistingCartRoute() async {
    try {
      final cartRoutes = await _cartRouteRepository.select(
        QueryBuilder()
            .equals('CodEmpresa', codEmpresa)
            .equals('Origem', ExpeditionOrigem.separacaoEstoque.code)
            .equals('CodOrigem', codSepararEstoque)
            .notEquals('Situacao', ExpeditionCartRouterSituation.cancelada.code),
      );

      return cartRoutes.isNotEmpty ? cartRoutes.first : null;
    } catch (e) {
      _setError('Erro ao verificar carrinho percurso existente: ${e.toString()}');
      return null;
    }
  }

  Future<bool> _startSeparation() async {
    try {
      final params = StartSeparationParams(
        codEmpresa: codEmpresa,
        origem: ExpeditionOrigem.separacaoEstoque,
        codOrigem: codSepararEstoque,
      );

      final result = await _startSeparationUseCase.call(params);
      return result.fold((success) => true, (failure) {
        final message = failure is AppFailure ? failure.userMessage : failure.toString();
        _setError('Erro ao iniciar separação: $message');
        return false;
      });
    } catch (e) {
      _setError('Erro inesperado ao iniciar separação: ${e.toString()}');
      return false;
    }
  }

  void clearScannedData() {
    _stopAutoAddCountdown();
    _scannedCart = null;
    _clearError();
    notifyListeners();
  }

  void _startAutoAddCountdown() {
    _stopAutoAddCountdown();

    if (!canAddCart) return;

    _countdownSeconds = 5;
    AppLogger.debug('COUNTDOWN: Iniciado - $_countdownSeconds segundos', tag: 'AddCartViewModel');
    notifyListeners();

    _autoAddTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed) return;

      _countdownSeconds--;
      AppLogger.debug('COUNTDOWN: Contagem $_countdownSeconds', tag: 'AddCartViewModel');

      if (_countdownSeconds <= 0) {
        _stopAutoAddCountdown();
        AppLogger.debug('COUNTDOWN: Executando addCartToSeparation', tag: 'AddCartViewModel');
        if (!_disposed) {
          AppLogger.debug('COUNTDOWN: Chamando addCartToSeparation diretamente', tag: 'AddCartViewModel');
          addCartToSeparation();
        }
      } else {
        notifyListeners();
      }
    });
  }

  void _stopAutoAddCountdown() {
    _autoAddTimer?.cancel();
    _autoAddTimer = null;
    _countdownSeconds = 0;
  }

  void cancelAutoAdd() {
    _stopAutoAddCountdown();
    notifyListeners();
  }

  void _setAdding(bool adding) {
    if (!_disposed) {
      _isAdding = adding;
      notifyListeners();
    }
  }

  void _setError(String message) {
    if (!_disposed) {
      _errorMessage = message;
      notifyListeners();
    }
  }

  void _clearError() {
    if (!_disposed) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _stopAutoAddCountdown();
    super.dispose();
  }
}
