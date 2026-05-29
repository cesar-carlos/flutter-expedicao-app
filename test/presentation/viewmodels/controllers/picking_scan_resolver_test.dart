import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/services/barcode_validation_service.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_unidade_medida_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/tipo_fator_conversao_model.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/picking_scan_resolver.dart';
import 'package:data7_expedicao/presentation/viewmodels/picking_scan_result.dart';

void main() {
  late PickingScanResolver resolver;
  late List<String> matchedShelves;
  late List<_RecordedScan> recordedScans;
  late Map<String, int> pickedQuantities;
  late Set<String> completedItems;

  setUp(() {
    BarcodeValidationService.clearCaches();
    resolver = const PickingScanResolver();
    matchedShelves = [];
    recordedScans = [];
    pickedQuantities = {};
    completedItems = {};
  });

  ScanProcessResult callResolve({
    String barcode = '7891234567890',
    int inputQuantity = 1,
    bool isCartInSeparation = true,
    List<SeparateItemConsultationModel>? items,
    int? userSectorCode,
    bool requiresShelfScanning = false,
    String? lastScannedAddress,
    bool Function(SeparateItemConsultationModel)? shouldScanShelfFor,
    bool allowOutOfSequence = false,
  }) {
    return resolver.resolve(
      barcode: barcode,
      inputQuantity: inputQuantity,
      isCartInSeparation: isCartInSeparation,
      items: items ?? [_buildItem()],
      userSectorCode: userSectorCode,
      requiresShelfScanning: requiresShelfScanning,
      lastScannedAddress: lastScannedAddress,
      onShelfAddressMatched: matchedShelves.add,
      isItemCompleted: completedItems.contains,
      getPickedQuantity: (id) => pickedQuantities[id] ?? 0,
      shouldScanShelfFor: shouldScanShelfFor,
      onScanRecorded: (b, t, s, e) => recordedScans.add(_RecordedScan(b, s, e)),
      allowOutOfSequence: allowOutOfSequence,
    );
  }

  group('PickingScanResolver - early returns', () {
    test('barcode vazio retorna ignored e registra metrica', () {
      final result = callResolve(barcode: '   ');
      expect(result.status, ScanProcessStatus.ignored);
      expect(recordedScans.single.success, isFalse);
      expect(recordedScans.single.errorMessage, contains('vazio'));
    });

    test('cart nao em separacao retorna cartNotInSeparation', () {
      final result = callResolve(isCartInSeparation: false);
      expect(result.status, ScanProcessStatus.cartNotInSeparation);
    });
  });

  group('PickingScanResolver - shelf scanning', () {
    test('shelf scanning desativado: nao valida prateleira', () {
      final result = callResolve(
        requiresShelfScanning: false,
        items: [_buildItem(endereco: '01-A-2')],
      );
      // Vai pro fluxo normal de validacao do produto.
      expect(result.status, isNot(ScanProcessStatus.wrongShelf));
    });

    test('quando endereco eh diferente do esperado, retorna wrongShelf', () {
      final result = callResolve(
        barcode: '02-B-3',
        requiresShelfScanning: true,
        items: [_buildItem(endereco: '01-A-2')],
        lastScannedAddress: null,
      );
      expect(result.status, ScanProcessStatus.wrongShelf);
      expect(result.expectedShelf, equals('01-A-2'));
      expect(result.scannedShelf, equals('02-B-3'));
      expect(matchedShelves, isEmpty);
    });

    test('quando endereco bate, retorna shelfScanned e chama onShelfAddressMatched', () {
      final result = callResolve(
        barcode: '01-A-2',
        requiresShelfScanning: true,
        items: [_buildItem(endereco: '01-A-2')],
        lastScannedAddress: null,
      );
      expect(result.status, ScanProcessStatus.shelfScanned);
      expect(matchedShelves, equals(['01-A-2']));
    });

    test('quando lastScannedAddress ja eh o esperado, segue para validacao normal', () {
      final result = callResolve(
        barcode: '7891234567890',
        requiresShelfScanning: true,
        items: [_buildItem(endereco: '01-A-2', codigoBarras: '7891234567890')],
        lastScannedAddress: '01-A-2',
      );
      expect(result.status, ScanProcessStatus.success);
    });

    test('shouldScanShelfFor=false ignora a checagem mesmo com requiresShelfScanning=true', () {
      final result = callResolve(
        barcode: '7891234567890',
        requiresShelfScanning: true,
        items: [_buildItem(endereco: '01-A-2', codigoBarras: '7891234567890')],
        shouldScanShelfFor: (_) => false,
      );
      expect(result.status, ScanProcessStatus.success);
    });

    test(
      'out-of-sequence: bipar produto de outro item pendente nao retorna wrongShelf',
      () {
        // Proximo item da ordem exige scan de prateleira (endereco 01-A-2).
        // O operador (com permissao) bipa o PRODUTO de outro item pendente.
        // Sem allowOutOfSequence isso daria wrongShelf; com a permissao, deve
        // resolver como produto (success).
        final items = [
          _buildItem(item: '1', codigoBarras: '111', endereco: '01-A-2'),
          _buildItem(item: '2', codigoBarras: '7891234567890', endereco: '09-Z-9'),
        ];
        final result = callResolve(
          barcode: '7891234567890', // produto do item 2 (fora de sequencia)
          requiresShelfScanning: true,
          items: items,
          lastScannedAddress: null,
          allowOutOfSequence: true,
        );
        expect(result.status, ScanProcessStatus.success);
        expect(result.expectedItem?.item, equals('2'));
        expect(matchedShelves, isEmpty);
      },
    );

    test(
      'out-of-sequence: codigo que nao casa com produto mantem wrongShelf',
      () {
        final items = [
          _buildItem(item: '1', codigoBarras: '111', endereco: '01-A-2'),
          _buildItem(item: '2', codigoBarras: '222', endereco: '09-Z-9'),
        ];
        final result = callResolve(
          barcode: '99-X-9', // nao bate com produto algum nem com a prateleira
          requiresShelfScanning: true,
          items: items,
          lastScannedAddress: null,
          allowOutOfSequence: true,
        );
        expect(result.status, ScanProcessStatus.wrongShelf);
        expect(result.expectedShelf, equals('01-A-2'));
      },
    );
  });

  group('PickingScanResolver - validacao do barcode', () {
    test('produto correto + quantidade dentro do limite -> success', () {
      final item = _buildItem(codigoBarras: '7891234567890', quantidade: 5);
      final result = callResolve(
        barcode: '7891234567890',
        inputQuantity: 3,
        items: [item],
      );
      expect(result.status, ScanProcessStatus.success);
      expect(result.expectedItem?.codigoBarras, equals('7891234567890'));
      expect(result.convertedQuantity, equals(3));
      expect(recordedScans.single.success, isTrue);
    });

    test('quantidade excederia o restante -> quantityExceeded', () {
      final item = _buildItem(codigoBarras: '7891234567890', quantidade: 5);
      pickedQuantities[item.item] = 3; // ja separou 3, restante = 2
      final result = callResolve(
        barcode: '7891234567890',
        inputQuantity: 5,
        items: [item],
      );
      expect(result.status, ScanProcessStatus.quantityExceeded);
      expect(result.requestedQuantity, equals(5));
      expect(result.availableQuantity, equals(2));
    });

    test('produto bipado pertence a outro setor -> wrongSector', () {
      final items = [
        _buildItem(item: '1', codigoBarras: 'XYZ', codSetorEstoque: 5),
        _buildItem(item: '2', codigoBarras: '999', codSetorEstoque: 99),
      ];
      final result = callResolve(
        barcode: '999',
        items: items,
        userSectorCode: 5,
      );
      expect(result.status, ScanProcessStatus.wrongSector);
      expect(result.scannedItem?.item, equals('2'));
    });

    test('barcode nao bate com proximo item esperado -> wrongProduct', () {
      final result = callResolve(
        barcode: '0000000000000',
        items: [_buildItem(codigoBarras: '7891234567890')],
      );
      expect(result.status, ScanProcessStatus.wrongProduct);
    });

    test('todos os itens completados -> allItemsCompleted', () {
      final item = _buildItem(item: '1');
      completedItems.add('1');
      final result = callResolve(
        barcode: '7891234567890',
        items: [item],
      );
      expect(result.status, ScanProcessStatus.allItemsCompleted);
    });

    test('usuario tem setor mas nao ha mais itens dele -> noItemsForSector', () {
      final items = [
        _buildItem(item: '1', codSetorEstoque: 99),
        _buildItem(item: '2', codSetorEstoque: 99),
      ];
      completedItems.addAll(['1', '2']);
      final result = callResolve(
        barcode: '7891234567890',
        items: items,
        userSectorCode: 5,
      );
      expect(result.status, ScanProcessStatus.noItemsForSector);
      expect(result.userSectorCode, equals(5));
    });
  });

  group('PickingScanResolver - conversao por unidade de medida', () {
    test('item com 1 unidade de medida usa inputQuantity diretamente', () {
      final item = _buildItem(
        codigoBarras: '7891234567890',
        quantidade: 100,
        unidadeMedidas: [_buildUnidade(codigoBarras: 'CX12', codUnidadeMedida: 'CX', fatorConversao: 12)],
      );
      final result = callResolve(
        barcode: '7891234567890',
        inputQuantity: 5,
        items: [item],
      );
      // Como unidadeMedidas.length <= 1, sem conversao.
      expect(result.status, ScanProcessStatus.success);
      expect(result.convertedQuantity, equals(5));
    });

    test('barcode da unidade caixa converte 2 caixas em 24 unidades', () {
      final item = _buildItem(
        codigoBarras: '7891234567890',
        quantidade: 100,
        unidadeMedidas: [
          _buildUnidade(codigoBarras: '7891234567890', codUnidadeMedida: 'UN', fatorConversao: 1),
          _buildUnidade(codigoBarras: 'CX12', codUnidadeMedida: 'CX', fatorConversao: 12),
        ],
      );
      final result = callResolve(
        barcode: 'CX12', // bipa caixa
        inputQuantity: 2, // 2 caixas
        items: [item],
      );
      expect(result.status, ScanProcessStatus.success);
      expect(result.convertedQuantity, equals(24)); // 2 caixas * 12 unidades
    });
  });
}

