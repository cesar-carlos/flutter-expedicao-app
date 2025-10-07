import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:exp/core/services/audio_service.dart';
import 'package:exp/core/services/barcode_validation_service.dart';
import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/domain/viewmodels/card_picking_viewmodel.dart';
import 'package:exp/di/locator.dart';

/// Processador responsável por processar entradas do scanner de códigos de barras
///
/// Gerencia a lógica de processamento de entrada do scanner, validação de
/// códigos de barras e feedback ao usuário (áudio e tátil).
class ScanInputProcessor {
  final CardPickingViewModel viewModel;
  final AudioService _audioService = locator<AudioService>();

  /// Timeout para aguardar mais entrada do scanner
  static const Duration _scannerTimeout = Duration(milliseconds: 300);

  /// Delay para aguardar atualização de estado após adição de item
  static const Duration _stateUpdateDelay = Duration(milliseconds: 100);

  /// Padrão regex para validar formato de código de barras (8-14 dígitos)
  static final RegExp _barcodePattern = RegExp(r'^\d{8,14}$');

  /// Comprimento mínimo esperado para um código de barras
  static const int _minBarcodeLength = 8;

  ScanInputProcessor({required this.viewModel});

  /// Processa entrada do scanner com timeout
  ///
  /// Analisa a entrada e decide se é um código completo ou se deve aguardar mais entrada.
  /// - Se vazio: ignora
  /// - Se muito curto: aguarda mais entrada
  /// - Se completo e válido: processa imediatamente
  /// - Se longo mas inválido: aguarda timeout para processar
  void processScannerInput(String input, void Function(String) onCompleteBarcode, void Function() onWaitForMore) {
    if (input.isEmpty) return;

    if (_isInputTooShort(input)) {
      _scheduleWaitForMore(onWaitForMore);
      return;
    }

    if (_isValidBarcode(input)) {
      onCompleteBarcode(input);
      return;
    }

    // Entrada longa mas formato inválido, aguardar timeout
    _scheduleWaitForMore(onWaitForMore);
  }

  /// Verifica se a entrada é muito curta para ser um código de barras válido
  bool _isInputTooShort(String input) => input.length < _minBarcodeLength;

  /// Verifica se a entrada tem formato de código de barras válido
  bool _isValidBarcode(String input) => _barcodePattern.hasMatch(input);

  /// Agenda callback para aguardar mais entrada após o timeout
  void _scheduleWaitForMore(void Function() callback) {
    Timer(_scannerTimeout, callback);
  }

  /// Valida código de barras escaneado
  BarcodeValidationResult validateScannedBarcode(String barcode) {
    return BarcodeValidationService.validateScannedBarcode(
      barcode,
      viewModel.items,
      viewModel.isItemCompleted,
      userSectorCode: viewModel.userModel?.codSetorEstoque,
    );
  }

  /// Processa adição bem-sucedida de item
  ///
  /// Executa a sequência completa de feedback e validações após
  /// adicionar um item com sucesso.
  Future<void> handleSuccessfulItemAddition(
    SeparateItemConsultationModel item,
    int quantity,
    void Function() onResetQuantity,
    void Function() onInvalidateCache,
    Future<void> Function() onCheckSectorCompletion,
  ) async {
    final itemId = item.item;
    final wasCompletedBefore = viewModel.isItemCompleted(itemId);

    // Feedback imediato ao usuário
    await _provideSuccessFeedback();

    // Aguardar atualização de estado e verificar completude
    await Future.delayed(_stateUpdateDelay);
    final isCompletedNow = viewModel.isItemCompleted(itemId);

    // Log apenas em modo debug
    _logItemCompletionStatus(itemId.toString(), wasCompletedBefore, isCompletedNow, item, quantity);

    // Feedback especial para item completado
    if (!wasCompletedBefore && isCompletedNow) {
      await _audioService.playItemCompleted();
    }

    // Executar callbacks pós-adição
    onResetQuantity();
    onInvalidateCache();
    await onCheckSectorCompletion();
  }

  /// Fornece feedback de sucesso ao usuário (áudio + tátil)
  Future<void> _provideSuccessFeedback() async {
    _audioService.playBarcodeScan();
    _provideTactileFeedback();
  }

  /// Processa falha na adição de item
  void handleFailedItemAddition(SeparateItemConsultationModel item, String errorMessage) {
    _audioService.playError();
  }

  /// Log do status de completude do item (apenas em modo debug)
  ///
  /// Registra informações sobre a mudança de estado do item após adição.
  void _logItemCompletionStatus(
    String itemId,
    bool wasCompletedBefore,
    bool isCompletedNow,
    SeparateItemConsultationModel item,
    int quantity,
  ) {
    if (!kDebugMode) return;

    final currentPickedQuantity = viewModel.getPickedQuantity(itemId);
    final totalQuantity = item.quantidade.toInt();
    final newPickedQuantity = currentPickedQuantity + quantity;

    debugPrint('📦 Item $itemId - Completude: $wasCompletedBefore → $isCompletedNow');
    debugPrint('   Quantidades: $currentPickedQuantity → $newPickedQuantity / $totalQuantity');
  }

  /// Fornece feedback tátil ao usuário
  ///
  /// Usa vibração leve para confirmar sucesso na adição do item.
  /// Falhas são ignoradas silenciosamente (dispositivo sem vibração).
  void _provideTactileFeedback() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {
      // Dispositivo não suporta feedback tátil
    }
  }
}
