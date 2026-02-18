import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/core/localization/localization_extensions.dart';
import 'package:data7_expedicao/domain/viewmodels/app_update_viewmodel.dart';
import 'package:data7_expedicao/domain/models/github_release.dart';
import 'package:data7_expedicao/ui/widgets/app_update_progress_dialog.dart';

class AppUpdateDialog extends StatelessWidget {
  final GitHubRelease release;

  const AppUpdateDialog({super.key, required this.release});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AppUpdateViewModel>(context, listen: false);
    final releaseVersion = release.getVersion();

    return AlertDialog(
      title: Text(context.l10n.appUpdateTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.appUpdateMessage),
          const SizedBox(height: 8),
          if (releaseVersion != null)
            Text(
              '${context.l10n.appUpdateVersionLabel} ${releaseVersion.version}+${releaseVersion.buildNumber}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          const SizedBox(height: 8),
          if (release.body != null && release.body!.isNotEmpty)
            Text(release.body!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      actions: [
        TextButton(
          key: const Key('app_update_later'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.appUpdateLaterButton),
        ),
        ElevatedButton(
          key: const Key('app_update_now'),
          onPressed: () {
            Navigator.of(context).pop();
            showDialog(context: context, barrierDismissible: false, builder: (_) => const AppUpdateProgressDialog());

            viewModel.downloadAndInstall();
          },
          child: Text(context.l10n.appUpdateNowButton),
        ),
      ],
    );
  }
}
