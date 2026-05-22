import 'package:flutter/services.dart';

import 'package:data7_expedicao/core/constants/scanner_broadcast_defaults.dart';
import 'package:data7_expedicao/domain/models/scanner_input_mode.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';

class BarcodeBroadcastService {
  static const _channel = EventChannel('br.com.se7esistemassinop.exp/barcode_broadcast');

  Stream<String> listen({required String action, required String extraKey}) {
    if (action == ScannerBroadcastDefaults.action && extraKey == ScannerBroadcastDefaults.extraKey) {
      AppLogger.warning(
        'Scanner broadcast usando action/extraKey padrao. Configure valores especificos do coletor quando possivel.',
        tag: 'BarcodeBroadcastService',
      );
    }
    return _channel.receiveBroadcastStream({'action': action, 'extraKey': extraKey}).cast<String>();
  }
}

class ScannerPreferences {
  final ScannerInputMode mode;
  final String action;
  final String extraKey;

  const ScannerPreferences({required this.mode, required this.action, required this.extraKey});
}
