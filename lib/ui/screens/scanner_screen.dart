import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/ui/widgets/common/index.dart';
import 'package:data7_expedicao/domain/viewmodels/scanner_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/scanner_title_with_connection_status.dart';
import 'package:go_router/go_router.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Listener para mudanças de foco
    _focusNode.addListener(() {
      setState(() {}); // Força rebuild para atualizar o indicador visual
    });

    // Garantir que o foco seja solicitado após a construção
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: const ScannerTitleWithConnectionStatus(),
        showSocketStatus: false,
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back), tooltip: 'Voltar'),
      ),
      body: Consumer<ScannerViewModel>(
        builder: (context, scannerViewModel, child) {
          return KeyboardListener(
            autofocus: true,
            focusNode: _focusNode,
            onKeyEvent: (KeyEvent event) {
              if (event is KeyDownEvent) {
                // Se for Enter, processar imediatamente
                if (event.logicalKey == LogicalKeyboardKey.enter) {
                  scannerViewModel.processScannedCode();
                  return; // Não processar caracteres após Enter
                }

                // Para outros caracteres, apenas adicionar (debounce será processado pelo timer)
                if (event.character != null && event.character!.isNotEmpty) {
                  scannerViewModel.addCharacter(event.character!);
                  // Não processar debounce aqui - deixar o serviço gerenciar
                }
              }
            },
            child: Column(
              children: [
                // Barra de ações do scanner
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Leituras: ${scannerViewModel.scanHistory.length}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _focusNode.hasFocus ? Colors.green : Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _focusNode.hasFocus ? 'Scanner ativo' : 'Scanner inativo',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: _focusNode.hasFocus ? Colors.green : Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (scannerViewModel.scanHistory.isNotEmpty)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.clear_all, size: 18),
                              label: const Text('Limpar Tudo'),
                              onPressed: () => _showClearAllDialog(context, scannerViewModel),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          if (scannerViewModel.scannedCode.isNotEmpty)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.clear, size: 18),
                              label: const Text('Limpar Atual'),
                              onPressed: scannerViewModel.clearCurrentCode,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Área de exibição do código atual
                if (scannerViewModel.scannedCode.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Última leitura:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          scannerViewModel.scannedCode,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                // Lista de leituras
                Expanded(child: _buildScanList(scannerViewModel)),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Constrói a lista de leituras
  Widget _buildScanList(ScannerViewModel viewModel) {
    if (viewModel.scanHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhuma leitura registrada',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Use o scanner para adicionar códigos',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: viewModel.scanHistory.length,
      itemBuilder: (context, index) {
        final scan = viewModel.scanHistory[index];
        final isLatest = index == 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: isLatest ? 4 : 1,
          color: isLatest ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isLatest ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            title: Text(
              scan.code,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isLatest ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
            subtitle: Text(
              _formatTimestamp(scan.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLatest)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ÚLTIMO',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _showDeleteDialog(context, viewModel, index),
                  tooltip: 'Remover leitura',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Formata timestamp para exibição
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Agora mesmo';
    } else if (difference.inMinutes < 60) {
      return 'Há ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Há ${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} '
          '${timestamp.hour.toString().padLeft(2, '0')}:'
          '${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Mostra diálogo de confirmação para deletar uma leitura
  void _showDeleteDialog(BuildContext context, ScannerViewModel viewModel, int index) {
    final scan = viewModel.scanHistory[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Leitura'),
        content: Text('Deseja remover a leitura "${scan.code}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              viewModel.removeFromHistory(index);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  /// Mostra diálogo de confirmação para limpar todas as leituras
  void _showClearAllDialog(BuildContext context, ScannerViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Todas as Leituras'),
        content: Text('Deseja remover todas as ${viewModel.scanHistory.length} leituras?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              viewModel.clearHistory();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Limpar Tudo'),
          ),
        ],
      ),
    );
  }
}
