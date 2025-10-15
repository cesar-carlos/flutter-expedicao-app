# BarcodeScannerService

## Visão Geral

O `BarcodeScannerService` é um serviço centralizado que fornece funcionalidades de processamento de códigos de barras com debounce automático, validação de formatos e feedback tátil. Este serviço permite reutilização da lógica de scanner em diferentes partes da aplicação.

## Características

- ✅ **Debounce automático** de 20ms para detectar quando usuário parou de digitar
- ✅ **Detecção de códigos completos** (13-16 dígitos) para processamento imediato
- ✅ **Limpeza automática** de caracteres especiais (Enter, Tab, etc.)
- ✅ **Validação de comprimento** configurável para teclado vs scanner
- ✅ **Feedback tátil** opcional para confirmação
- ✅ **Suporte a caracteres de controle** para scanners que enviam confirmação

## Localização

```
lib/core/services/barcode_scanner_service.dart
```

## Registro no DI

O serviço está registrado como singleton no `locator.dart`:

```dart
locator.registerLazySingleton(() => BarcodeScannerService());
```

## Métodos Principais

### `processBarcodeInput()`

Processa entrada com debounce padrão:

```dart
void processBarcodeInput(
  String input,
  void Function(String) onCompleteBarcode,
  void Function() onWaitForMore,
)
```

### `processBarcodeInputWithControlDetection()`

Versão que detecta caracteres de controle:

```dart
void processBarcodeInputWithControlDetection(
  String input,
  void Function(String) onCompleteBarcode,
  void Function() onWaitForMore,
)
```

### `cleanBarcodeText()`

Limpa caracteres especiais:

```dart
String cleanBarcodeText(String text)
```

### `isValidBarcodeLength()`

Valida comprimento mínimo:

```dart
bool isValidBarcodeLength(String text, {bool isKeyboardInput = false})
```

### `provideTactileFeedback()`

Fornece feedback tátil:

```dart
void provideTactileFeedback()
```

## Exemplos de Uso

### 1. Uso Direto do Serviço

```dart
class MyScannerWidget extends StatefulWidget {
  @override
  State<MyScannerWidget> createState() => _MyScannerWidgetState();
}

class _MyScannerWidgetState extends State<MyScannerWidget> {
  final TextEditingController _controller = TextEditingController();
  final BarcodeScannerService _scannerService = locator<BarcodeScannerService>();

  void _onInput() {
    _scannerService.processBarcodeInputWithControlDetection(
      _controller.text,
      (barcode) => _handleCompleteBarcode(barcode),
      () => _handleDebouncedInput(),
    );
  }

  void _handleCompleteBarcode(String barcode) {
    // Processar código completo
    print('Código completo: $barcode');
    _scannerService.provideTactileFeedback();
  }

  void _handleDebouncedInput() {
    final cleanText = _scannerService.cleanBarcodeText(_controller.text);
    if (_scannerService.isValidBarcodeLength(cleanText)) {
      _handleCompleteBarcode(cleanText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (_) => _onInput(),
    );
  }
}
```

### 2. Uso do Widget Genérico

```dart
GenericBarcodeScanner(
  onBarcodeScanned: (barcode) {
    print('Código escaneado: $barcode');
  },
  minLength: 6,
  enableTactileFeedback: true,
  hintText: 'Escaneie o código',
  decoration: InputDecoration(
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.qr_code_scanner),
  ),
)
```

### 3. Validação Customizada

```dart
void _validateCustomBarcode(String text) {
  final cleanText = _scannerService.cleanBarcodeText(text);

  // Validação customizada
  if (cleanText.length >= 8 && cleanText.length <= 12) {
    // Processar código customizado
    _processCustomBarcode(cleanText);
  } else {
    // Código inválido
    _showError('Código deve ter entre 8 e 12 dígitos');
  }
}
```

## Configurações

### Comprimentos Mínimos

- **Scanner**: 6 dígitos (padrão)
- **Teclado**: 3 dígitos (padrão)
- **Códigos completos**: 13-16 dígitos (EAN-13+)

### Debounce

- **Timeout**: 20ms
- **Objetivo**: Detectar quando usuário parou de digitar

### Caracteres de Controle

Detecta automaticamente:

- `\n` (Enter)
- `\r` (Return)
- `\t` (Tab)

## Migração

### Antes (código duplicado)

```dart
// Em cada widget
Timer? _scanTimer;
static const Duration _debounceTimeout = Duration(milliseconds: 20);
static final RegExp _barcodePattern = RegExp(r'^\d{6,16}$');

void _onInput() {
  _scanTimer?.cancel();
  _scanTimer = Timer(_debounceTimeout, () {
    // lógica duplicada...
  });
}
```

### Depois (usando serviço)

```dart
// Em qualquer widget
final BarcodeScannerService _scannerService = locator<BarcodeScannerService>();

void _onInput() {
  _scannerService.processBarcodeInput(
    _controller.text,
    _handleComplete,
    _handleWait,
  );
}
```

## Benefícios

1. **Reutilização**: Lógica centralizada e reutilizável
2. **Consistência**: Comportamento uniforme em toda aplicação
3. **Manutenibilidade**: Mudanças em um lugar afetam toda aplicação
4. **Testabilidade**: Serviço isolado e testável
5. **Performance**: Debounce otimizado e validações eficientes

## Arquivos Relacionados

- `lib/core/services/barcode_scanner_service.dart` - Serviço principal
- `lib/ui/widgets/scanner/generic_barcode_scanner.dart` - Widget genérico
- `example/barcode_scanner_service_example.dart` - Exemplos de uso
- `lib/ui/widgets/card_picking/components/scan_input_processor.dart` - Implementação no picking
- `lib/ui/widgets/add_cart/barcode_scanner_widget.dart` - Implementação no add cart
