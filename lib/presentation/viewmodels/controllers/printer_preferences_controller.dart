import 'package:uuid/uuid.dart';

import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:data7_expedicao/domain/models/printer_config.dart';
import 'package:data7_expedicao/domain/models/printer_discovery_report.dart';
import 'package:data7_expedicao/domain/repositories/i_printer_preferences_repository.dart';
import 'package:data7_expedicao/domain/repositories/i_thermal_printer_repository.dart';

class PrinterPreferencesController {
  final IPrinterPreferencesRepository _printerPreferencesRepository;
  final IThermalPrinterRepository? _thermalPrinterRepository;
  final void Function() _notify;
  final void Function(String message) _setError;
  final Uuid _uuid = const Uuid();

  List<PrinterConfig> _printers = const [];
  String? _defaultPrinterId;
  bool _isLoadingPrinters = false;
  bool _isTestingPrinter = false;
  String? _testingPrinterId;

  PrinterPreferencesController(
    this._printerPreferencesRepository,
    this._thermalPrinterRepository, {
    required void Function() notify,
    required void Function(String message) setError,
  }) : _notify = notify,
       _setError = setError;

  List<PrinterConfig> get printers => List.unmodifiable(_printers);
  String? get defaultPrinterId => _defaultPrinterId;
  bool get isLoadingPrinters => _isLoadingPrinters;
  bool get isTestingPrinter => _isTestingPrinter;
  String? get testingPrinterId => _testingPrinterId;

  PrinterConfig? get defaultPrinter {
    if (_defaultPrinterId == null) return null;
    for (final printer in _printers) {
      if (printer.id == _defaultPrinterId) {
        return printer;
      }
    }
    return null;
  }

  Future<void> loadPrintersInternal() async {
    final loadedPrinters = await _printerPreferencesRepository.loadPrinters();
    var loadedDefaultId = await _printerPreferencesRepository.loadDefaultPrinterId();

    if (loadedDefaultId != null && !loadedPrinters.any((item) => item.id == loadedDefaultId)) {
      loadedDefaultId = null;
    }

    _printers = loadedPrinters;
    _defaultPrinterId = loadedDefaultId ?? (loadedPrinters.isNotEmpty ? loadedPrinters.first.id : null);
  }

  Future<void> persistPrinters() async {
    await _printerPreferencesRepository.savePrinters(_printers);
    await _printerPreferencesRepository.saveDefaultPrinterId(_defaultPrinterId);
  }

  Future<void> clearPreferencesRepo() async {
    await _printerPreferencesRepository.clear();
  }

  void resetPrinterState() {
    _printers = const [];
    _defaultPrinterId = null;
  }

  Future<void> loadPrinters() async {
    setLoadingPrinters(true);
    try {
      await loadPrintersInternal();
    } catch (e) {
      _setError('Erro ao carregar impressoras: $e');
    } finally {
      setLoadingPrinters(false);
      _notify();
    }
  }

  Future<void> addPrinter({required String name, required String ip, required int port}) async {
    final normalizedName = name.trim();
    final normalizedIp = ip.trim();

    if (normalizedName.isEmpty) {
      _setError('Nome da impressora e obrigatorio');
      _notify();
      return;
    }

    if (normalizedIp.isEmpty) {
      _setError('IP ou host da impressora e obrigatorio');
      _notify();
      return;
    }

    if (port < 1 || port > 65535) {
      _setError('Porta da impressora deve estar entre 1 e 65535');
      _notify();
      return;
    }

    final endpointKey = _buildEndpointKey(normalizedIp, port);
    final hasDuplicateEndpoint = _printers.any((item) => _buildEndpointKey(item.ip, item.port) == endpointKey);
    if (hasDuplicateEndpoint) {
      _setError('Ja existe uma impressora cadastrada para $normalizedIp:$port.');
      _notify();
      return;
    }

    _setError('');
    final newPrinter = PrinterConfig(id: _uuid.v4(), name: normalizedName, ip: normalizedIp, port: port);

    _printers = [..._printers, newPrinter];
    _defaultPrinterId ??= newPrinter.id;
    await persistPrinters();
    _notify();
  }

