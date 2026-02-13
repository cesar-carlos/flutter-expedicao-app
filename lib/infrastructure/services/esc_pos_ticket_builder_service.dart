import 'dart:typed_data';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;

import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/expedition_item_print_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/i_esc_pos_ticket_builder_service.dart';
import 'package:data7_expedicao/infrastructure/services/company_logo_service.dart';

class EscPosTicketBuilderService implements IEscPosTicketBuilderService {
  static const String _defaultCodeTable = 'CP1252';
  static const int _defaultLogoMaxWidthPx = 576;
  static const int _defaultLeftMarginMm = 5;
  static const int _maxPrintLength = 80;

  final CompanyLogoService? _logoService;

  const EscPosTicketBuilderService({CompanyLogoService? logoService}) : _logoService = logoService;

  @override
  Future<List<int>> buildPrinterTestTicketBytes({
    required String printerName,
    required String printerIp,
    required int printerPort,
    Uint8List? logoBytes,
    int logoMaxWidthPx = _defaultLogoMaxWidthPx,
    bool autoCut = true,
    int? leftMarginMm,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    final bytes = <int>[];
    final printedAt = DateTime.now();
    bytes.addAll(generator.setGlobalCodeTable(_defaultCodeTable));
    _appendLeftMarginIfNeeded(bytes, generator, leftMarginMm);

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
        styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size2, width: PosTextSize.size1),
      ),
    );
    bytes.addAll(generator.hr(ch: '-'));
    bytes.addAll(
      generator.text('Nome: ${_sanitizeForPrint(printerName)}', styles: const PosStyles(align: PosAlign.left)),
    );
    bytes.addAll(
      generator.text('IP: ${_sanitizeForPrint(printerIp)}', styles: const PosStyles(align: PosAlign.left)),
    );
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

  @override
  Future<List<int>> buildExpeditionTicketBytes({
    required List<ExpeditionItemPrintConsultationModel> items,
    String? separatorName,
    Uint8List? logoBytes,
    int logoMaxWidthPx = _defaultLogoMaxWidthPx,
    bool autoCut = true,
    int? codSetorEstoque,
    int? codUsuario,
    int? leftMarginMm,
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
    _appendLeftMarginIfNeeded(bytes, generator, leftMarginMm);

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
        styles: const PosStyles(align: PosAlign.left, bold: true, height: PosTextSize.size2, width: PosTextSize.size1),
      ),
    );
    bytes.addAll(generator.hr(ch: '-'));

    // DEPOSITO: DescricaoSetorEstoque
    _writeLine(bytes, generator, 'DEPOSITO', header.descricaoSetorEstoque);

    // CLIENTE: CodEntidade-NomeEntidade
    _writeLine(bytes, generator, 'CLIENTE', '${header.codEntidade}-${header.nomeEntidade}');

    // NomeFantasiaCliente
    final nomeFantasia = _truncateForPrint(header.nomeFantasiaCliente, _maxPrintLength);
    if (nomeFantasia != null && nomeFantasia.isNotEmpty) {
      bytes.addAll(generator.text(nomeFantasia, styles: const PosStyles(align: PosAlign.left)));
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
    final observacao = _truncateForPrint(header.orcamentoObservacao?.trim(), _maxPrintLength);
    if (observacao != null && observacao.isNotEmpty) {
      bytes.addAll(generator.emptyLines(1));
      bytes.addAll(
        generator.text(observacao, styles: const PosStyles(align: PosAlign.left, bold: true)),
      );
    }

    bytes.addAll(generator.emptyLines(1));
    bytes.addAll(generator.hr(ch: '-'));

    for (final item in items) {
      bytes.addAll(
        generator.row([
          PosColumn(
            text: 'CODIGO: ${item.codProduto}',
            width: 6,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: 'MARCA: ${_sanitizeForPrint(item.nomeMarca ?? '')}',
            width: 6,
            styles: const PosStyles(align: PosAlign.left),
          ),
        ]),
      );

      // Descrição do produto (esquerda)
      final nomeProduto = _truncateForPrint(item.nomeProduto, _maxPrintLength) ?? item.nomeProduto;
      bytes.addAll(
        generator.text(nomeProduto, styles: const PosStyles(align: PosAlign.left)),
      );

      // FAB (esquerda - conforme modelo)
      bytes.addAll(
        generator.text(
          'FAB: ${_sanitizeForPrint(item.codigoFabricante ?? '-')}',
          styles: const PosStyles(align: PosAlign.left),
        ),
      );

      // END (esquerda - conforme modelo)
      bytes.addAll(
        generator.text(
          'END: ${_sanitizeForPrint(item.descricaoEnderecoProduto ?? '-')}',
          styles: const PosStyles(align: PosAlign.left),
        ),
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
          ? '$codUsuario ${_sanitizeForPrint(normalizedSeparator)}'
          : (codUsuario?.toString() ?? _sanitizeForPrint(normalizedSeparator ?? ''));
      bytes.addAll(
        generator.text('SEPARADOR: $separatorText', styles: const PosStyles(align: PosAlign.center, bold: true)),
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

  String _sanitizeForPrint(String text) {
    return text.replaceAllMapped(
      RegExp(r'[\x00-\x1F\x7F]'),
      (_) => ' ',
    );
  }

  String? _truncateForPrint(String? text, int maxLength) {
    if (text == null) return null;
    final sanitized = _sanitizeForPrint(text);
    final trimmed = sanitized.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.length <= maxLength) return trimmed;
    return '${trimmed.substring(0, maxLength)}...';
  }

  void _writeLine(
    List<int> bytes,
    Generator generator,
    String label,
    String? value, {
    String? inlineLabel,
    String? inlineValue,
  }) {
    final truncatedValue = _truncateForPrint(value, _maxPrintLength);
    if (truncatedValue == null || truncatedValue.isEmpty) {
      return;
    }

    final truncatedInline = inlineValue != null ? _truncateForPrint(inlineValue, _maxPrintLength) : null;
    if (inlineLabel != null && truncatedInline != null && truncatedInline.isNotEmpty) {
      bytes.addAll(
        generator.row([
          PosColumn(
            text: '$label: $truncatedValue',
            width: 7,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: '$inlineLabel: $truncatedInline',
            width: 5,
            styles: const PosStyles(align: PosAlign.left),
          ),
        ]),
      );
      return;
    }

    bytes.addAll(generator.text('$label: $truncatedValue', styles: const PosStyles(align: PosAlign.left)));
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

  void _appendLeftMarginIfNeeded(List<int> bytes, Generator generator, int? leftMarginMm) {
    final marginMm = leftMarginMm ?? _defaultLeftMarginMm;
    if (marginMm <= 0) {
      return;
    }
    final dotsPerMm = 8;
    final leftMarginDots = (marginMm * dotsPerMm).round().clamp(0, 65535);
    final nL = leftMarginDots & 0xFF;
    final nH = (leftMarginDots >> 8) & 0xFF;
    bytes.addAll(generator.rawBytes([0x1D, 0x4C, nL, nH]));
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

      bytes.addAll(generator.imageRaster(preparedLogo, align: PosAlign.left, imageFn: PosImageFn.graphics));
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
