import 'package:data7_expedicao/data/datasources/printer_preferences_service.dart';
import 'package:data7_expedicao/domain/models/printer_config.dart';
import 'package:data7_expedicao/domain/repositories/i_printer_preferences_repository.dart';

class PrinterPreferencesRepositoryImpl implements IPrinterPreferencesRepository {
  final PrinterPreferencesService _service;

  const PrinterPreferencesRepositoryImpl({
    required PrinterPreferencesService service,
  }) : _service = service;

  @override
  Future<List<PrinterConfig>> loadPrinters() => _service.loadPrinters();

  @override
  Future<void> savePrinters(List<PrinterConfig> printers) =>
      _service.savePrinters(printers);

  @override
  Future<String?> loadDefaultPrinterId() async =>
      _service.loadDefaultPrinterId();

  @override
  Future<void> saveDefaultPrinterId(String? printerId) async =>
      _service.saveDefaultPrinterId(printerId);

  @override
  Future<void> clear() => _service.clear();

  @override
  Future<PrinterConfig?> getDefaultPrinter() async {
    final printers = await _service.loadPrinters();

    if (printers.isEmpty) {
      return null;
    }

    final defaultPrinterId = await _service.loadDefaultPrinterId();

    if (defaultPrinterId == null || defaultPrinterId.isEmpty) {
      return printers.first;
    }

    for (final printer in printers) {
      if (printer.id == defaultPrinterId) {
        return printer;
      }
    }

    return printers.first;
  }
}
