import 'package:flutter/services.dart';

import 'package:exp/di/locator.dart';
import 'package:exp/core/services/audio_service.dart';
import 'package:exp/core/services/barcode_scanner_service.dart';
import 'package:exp/core/services/barcode_validation_service.dart';
import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/domain/viewmodels/card_picking_viewmodel.dart';

/// Processador responsável por processar entradas do scanner de códigos de barras
///
/// Responsabilidades:
/// - Processar entrada incremental do scanner com timeout inteligente
/// - Validar formato e conteúdo de códigos de barras
/// - Coordenar callbacks de sucesso/erro de forma otimizada
/// - Fornecer feedback audiovisual (som + vibração) ao usuário
///
/// Estratégias de Processamento:
/// - Entrada curta (< 6 dígitos): aguarda mais entrada
/// - Entrada válida (6-16 dígitos): processa imediatamente
/// - Códigos completos (13-16 dígitos): processa imediatamente
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
  final BarcodeScannerService _scannerService = locator<BarcodeScannerService>();

  ScanInputProcessor({required this.viewModel});

  /// Limpa recursos quando não precisar mais do processador
  void dispose() {
    _scannerService.dispose();
  }

  /// Processa entrada do scanner com debounce
  ///
  /// Delega o processamento para o BarcodeScannerService centralizado.
  void processScannerInput(String input, void Function(String) onCompleteBarcode, void Function() onWaitForMore) {
    _scannerService.processBarcodeInput(input, onCompleteBarcode, onWaitForMore);
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

    // Verificar se item já estava completo antes do scan
    if (wasCompletedBefore) {
      final currentQuantity = _getCurrentQuantity(itemId);
      final totalQuantity = _getTotalQuantity(item);

      // Item já estava completo e quantidade atual = total
      // (escaneando a "última unidade conceitual")
      if (currentQuantity == totalQuantity) {
        await _audioService.playItemCompleted();
        return;
      }
    }

    // Tocar som de feedback apropriado
    if (_didItemBecomeCompleted(itemId, wasCompletedBefore)) {
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
  void _provideTactileFeedback() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {
      // Dispositivo não suporta feedback tátil - ignorar silenciosamente
    }
  }

  /// Verifica se um item mudou de status (incompleto -> completo)
  bool _didItemBecomeCompleted(String itemId, bool wasCompletedBefore) {
    return !wasCompletedBefore && viewModel.isItemCompleted(itemId);
  }

  /// Obtém a quantidade atual separada para um item
  int _getCurrentQuantity(String itemId) => viewModel.getPickedQuantity(itemId);

  /// Obtém a quantidade total esperada para um item
  int _getTotalQuantity(SeparateItemConsultationModel item) => item.quantidade.toInt();
}
