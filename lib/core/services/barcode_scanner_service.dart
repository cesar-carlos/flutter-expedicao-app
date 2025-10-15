import 'dart:async';

/// Serviço responsável por processar entradas de códigos de barras com debounce
///
/// Este serviço centraliza a lógica de processamento de códigos de barras,
/// permitindo reutilização em diferentes partes da aplicação.
///
/// Características:
/// - Processamento com debounce para detectar quando usuário parou de digitar
/// - Validação de formatos de códigos de barras
/// - Detecção automática de códigos completos (EAN-13+)
/// - Feedback tátil para confirmação
/// - Configuração flexível de timeouts e validações
class BarcodeScannerService {
  /// Timer para debounce - aguarda usuário parar de digitar
  Timer? _debounceTimer;

  /// Tempo de debounce para detectar quando usuário parou de digitar
  static const Duration _debounceTimeout = Duration(milliseconds: 40);

  /// Padrão regex para validar formato de código de barras (8-16 dígitos)
  static final RegExp _barcodePattern = RegExp(r'^\d{8,16}$');

  /// Padrão regex para códigos completos (13-16 dígitos)
  static final RegExp _completeBarcodePattern = RegExp(r'^\d{13,16}$');

  /// Padrão regex para caracteres de controle
  static final RegExp _controlCharPattern = RegExp(r'[\n\r\t]');

  /// Comprimento mínimo esperado para um código de barras
  static const int _minBarcodeLength = 8;

  /// Comprimento mínimo para códigos completos (EAN-13+)
  static const int _completeBarcodeMinLength = 13;

  /// Comprimento máximo para códigos completos
  static const int _completeBarcodeMaxLength = 16;

  /// Comprimento mínimo para entrada via teclado
  static const int _minKeyboardLength = 3;

  /// Comprimento mínimo para entrada via scanner
  static const int _minScannerLength = 8;

  /// Limpa recursos quando não precisar mais do serviço
  void dispose() {
    _debounceTimer?.cancel();
  }

  /// Processa entrada de código de barras com debounce
  ///
  /// Cancela timer anterior e agenda novo timer para detectar quando usuário parou de digitar.
  /// - Se vazio: ignora
  /// - Se código completo (13-16 dígitos): processa imediatamente
  /// - Caso contrário: aguarda 20ms sem nova entrada
  void processBarcodeInput(String input, void Function(String) onCompleteBarcode, void Function() onWaitForMore) {
    if (input.isEmpty) return;

    // Detecção específica para códigos completos (13-16 dígitos) - processar imediatamente
    if (_isCompleteBarcode(input)) {
      _debounceTimer?.cancel();
      onCompleteBarcode(input);
      return;
    }

    // Cancelar timer anterior e agendar novo
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceTimeout, () {
      _processInputAfterDebounce(input, onCompleteBarcode, onWaitForMore);
    });
  }

  /// Processa entrada após debounce - usuário parou de digitar
  void _processInputAfterDebounce(
    String input,
    void Function(String) onCompleteBarcode,
    void Function() onWaitForMore,
  ) {
    // Só processar códigos com pelo menos 8 dígitos
    if (input.length < _minBarcodeLength) {
      onWaitForMore();
      return;
    }

    // Processar códigos válidos (8+ dígitos)
    if (_isValidBarcode(input)) {
      onCompleteBarcode(input);
      return;
    }

    // Entrada longa mas formato inválido, aguardar mais
    onWaitForMore();
  }

  /// Processa entrada com detecção de caracteres de controle
  ///
  /// Versão alternativa que detecta caracteres de controle (Enter, Return, Tab)
  /// e processa imediatamente quando encontrados.
  void processBarcodeInputWithControlDetection(
    String input,
    void Function(String) onCompleteBarcode,
    void Function() onWaitForMore,
  ) {
    if (input.isEmpty) return;

    final text = input.trim();

    // Verificar se há caracteres de controle no texto completo
    if (_controlCharPattern.hasMatch(text)) {
      _debounceTimer?.cancel();
      onCompleteBarcode(text);
      return;
    }

    // Usar processamento normal com debounce
    processBarcodeInput(input, onCompleteBarcode, onWaitForMore);
  }

  /// Limpa caracteres especiais de um texto
  ///
  /// Remove caracteres não numéricos que podem vir do scanner
  /// (incluindo Enter/Return/Tab/etc)
  String cleanBarcodeText(String text) {
    return text.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Valida se um código de barras tem comprimento mínimo
  ///
  /// Considera diferentes comprimentos mínimos para teclado vs scanner
  bool isValidBarcodeLength(String text, {bool isKeyboardInput = false}) {
    final minLength = isKeyboardInput ? _minKeyboardLength : _minScannerLength;
    return text.length >= minLength;
  }

  /// Verifica se a entrada tem formato de código de barras válido
  bool _isValidBarcode(String input) => _barcodePattern.hasMatch(input);

  /// Verifica se a entrada é um código completo (13-16 dígitos)
  bool _isCompleteBarcode(String input) =>
      input.length >= _completeBarcodeMinLength &&
      input.length <= _completeBarcodeMaxLength &&
      _completeBarcodePattern.hasMatch(input);
}