class _RecordedScan {
  final String barcode;
  final bool success;
  final String? errorMessage;
  _RecordedScan(this.barcode, this.success, this.errorMessage);
}

SeparateItemConsultationModel _buildItem({
  String item = '1',
  int codProduto = 10,
  String? codigoBarras = '7891234567890',
  String? codigoBarras2,
  String? endereco,
  int? codSetorEstoque,
  double quantidade = 10,
  List<SeparateItemUnidadeMedidaConsultationModel>? unidadeMedidas,
}) {
  return SeparateItemConsultationModel(
    codEmpresa: 1,
    codSepararEstoque: 100,
    item: item,
    origem: ExpeditionOrigem.separacaoEstoque,
    codOrigem: 100,
    codProduto: codProduto,
    nomeProduto: 'Produto',
    ativo: Situation.ativo,
    codTipoProduto: '1',
    codUnidadeMedida: 'UN',
    nomeUnidadeMedida: 'Unidade',
    codGrupoProduto: 1,
    nomeGrupoProduto: 'Grupo',
    codSetorEstoque: codSetorEstoque,
    codigoBarras: codigoBarras,
    codigoBarras2: codigoBarras2,
    endereco: endereco,
    enderecoDescricao: endereco,
    codLocalArmazenagem: 1,
    nomeLocaArmazenagem: 'Local',
    quantidade: quantidade,
    quantidadeInterna: quantidade,
    quantidadeExterna: 0,
    quantidadeSeparacao: 0,
    unidadeMedidas: unidadeMedidas ?? const [],
  );
}

SeparateItemUnidadeMedidaConsultationModel _buildUnidade({
  required String codigoBarras,
  String codUnidadeMedida = 'UN',
  double fatorConversao = 1,
}) {
  return SeparateItemUnidadeMedidaConsultationModel(
    codEmpresa: 1,
    codSepararEstoque: 100,
    item: '1',
    codProduto: 10,
    itemUnidadeMedida: '1',
    codUnidadeMedida: codUnidadeMedida,
    unidadeMedidaDescricao: codUnidadeMedida,
    unidadeMedidaPadrao: Situation.inativo,
    tipoFatorConversao: TipoFatorConversao.multiplicacao,
    fatorConversao: fatorConversao,
    codigoBarras: codigoBarras,
  );
}
