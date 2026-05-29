import 'dart:async';

import 'package:data7_expedicao/core/utils/app_logger.dart';

/// Serviço responsável por processar entradas de códigos de barras com detecção de Enter
///
/// Este serviço centraliza a lógica de processamento de códigos de barras,
/// permitindo reutilização em diferentes partes da aplicação.
///
/// Características:
/// - Detecção prioritária de Enter para confirmação de leitura completa
/// - Debounce como fallback para leitores que não enviam Enter
/// - Validação de formatos de códigos de barras
/// - Detecção automática de códigos completos (EAN-13+)
/// - Cache de validações para melhor performance
/// - Configuração flexível de timeouts e validações
class BarcodeScannerService {
  /// Timer para debounce - aguarda usuário parar de digitar
  Timer? _debounceTimer;

  /// Tempo de debounce padrão para detectar quando o usuário/leitor parou de
  /// enviar caracteres.
  ///
  /// Valor baixo favorece responsividade com scanners rápidos, mas leitores
  /// com atraso entre caracteres (alguns HID/Bluetooth) podem fatiar a leitura
  /// se o valor for curto demais. Por isso o timeout é configurável por
  /// instância (ver [debounceTimeout]).
  static const Duration defaultDebounceTimeout = Duration(milliseconds: 40);

  /// Tempo de debounce efetivo desta instância. Ajustável conforme o perfil do
  /// leitor (ex.: subir para evitar leituras parciais em scanners lentos).
  Duration _debounceTimeout;

  BarcodeScannerService({Duration debounceTimeout = defaultDebounceTimeout}) : _debounceTimeout = debounceTimeout;

  /// Timeout de debounce atualmente em uso.
  Duration get debounceTimeout => _debounceTimeout;

  /// Permite ajustar o debounce em runtime (ex.: a partir de uma preferência do
  /// usuário). Valores não positivos são ignorados para evitar processamento
  /// imediato indevido.
  set debounceTimeout(Duration value) {
    if (value <= Duration.zero) return;
    _debounceTimeout = value;
  }

  /// Padrão regex para validar o formato do código de barras (7-16 dígitos
  /// numéricos). Cobre EAN-8/13, UPC-A/E e Code 128 puramente numérico.
  ///
  /// Importante: códigos alfanuméricos (ex.: unidades de medida tipo `CX12`)
  /// NÃO passam por este gate; eles são casados adiante por comparação exata
  /// em `PickingUtils`/`BarcodeValidationService`, e chegam ao processamento
  /// pela detecção de Enter ou pelo fallback de debounce.
  static final RegExp _barcodePattern = RegExp(r'^\d{7,16}$');

  /// Padrão regex para códigos completos (13-16 dígitos)
  static final RegExp _completeBarcodePattern = RegExp(r'^\d{13,16}$');

  /// Padrão regex para caracteres de controle
  static final RegExp _controlCharPattern = RegExp(r'[\n\r\t]');

  /// Comprimento mínimo esperado para um código de barras
  static const int _minBarcodeLength = 7;

  /// Comprimento mínimo para códigos completos (EAN-13+)
  static const int _completeBarcodeMinLength = 13;

  /// Comprimento máximo para códigos completos
  static const int _completeBarcodeMaxLength = 16;

  /// Comprimento mínimo para entrada via teclado
  static const int _minKeyboardLength = 3;

  /// Comprimento mínimo para entrada via scanner
  static const int _minScannerLength = 8;

  void _safeOnComplete(void Function(String) onCompleteBarcode, String code) {
    try {
      onCompleteBarcode(code);
    } catch (e, s) {
      AppLogger.warning(
        'Erro no callback onCompleteBarcode',
        tag: 'BarcodeScannerService',
        error: e,
        stackTrace: s,
      );
    }
  }

