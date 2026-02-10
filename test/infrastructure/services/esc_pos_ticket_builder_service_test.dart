import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:data7_expedicao/domain/models/expedition_item_print_consultation_model.dart';
import 'package:data7_expedicao/infrastructure/services/esc_pos_ticket_builder_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EscPosTicketBuilderService', () {
    const service = EscPosTicketBuilderService();

    test('deve gerar bytes para ticket de teste da impressora', () async {
      final bytes = await service.buildPrinterTestTicketBytes(
        printerName: 'Impressora Expedicao',
        printerIp: '192.168.0.200',
        printerPort: 9100,
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(20));
    });

    test('deve gerar ticket com logo quando imagem for valida', () async {
      final logo = img.Image(width: 32, height: 16);
      img.fill(logo, color: img.ColorRgb8(0, 0, 0));
      final logoBytes = Uint8List.fromList(img.encodePng(logo));

      final bytes = await service.buildPrinterTestTicketBytes(
        printerName: 'Impressora Expedicao',
        printerIp: '192.168.0.200',
        printerPort: 9100,
        logoBytes: logoBytes,
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(20));
    });

    test('deve ignorar logo invalida sem falhar o ticket', () async {
      final bytes = await service.buildExpeditionTicketBytes(
        items: [_buildItem()],
        logoBytes: Uint8List.fromList([1, 2, 3, 4, 5]),
      );

      expect(bytes, isNotEmpty);
    });

    test('deve gerar bytes para ticket de expedicao com itens reais', () async {
      final bytes = await service.buildExpeditionTicketBytes(
        items: [_buildItem()],
        separatorName: 'JOAO',
        autoCut: true,
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(100));
    });

    test('deve lancar StateError quando lista de itens estiver vazia', () async {
      expect(() => service.buildExpeditionTicketBytes(items: const []), throwsA(isA<StateError>()));
    });
  });
}

ExpeditionItemPrintConsultationModel _buildItem() {
  return ExpeditionItemPrintConsultationModel(
    codEmpresa: 1,
    codSepararEstoque: 2,
    item: '1',
    origem: 'SEPARACAO_ESTOQUE',
    codOrigem: 4242,
    itemOrigem: '1',
    dataSepararEstoque: DateTime(2026, 2, 9),
    horaSepararEstoque: '10:00',
    situacao: 'SEPARANDO',
    codTipoOperacaoSaida: 10,
    descricaoTipoOperacaoSaida: 'EXPEDICAO',
    codVendedor: 20,
    nomeVendedor: 'VENDEDOR TESTE',
    tipoEntidade: 'CLIENTE',
    codEntidade: '20087',
    nomeEntidade: 'CENTRAL MOTOS',
    codPrioridade: 5,
    descricaoPrioridade: 'TRANSPORTADORA',
    codCliente: 20087,
    nomeCliente: 'S A M DE BRITO - ME',
    nomeFantasiaCliente: 'CENTRAL MOTOS',
    codTransportadora: 1,
    nomeFantasiaTransportadora: 'CAR VALIMA',
    razaoSocialTransportadora: 'CAR VALIMA',
    codMunicipioEntrega: 1,
    nomeMunicipioEntrega: 'RIBEIRAO CASCAL',
    codLocalArmazenagem: 1,
    nomeLocalArmazenagem: 'MEZANINO 1',
    codSetorEstoque: 119,
    descricaoSetorEstoque: 'MEZANINO 1',
    codProduto: 16580,
    nomeProduto: 'PARAF PASTILHA FREIO',
    descricaoProduto: 'PARAF PASTILHA FREIO CG150',
    codGrupoProduto: 1,
    nomeGrupoProduto: 'PECAS',
    codMarca: 1,
    nomeMarca: 'TRILHA',
    codigoFabricante: '39885',
    codigoFornecedor: 'F0001',
    codigoReferencia: '01-1R-G-Q4-33',
    codigoBarras: '7891234567890',
    descricaoEnderecoProduto: '01-1R-G-Q4-33',
    codUnidadeMedida: 'UN',
    descricaoUnidadeMedida: 'UNIDADE',
    quantidade: 10.0,
    quantidadeInterna: 10.0,
    quantidadeExterna: 0.0,
    quantidadeSeparacao: 10.0,
    historicoSepararEstoque: null,
    observacaoSepararEstoque: 'COMPLEMENTO A MANHA',
    orcamentoObservacao: null,
  );
}
