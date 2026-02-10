import 'dart:typed_data';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;

import 'package:data7_expedicao/domain/models/expedition_item_print_consultation_model.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/infrastructure/services/company_logo_service.dart';

class EscPosTicketBuilderService {
  static const String _defaultCodeTable = 'CP1252';
  static const int _defaultLogoMaxWidthPx = 576;

  final CompanyLogoService? _logoService;

  const EscPosTicketBuilderService({CompanyLogoService? logoService}) : _logoService = logoService;

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

    // Carrega logo automaticamente se não fornecido e serviço disponível
    final effectiveLogoBytes = logoBytes ?? await _loadLogoIfAvailable();

    _appendLogoIfProvided(
      bytes: bytes,
      generator: generator,
      logoBytes: effectiveLogoBytes,
      logoMaxWidthPx: logoMaxWidthPx,
    );

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
    bytes.addAll(generator.text('Nome: $printerName', styles: const PosStyles(align: PosAlign.left)));
    bytes.addAll(generator.text('IP: $printerIp', styles: const PosStyles(align: PosAlign.left)));
    bytes.addAll(generator.text('Porta: $printerPort', styles: const PosStyles(align: PosAlign.left)));
    bytes.addAll(generator.text('Data: ${_formatDateTime(printedAt)}', styles: const PosStyles(align: PosAlign.left)));
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
    int? codSetorEstoque,
    int? codUsuario,
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

    // Carrega logo automaticamente se não fornecido e serviço disponível
    final effectiveLogoBytes = logoBytes ?? await _loadLogoIfAvailable();

    _appendLogoIfProvided(
      bytes: bytes,
      generator: generator,
      logoBytes: effectiveLogoBytes,
      logoMaxWidthPx: logoMaxWidthPx,
    );

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

    // DEPOSITO: DescricaoSetorEstoque
    _writeLine(bytes, generator, 'DEPOSITO', header.descricaoSetorEstoque);

    // CLIENTE: CodEntidade-NomeEntidade
    _writeLine(bytes, generator, 'CLIENTE', '${header.codEntidade}-${header.nomeEntidade}');

    // NomeFantasiaCliente
    if (header.nomeFantasiaCliente?.isNotEmpty == true) {
      bytes.addAll(generator.text(header.nomeFantasiaCliente!, styles: const PosStyles(align: PosAlign.left)));
    }

    _writeLine(bytes, generator, 'CIDADE', header.nomeMunicipioEntrega);
    _writeLine(bytes, generator, 'VENDEDOR', header.nomeVendedor);
    _writeLine(bytes, generator, 'PEDIDO', '${header.origem}-${header.codOrigem}');
    _writeLine(bytes, generator, 'TRANSP', header.nomeFantasiaTransportadora ?? header.razaoSocialTransportadora);
    _writeLine(bytes, generator, 'PRIORIDADE', '${header.codTipoOperacaoSaida}-${header.descricaoTipoOperacaoSaida}');

    _writeLine(bytes, generator, 'DATA IMPRESSAO', _formatDateTime(printedAt));
    _writeLine(
      bytes,
      generator,
      'DATA PEDIDO',
      '${_formatDate(header.dataSepararEstoque)} ${header.horaSepararEstoque}',
    );

    // Observacao Interna: Apenas OrcamentoObservacao
    if (header.orcamentoObservacao != null && header.orcamentoObservacao!.trim().isNotEmpty) {
      bytes.addAll(generator.emptyLines(1));
      bytes.addAll(
        generator.text(header.orcamentoObservacao!.trim(), styles: const PosStyles(align: PosAlign.left, bold: true)),
      );
    }

    bytes.addAll(generator.emptyLines(1));
    bytes.addAll(generator.hr(ch: '-'));

    for (final item in items) {
      // CODIGO (esquerda) + MARCA (direita)
      bytes.addAll(
        generator.row([
          PosColumn(
            text: 'CODIGO: ${item.codProduto}',
            width: 6,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: 'MARCA: ${item.nomeMarca}',
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]),
      );

      // Descrição do produto (esquerda)
      bytes.addAll(
        generator.text(
          item.descricaoProduto?.trim().isNotEmpty == true ? item.descricaoProduto! : item.nomeProduto,
          styles: const PosStyles(align: PosAlign.left),
        ),
      );

      // FAB (esquerda - conforme modelo)
      bytes.addAll(
        generator.text('FAB: ${item.codigoFabricante ?? '-'}', styles: const PosStyles(align: PosAlign.left)),
      );

      // END (esquerda - conforme modelo)
      bytes.addAll(
        generator.text('END: ${item.descricaoEnderecoProduto ?? '-'}', styles: const PosStyles(align: PosAlign.left)),
      );

      // QTD (esquerda - conforme solicitado)
      bytes.addAll(
        generator.text(
          'QTD: ${_formatQuantity(item.quantidade)} ${item.codUnidadeMedida}',
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
      );

      bytes.addAll(generator.hr(ch: '-'));
    }

    final normalizedSeparator = separatorName?.trim();
    if (codUsuario != null || (normalizedSeparator != null && normalizedSeparator.isNotEmpty)) {
      final separatorText = codUsuario != null && normalizedSeparator != null && normalizedSeparator.isNotEmpty
          ? '$codUsuario $normalizedSeparator'
          : (codUsuario?.toString() ?? normalizedSeparator ?? '');
      bytes.addAll(
        generator.text('SEPARADOR: $separatorText', styles: const PosStyles(align: PosAlign.left, bold: true)),
      );
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
      // Para o cabeçalho, mantém alinhado à esquerda
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

  Future<Uint8List?> _loadLogoIfAvailable() async {
    if (_logoService == null) {
      return null;
    }

    try {
      return await _logoService.loadDefaultLogo();
    } catch (e) {
      _safeWarning('Falha ao carregar logo da empresa: $e');
      return null;
    }
  }
}
