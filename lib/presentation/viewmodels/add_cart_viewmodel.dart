import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/usecases/add_cart/add_cart_params.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_router_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:data7_expedicao/domain/usecases/start_separation/start_separation_failure.dart';
import 'package:data7_expedicao/domain/usecases/start_separation/start_separation_params.dart';
import 'package:data7_expedicao/domain/usecases/start_separation/start_separation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/add_cart/add_cart_usecase.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';

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
  int _successCounter = 0;

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
  int get successCounter => _successCounter;

  ExpeditionCartConsultationModel? get scannedCart => _scannedCart;
  String? get errorMessage => _errorMessage;

  Future<void> scanBarcode(String barcode) async {
    if (barcode.isEmpty) return;
    if (_isScanning) return;

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
        _scannedCart = null;
        _stopAutoAddCountdown();
        _errorMessage = 'Carrinho não encontrado com o código de barras informado.';
        _audioService.playError();
      }
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar carrinho', tag: 'AddCartViewModel', error: e, stackTrace: stackTrace);
      _scannedCart = null;
      _stopAutoAddCountdown();
      _errorMessage = 'Erro ao buscar carrinho. Tente novamente.';
      _audioService.playError();
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<bool> addCartToSeparation() async {
    if (_disposed) return false;

    if (_scannedCart == null) {
      _setError('Nenhum carrinho foi escaneado.');
      return false;
    }

    if (!canAddCart) {
      _setError('Carrinho deve estar na situação LIBERADO para ser adicionado à separação.');
      return false;
    }

    if (_isAdding) return false;

    _stopAutoAddCountdown();
    _setAdding(true);
    _clearError();

    try {
      final existingCartRouteResult = await _checkExistingCartRoute();

      if (!existingCartRouteResult.isSuccess()) {
        final failure = existingCartRouteResult.exceptionOrNull();
        if (failure == null) {
          _setError('Erro ao verificar percurso. Tente novamente.');
          _audioService.playError();
          return false;
        }
        if (failure is AppFailure) {
          if (failure is DataFailure && failure.code == 'NOT_FOUND') {
            final startResult = await _startSeparation();
            if (!startResult) return false;
          } else {
            _setError(failure.userMessage);
            _audioService.playError();
            return false;
          }
        } else {
          AppLogger.error('Falha inesperada ao verificar percurso', tag: 'AddCartViewModel', error: failure);
          _setError('Erro ao verificar percurso. Tente novamente.');
          _audioService.playError();
          return false;
        }
      }

      final existingRoute = existingCartRouteResult.getOrNull();
      final params = AddCartParams(
        codEmpresa: codEmpresa,
        origem: ExpeditionOrigem.separacaoEstoque,
        codOrigem: codSepararEstoque,
        codCarrinho: _scannedCart!.codCarrinho,
        scannedCart: _scannedCart,
        codCarrinhoPercurso: existingRoute?.codCarrinhoPercurso,
      );

      final result = await _addCartUseCase.call(params);
      return result.fold(
        (success) {
          _audioService.playCartAddSuccess();
          _successCounter++;
          notifyListeners();
          return true;
        },
        (failure) {
          final message = failure is AppFailure ? failure.userMessage : 'Erro ao adicionar carrinho. Tente novamente.';
          _setError(message);
          _audioService.playError();
          return false;
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erro inesperado ao adicionar carrinho', tag: 'AddCartViewModel', error: e, stackTrace: stackTrace);
      _setError('Erro inesperado. Tente novamente.');
      _audioService.playError();
      return false;
    } finally {
      _setAdding(false);
    }
  }

  Future<Result<ExpeditionCartRouteModel>> _checkExistingCartRoute() async {
    try {
      final cartRoutes = await _cartRouteRepository.select(
        QueryBuilder()
            .equals('CodEmpresa', codEmpresa)
            .equals('Origem', ExpeditionOrigem.separacaoEstoque.code)
            .equals('CodOrigem', codSepararEstoque)
            .notEquals('Situacao', ExpeditionCartRouterSituation.cancelada.code),
      );

      if (cartRoutes.isNotEmpty) {
        return Success(cartRoutes.first);
      }

      return Failure(DataFailure.notFound('Percurso de carrinho'));
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao verificar carrinho percurso existente', tag: 'AddCartViewModel', error: e, stackTrace: stackTrace);
      return Failure(DataFailure.repository(e));
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
        final message = failure is StartSeparationFailure &&
                failure.type == StartSeparationFailureType.separationAlreadyStarted
            ? 'Outro setor já iniciou esta separação. Toque em Adicionar novamente para incluir seu carrinho.'
            : (failure is AppFailure ? failure.userMessage : 'Erro ao iniciar separação. Tente novamente.');
        _setError(message);
        return false;
      });
    } catch (e, stackTrace) {
      AppLogger.error('Erro inesperado ao iniciar separação', tag: 'AddCartViewModel', error: e, stackTrace: stackTrace);
      _setError('Erro inesperado. Tente novamente.');
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
    notifyListeners();

    _autoAddTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed) return;

      _countdownSeconds--;

      if (_countdownSeconds <= 0) {
        _stopAutoAddCountdown();
        if (!_disposed) {
          // Bug MMM: erro do future fire-and-forget agora vai para o log
          // em vez de virar uncaught exception silenciosa. addCartToSeparation
          // ja seta _errorMessage internamente em caso de falha — aqui so
          // garantimos que excecoes inesperadas nao escapem para o root zone.
          unawaited(
            addCartToSeparation().catchError((Object e, StackTrace s) {
              AppLogger.error(
                'Erro inesperado em addCartToSeparation (auto)',
                tag: 'AddCartViewModel',
                error: e,
                stackTrace: s,
              );
              return false;
            }),
          );
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
