import 'dart:typed_data';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;

import 'package:data7_expedicao/domain/models/expedition_item_print_consultation_model.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';

class EscPosTicketBuilderService {
  static const String _defaultCodeTable = 'CP1252';
  static const int _defaultLogoMaxWidthPx = 576;

  const EscPosTicketBuilderService();

  Future<List<int>> buildPrinterTestTicketBytes({
    required String printerName,
    required String printerIp,
    required int printerPort,
    Uint8List? logoBytes,
    int logoMaxWidthPx = _defaultLogoMaxWidthPx,
    bool autoCut = true,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    final bytes = <int>[];
    final printedAt = DateTime.now();
    bytes.addAll(generator.setGlobalCodeTable(_defaultCodeTable));

    _appendLogoIfProvided(bytes: bytes, generator: generator, logoBytes: logoBytes, logoMaxWidthPx: logoMaxWidthPx);

    bytes.addAll(
      generator.text(
        'TESTE DE IMPRESSORA',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size1,
        ),
      ),
    );
    bytes.addAll(generator.hr(ch: '-'));
    bytes.addAll(generator.text('Nome: $printerName'));
    bytes.addAll(generator.text('IP: $printerIp'));
    bytes.addAll(generator.text('Porta: $printerPort'));
    bytes.addAll(generator.text('Data: ${_formatDateTime(printedAt)}'));
    bytes.addAll(generator.emptyLines(1));
    bytes.addAll(generator.text('Conexao ESC/POS TCP OK', styles: const PosStyles(align: PosAlign.center, bold: true)));
    bytes.addAll(generator.emptyLines(2));

    if (autoCut) {
      bytes.addAll(generator.cut());
    }

    return bytes;
  }

  Future<List<int>> buildExpeditionTicketBytes({
    required List<ExpeditionItemPrintConsultationModel> items,
    String? separatorName,
    Uint8List? logoBytes,
    int logoMaxWidthPx = _defaultLogoMaxWidthPx,
    bool autoCut = true,
  }) async {
    if (items.isEmpty) {
      throw StateError('Lista de itens para impressao nao pode estar vazia.');
    }

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    final bytes = <int>[];

    final header = items.first;
    final printedAt = DateTime.now();
    bytes.addAll(generator.setGlobalCodeTable(_defaultCodeTable));

    _appendLogoIfProvided(bytes: bytes, generator: generator, logoBytes: logoBytes, logoMaxWidthPx: logoMaxWidthPx);

    bytes.addAll(
      generator.text(
        'LISTA DE SEPARACAO',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size1,
        ),
      ),
    );
    bytes.addAll(generator.hr(ch: '-'));

    _writeLine(bytes, generator, 'DEPOSITO', header.nomeLocalArmazenagem);
    _writeLine(bytes, generator, 'CLIENTE', '${header.codEntidade} - ${header.nomeEntidade}');
    _writeLine(bytes, generator, 'CIDADE', header.nomeMunicipioEntrega);
    _writeLine(bytes, generator, 'VENDEDOR', header.nomeVendedor);
    _writeLine(bytes, generator, 'PEDIDO', header.codOrigem?.toString() ?? header.itemOrigem);
    _writeLine(bytes, generator, 'TRANSP', header.nomeFantasiaTransportadora ?? header.razaoSocialTransportadora);
    _writeLine(bytes, generator, 'PRIORIDADE', '${header.codPrioridade} - ${header.descricaoPrioridade}');
    _writeLine(bytes, generator, 'DATA IMPRESSAO', _formatDateTime(printedAt));
    _writeLine(
      bytes,
      generator,
      'DATA PEDIDO',
      '${_formatDate(header.dataSepararEstoque)} ${header.horaSepararEstoque}',
    );

    final observacao = header.observacaoSepararEstoque ?? header.orcamentoObservacao ?? header.historicoSepararEstoque;
    if (observacao != null && observacao.trim().isNotEmpty) {
      bytes.addAll(generator.emptyLines(1));
      bytes.addAll(
        generator.text(
          'Observacao Interna:',
          styles: const PosStyles(
            bold: true,
            align: PosAlign.left,
            height: PosTextSize.size2,
            width: PosTextSize.size1,
          ),
        ),
      );
      bytes.addAll(generator.text(observacao.trim(), styles: const PosStyles(bold: true)));
    }