  void _safeOnWait(void Function() onWaitForMore) {
    try {
      onWaitForMore();
    } catch (e, s) {
      AppLogger.warning(
        'Erro no callback onWaitForMore',
        tag: 'BarcodeScannerService',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Mantido por compatibilidade. Cache de validações foi removido (B11)
  /// porque o ganho era irrelevante (regex já roda em microssegundos)
  /// e o cache crescia indefinidamente em sessões longas.
  void clearValidationCache() {
    // no-op
  }

  /// Limpa recursos quando não precisar mais do serviço
  void dispose() {
    _debounceTimer?.cancel();
  }

  /// Processa entrada de código de barras com detecção de Enter e debounce como fallback
  ///
  /// Prioriza detecção de Enter para confirmação de leitura completa.
  /// Usa debounce apenas como fallback para leitores que não enviam Enter.
  /// - Se vazio: ignora
  /// - Se contém Enter: processa imediatamente
  /// - Se código completo (13-16 dígitos): processa imediatamente
  /// - Caso contrário: aguarda debounce como fallback
  void processBarcodeInput(String input, void Function(String) onCompleteBarcode, void Function() onWaitForMore) {
    if (input.isEmpty) return;

    // Prioridade 1: Detecção de Enter (confirmação de leitura completa)
    if (_controlCharPattern.hasMatch(input)) {
      _debounceTimer?.cancel();
      final cleanedInput = cleanBarcodeText(input);
      if (cleanedInput.isNotEmpty) {
        _safeOnComplete(onCompleteBarcode, cleanedInput);
      }
      return;
    }

    // Prioridade 2: Códigos completos (13-16 dígitos) - processar imediatamente
    if (_isCompleteBarcode(input)) {
      _debounceTimer?.cancel();
      _safeOnComplete(onCompleteBarcode, input);
      return;
    }

    // Prioridade 3: Debounce como fallback para leitores sem Enter
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceTimeout, () {
      try {
        _processInputAfterDebounce(input, onCompleteBarcode, onWaitForMore);
      } catch (e, s) {
        AppLogger.warning(
          'Erro no tick de debounce do barcode scanner',
          tag: 'BarcodeScannerService',
          error: e,
          stackTrace: s,
        );
      }
    });
  }

  /// Processa entrada após debounce - usuário parou de digitar
  void _processInputAfterDebounce(
    String input,
    void Function(String) onCompleteBarcode,
    void Function() onWaitForMore,
  ) {
    // Só processar códigos com pelo menos 7 dígitos
    if (input.length < _minBarcodeLength) {
      _safeOnWait(onWaitForMore);
      return;
    }

    // Processar códigos válidos (7+ dígitos)
    if (_isValidBarcode(input)) {
      _safeOnComplete(onCompleteBarcode, input);
      return;
    }

    // Entrada longa mas formato inválido, aguardar mais
    _safeOnWait(onWaitForMore);
  }

  /// Processa entrada com detecção prioritária de Enter
  ///
  /// Versão otimizada que detecta Enter como confirmação de leitura completa.
  /// Usa debounce apenas como fallback para leitores que não enviam Enter.
  void processBarcodeInputWithControlDetection(
    String input,
    void Function(String) onCompleteBarcode,
    void Function() onWaitForMore,
  ) {
    if (input.isEmpty) return;

    final text = input.trim();

    // Detecção prioritária de Enter (confirmação de leitura completa)
    if (_controlCharPattern.hasMatch(text)) {
      _debounceTimer?.cancel();
      final cleanedInput = cleanBarcodeText(text);
      if (cleanedInput.isNotEmpty) {
        _safeOnComplete(onCompleteBarcode, cleanedInput);
      }

      return;
    }

    // Usar processamento normal com debounce como fallback
    processBarcodeInput(input, onCompleteBarcode, onWaitForMore);
  }

  /// Limpa caracteres especiais de um texto
  ///
  /// Remove caracteres não numéricos que podem vir do scanner
  /// (incluindo Enter/Return/Tab/etc) mantendo apenas dígitos
  String cleanBarcodeText(String text) {
    return text.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Verifica se o texto contém Enter (confirmação de leitura completa)
  bool hasEnterCharacter(String text) {
    return _controlCharPattern.hasMatch(text);
  }

  /// Valida se um código de barras tem comprimento mínimo
  ///
  /// Considera diferentes comprimentos mínimos para teclado vs scanner
  bool isValidBarcodeLength(String text, {bool isKeyboardInput = false}) {
    final minLength = isKeyboardInput ? _minKeyboardLength : _minScannerLength;
    return text.length >= minLength;
  }

  /// Verifica se a entrada tem formato de código de barras válido.
  /// (B11: cache foi removido — regex já é da ordem de microssegundos.)
  bool _isValidBarcode(String input) {
    return _barcodePattern.hasMatch(input);
  }

  /// Valida o formato de um código de barras (somente dígitos).
  ///
  /// **Formatos numéricos cobertos:**
  /// - EAN-13: 13 dígitos
  /// - EAN-8: 8 dígitos
  /// - UPC-A: 12 dígitos
  /// - UPC-E: 8 dígitos
  /// - Code 128 numérico: 7-16 dígitos
  ///
  /// **Retorno:**
  /// - `true` se o formato é válido (7-16 dígitos numéricos)
  /// - `false` caso contrário (inclui códigos com letras)
  bool isValidBarcodeFormat(String barcode) {
    final trimmed = barcode.trim();
    if (trimmed.isEmpty) return false;
    return _barcodePattern.hasMatch(trimmed);
  }

  /// Obtém informações sobre o formato do código de barras
  ///
  /// **Retorno:**
  /// - String descrevendo o formato detectado ou "Formato inválido"
  String getBarcodeFormatInfo(String barcode) {
    final trimmed = barcode.trim();
    if (trimmed.isEmpty) return 'Código vazio';
    if (!_barcodePattern.hasMatch(trimmed)) return 'Formato inválido';

    final length = trimmed.length;
    if (length == 8) return 'EAN-8 ou UPC-E';
    if (length == 12) return 'UPC-A';
    if (length == 13) return 'EAN-13';
    if (length >= 7 && length <= 16) return 'Código numérico (7-16 dígitos)';

    return 'Formato válido';
  }

  /// Verifica se a entrada é um código completo (13-16 dígitos)
  bool _isCompleteBarcode(String input) =>
      input.length >= _completeBarcodeMinLength &&
      input.length <= _completeBarcodeMaxLength &&
      _completeBarcodePattern.hasMatch(input);
}
