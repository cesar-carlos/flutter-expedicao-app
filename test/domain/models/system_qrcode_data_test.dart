import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:data7_expedicao/domain/models/user/system_qrcode_data.dart';

void main() {
  group('SystemQRCodeData.fromQRCodeString', () {
    test('retorna sucesso quando JSON contem os campos obrigatorios', () {
      const qrCodeContent = '{"CodUsuario":123,"NomeUsuario":"Maria","SenhaUsuario":"1234","CodEmpresa":1}';

      final result = SystemQRCodeData.fromQRCodeString(qrCodeContent);

      expect(result.isSuccess(), isTrue);
      final data = result.getOrNull()!;
      expect(data.codUsuario, equals(123));
      expect(data.nomeUsuario, equals('Maria'));
      expect(data.senhaUsuario, equals('1234'));
      expect(data.codEmpresa, equals(1));
    });

    test('retorna falha quando CodEmpresa esta ausente', () {
      const qrCodeContent = '{"CodUsuario":123,"NomeUsuario":"Maria","SenhaUsuario":"1234"}';

      final result = SystemQRCodeData.fromQRCodeString(qrCodeContent);

      final failure = result.exceptionOrNull() as ValidationFailure?;
      expect(failure, isNotNull);
      expect(failure!.message, contains('CodEmpresa'));
    });

    test('retorna falha quando JSON eh invalido', () {
      const qrCodeContent = '{"CodUsuario":123,';

      final result = SystemQRCodeData.fromQRCodeString(qrCodeContent);

      final failure = result.exceptionOrNull() as ValidationFailure?;
      expect(failure, isNotNull);
      expect(failure!.message, contains('formato JSON inválido'));
    });

    test('aplica defaults nos flags opcionais ausentes', () {
      const qrCodeContent = '''
      {
        "CodUsuario": 123,
        "NomeUsuario": "Maria",
        "SenhaUsuario": "1234",
        "CodEmpresa": 1,
        "NomeEmpresa": "Empresa Teste"
      }
      ''';

      final result = SystemQRCodeData.fromQRCodeString(qrCodeContent);

      expect(result.isSuccess(), isTrue);
      final data = result.getOrNull()!;
      expect(data.permiteSepararForaSequencia, equals('N'));
      expect(data.visualizaTodasSeparacoes, equals('N'));
      expect(data.permiteConferirForaSequencia, equals('N'));
      expect(data.visualizaTodasConferencias, equals('N'));
      expect(data.permiteArmazenarForaSequencia, equals('N'));
      expect(data.visualizaTodasArmazenagem, equals('N'));
      expect(data.editaCarrinhoOutroUsuario, equals('N'));
      expect(data.salvaCarrinhoOutroUsuario, equals('N'));
      expect(data.excluiCarrinhoOutroUsuario, equals('N'));
      expect(data.expedicaoEntregaBalcaoPreVenda, equals('N'));
    });
  });
}
