import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/services/shelf_scanning_service.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';

import '../../mocks/user_system_model_mock.dart';

void main() {
  group('ShelfScanningService', () {
    late ShelfScanningService service;

    setUp(() {
      service = ShelfScanningService();
    });

    SeparateItemConsultationModel buildItem({String? endereco}) {
      return SeparateItemConsultationModel(
        codEmpresa: 1,
        codSepararEstoque: 100,
        item: '001',
        origem: ExpeditionOrigem.separacaoEstoque,
        codOrigem: 100,
        codProduto: 1,
        nomeProduto: 'P',
        ativo: Situation.ativo,
        codTipoProduto: '1',
        codUnidadeMedida: 'UN',
        nomeUnidadeMedida: 'UN',
        codGrupoProduto: 1,
        nomeGrupoProduto: 'G',
        codSetorEstoque: 1,
        nomeSetorEstoque: 'S',
        codigoBarras: '1',
        endereco: endereco,
        enderecoDescricao: endereco,
        codLocalArmazenagem: 1,
        nomeLocaArmazenagem: 'L',
        quantidade: 10,
        quantidadeInterna: 10,
        quantidadeExterna: 0,
        quantidadeSeparacao: 0,
        unidadeMedidas: const [],
      );
    }

    test('requiresShelfScanning segue flag do usuario', () {
      expect(service.requiresShelfScanning(createTestUserSystem()), isTrue);
      expect(service.requiresShelfScanning(createInactiveTestUserSystem()), isFalse);
      expect(service.requiresShelfScanning(null), isFalse);
    });

    test('shouldScanShelf false quando obrigacao desligada', () {
      expect(service.shouldScanShelf(buildItem(endereco: 'A1'), createInactiveTestUserSystem()), isFalse);
    });

    test('shouldScanShelf false quando endereco vazio', () {
      expect(service.shouldScanShelf(buildItem(endereco: null), createTestUserSystem()), isFalse);
      expect(service.shouldScanShelf(buildItem(endereco: ''), createTestUserSystem()), isFalse);
    });

    test('shouldScanShelf true no primeiro endereco quando obrigatorio', () {
      expect(service.shouldScanShelf(buildItem(endereco: 'A1'), createTestUserSystem()), isTrue);
    });

    test('shouldScanShelf true quando endereco muda', () {
      service.updateScannedAddress('A1');
      expect(service.shouldScanShelf(buildItem(endereco: 'B2'), createTestUserSystem()), isTrue);
    });

    test('shouldScanShelf false quando mesmo endereco ja escaneado', () {
      service.updateScannedAddress('A1');
      expect(service.shouldScanShelf(buildItem(endereco: 'A1'), createTestUserSystem()), isFalse);
    });

    test('resetScannedAddress limpa estado', () {
      service.updateScannedAddress('A1');
      service.resetScannedAddress();
      expect(service.shouldScanShelf(buildItem(endereco: 'A1'), createTestUserSystem()), isTrue);
    });

    test('validateScannedAddress modo scan compara endereco literal', () {
      expect(
        service.validateScannedAddress(
          scannedAddress: 'X1',
          expectedAddress: 'X1',
          expectedAddressDescription: 'desc',
          isManualMode: false,
        ),
        isTrue,
      );
      expect(
        service.validateScannedAddress(
          scannedAddress: 'x1',
          expectedAddress: 'X1',
          expectedAddressDescription: 'desc',
          isManualMode: false,
        ),
        isFalse,
      );
    });

    test('validateScannedAddress modo manual ignora case na descricao', () {
      expect(
        service.validateScannedAddress(
          scannedAddress: 'Prateleira A',
          expectedAddress: 'X',
          expectedAddressDescription: 'prateleira a',
          isManualMode: true,
        ),
        isTrue,
      );
    });

    test('cleanScannedAddress preserva letras, hifens e pontos', () {
      expect(service.cleanScannedAddress('01-A-2'), equals('01-A-2'));
      expect(service.cleanScannedAddress('A.01-02'), equals('A.01-02'));
    });

    test('cleanScannedAddress remove controles e espacos externos', () {
      expect(service.cleanScannedAddress('  01-A-2\n'), equals('01-A-2'));
      expect(service.cleanScannedAddress('\tA.01-02\r'), equals('A.01-02'));
    });

    test('shouldShowInitialShelfScan retorna proximo item quando aplicavel', () {
      final items = [buildItem(endereco: 'Z9')];
      final next = items.first;
      final result = service.shouldShowInitialShelfScan(items, createTestUserSystem(), () => next);
      expect(result, equals(next));
    });

    test('shouldShowInitialShelfScan null quando lista vazia', () {
      expect(service.shouldShowInitialShelfScan([], createTestUserSystem(), () => null), isNull);
    });
  });
}