  Future<void> updatePrinter(PrinterConfig printer) async {
    final normalizedName = printer.name.trim();
    final normalizedIp = printer.ip.trim();

    if (normalizedName.isEmpty) {
      _setError('Nome da impressora e obrigatorio');
      _notify();
      return;
    }

    if (normalizedIp.isEmpty) {
      _setError('IP ou host da impressora e obrigatorio');
      _notify();
      return;
    }

    if (printer.port < 1 || printer.port > 65535) {
      _setError('Porta da impressora deve estar entre 1 e 65535');
      _notify();
      return;
    }

    final index = _printers.indexWhere((item) => item.id == printer.id);
    if (index == -1) {
      _setError('Impressora nao encontrada para atualizacao');
      _notify();
      return;
    }

    final endpointKey = _buildEndpointKey(normalizedIp, printer.port);
    final hasDuplicateEndpoint = _printers.any(
      (item) => item.id != printer.id && _buildEndpointKey(item.ip, item.port) == endpointKey,
    );
    if (hasDuplicateEndpoint) {
      _setError('Ja existe outra impressora cadastrada para $normalizedIp:${printer.port}.');
      _notify();
      return;
    }

    _setError('');
    final updated = [..._printers];
    updated[index] = printer.copyWith(name: normalizedName, ip: normalizedIp);
    _printers = updated;
    await persistPrinters();
    _notify();
  }

  Future<void> removePrinter(String printerId) async {
    _setError('');
    _printers = _printers.where((item) => item.id != printerId).toList();

    if (_defaultPrinterId == printerId) {
      _defaultPrinterId = _printers.isNotEmpty ? _printers.first.id : null;
    }

    await persistPrinters();
    _notify();
  }

  Future<void> setDefaultPrinter(String printerId) async {
    final exists = _printers.any((item) => item.id == printerId);
    if (!exists) {
      _setError('Impressora não encontrada para definir padrão');
      _notify();
      return;
    }

    _setError('');
    _defaultPrinterId = printerId;
    await persistPrinters();
    _notify();
  }

  Future<int> mergeDiscoveredEndpoints(List<PrinterDiscoveryEndpoint> endpoints) async {
    final existingKeys = _printers.map((item) => '${item.ip}:${item.port}').toSet();

    var addedCount = 0;
    final updatedPrinters = [..._printers];

    for (final endpoint in endpoints) {
      final key = '${endpoint.ip}:${endpoint.port}';
      if (existingKeys.contains(key)) {
        continue;
      }

      updatedPrinters.add(
        PrinterConfig(id: _uuid.v4(), name: 'Impressora ${endpoint.ip}', ip: endpoint.ip, port: endpoint.port),
      );
      existingKeys.add(key);
      addedCount++;
    }

    _printers = updatedPrinters;
    _defaultPrinterId ??= _printers.isNotEmpty ? _printers.first.id : null;

    if (addedCount > 0) {
      await persistPrinters();
    }

    return addedCount;
  }

  Future<PrinterTestUiResult> testPrinter(PrinterConfig printer) async {
    if (_isTestingPrinter) {
      return const PrinterTestUiResult(isSuccess: false, message: 'Ja existe um teste de impressora em andamento.');
    }

    setTestingPrinter(true, printer.id);
    _setError('');
    _notify();

    try {
      final thermalPrinterRepository = _thermalPrinterRepository;
      if (thermalPrinterRepository == null) {
        const message = 'Servico de impressao nao esta disponivel.';
        _setError(message);
        _notify();
        return const PrinterTestUiResult(isSuccess: false, message: message);
      }

      final result = await thermalPrinterRepository.printTestTicket(printer: printer);
      final success = result.getOrNull();

      if (success != null) {
        return PrinterTestUiResult(
          isSuccess: true,
          message: 'Teste enviado para ${printer.name} (${printer.ip}:${printer.port}).',
          elapsed: success.elapsed,
        );
      }

      final failure = result.exceptionOrNull();
      final message = _extractPrinterFailureMessage(failure);
      _setError(message);
      _notify();
      return PrinterTestUiResult(isSuccess: false, message: message);
    } catch (e) {
      final message = 'Erro ao testar impressora: $e';
      _setError(message);
      _notify();
      return PrinterTestUiResult(isSuccess: false, message: message);
    } finally {
      setTestingPrinter(false);
    }
  }

  void setLoadingPrinters(bool loading) {
    _isLoadingPrinters = loading;
    _notify();
  }

  void setTestingPrinter(bool testing, [String? printerId]) {
    _isTestingPrinter = testing;
    _testingPrinterId = testing ? printerId : null;
    _notify();
  }

  String _extractPrinterFailureMessage(Object? failure) {
    if (failure is AppFailure) {
      return failure.message;
    }

    if (failure != null) {
      return failure.toString();
    }

    return 'Falha ao testar impressora.';
  }

  String _buildEndpointKey(String ip, int port) {
    return '${ip.trim().toLowerCase()}:$port';
  }
}

class PrinterTestUiResult {
  final bool isSuccess;
  final String message;
  final Duration? elapsed;

  const PrinterTestUiResult({required this.isSuccess, required this.message, this.elapsed});
}
