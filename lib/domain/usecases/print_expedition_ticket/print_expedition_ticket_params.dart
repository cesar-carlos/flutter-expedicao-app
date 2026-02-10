import 'package:data7_expedicao/domain/models/printer_config.dart';

class PrintExpeditionTicketParams {
  final int codEmpresa;
  final int codSepararEstoque;
  final PrinterConfig printer;
  final String? separatorName;
  final bool autoCut;
  final int? codSetorEstoque;
  final int? codUsuario;

  const PrintExpeditionTicketParams({
    required this.codEmpresa,
    required this.codSepararEstoque,
    required this.printer,
    this.separatorName,
    this.autoCut = true,
    this.codSetorEstoque,
    this.codUsuario,
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

  @override
  String toString() {
    return 'PrintExpeditionTicketParams('
        'codEmpresa: $codEmpresa, '
        'codSepararEstoque: $codSepararEstoque, '
        'printer: ${printer.name} (${printer.ip}:${printer.port}), '
        'codSetorEstoque: $codSetorEstoque, '
        'codUsuario: $codUsuario)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrintExpeditionTicketParams &&
        other.codEmpresa == codEmpresa &&
        other.codSepararEstoque == codSepararEstoque &&
        other.printer == printer &&
        other.separatorName == separatorName &&
        other.autoCut == autoCut &&
        other.codSetorEstoque == codSetorEstoque &&
        other.codUsuario == codUsuario;
  }

  @override
  int get hashCode => Object.hash(
        codEmpresa,
        codSepararEstoque,
        printer,
        separatorName,
        autoCut,
        codSetorEstoque,
        codUsuario,
      );
}
