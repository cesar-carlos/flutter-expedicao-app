import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/core/constants/app_strings.dart';
import 'package:data7_expedicao/domain/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/config/index.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  void _handleReset(BuildContext context) async {
    final configViewModel = context.read<ConfigViewModel>();

    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetar Configuração'),
        content: const Text('Isso irá restaurar as configurações padrão. Deseja continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Resetar')),
        ],
      ),
    );

    if (confirmed == true) {
      await configViewModel.resetToDefault();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuração resetada!'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.configTitle),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(AppRouter.home)),
        actions: [
          IconButton(
            onPressed: () => _handleReset(context),
            icon: const Icon(Icons.refresh),
            tooltip: 'Resetar para padrão',
          ),
        ],
      ),
      body: const SafeArea(
        child: SingleChildScrollView(padding: EdgeInsets.all(24.0), child: ServerConfigForm()),
      ),
    );
  }
}
