import 'package:data7_expedicao/domain/repositories/i_printer_discovery_service.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/printer_preferences_controller.dart';

class PrinterDiscoveryController {
  final IPrinterDiscoveryService _printerDiscoveryService;
  final PrinterPreferencesController _printerController;
  final void Function() _notify;
  final void Function(String message) _setError;

  bool _isDiscoveringPrinters = false;

  PrinterDiscoveryController(
    this._printerDiscoveryService,
    this._printerController, {
    required void Function() notify,
    required void Function(String message) setError,
  }) : _notify = notify,
       _setError = setError;

  bool get isDiscoveringPrinters => _isDiscoveringPrinters;

  Future<PrinterDiscoveryUiResult> discoverInNetwork({int port = 9100}) async {
    if (_isDiscoveringPrinters) {
      return const PrinterDiscoveryUiResult(
        isSuccess: false,
        foundCount: 0,
        addedCount: 0,
        subnet: null,
        message: 'Ja existe uma busca em andamento.',
      );
    }

    setDiscovering(true);

    try {
      _setError('');
      final report = await _printerDiscoveryService.discover(port: port);

      final addedCount = await _printerController.mergeDiscoveredEndpoints(report.endpoints);

      _notify();

      if (report.endpoints.isEmpty) {
        return PrinterDiscoveryUiResult(
          isSuccess: true,
          foundCount: 0,
          addedCount: 0,
          subnet: report.subnet,
          message: 'Nenhum dispositivo respondeu na porta $port em ${report.subnet}.',
        );
      }

      if (addedCount == 0) {
        return PrinterDiscoveryUiResult(
          isSuccess: true,
          foundCount: report.endpoints.length,
          addedCount: 0,
          subnet: report.subnet,
          message: '${report.endpoints.length} dispositivo(s) encontrado(s), mas todos ja estavam cadastrados.',
        );
      }

      return PrinterDiscoveryUiResult(
        isSuccess: true,
        foundCount: report.endpoints.length,
        addedCount: addedCount,
        subnet: report.subnet,
        message: '$addedCount nova(s) impressora(s) adicionada(s) em ${report.subnet}.',
      );
    } on StateError catch (e) {
      final message = e.message;
      _setError(message);
      _notify();
      return PrinterDiscoveryUiResult(isSuccess: false, foundCount: 0, addedCount: 0, subnet: null, message: message);
    } catch (e) {
      final message = 'Erro ao buscar impressoras: $e';
      _setError(message);
      _notify();
      return PrinterDiscoveryUiResult(isSuccess: false, foundCount: 0, addedCount: 0, subnet: null, message: message);
    } finally {
      setDiscovering(false);
    }
  }

  Future<PrinterDiscoveryUiResult> discoverInRange({
    required String subnetPrefix,
    required int startHost,
    required int endHost,
    int port = 9100,
  }) async {
    if (_isDiscoveringPrinters) {
      return const PrinterDiscoveryUiResult(
        isSuccess: false,
        foundCount: 0,
        addedCount: 0,
        subnet: null,
        message: 'Ja existe uma busca em andamento.',
      );
    }

    setDiscovering(true);

    try {
      _setError('');
      final report = await _printerDiscoveryService.discover(
        port: port,
        subnetPrefix: subnetPrefix,
        startHost: startHost,
        endHost: endHost,
      );

      final addedCount = await _printerController.mergeDiscoveredEndpoints(report.endpoints);

      _notify();

      if (report.endpoints.isEmpty) {
        return PrinterDiscoveryUiResult(
          isSuccess: true,
          foundCount: 0,
          addedCount: 0,
          subnet: report.subnet,
          message: 'Nenhum dispositivo respondeu na porta $port em ${report.subnet}.',
        );
      }

      if (addedCount == 0) {
        return PrinterDiscoveryUiResult(
          isSuccess: true,
          foundCount: report.endpoints.length,
          addedCount: 0,
          subnet: report.subnet,
          message: '${report.endpoints.length} dispositivo(s) encontrado(s), mas todos ja estavam cadastrados.',
        );
      }

      return PrinterDiscoveryUiResult(
        isSuccess: true,
        foundCount: report.endpoints.length,
        addedCount: addedCount,
        subnet: report.subnet,
        message: '$addedCount nova(s) impressora(s) adicionada(s) em ${report.subnet}.',
      );
    } on StateError catch (e) {
      final message = e.message;
      _setError(message);
      _notify();
      return PrinterDiscoveryUiResult(isSuccess: false, foundCount: 0, addedCount: 0, subnet: null, message: message);
    } catch (e) {
      final message = 'Erro ao buscar impressoras: $e';
      _setError(message);
      _notify();
      return PrinterDiscoveryUiResult(isSuccess: false, foundCount: 0, addedCount: 0, subnet: null, message: message);
    } finally {
      setDiscovering(false);
    }
  }

  Future<String?> getSuggestedSubnetPrefix() async {
    return _printerDiscoveryService.detectLocalSubnetPrefix();
  }

  void setDiscovering(bool discovering) {
    _isDiscoveringPrinters = discovering;
    _notify();
  }
}

class PrinterDiscoveryUiResult {
  final bool isSuccess;
  final int foundCount;
  final int addedCount;
  final String? subnet;
  final String message;

  const PrinterDiscoveryUiResult({
    required this.isSuccess,
    required this.foundCount,
    required this.addedCount,
    required this.subnet,
    required this.message,
  });
}
