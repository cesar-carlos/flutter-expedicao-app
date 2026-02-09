import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:data7_expedicao/domain/models/printer_config.dart';

class PrinterPreferencesService {
  static const String _printersKey = 'printer_preferences.printers';
  static const String _defaultPrinterIdKey = 'printer_preferences.default_printer_id';

  const PrinterPreferencesService();

  Future<List<PrinterConfig>> loadPrinters() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString(_printersKey);

    if (rawData == null || rawData.isEmpty) {
      return const [];
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(rawData);
    } catch (_) {
      await prefs.remove(_printersKey);
      return const [];
    }

    if (decoded is! List) {
      await prefs.remove(_printersKey);
      return const [];
    }

    final result = <PrinterConfig>[];
    final seenEndpoints = <String>{};

    for (final item in decoded.whereType<Map>()) {
      try {
        final printer = PrinterConfig.fromJson(Map<String, dynamic>.from(item));
        if (printer.id.isEmpty || printer.name.isEmpty || printer.ip.isEmpty) {
          continue;
        }

        final endpointKey = '${printer.ip.toLowerCase()}:${printer.port}';
        if (seenEndpoints.contains(endpointKey)) {
          continue;
        }

        seenEndpoints.add(endpointKey);
        result.add(printer);
      } catch (_) {
        continue;
      }
    }

    return result;
  }

  Future<void> savePrinters(List<PrinterConfig> printers) async {
    final prefs = await SharedPreferences.getInstance();
    final data = printers.map((item) => item.toJson()).toList();
    await prefs.setString(_printersKey, jsonEncode(data));
  }

  Future<String?> loadDefaultPrinterId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultPrinterIdKey);
  }

  Future<void> saveDefaultPrinterId(String? printerId) async {
    final prefs = await SharedPreferences.getInstance();
    if (printerId == null || printerId.isEmpty) {
      await prefs.remove(_defaultPrinterIdKey);
      return;
    }
    await prefs.setString(_defaultPrinterIdKey, printerId);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_printersKey);
    await prefs.remove(_defaultPrinterIdKey);
  }
}
