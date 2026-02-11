import 'package:data7_expedicao/domain/models/printer_config.dart';
import 'package:data7_expedicao/domain/repositories/i_printer_preferences_repository.dart';

class FakePrinterPreferencesRepository implements IPrinterPreferencesRepository {
  List<PrinterConfig> _printers = const [];
  String? _defaultPrinterId;

  @override
  Future<List<PrinterConfig>> loadPrinters() async => _printers;

  @override
  Future<void> savePrinters(List<PrinterConfig> printers) async {
    _printers = List<PrinterConfig>.from(printers);
  }

  @override
  Future<String?> loadDefaultPrinterId() async => _defaultPrinterId;

  @override
  Future<void> saveDefaultPrinterId(String? printerId) async {
    _defaultPrinterId = printerId;
  }

  @override
  Future<void> clear() async {
    _printers = const [];
    _defaultPrinterId = null;
  }

  @override
  Future<PrinterConfig?> getDefaultPrinter() async {
    if (_printers.isEmpty) return null;
    if (_defaultPrinterId == null || _defaultPrinterId!.isEmpty) {
      return _printers.first;
    }
    for (final printer in _printers) {
      if (printer.id == _defaultPrinterId) return printer;
    }
    return _printers.first;
  }
}
