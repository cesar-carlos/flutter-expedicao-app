import 'dart:async' show Timer;
import 'package:flutter/services.dart';

import 'package:exp/di/locator.dart';
import 'package:exp/core/services/audio_service.dart';
import 'package:exp/core/services/barcode_validation_service.dart';
import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/domain/viewmodels/card_picking_viewmodel.dart';
import 'package:exp/core/constants/ui_constants.dart';

/// Processador responsável por processar entradas do scanner de códigos de barras
///
/// Responsabilidades:
/// - Processar entrada incremental do scanner com timeout inteligente
/// - Validar formato e conteúdo de códigos de barras
/// - Coordenar callbacks de sucesso/erro de forma otimizada
/// - Fornecer feedback audiovisual (som + vibração) ao usuário
///
/// Estratégias de Processamento:
/// - Entrada curta (< 8 dígitos): aguarda mais entrada
/// - Entrada válida (8-14 dígitos): processa imediatamente
/// - Entrada inválida: aguarda timeout antes de processar
///
/// Performance:
/// - Validação rápida de formato via regex
/// - Callbacks executados em paralelo via Future.wait()
/// - Delay otimizado de 10ms para atualização de UI
/// - Feedback não-bloqueante
class ScanInputProcessor {
  final CardPickingViewModel viewModel;
  final AudioService _audioService = locator<AudioService>();

  /// Timeout para aguardar mais entrada do scanner
  static const Duration _scannerTimeout = UIConstants.slideInDuration;

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
    if (input.isEmpty) {
      return;
    }

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

  /// Processa adição bem-sucedida de item de forma otimizada
  ///
  /// Executa callbacks críticos de forma síncrona e instantânea,
  /// e a verificação de setor em background para não bloquear o usuário.
  Future<void> handleSuccessfulItemAddition(
    SeparateItemConsultationModel item,
    int quantity,
    void Function() onResetQuantity,
    void Function() onInvalidateCache,
    Future<void> Function() onCheckSectorCompletion,
  ) async {
    final itemId = item.item;
    final wasCompletedBefore = viewModel.isItemCompleted(itemId);

    // Executar callbacks síncronos imediatamente (atualização otimista já foi feita)
    onResetQuantity();
    onInvalidateCache();

    // Verificar completude do item após todas as atualizações
    final isCompletedNow = viewModel.isItemCompleted(itemId);

    // Verificar se item já estava completo antes do scan
    if (wasCompletedBefore) {
      final currentQuantity = viewModel.getPickedQuantity(itemId);
      final totalQuantity = item.quantidade.toInt();

      // Item já estava completo e quantidade atual = total
      // (escaneando a "última unidade conceitual")
      if (currentQuantity == totalQuantity) {
        await _audioService.playItemCompleted();
        return;
      }
    }

    // Tocar som de feedback apropriado
    if (!wasCompletedBefore && isCompletedNow) {
      // Última unidade: som de sucesso
      await _audioService.playItemCompleted();
    } else {
      // Unidades normais: som de scan
      await _provideSuccessFeedback();
    }

    // Executar verificação de setor em background (não bloqueante)
    onCheckSectorCompletion().catchError((_) {});
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
