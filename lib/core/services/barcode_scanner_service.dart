import 'dart:async';

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

  /// Cache de validações para melhorar performance
  final Map<String, bool> _validationCache = {};

  /// Tempo de debounce para detectar quando usuário parou de digitar
  /// Reduzido para melhor responsividade com scanners rápidos
  static const Duration _debounceTimeout = Duration(milliseconds: 40);

  /// Padrão regex para validar formato de código de barras (7-16 dígitos)
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

  /// Limpa o cache de validações
  /// Útil quando há mudanças no contexto que podem afetar validações
  void clearValidationCache() {
    _validationCache.clear();
  }

  /// Limpa recursos quando não precisar mais do serviço
  void dispose() {
    _debounceTimer?.cancel();
    _validationCache.clear();
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
        onCompleteBarcode(cleanedInput);
      }
      return;
    }

    // Prioridade 2: Códigos completos (13-16 dígitos) - processar imediatamente
    if (_isCompleteBarcode(input)) {
      _debounceTimer?.cancel();
      onCompleteBarcode(input);
      return;
    }

    // Prioridade 3: Debounce como fallback para leitores sem Enter
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
    // Só processar códigos com pelo menos 7 dígitos
    if (input.length < _minBarcodeLength) {
      onWaitForMore();
      return;
    }

    // Processar códigos válidos (7+ dígitos)
    if (_isValidBarcode(input)) {
      onCompleteBarcode(input);
      return;
    }

    // Entrada longa mas formato inválido, aguardar mais
    onWaitForMore();
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
      if (cleanedInput.isNotEmpty) onCompleteBarcode(cleanedInput);

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

  /// Verifica se a entrada tem formato de código de barras válido
  /// Usa cache para melhorar performance em validações repetidas
  bool _isValidBarcode(String input) {
    // Verificar cache primeiro
    if (_validationCache.containsKey(input)) {
      return _validationCache[input]!;
    }

    // Validar e cachear resultado
    final isValid = _barcodePattern.hasMatch(input);
    _validationCache[input] = isValid;

    return isValid;
  }

  /// Verifica se a entrada é um código completo (13-16 dígitos)
  bool _isCompleteBarcode(String input) =>
      input.length >= _completeBarcodeMinLength &&
      input.length <= _completeBarcodeMaxLength &&
      _completeBarcodePattern.hasMatch(input);
}
