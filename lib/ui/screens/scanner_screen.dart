import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:exp/domain/models/scanner_data.dart';
import 'package:exp/domain/viewmodels/scanner_viewmodel.dart';
import 'package:exp/ui/widgets/scanner/index.dart';
import 'package:exp/ui/widgets/common/index.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.withUserInfo(title: 'Scanner TC60', showSocketStatus: true, replaceWithUserName: false),
      body: Consumer<ScannerViewModel>(
        builder: (context, scannerViewModel, child) {
          return KeyboardListener(
            autofocus: true,
            focusNode: _focusNode,
            onKeyEvent: (KeyEvent event) {
              if (event is KeyDownEvent) {
                if (event.character != null && event.character!.isNotEmpty) {
                  scannerViewModel.addCharacter(event.character!);
                }

                if (event.logicalKey == LogicalKeyboardKey.enter) {
                  scannerViewModel.processScannedCode();
                }
              }
            },
            child: Column(
              children: [
                // Barra de ações do scanner
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (scannerViewModel.scanHistory.isNotEmpty)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.history),
                          label: const Text('Histórico'),
                          onPressed: () {
                            _showHistoryDialog(context, scannerViewModel);
                          },
                        ),
                      const Spacer(),
                      if (scannerViewModel.scannedCode.isNotEmpty)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.clear),
                          label: const Text('Limpar'),
                          onPressed: scannerViewModel.clearCurrentCode,
                        ),
                    ],
                  ),
                ),
                // Área de exibição do scanner
                Expanded(
                  child: ScannerDisplay(
                    scanData: ScannerData(code: scannerViewModel.scannedCode),
                    onClear: scannerViewModel.clearCurrentCode,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showHistoryDialog(BuildContext context, ScannerViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Histórico de Leituras'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: viewModel.scanHistory.isEmpty
              ? const Center(child: Text('Nenhuma leitura registrada'))
              : ListView.builder(
                  itemCount: viewModel.scanHistory.length,
                  itemBuilder: (context, index) {
                    final scan = viewModel.scanHistory[index];
                    return ListTile(
                      title: Text(scan.code),
                      subtitle: Text(
                        '${scan.timestamp.day}/${scan.timestamp.month}/${scan.timestamp.year} '
                        '${scan.timestamp.hour.toString().padLeft(2, '0')}:'
                        '${scan.timestamp.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          viewModel.removeFromHistory(index);
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          if (viewModel.scanHistory.isNotEmpty)
            TextButton(
              onPressed: () {
                viewModel.clearHistory();
              },
              child: const Text('Limpar Tudo'),
            ),
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fechar')),
        ],
      ),
    );
  }
}