    bytes.addAll(generator.emptyLines(1));
    bytes.addAll(generator.hr(ch: '-'));

    for (final item in items) {
      _writeLine(
        bytes,
        generator,
        'CODIGO',
        item.codProduto.toString(),
        inlineLabel: 'MARCA',
        inlineValue: item.nomeMarca,
      );
      bytes.addAll(
        generator.text(
          item.descricaoProduto?.trim().isNotEmpty == true ? item.descricaoProduto! : item.nomeProduto,
          styles: const PosStyles(align: PosAlign.left),
        ),
      );
      _writeLine(bytes, generator, 'FAB', item.codigoFabricante);
      _writeLine(bytes, generator, 'END', item.descricaoEnderecoProduto);

      bytes.addAll(
        generator.row([
          PosColumn(
            text: 'QTD:',
            width: 3,
            styles: const PosStyles(align: PosAlign.left, bold: true),
          ),
          PosColumn(
            text: _formatQuantity(item.quantidade),
            width: 6,
            styles: const PosStyles(align: PosAlign.right, bold: true),
          ),
          PosColumn(
            text: item.codUnidadeMedida,
            width: 3,
            styles: const PosStyles(align: PosAlign.right, bold: true),
          ),
        ]),
      );

      bytes.addAll(generator.hr(ch: '-'));
    }

    final normalizedSeparator = separatorName?.trim();
    if (normalizedSeparator != null && normalizedSeparator.isNotEmpty) {
      bytes.addAll(generator.text('SEPARADOR: $normalizedSeparator', styles: const PosStyles(bold: true)));
      bytes.addAll(generator.emptyLines(1));
    }

    bytes.addAll(generator.qrcode('SEP:${header.codEmpresa}-${header.codSepararEstoque}', size: QRSize.size6));
    bytes.addAll(generator.emptyLines(1));
    bytes.addAll(generator.text('www.se7esistemas.com.br', styles: const PosStyles(align: PosAlign.center)));
    bytes.addAll(generator.emptyLines(2));

    if (autoCut) {
      bytes.addAll(generator.cut());
    }

    return bytes;
  }

  void _writeLine(
    List<int> bytes,
    Generator generator,
    String label,
    String? value, {
    String? inlineLabel,
    String? inlineValue,
  }) {
    if (value == null || value.trim().isEmpty) {
      return;
    }

    if (inlineLabel != null && inlineValue != null && inlineValue.trim().isNotEmpty) {
      bytes.addAll(
        generator.row([
          PosColumn(
            text: '$label: $value',
            width: 7,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: '$inlineLabel: $inlineValue',
            width: 5,
            styles: const PosStyles(align: PosAlign.left),
          ),
        ]),
      );
      return;
    }

    bytes.addAll(generator.text('$label: $value', styles: const PosStyles(align: PosAlign.left)));
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    return '$day/$month/$year';
  }

  String _formatQuantity(double value) {
    final rounded = value.toStringAsFixed(3);
    final withoutTrailingZero = rounded.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return withoutTrailingZero;
  }

  void _appendLogoIfProvided({
    required List<int> bytes,
    required Generator generator,
    required Uint8List? logoBytes,
    required int logoMaxWidthPx,
  }) {
    if (logoBytes == null || logoBytes.isEmpty) {
      return;
    }

    try {
      final decodedLogo = img.decodeImage(logoBytes);
      if (decodedLogo == null) {
        return;
      }

      final normalizedLogoWidth = logoMaxWidthPx.clamp(1, _defaultLogoMaxWidthPx);
      final preparedLogo = decodedLogo.width > normalizedLogoWidth
          ? img.copyResize(decodedLogo, width: normalizedLogoWidth, interpolation: img.Interpolation.average)
          : decodedLogo;

      bytes.addAll(generator.imageRaster(preparedLogo, align: PosAlign.center, imageFn: PosImageFn.graphics));
      bytes.addAll(generator.emptyLines(1));
    } catch (e) {
      _safeWarning('Falha ao converter logo para ESC/POS: $e');
    }
  }

  void _safeWarning(String message) {
    try {
      AppLogger.warning(message, tag: 'EscPosTicketBuilderService');
    } catch (_) {}
  }
}
