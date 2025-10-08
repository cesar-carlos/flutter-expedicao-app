// ignore_for_file: unused_local_variable, avoid_print

import 'package:exp/di/locator.dart';
import 'package:exp/domain/usecases/scan_barcode/scan_barcode_usecase.dart';
import 'package:exp/domain/usecases/scan_barcode/scan_barcode_params.dart';
import 'package:exp/domain/usecases/scan_barcode/scan_barcode_failure.dart';

/// Exemplo de uso do ScanBarcodeUseCase
///
/// Este exemplo mostra como usar o caso de uso para escanear
/// códigos de barras usando a câmera do dispositivo Android.
void main() async {
  // 1. Obter o UseCase do locator (dependency injection)
  final scanBarcodeUseCase = locator<ScanBarcodeUseCase>();

  // 2. Preparar parâmetros (não requer parâmetros neste caso)
  const params = ScanBarcodeParams();

  // 3. Executar o scan
  final result = await scanBarcodeUseCase(params);

  // 4. Processar resultado
  result.fold(
    (success) {
      // Sucesso: código de barras escaneado
      print('Código escaneado: ${success.barcode}');
      print('Mensagem: ${success.message}');

      // Aqui você pode:
      // - Salvar o código no banco
      // - Buscar produto por código
      // - Validar o código
      // - etc.
    },
    (failure) {
      // Falha: erro ao escanear
      if (failure is ScanBarcodeFailure) {
        print('Erro: ${failure.message}');
        print('Código: ${failure.code}');
      } else {
        print('Erro: $failure');
      }

      // Tipos de falha possíveis:
      // - SCAN_CANCELLED: usuário cancelou
      // - EMPTY_BARCODE: código vazio
      // - SCANNER_ERROR: erro genérico
      // - PERMISSION_DENIED: sem permissão de câmera
    },
  );
}

/// Exemplo de uso em um ViewModel
class ExampleViewModel {
  final ScanBarcodeUseCase _scanBarcodeUseCase;

  ExampleViewModel(this._scanBarcodeUseCase);

  Future<void> openScanner() async {
    const params = ScanBarcodeParams();
    final result = await _scanBarcodeUseCase(params);

    result.fold(
      (success) {
        // Processar código escaneado
        final barcode = success.barcode;
        print('Código: $barcode');
      },
      (failure) {
        // Mostrar erro ao usuário
        if (failure is ScanBarcodeFailure) {
          print('Erro: ${failure.userMessage}');
        } else {
          print('Erro: $failure');
        }
      },
    );
  }
}

/// Exemplo de uso em um Widget (Flutter)
/// 
/// ```dart
/// class ScannerButton extends StatelessWidget {
///   const ScannerButton({super.key});
/// 
///   @override
///   Widget build(BuildContext context) {
///     return ElevatedButton.icon(
///       icon: const Icon(Icons.qr_code_scanner),
///       label: const Text('Escanear'),
///       onPressed: () async {
///         final scanBarcodeUseCase = locator<ScanBarcodeUseCase>();
///         const params = ScanBarcodeParams();
///         
///         final result = await scanBarcodeUseCase(params);
///         
///         result.fold(
///           (success) {
///             ScaffoldMessenger.of(context).showSnackBar(
///               SnackBar(content: Text('Código: ${success.barcode}')),
///             );
///           },
///           (failure) {
///             ScaffoldMessenger.of(context).showSnackBar(
///               SnackBar(
///                 content: Text(failure.userMessage),
///                 backgroundColor: Colors.red,
///               ),
///             );
///           },
///         );
///       },
///     );
///   }
/// }
/// ```

