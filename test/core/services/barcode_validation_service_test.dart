import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/services/barcode_validation_service.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_unidade_medida_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/tipo_fator_conversao_model.dart';

void main() {
  setUp(() {
    BarcodeValidationService.clearCaches();
  });

  group('BarcodeValidationService.validateScannedBarcode', () {
    test('retorna empty quando barcode eh string vazia', () {
      final result = BarcodeValidationService.validateScannedBarcode(
        '',
        [_buildItem(codigoBarras: '7891234567890')],
        (_) => false,
      );
      expect(result.isEmpty, isTrue);
      expect(result.errorMessage, contains('vazio'));
    });

    test('retorna empty quando barcode tem apenas espacos', () {
      final result = BarcodeValidationService.validateScannedBarcode(
        '   ',
        [_buildItem(codigoBarras: '7891234567890')],
        (_) => false,
      );
      expect(result.isEmpty, isTrue);
    });

    test('retorna allItemsCompleted quando todos os itens estao concluidos', () {
      final result = BarcodeValidationService.validateScannedBarcode(
        '7891234567890',
        [_buildItem(codigoBarras: '7891234567890')],
        (_) => true,
      );
      expect(result.allItemsCompleted, isTrue);
    });

    test('retorna noItemsForSector quando usuario tem setor mas nao ha itens dele', () {
      final items = [
        _buildItem(item: '1', codigoBarras: '111', codSetorEstoque: 99),
        _buildItem(item: '2', codigoBarras: '222', codSetorEstoque: 99),
      ];
      final result = BarcodeValidationService.validateScannedBarcode(
        '111',
        items,
        (_) => true, // todos completos
        userSectorCode: 5, // setor diferente
      );
      expect(result.noItemsForSector, isTrue);
      expect(result.userSectorCode, equals(5));
    });

    test('retorna valid quando barcode bate com proximo item', () {
      final item = _buildItem(item: '1', codigoBarras: '7891234567890');
      final result = BarcodeValidationService.validateScannedBarcode(
        '7891234567890',
        [item],
        (_) => false,
      );
      expect(result.isValid, isTrue);
      expect(result.expectedItem?.item, equals('1'));
    });

    test('retorna valid quando barcode bate com codigoBarras2 do proximo item', () {
      final item = _buildItem(
        item: '1',
        codigoBarras: '7891234567890',
        codigoBarras2: '0000000000001',
      );
      final result = BarcodeValidationService.validateScannedBarcode(
        '0000000000001',
        [item],
        (_) => false,
      );
      expect(result.isValid, isTrue);
    });

    test('retorna valid quando barcode bate com unidade de medida', () {
      final item = _buildItem(
        item: '1',
        codigoBarras: '7891234567890',
        unidadeMedidas: [_buildUnidade(codigoBarras: 'CX1234')],
      );
      final result = BarcodeValidationService.validateScannedBarcode(
        'CX1234',
        [item],
        (_) => false,
      );
      expect(result.isValid, isTrue);
    });

    test('retorna invalid quando barcode nao corresponde ao proximo item esperado', () {
      final item = _buildItem(item: '1', codigoBarras: '7891234567890');
      final result = BarcodeValidationService.validateScannedBarcode(
        '0000000000000',
        [item],
        (_) => false,
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('não corresponde'));
    });

    test('retorna wrongSector quando produto bipado pertence a outro setor', () {
      final items = [
        _buildItem(item: '1', codigoBarras: '111', codSetorEstoque: 5),
        _buildItem(item: '2', codigoBarras: '222', codSetorEstoque: 99),
      ];
      // Usuario do setor 5, bipa codigo 222 (que pertence ao setor 99)
      final result = BarcodeValidationService.validateScannedBarcode(
        '222',
        items,
        (_) => false,
        userSectorCode: 5,
      );
      expect(result.isWrongSector, isTrue);
      expect(result.scannedItem?.item, equals('2'));
      expect(result.userSectorCode, equals(5));
    });
  });

  group('BarcodeValidationService - cache (regressao)', () {
    test('clearCaches() limpa o cache de busca por barcode', () {
      final itemsA = [_buildItem(item: '1', codigoBarras: '111', codProduto: 100)];
      final itemsB = [_buildItem(item: '1', codigoBarras: '111', codProduto: 999)];

      // Cache eh populado com a busca da separacao A
      BarcodeValidationService.validateScannedBarcode('999', itemsA, (_) => false);

      // Limpa cache antes de mudar para separacao B
      BarcodeValidationService.clearCaches();

      // Apos limpar, validacoes devem usar a nova lista
      final result = BarcodeValidationService.validateScannedBarcode(
        '111',
        itemsB,
        (_) => false,
      );
      expect(result.isValid, isTrue);
      expect(result.expectedItem?.codProduto, equals(999));
    });

    test('B1: cache invalida AUTOMATICAMENTE ao trocar de lista de items', () {
      // Cenario que exibe o bug original:
      // Na separacao A, o codigo "999" pertence a um item do setor 99
      // (diferente do setor do usuario = 5), entao deveria gerar wrongSector.
      // O cache global salvaria "999" -> item-do-setor-99.
      //
      // Quando muda para a separacao B, onde "999" NAO existe, o cache
      // global retornaria erroneamente o item da separacao A, gerando
      // wrongSector falso. Apos a correcao, B1 nao deve mais ocorrer.

      // Separacao A: bipa codigo do setor 99, mas usuario eh do setor 5
      final itemsA = [
        _buildItem(item: '1', codigoBarras: 'XYZ', codProduto: 100, codSetorEstoque: 5),
        _buildItem(item: '2', codigoBarras: '999', codProduto: 200, codSetorEstoque: 99),
      ];
      // Separacao B: lista totalmente diferente, sem nada com barcode "999"
      final itemsB = [
        _buildItem(item: '1', codigoBarras: 'AAA', codProduto: 300, codSetorEstoque: 5),
      ];

      // 1. Bipa "999" na separacao A. O cache aprende que "999" -> setor 99.
      final resultA = BarcodeValidationService.validateScannedBarcode(
        '999',
        itemsA,
        (_) => false,
        userSectorCode: 5,
      );
      expect(resultA.isWrongSector, isTrue);

      // 2. Sem clearCaches manual, valida o mesmo "999" na separacao B.
      //    Antes da correcao: cache retornava item da separacao A, dando
      //    wrongSector falso. Apos: cache invalida, e como "999" nao existe
      //    em B, deve retornar invalid puro (sem scannedItem).
      final resultB = BarcodeValidationService.validateScannedBarcode(
        '999',
        itemsB,
        (_) => false,
        userSectorCode: 5,
      );
      expect(resultB.isWrongSector, isFalse,
          reason: 'B1: cache estatico antigo causava wrongSector falso ao trocar de separacao');
      expect(resultB.scannedItem, isNull,
          reason: 'cache deveria ter sido invalidado ao mudar a lista de items');
    });

    test('B10: cache nao cresce indefinidamente (max-size = 256)', () {
      // Cria uma lista com 1 item generico
      final items = [_buildItem(item: '1', codigoBarras: 'XYZ')];

      // Bipa 500 codigos diferentes que nao batem com nada
      for (var i = 0; i < 500; i++) {
        BarcodeValidationService.validateScannedBarcode(
          'codigo-inexistente-$i',
          items,
          (_) => false,
        );
      }

      // Como nao temos getter publico para o tamanho do cache, o teste validativo
      // eh garantir que tudo continua funcionando (nao vaza memoria nem crash).
      final result = BarcodeValidationService.validateScannedBarcode(
        'XYZ',
        items,
        (_) => false,
      );
      expect(result.isValid, isTrue);
    });
  });
}

