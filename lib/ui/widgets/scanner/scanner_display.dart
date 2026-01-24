import 'package:flutter/material.dart';

import 'package:data7_expedicao/domain/models/scanner_data.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';
import 'package:data7_expedicao/core/localization/localization_extensions.dart';

class ScannerDisplay extends StatelessWidget {
  final ScannerData scanData;

  final VoidCallback onClear;

  const ScannerDisplay({super.key, required this.scanData, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(context.l10n.lastReadingColon, style: AppFonts.inter(fontSize: 18)),
          const SizedBox(height: 10),
          Text(scanData.code, style: AppFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: onClear,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
            child: Text(context.l10n.clearReading, style: AppFonts.inter(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
