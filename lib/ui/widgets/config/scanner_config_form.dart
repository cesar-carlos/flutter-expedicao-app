import 'package:flutter/material.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/core/localization/localization_extensions.dart';
import 'package:data7_expedicao/domain/models/scanner_input_mode.dart';
import 'package:data7_expedicao/domain/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/common/index.dart';

class ScannerConfigForm extends StatefulWidget {
  const ScannerConfigForm({super.key});

  @override
  State<ScannerConfigForm> createState() => _ScannerConfigFormState();
}

class _ScannerConfigFormState extends State<ScannerConfigForm> {
  final _formKey = GlobalKey<FormState>();
  late ScannerInputMode _mode;
  final _actionController = TextEditingController();
  final _extraController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentPrefs();
  }

  void _loadCurrentPrefs() {
    final vm = context.read<ConfigViewModel>();
    vm.loadConfigSilent();
    _mode = vm.scannerInputMode;
    _actionController.text = vm.broadcastAction.isNotEmpty ? vm.broadcastAction : 'com.scanner.BARCODE';
    _extraController.text = vm.broadcastExtraKey.isNotEmpty ? vm.broadcastExtraKey : 'data';
  }

  @override
  void dispose() {
    _actionController.dispose();
    _extraController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final vm = context.read<ConfigViewModel>();
    await vm.saveScannerPreferences(mode: _mode, action: _actionController.text, extraKey: _extraController.text);

    if (!mounted) return;
    if (vm.errorMessage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.scannerConfigSaved),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.fixed,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage), backgroundColor: AppColors.error, behavior: SnackBarBehavior.fixed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<ConfigViewModel>(
      builder: (context, vm, child) {
        return Form(
          key: _formKey,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.qr_code_scanner, color: colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.scannerConfigTitle,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Escolha como o leitor envia o código: foco no campo ou broadcast (intent).',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  _buildModeSelector(theme, colorScheme),
                  if (_mode == ScannerInputMode.broadcast) ...[
                    const SizedBox(height: 12),
                    _buildActionField(context, theme),
                    const SizedBox(height: 12),
                    _buildExtraField(context, theme),
                  ],
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: vm.isSaving ? null : _handleSave,
                      icon: vm.isSaving
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save),
                      label: Text(context.l10n.saveConfig),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ErrorMessage(message: vm.errorMessage),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeSelector(ThemeData theme, ColorScheme colorScheme) {
    return RadioGroup<ScannerInputMode>(
      groupValue: _mode,
      onChanged: (mode) => setState(() => _mode = mode ?? ScannerInputMode.focus),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.scannerModeLabel, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          RadioListTile<ScannerInputMode>(value: ScannerInputMode.focus, title: Text(context.l10n.scannerModeFocus)),
          RadioListTile<ScannerInputMode>(
            value: ScannerInputMode.broadcast,
            title: Text(context.l10n.scannerModeBroadcast),
          ),
        ],
      ),
    );
  }

  Widget _buildActionField(BuildContext context, ThemeData theme) {
    return TextFormField(
      controller: _actionController,
      decoration: InputDecoration(
        labelText: context.l10n.broadcastActionLabel,
        hintText: 'Ex: com.scanner.BARCODE',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (_mode == ScannerInputMode.broadcast && (value == null || value.trim().isEmpty)) {
          return 'Informe a action do broadcast';
        }
        return null;
      },
    );
  }

  Widget _buildExtraField(BuildContext context, ThemeData theme) {
    return TextFormField(
      controller: _extraController,
      decoration: InputDecoration(
        labelText: context.l10n.broadcastExtraLabel,
        hintText: 'Ex: barcode',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (_mode == ScannerInputMode.broadcast && (value == null || value.trim().isEmpty)) {
          return 'Informe a chave do extra';
        }
        return null;
      },
    );
  }
}
