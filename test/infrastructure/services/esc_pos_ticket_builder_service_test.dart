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

    test('bytes de expedicao devem conter comandos ESC e GS', () async {
      final bytes = await service.buildExpeditionTicketBytes(
        items: [_buildItem()],
      );

      expect(bytes, contains(0x1B));
      expect(bytes, contains(0x1D));
    });

    test('bytes de expedicao devem conter texto LISTA DE SEPARACAO', () async {
      final bytes = await service.buildExpeditionTicketBytes(
        items: [_buildItem()],
      );
      final asString = String.fromCharCodes(bytes.where((b) => b >= 32 && b < 127));
      expect(asString, contains('LISTA DE SEPARACAO'));
    });

    test('nao deve enviar GS L quando leftMarginMm for 0', () async {
      final bytes = await service.buildExpeditionTicketBytes(
        items: [_buildItem()],
        leftMarginMm: 0,
      );

      final hasGsL = _containsSequence(bytes, [0x1D, 0x4C]);
      expect(hasGsL, isFalse);
    });

    test('deve enviar GS L quando leftMarginMm for maior que zero', () async {
      final bytes = await service.buildExpeditionTicketBytes(
        items: [_buildItem()],
        leftMarginMm: 5,
      );

      final hasGsL = _containsSequence(bytes, [0x1D, 0x4C]);
      expect(hasGsL, isTrue);
    });

    test('deve truncar nomeProduto quando exceder 80 caracteres', () async {
      final longName = 'A' * 120;
      final item = _buildItem().copyWith(nomeProduto: longName);
      final bytes = await service.buildExpeditionTicketBytes(items: [item]);

      final asString = String.fromCharCodes(bytes.where((b) => b >= 32 && b < 127));
      expect(asString, contains('A' * 80 + '...'));
      expect(asString, isNot(contains('A' * 120)));
    });

    test('deve sanitizar caracteres de controle em nomeProduto sem falhar', () async {
      const textWithControlChars = 'Produto\x01\x0A\x0DTeste';
      final item = _buildItem().copyWith(nomeProduto: textWithControlChars);
      final bytes = await service.buildExpeditionTicketBytes(items: [item]);

      expect(bytes, isNotEmpty);
      final printable = String.fromCharCodes(bytes.where((b) => b >= 32 && b < 127));
      expect(printable, contains('Produto'));
      expect(printable, contains('Teste'));
    });
  });
}

bool _containsSequence(List<int> bytes, List<int> sequence) {
  if (sequence.isEmpty || bytes.length < sequence.length) {
    return false;
  }
  for (var i = 0; i <= bytes.length - sequence.length; i++) {
    var match = true;
    for (var j = 0; j < sequence.length; j++) {
      if (bytes[i + j] != sequence[j]) {
        match = false;
        break;
      }
    }
    if (match) return true;
  }
  return false;
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
