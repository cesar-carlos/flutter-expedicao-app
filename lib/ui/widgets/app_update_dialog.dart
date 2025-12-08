import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data7_expedicao/domain/viewmodels/app_update_viewmodel.dart';
import 'package:data7_expedicao/domain/models/github_release.dart';

class AppUpdateDialog extends StatelessWidget {
  final GitHubRelease release;

  const AppUpdateDialog({super.key, required this.release});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AppUpdateViewModel>(context, listen: false);
    final releaseVersion = release.getVersion();

    return AlertDialog(
      title: const Text('Atualização Disponível'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Uma nova versão do app está disponível:'),
          const SizedBox(height: 8),
          if (releaseVersion != null)
            Text(
              'Versão: ${releaseVersion.version}+${releaseVersion.buildNumber}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          const SizedBox(height: 8),
          if (release.body != null && release.body!.isNotEmpty)
            Text(release.body!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Depois')),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            viewModel.downloadAndInstall();
          },
          child: const Text('Atualizar Agora'),
        ),
      ],
    );
  }
}