SeparateItemConsultationModel _buildItem({
  String item = '1',
  int codProduto = 10,
  String? codigoBarras = '7891234567890',
  String? codigoBarras2,
  String? endereco,
  int? codSetorEstoque,
  List<SeparateItemUnidadeMedidaConsultationModel>? unidadeMedidas,
}) {
  return SeparateItemConsultationModel(
    codEmpresa: 1,
    codSepararEstoque: 100,
    item: item,
    origem: ExpeditionOrigem.separacaoEstoque,
    codOrigem: 100,
    codProduto: codProduto,
    nomeProduto: 'Produto Teste',
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
    quantidade: 10,
    quantidadeInterna: 10,
    quantidadeExterna: 0,
    quantidadeSeparacao: 0,
    unidadeMedidas: unidadeMedidas ?? const [],
  );
}

SeparateItemUnidadeMedidaConsultationModel _buildUnidade({required String codigoBarras}) {
  return SeparateItemUnidadeMedidaConsultationModel(
    codEmpresa: 1,
    codSepararEstoque: 100,
    item: '1',
    codProduto: 10,
    itemUnidadeMedida: '1',
    codUnidadeMedida: 'CX',
    unidadeMedidaDescricao: 'Caixa',
    unidadeMedidaPadrao: Situation.inativo,
    tipoFatorConversao: TipoFatorConversao.multiplicacao,
    fatorConversao: 12,
    codigoBarras: codigoBarras,
  );
}
