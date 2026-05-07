import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/validation/schemas/model_schema/system_qrcode_data_schema.dart';

void main() {
  group('SystemQRCodeDataSchema.safeValidate', () {
    test('should accept a valid normalized QR payload', () {
      final result = SystemQRCodeDataSchema.safeValidate(_validPayload());

      expect(result.isSuccess(), isTrue);
    });

    test('should reject CodEmpresa equal to zero', () {
      final result = SystemQRCodeDataSchema.safeValidate(_validPayload()..['CodEmpresa'] = 0);

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull().toString(), contains('CodEmpresa'));
    });

    test('should reject NomeUsuario empty', () {
      final result = SystemQRCodeDataSchema.safeValidate(_validPayload()..['NomeUsuario'] = '');

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull().toString(), contains('Campo'));
    });

    test('should reject SenhaUsuario shorter than four chars', () {
      final result = SystemQRCodeDataSchema.safeValidate(_validPayload()..['SenhaUsuario'] = '123');

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull().toString(), contains('SenhaUsuario'));
    });
  });
}

Map<String, dynamic> _validPayload() {
  return <String, dynamic>{
    'CodUsuario': 123,
    'NomeUsuario': 'Maria',
    'SenhaUsuario': '1234',
    'Ativo': 'S',
    'CodEmpresa': 1,
    'NomeEmpresa': 'Empresa Teste',
    'PermiteSepararForaSequencia': 'N',
    'VisualizaTodasSeparacoes': 'N',
    'PermiteConferirForaSequencia': 'N',
    'VisualizaTodasConferencias': 'N',
    'PermiteArmazenarForaSequencia': 'N',
    'VisualizaTodasArmazenagem': 'N',
    'EditaCarrinhoOutroUsuario': 'N',
    'SalvaCarrinhoOutroUsuario': 'N',
    'ExcluiCarrinhoOutroUsuario': 'N',
    'ExpedicaoEntregaBalcaoPreVenda': 'N',
  };
}
