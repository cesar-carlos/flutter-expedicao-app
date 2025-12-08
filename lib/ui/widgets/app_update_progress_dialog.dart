import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data7_expedicao/domain/viewmodels/app_update_viewmodel.dart';

class AppUpdateProgressDialog extends StatelessWidget {
  const AppUpdateProgressDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppUpdateViewModel>(
      builder: (context, viewModel, child) {
        return PopScope(
          canPop: !viewModel.isDownloading,
          child: AlertDialog(
            title: const Text('Baixando Atualização'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (viewModel.isDownloading) ...[
                  LinearProgressIndicator(value: viewModel.downloadProgress),
                  const SizedBox(height: 16),
                  Text(
                    '${(viewModel.downloadProgress * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ] else if (viewModel.isInstalling) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Instalando atualização...'),
                ],
              ],
            ),
            actions: [
              if (viewModel.isDownloading)
                TextButton(
                  onPressed: () {
                    viewModel.cancelDownload();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
            ],
          ),
        );
      },
    );
  }
}
