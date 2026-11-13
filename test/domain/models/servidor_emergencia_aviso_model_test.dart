import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/servidor_emergencia_aviso_model.dart';

void main() {
  group('ServidorEmergenciaAvisoModel', () {
    test('should read Data[0] without Session', () {
      final aviso = ServidorEmergenciaAvisoModel.fromPayload({
        'Data': [
          {
            'Nivel': 'aviso',
            'Codigo': 'SERVIDOR_AVISO',
            'Mensagem': 'Servidor em manutencao em 10 minutos.',
            'Acao': 'nenhuma',
            'PrazoMs': 0,
            'EmitidoEm': '2026-11-13T12:00:00.000Z',
          },
        ],
      });

      expect(aviso, isNotNull);
      expect(aviso!.nivel, 'aviso');
      expect(aviso.codigo, 'SERVIDOR_AVISO');
      expect(aviso.mensagem, 'Servidor em manutencao em 10 minutos.');
      expect(aviso.acao, 'nenhuma');
      expect(aviso.vaiDesconectar, isFalse);
      expect(aviso.titulo, 'Aviso do servidor');
      expect(aviso.detalhe, aviso.mensagem);
    });

    test('should accept JSON string and Acao=desconectar', () {
      final aviso = ServidorEmergenciaAvisoModel.fromPayload(
        jsonEncode({
          'Data': [
            {
              'Nivel': 'desconectar',
              'Codigo': 'SERVIDOR_DESCONECTAR',
              'Mensagem': 'Sessao encerrada pelo operador.',
              'Acao': 'desconectar',
              'PrazoMs': 10000,
            },
          ],
        }),
      );

      expect(aviso, isNotNull);
      expect(aviso!.vaiDesconectar, isTrue);
      expect(aviso.prazoMs, 10000);
      expect(aviso.titulo, 'Sessão será encerrada');
      expect(aviso.detalhe, contains('10 segundos'));
      expect(aviso.detalhe, isNot(contains('Erro ao')));
    });

    test('should classify urgente and reject empty Data', () {
      final urgente = ServidorEmergenciaAvisoModel.fromJson({'Nivel': 'urgente', 'Mensagem': 'Base saturada'});
      expect(urgente.titulo, 'Aviso urgente');
      expect(urgente.acao, 'nenhuma');

      expect(ServidorEmergenciaAvisoModel.fromPayload({'Data': <Object>[]}), isNull);
      expect(ServidorEmergenciaAvisoModel.fromPayload(null), isNull);
    });
  });
}
