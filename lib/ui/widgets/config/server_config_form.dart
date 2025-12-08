import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/core/constants/app_strings.dart';
import 'package:data7_expedicao/core/validation/forms/form_validators.dart';
import 'package:data7_expedicao/domain/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/common/index.dart';

class ServerConfigForm extends StatefulWidget {
  const ServerConfigForm({super.key});

  @override
  State<ServerConfigForm> createState() => _ServerConfigFormState();
}

class _ServerConfigFormState extends State<ServerConfigForm> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _portController = TextEditingController();
  bool _useHttps = false;

  @override
  void initState() {
    super.initState();
    // Carrega a configuração silenciosamente sem causar rebuild
    _loadCurrentConfig();
  }

  void _loadCurrentConfig() {
    final configViewModel = context.read<ConfigViewModel>();
    configViewModel.loadConfigSilent();

    final config = configViewModel.currentConfig;
    _urlController.text = config.apiUrl;
    _portController.text = config.apiPort.toString();
    _useHttps = config.useHttps;
  }

  @override
  void dispose() {
    _urlController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final configViewModel = context.read<ConfigViewModel>();

      await configViewModel.saveConfig(
        apiUrl: _urlController.text.trim(),
        apiPort: _portController.text.trim(),
        useHttps: _useHttps,
      );

      if (mounted && configViewModel.errorMessage.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.configSaved),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );

        // Navega de volta para o login de forma segura
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/login');
        }
      }
    }
  }

  void _handleTest() async {
    if (_formKey.currentState?.validate() ?? false) {
      final configViewModel = context.read<ConfigViewModel>();

      final success = await configViewModel.testConnection(
        apiUrl: _urlController.text.trim(),
        apiPort: _portController.text.trim(),
        useHttps: _useHttps,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(success ? Icons.check_circle : Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    success
                        ? AppStrings.connectionSuccess
                        : '${AppStrings.connectionError}: ${configViewModel.errorMessage}',
                  ),
                ),
              ],
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            duration: Duration(seconds: success ? 3 : 5),
          ),
        );
      }
    }
  }

  String _buildPreviewUrl() {
    final protocol = _useHttps ? AppStrings.httpsProtocol : AppStrings.httpProtocol;
    final url = _urlController.text.trim().isNotEmpty ? _urlController.text.trim() : AppStrings.defaultUrl;
    final port = _portController.text.trim().isNotEmpty ? _portController.text.trim() : AppStrings.defaultPort;

    return '$protocol://$url:$port${AppStrings.apiEndpoint}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ConfigViewModel>(
      builder: (context, configViewModel, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card informativo
              _buildInfoCard(theme, configViewModel),

              const SizedBox(height: 24),

              // Campos de configuração
              _buildConfigFields(configViewModel),

              const SizedBox(height: 24),

              // Preview da URL
              _buildUrlPreview(theme),

              const SizedBox(height: 24),

              // Botões de ação
              _buildActionButtons(configViewModel),

              const SizedBox(height: 16),

              // Mensagem de erro
              ErrorMessage(message: configViewModel.errorMessage),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(ThemeData theme, ConfigViewModel configViewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings_ethernet, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  AppStrings.serverConfigTitle,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.configSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            if (configViewModel.currentConfig.lastUpdated != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: theme.colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    '${AppStrings.lastUpdate}: ${_formatDate(configViewModel.currentConfig.lastUpdated!)}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfigFields(ConfigViewModel configViewModel) {
    return Column(
      children: [
        // Campo URL
        CustomTextFormField(
          controller: _urlController,
          enabled: !configViewModel.isLoading,
          labelText: AppStrings.apiUrl,
          hintText: AppStrings.apiUrlHint,
          prefixIcon: Icons.language,
          validator: FormValidators.apiUrl,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: () {
            // Foca no próximo campo
            FocusScope.of(context).nextFocus();
          },
        ),

        const SizedBox(height: 16),

        // Campo Porta
        CustomTextFormField(
          controller: _portController,
          enabled: !configViewModel.isLoading,
          labelText: AppStrings.apiPort,
          hintText: AppStrings.apiPortHint,
          prefixIcon: Icons.settings_ethernet,
          keyboardType: TextInputType.number,
          validator: FormValidators.apiPort,
          textInputAction: TextInputAction.done,
        ),

        const SizedBox(height: 16),

        // Switch HTTPS
        Card(
          child: SwitchListTile(
            title: const Text(AppStrings.useHttps),
            subtitle: const Text(AppStrings.httpsSubtitle),
            secondary: Icon(_useHttps ? Icons.lock : Icons.lock_open, color: _useHttps ? Colors.green : Colors.grey),
            value: _useHttps,
            onChanged: configViewModel.isLoading ? null : (value) => setState(() => _useHttps = value),
          ),
        ),
      ],
    );
  }

  Widget _buildUrlPreview(ThemeData theme) {
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.preview, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  AppStrings.previewUrl,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
              ),
              child: Text(
                _buildPreviewUrl(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'monospace',
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ConfigViewModel configViewModel) {
    return Column(
      children: [
        // Botão de testar conexão
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: configViewModel.isTesting ? null : _handleTest,
            icon: configViewModel.isTesting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.wifi_find),
            label: Text(configViewModel.isTesting ? AppStrings.testing : AppStrings.testConnection),
          ),
        ),
        const SizedBox(height: 12),
        // Botão de salvar
        SizedBox(
          width: double.infinity,
          child: LoadingButton(
            text: AppStrings.saveConfig,
            onPressed: _handleSave,
            isLoading: configViewModel.isSaving,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
