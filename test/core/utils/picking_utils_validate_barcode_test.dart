import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/utils/picking_utils.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_unidade_medida_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/tipo_fator_conversao_model.dart';

void main() {
  group('PickingUtils.validateBarcode', () {
    test('aceita codigoBarras principal', () {
      final item = _buildItem(codigoBarras: '7891234567890');
      expect(PickingUtils.validateBarcode('7891234567890', item), isTrue);
    });

    test('aceita codigoBarras2 alternativo', () {
      final item = _buildItem(codigoBarras: '7891234567890', codigoBarras2: '0000000000123');
      expect(PickingUtils.validateBarcode('0000000000123', item), isTrue);
    });

    test('aceita codigo de unidade de medida', () {
      final item = _buildItem(
        codigoBarras: '7891234567890',
        unidadeMedidas: [
          _buildUnidade(codigoBarras: 'CX12345678'),
        ],
      );
      expect(PickingUtils.validateBarcode('CX12345678', item), isTrue);
    });

    test('faz trim no codigo recebido', () {
      final item = _buildItem(codigoBarras: '7891234567890');
      expect(PickingUtils.validateBarcode('  7891234567890  ', item), isTrue);
    });

    test('rejeita codigo diferente', () {
      final item = _buildItem(codigoBarras: '7891234567890');
      expect(PickingUtils.validateBarcode('0000000000000', item), isFalse);
    });

    test('rejeita quando item nao tem nenhum codigoBarras', () {
      final item = _buildItem(codigoBarras: null, codigoBarras2: null);
      expect(PickingUtils.validateBarcode('7891234567890', item), isFalse);
    });
  });

  group('PickingUtils.validateShelfBarcode', () {
    test('aceita endereco identico apos trim', () {
      final item = _buildItem(endereco: '01-A-2');
      expect(PickingUtils.validateShelfBarcode('01-A-2', item), isTrue);
      expect(PickingUtils.validateShelfBarcode('  01-A-2  ', item), isTrue);
    });

    test('CRITICO: rejeita endereco com hifen quando recebido sem hifen', () {
      // REGRA DE NEGOCIO: a validacao eh exata. Endereco "01-A-2" so vale como "01-A-2".
      // Se a UI estiver removendo hifens antes de validar, ESSE TESTE BATE NO BUG.
      final item = _buildItem(endereco: '01-A-2');
      expect(PickingUtils.validateShelfBarcode('01A2', item), isFalse);
    });

    test('rejeita endereco vazio ou null', () {
      final item = _buildItem(endereco: null);
      expect(PickingUtils.validateShelfBarcode('01-A-2', item), isFalse);
    });

    test('rejeita codigo divergente', () {
      final item = _buildItem(endereco: '01-A-2');
      expect(PickingUtils.validateShelfBarcode('02-B-3', item), isFalse);
    });
  });
}

SeparateItemConsultationModel _buildItem({
  String? codigoBarras = '7891234567890',
  String? codigoBarras2,
  String? endereco,
  int? codSetorEstoque,
  List<SeparateItemUnidadeMedidaConsultationModel>? unidadeMedidas,
  String item = '1',
}) {
  return SeparateItemConsultationModel(
    codEmpresa: 1,
    codSepararEstoque: 100,
    item: item,
    origem: ExpeditionOrigem.separacaoEstoque,
    codOrigem: 100,
    codProduto: 10,
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
