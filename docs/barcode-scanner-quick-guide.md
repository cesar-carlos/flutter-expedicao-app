# Guia Rápido - Scanner de Código de Barras

## 🚀 Como Usar

### 1. Em um Widget/Screen

```dart
import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/domain/usecases/scan_barcode/scan_barcode_usecase.dart';
import 'package:data7_expedicao/domain/usecases/scan_barcode/scan_barcode_params.dart';

// No seu widget
ElevatedButton.icon(
  icon: const Icon(Icons.qr_code_scanner),
  label: const Text('Escanear'),
  onPressed: () async {
    // 1. Obter UseCase
    final scanBarcodeUseCase = locator<ScanBarcodeUseCase>();

    // 2. Executar scan
    const params = ScanBarcodeParams();
    final result = await scanBarcodeUseCase(params);

    // 3. Processar resultado
    result.fold(
      (success) {
        // ✅ Sucesso
        final barcode = success.barcode;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Código: $barcode')),
        );
      },
      (failure) {
        // ❌ Erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.userMessage),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  },
)
```

### 2. Em um ViewModel

```dart
import 'package:data7_expedicao/domain/usecases/scan_barcode/scan_barcode_usecase.dart';
import 'package:data7_expedicao/domain/usecases/scan_barcode/scan_barcode_params.dart';

class MyViewModel extends ChangeNotifier {
  final ScanBarcodeUseCase _scanBarcodeUseCase;

  String? _scannedBarcode;
  String? _errorMessage;
  bool _isLoading = false;

  String? get scannedBarcode => _scannedBarcode;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  MyViewModel(this._scanBarcodeUseCase);

  Future<void> scanBarcode() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    const params = ScanBarcodeParams();
    final result = await _scanBarcodeUseCase(params);

    result.fold(
      (success) {
        _scannedBarcode = success.barcode;
        _errorMessage = null;
      },
      (failure) {
        _scannedBarcode = null;
        _errorMessage = failure.userMessage;
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}
```

## 📝 Tipos de Erro

| Código              | Quando Ocorre           |
| ------------------- | ----------------------- |
| `SCAN_CANCELLED`    | Usuário cancelou        |
| `EMPTY_BARCODE`     | Código vazio            |
| `SCANNER_ERROR`     | Erro genérico           |
| `PERMISSION_DENIED` | Sem permissão de câmera |

## 🔄 Como Trocar de Biblioteca

### Passo 1: Adicionar nova biblioteca no `pubspec.yaml`

```yaml
dependencies:
  # mobile_scanner: ^3.0.0
```

### Passo 2: Criar nova implementação

```dart
// lib/data/repositories/barcode_scanner_repository_mobile_impl.dart

class BarcodeScannerRepositoryMobileImpl implements BarcodeScannerRepository {
  @override
  Future<Result<String>> scanBarcode() async {
    // Implementação com a nova biblioteca
  }
}
```

### Passo 3: Atualizar DI em `lib/di/locator.dart`

```dart
locator.registerLazySingleton<BarcodeScannerRepository>(
  () => BarcodeScannerRepositoryMobileImpl(), // ← Trocar aqui
);
```

**Pronto!** Nenhuma outra mudança necessária.

## 🏗️ Estrutura Criada

```
lib/
├── domain/
│   ├── repositories/
│   │   └── barcode_scanner_repository.dart       ← Interface
│   └── usecases/
│       └── scan_barcode/
│           ├── scan_barcode_params.dart
│           ├── scan_barcode_success.dart
│           ├── scan_barcode_failure.dart
│           └── scan_barcode_usecase.dart         ← UseCase
├── data/
│   └── repositories/
│       └── barcode_scanner_repository_impl.dart  ← Implementação
└── di/
    └── locator.dart                              ← DI
```

## 📦 Pacote Usado

- **Atual:** `flutter_barcode_scanner: ^2.0.0`
- **Alternativas:** `mobile_scanner`, `qr_code_scanner`, `ai_barcode_scanner`

## 🔗 Documentação Completa

Para mais detalhes sobre a arquitetura, veja:

- [Documentação Completa](./barcode-scanner-architecture.md)
- [Exemplo de Uso](../example/scan_barcode_example.dart)

## ✅ Vantagens da Arquitetura

- ✅ Fácil trocar de biblioteca (sem quebrar código existente)
- ✅ Código testável (interfaces mockáveis)
- ✅ Separação de responsabilidades (Clean Architecture)
- ✅ Tratamento de erros consistente
- ✅ Reutilizável em todo o projeto

## 🤝 Contribuindo

Ao adicionar novas funcionalidades ao scanner, siga os princípios:

1. **Domain** - Defina interfaces e casos de uso
2. **Data** - Implemente usando bibliotecas específicas
3. **DI** - Registre no locator
4. **Teste** - Crie testes unitários com mocks

---

**Desenvolvido:** Outubro 2025  
**Padrão:** Clean Architecture + Repository Pattern
