import 'package:flutter_test/flutter_test.dart';
import 'package:exp/domain/models/expedition_cancellation_model.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';

void main() {
  group('ExpeditionCancellationModel', () {
    test('should create model with ExpeditionOrigem enum', () {
      final model = ExpeditionCancellationModel(
        codEmpresa: 1,
        codCancelamento: 123,
        origem: ExpeditionOrigem.orcamentoBalcao,
        codOrigem: 456,
        itemOrigem: 'ITEM001',
        codMotivoCancelamento: 1,
        dataCancelamento: DateTime(2023, 12, 25),
        horaCancelamento: '10:30:00',
        codUsuarioCancelamento: 1,
        nomeUsuarioCancelamento: 'João Silva',
        observacaoCancelamento: 'Cancelamento por falta de estoque',
      );

      expect(model.origem, ExpeditionOrigem.orcamentoBalcao);
      expect(model.origemCode, 'OB');
      expect(model.origemDescription, 'Orcamento Balcão');
    });

    test('should serialize to JSON correctly', () {
      final model = ExpeditionCancellationModel(
        codEmpresa: 1,
        codCancelamento: 123,
        origem: ExpeditionOrigem.separacaoEstoque,
        codOrigem: 456,
        itemOrigem: 'ITEM001',
        dataCancelamento: DateTime(2023, 12, 25),
        horaCancelamento: '10:30:00',
        codUsuarioCancelamento: 1,
        nomeUsuarioCancelamento: 'João Silva',
      );

      final json = model.toJson();

      expect(json['Origem'], 'SE'); // Código do enum
      expect(json['CodEmpresa'], 1);
      expect(json['CodCancelamento'], 123);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'CodEmpresa': 1,
        'CodCancelamento': 123,
        'Origem': 'CP', // Código da origem
        'CodOrigem': 456,
        'ItemOrigem': 'ITEM001',
        'CodMotivoCancelamento': 1,
        'DataCancelamento': '2023-12-25T10:30:00.000Z',
        'HoraCancelamento': '10:30:00',
        'CodUsuarioCancelamento': 1,
        'NomeUsuarioCancelamento': 'João Silva',
        'ObservacaoCancelamento': 'Teste',
      };

      final model = ExpeditionCancellationModel.fromJson(json);

      expect(model.origem, ExpeditionOrigem.compraMercadoria);
      expect(model.origemCode, 'CP');
      expect(model.origemDescription, 'Compra de Mercadoria');
    });

    test('should handle invalid origem code with fallback', () {
      final json = {
        'CodEmpresa': 1,
        'CodCancelamento': 123,
        'Origem': 'INVALID_CODE', // Código inválido
        'CodOrigem': 456,
        'ItemOrigem': 'ITEM001',
        'DataCancelamento': '2023-12-25T10:30:00.000Z',
        'HoraCancelamento': '10:30:00',
        'CodUsuarioCancelamento': 1,
        'NomeUsuarioCancelamento': 'João Silva',
      };

      final model = ExpeditionCancellationModel.fromJson(json);

      expect(model.origem, ExpeditionOrigem.vazio); // Fallback padrão
      expect(model.origemCode, '');
      expect(model.origemDescription, '');
    });

    test('should handle null origem with fallback', () {
      final json = {
        'CodEmpresa': 1,
        'CodCancelamento': 123,
        'Origem': null, // Null
        'CodOrigem': 456,
        'ItemOrigem': 'ITEM001',
        'DataCancelamento': '2023-12-25T10:30:00.000Z',
        'HoraCancelamento': '10:30:00',
        'CodUsuarioCancelamento': 1,
        'NomeUsuarioCancelamento': 'João Silva',
      };

      final model = ExpeditionCancellationModel.fromJson(json);

      expect(model.origem, ExpeditionOrigem.vazio); // Fallback padrão
    });

    test('should copy with new origem', () {
      final original = ExpeditionCancellationModel(
        codEmpresa: 1,
        codCancelamento: 123,
        origem: ExpeditionOrigem.orcamentoBalcao,
        codOrigem: 456,
        itemOrigem: 'ITEM001',
        dataCancelamento: DateTime(2023, 12, 25),
        horaCancelamento: '10:30:00',
        codUsuarioCancelamento: 1,
        nomeUsuarioCancelamento: 'João Silva',
      );

      final copied = original.copyWith(origem: ExpeditionOrigem.entregaBalcao);

      expect(copied.origem, ExpeditionOrigem.entregaBalcao);
      expect(copied.origemCode, 'EB');
      expect(copied.origemDescription, 'Entrega Balcão');
      expect(copied.codEmpresa, 1); // Outros campos mantidos
    });

    test('should have correct toString with origem description', () {
      final model = ExpeditionCancellationModel(
        codEmpresa: 1,
        codCancelamento: 123,
        origem: ExpeditionOrigem.devolucaoVenda,
        codOrigem: 456,
        itemOrigem: 'ITEM001',
        dataCancelamento: DateTime(2023, 12, 25),
        horaCancelamento: '10:30:00',
        codUsuarioCancelamento: 1,
        nomeUsuarioCancelamento: 'João Silva',
      );

      final stringRepresentation = model.toString();

      expect(stringRepresentation, contains('origem: Devolução de Venda'));
      expect(stringRepresentation, contains('codCancelamento: 123'));
    });
  });
}
