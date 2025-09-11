import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:exp/core/constants/app_strings.dart';
import 'package:exp/domain/viewmodels/config_viewmodel.dart';
import 'package:exp/ui/widgets/config/index.dart';
import 'package:exp/ui/widgets/app_drawer/index.dart';
import 'package:exp/ui/widgets/common/index.dart';

class ConfigScreen extends StatelessWidget {
  final bool showDrawer;

  const ConfigScreen({super.key, this.showDrawer = true});

  void _handleReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetar Configuração'),
        content: const Text(
          'Isso irá restaurar as configurações padrão. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Resetar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final configViewModel = context.read<ConfigViewModel>();
      await configViewModel.resetToDefault();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuração resetada!'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.withActions(
        title: AppStrings.configTitle,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _handleReset(context),
            icon: const Icon(Icons.refresh),
            tooltip: 'Resetar para padrão',
          ),
        ],
      ),
      drawer: showDrawer ? const AppDrawer() : null,
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: ServerConfigForm(),
        ),
      ),
    );
  }
}
