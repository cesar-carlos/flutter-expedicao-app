import 'package:data7_expedicao/domain/models/printer_config.dart';

class PrintExpeditionTicketParams {
  final int codEmpresa;
  final int codSepararEstoque;
  final PrinterConfig printer;
  final String? separatorName;
  final bool autoCut;

  const PrintExpeditionTicketParams({
    required this.codEmpresa,
    required this.codSepararEstoque,
    required this.printer,
    this.separatorName,
    this.autoCut = true,
  });

  bool get isValid => validationErrors.isEmpty;

  List<String> get validationErrors {
    final errors = <String>[];

    if (codEmpresa <= 0) {
      errors.add('codEmpresa deve ser maior que zero');
    }

    if (codSepararEstoque <= 0) {
      errors.add('codSepararEstoque deve ser maior que zero');
    }

    if (printer.name.trim().isEmpty) {
      errors.add('nome da impressora nao pode estar vazio');
    }

    if (printer.ip.trim().isEmpty) {
      errors.add('ip/host da impressora nao pode estar vazio');
    }

    if (printer.port < 1 || printer.port > 65535) {
      errors.add('porta da impressora deve estar entre 1 e 65535');
    }

    return errors;
  }
}
