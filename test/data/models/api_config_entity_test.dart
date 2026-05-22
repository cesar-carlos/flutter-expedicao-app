import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/data/models/api_config_entity.dart';
import 'package:data7_expedicao/domain/models/scanner_input_mode.dart';

void main() {
  group('ApiConfigEntity.toDomain', () {
    ApiConfigEntity buildEntity({required int scannerModeIndex}) {
      return ApiConfigEntity(apiUrl: 'localhost', apiPort: 3001, scannerModeIndex: scannerModeIndex);
    }

    test('usa modo salvo quando indice eh valido', () {
      final config = buildEntity(scannerModeIndex: ScannerInputMode.focus.index).toDomain();

      expect(config.scannerInputMode, ScannerInputMode.focus);
    });

    test('usa default quando indice eh negativo', () {
      final config = buildEntity(scannerModeIndex: -1).toDomain();

      expect(config.scannerInputMode, ScannerInputMode.broadcast);
    });

    test('usa default quando indice esta acima do range', () {
      final config = buildEntity(scannerModeIndex: ScannerInputMode.values.length).toDomain();

      expect(config.scannerInputMode, ScannerInputMode.broadcast);
    });
  });
}
