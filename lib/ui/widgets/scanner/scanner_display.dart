import 'package:flutter/material.dart';

import 'package:data7_expedicao/domain/models/scanner_data.dart';

/// Widget para exibir os dados escaneados
class ScannerDisplay extends StatelessWidget {
  /// Dados do scanner para exibir
  final ScannerData scanData;

  /// Callback para limpar o código escaneado
  final VoidCallback onClear;

  /// Construtor
  const ScannerDisplay({super.key, required this.scanData, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Última leitura:", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Text(scanData.code, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: onClear,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
            child: const Text("Limpar Leitura", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
