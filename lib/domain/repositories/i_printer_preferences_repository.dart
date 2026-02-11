import 'package:data7_expedicao/domain/models/printer_config.dart';

abstract class IPrinterPreferencesRepository {
  Future<List<PrinterConfig>> loadPrinters();
  Future<void> savePrinters(List<PrinterConfig> printers);
  Future<String?> loadDefaultPrinterId();
  Future<void> saveDefaultPrinterId(String? printerId);
  Future<void> clear();
  Future<PrinterConfig?> getDefaultPrinter();
}
