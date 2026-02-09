import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/core/localization/localization_extensions.dart';
import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/domain/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/common/custom_app_bar.dart';
import 'package:data7_expedicao/ui/widgets/config/server_config_form.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    final authStatus = context.read<AuthViewModel>().status;
    if (authStatus == AuthStatus.authenticated) {
      context.go(AppRouter.home);
      return;
    }

    context.go(AppRouter.login);
  }

  Future<void> _handleReset(BuildContext context) async {
    final configViewModel = context.read<ConfigViewModel>();

    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Resetar Configuração do Servidor'),
        content: const Text(
          'Isso irá restaurar apenas as configurações do servidor. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Resetar'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await configViewModel.resetServerConfig();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuração do servidor resetada!'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.withoutSocket(
        title: context.l10n.serverConfigTitle,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _handleBack(context),
        ),
        actions: [
          IconButton(
            onPressed: () => _handleReset(context),
            icon: const Icon(Icons.refresh),
            tooltip: 'Resetar servidor',
          ),
        ],
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: ServerConfigForm(),
        ),
      ),
    );
  }
}
