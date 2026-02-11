import 'package:data7_expedicao/domain/models/printer_config.dart';
import 'package:data7_expedicao/domain/repositories/i_printer_preferences_repository.dart';

class GetDefaultPrinterUseCase {
  final IPrinterPreferencesRepository _repository;

  const GetDefaultPrinterUseCase({
    required IPrinterPreferencesRepository repository,
  }) : _repository = repository;

  Future<PrinterConfig?> call() => _repository.getDefaultPrinter();
}
