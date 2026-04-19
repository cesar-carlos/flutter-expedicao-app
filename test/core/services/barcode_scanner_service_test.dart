import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/services/barcode_scanner_service.dart';

void main() {
  group('BarcodeScannerService', () {
    late BarcodeScannerService service;

    setUp(() {
      service = BarcodeScannerService();
    });

    tearDown(() {
      service.dispose();
    });

    group('cleanBarcodeText', () {
      test('mantem apenas digitos, removendo letras e caracteres especiais', () {
        expect(service.cleanBarcodeText('789123\n'), equals('789123'));
        expect(service.cleanBarcodeText('AB12-34\t'), equals('1234'));
        expect(service.cleanBarcodeText('  789  '), equals('789'));
        expect(service.cleanBarcodeText(''), equals(''));
      });
    });

    group('hasEnterCharacter', () {
      test('detecta \\n, \\r e \\t como confirmacao', () {
        expect(service.hasEnterCharacter('789123\n'), isTrue);
        expect(service.hasEnterCharacter('789123\r'), isTrue);
        expect(service.hasEnterCharacter('789123\t'), isTrue);
        expect(service.hasEnterCharacter('789123'), isFalse);
      });
    });

    group('isValidBarcodeFormat', () {
      test('aceita 7 a 16 digitos', () {
        expect(service.isValidBarcodeFormat('1234567'), isTrue);
        expect(service.isValidBarcodeFormat('7891234567890'), isTrue); // EAN-13
        expect(service.isValidBarcodeFormat('1234567890123456'), isTrue); // 16
      });

      test('rejeita comprimentos fora do range', () {
        expect(service.isValidBarcodeFormat('123456'), isFalse);
        expect(service.isValidBarcodeFormat('12345678901234567'), isFalse);
        expect(service.isValidBarcodeFormat(''), isFalse);
      });

      test('rejeita codigos com letras', () {
        expect(service.isValidBarcodeFormat('ABC1234'), isFalse);
      });

      test('aceita codigo com espacos sendo trimado', () {
        expect(service.isValidBarcodeFormat('  7891234567890  '), isTrue);
      });
    });

    group('isValidBarcodeLength', () {
      test('usa minimo de 8 para scanner', () {
        expect(service.isValidBarcodeLength('1234567', isKeyboardInput: false), isFalse);
        expect(service.isValidBarcodeLength('12345678', isKeyboardInput: false), isTrue);
      });

      test('usa minimo de 3 para teclado', () {
        expect(service.isValidBarcodeLength('12', isKeyboardInput: true), isFalse);
        expect(service.isValidBarcodeLength('123', isKeyboardInput: true), isTrue);
      });
    });

    group('getBarcodeFormatInfo', () {
      test('identifica EAN-13 e EAN-8', () {
        expect(service.getBarcodeFormatInfo('7891234567890'), equals('EAN-13'));
        expect(service.getBarcodeFormatInfo('12345670'), equals('EAN-8 ou UPC-E'));
        expect(service.getBarcodeFormatInfo('123456789012'), equals('UPC-A'));
      });

      test('retorna mensagens claras para entradas invalidas', () {
        expect(service.getBarcodeFormatInfo(''), equals('Código vazio'));
        expect(service.getBarcodeFormatInfo('ABC'), equals('Formato inválido'));
      });
    });

    group('processBarcodeInput - prioridade Enter', () {
      test('processa imediatamente quando contem Enter', () async {
        String? completedCode;
        var waitCalls = 0;

        service.processBarcodeInput(
          '789123\n',
          (code) => completedCode = code,
          () => waitCalls++,
        );

        expect(completedCode, equals('789123'));
        expect(waitCalls, equals(0));
      });

      test('limpa caracteres nao-digito ao processar com Enter', () async {
        String? completedCode;
        service.processBarcodeInput('AB789-123\r', (code) => completedCode = code, () {});
        expect(completedCode, equals('789123'));
      });
    });

    group('processBarcodeInput - codigos completos', () {
      test('processa imediatamente codigo de 13 digitos', () async {
        String? completedCode;
        service.processBarcodeInput('7891234567890', (code) => completedCode = code, () {});
        expect(completedCode, equals('7891234567890'));
      });

      test('processa imediatamente codigo de 16 digitos', () async {
        String? completedCode;
        service.processBarcodeInput('1234567890123456', (code) => completedCode = code, () {});
        expect(completedCode, equals('1234567890123456'));
      });

      test('NAO processa imediatamente codigo de 12 digitos (espera debounce)', () async {
        String? completedCode;
        service.processBarcodeInput('123456789012', (code) => completedCode = code, () {});
        expect(completedCode, isNull);
      });
    });

    group('processBarcodeInput - debounce', () {
      test('processa codigo valido apos timeout do debounce', () async {
        String? completedCode;
        var waitCalls = 0;

        service.processBarcodeInput(
          '1234567', // 7 digitos: valido mas nao "completo"
          (code) => completedCode = code,
          () => waitCalls++,
        );

        expect(completedCode, isNull, reason: 'antes do debounce nao deve completar');

        await Future.delayed(const Duration(milliseconds: 60));
        expect(completedCode, equals('1234567'));
        expect(waitCalls, equals(0));
      });

      test('chama onWaitForMore quando comprimento eh menor que minimo', () async {
        var waitCalls = 0;
        String? completedCode;

        service.processBarcodeInput(
          '12345', // 5 digitos
          (code) => completedCode = code,
          () => waitCalls++,
        );

        await Future.delayed(const Duration(milliseconds: 60));
        expect(waitCalls, equals(1));
        expect(completedCode, isNull);
      });
    });

    group('processBarcodeInput - cancelamento de debounce', () {
      test('chamada subsequente cancela timer anterior', () async {
        final completed = <String>[];
        service.processBarcodeInput('1234567', (code) => completed.add(code), () {});
        service.processBarcodeInput('7891234567890', (code) => completed.add(code), () {});

        await Future.delayed(const Duration(milliseconds: 60));
        expect(completed, equals(['7891234567890']),
            reason: 'apenas o segundo (codigo completo) deve disparar');
      });
    });

    group('input vazio', () {
      test('ignora silenciosamente entrada vazia', () {
        var anyCall = false;
        service.processBarcodeInput('', (_) => anyCall = true, () => anyCall = true);
        expect(anyCall, isFalse);
      });
    });
  });
}
