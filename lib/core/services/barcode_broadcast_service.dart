import 'package:flutter/services.dart';

import 'package:data7_expedicao/domain/models/scanner_input_mode.dart';

class BarcodeBroadcastService {
  static const _channel = EventChannel('br.com.se7esistemassinop.exp/barcode_broadcast');

  Stream<String> listen({
    required String action,
    required String extraKey,
  }) {
    return _channel.receiveBroadcastStream({'action': action, 'extraKey': extraKey}).cast<String>();
  }
}

class ScannerPreferences {
  final ScannerInputMode mode;
  final String action;
  final String extraKey;

  const ScannerPreferences({
    required this.mode,
    required this.action,
    required this.extraKey,
  });
}


