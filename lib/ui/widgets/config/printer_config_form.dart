import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/core/localization/localization_extensions.dart';
import 'package:data7_expedicao/core/theme/theme_extensions.dart';
import 'package:data7_expedicao/domain/models/printer_config.dart';
import 'package:data7_expedicao/domain/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/common/error_message.dart';

class PrinterConfigForm extends StatefulWidget {
  const PrinterConfigForm({super.key});

  @override
  State<PrinterConfigForm> createState() => _PrinterConfigFormState();
}

class _PrinterConfigFormState extends State<PrinterConfigForm> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConfigViewModel>().loadPrinters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.isDark;
    final accentColor = theme.adaptiveSecondary(colorScheme);
    final actionButtonForeground = isDark ? colorScheme.onSurface : colorScheme.primary;
    final actionButtonBorderColor = colorScheme.outline.withValues(alpha: isDark ? 0.8 : 0.6);
    final actionButtonStyle = OutlinedButton.styleFrom(
      foregroundColor: actionButtonForeground,
      side: BorderSide(color: actionButtonBorderColor),
      disabledForegroundColor: actionButtonForeground.withValues(alpha: 0.45),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

    return Consumer<ConfigViewModel>(
      builder: (context, vm, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.print, color: accentColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.l10n.printerConfigTitle,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: vm.isLoadingPrinters ? null : vm.loadPrinters,
                      tooltip: context.l10n.printerConfigRefreshTooltip,
                      icon: vm.isLoadingPrinters
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(actionButtonForeground),
                              ),
                            )
                          : Icon(Icons.refresh, color: accentColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.printerConfigDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? colorScheme.onSurface.withValues(alpha: 0.85) : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                if (vm.printers.isEmpty)
                  _buildEmptyState(context)
                else
                  ...vm.printers.map((printer) => _buildPrinterTile(context, vm, printer)),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        style: actionButtonStyle,
                        onPressed: vm.isDiscoveringPrinters ? null : _discoverPrinters,
                        icon: vm.isDiscoveringPrinters
                            ? SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(actionButtonForeground),
                                ),
                              )
                            : const Icon(Icons.wifi_find),
                        label: Text(
                          vm.isDiscoveringPrinters
                              ? context.l10n.printerConfigSearchingNetwork
                              : context.l10n.printerConfigSearchNetwork,
                        ),
                      ),
                      OutlinedButton.icon(
                        style: actionButtonStyle,
                        onPressed: vm.isDiscoveringPrinters ? null : _showAdvancedDiscoveryDialog,
                        icon: const Icon(Icons.tune),
                        label: Text(context.l10n.printerConfigAdvancedSearch),
                      ),
                      OutlinedButton.icon(
                        style: actionButtonStyle,
                        onPressed: () => _showPrinterDialog(context),
                        icon: const Icon(Icons.add),
                        label: Text(context.l10n.printerConfigAddPrinter),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ErrorMessage(message: vm.errorMessage),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.printerConfigEmpty,
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrinterTile(BuildContext context, ConfigViewModel vm, PrinterConfig printer) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.isDark;
    final isDefault = vm.defaultPrinterId == printer.id;
    final isTestingThisPrinter = vm.isTestingPrinter && vm.testingPrinterId == printer.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? colorScheme.surfaceContainer : null,
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                printer.name,
                style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
              ),
            ),
            if (isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.l10n.printerConfigDefaultBadge,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          '${printer.ip}:${printer.port}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? colorScheme.onSurface.withValues(alpha: 0.82) : colorScheme.onSurfaceVariant,
          ),
        ),
        leading: Icon(isDefault ? Icons.print : Icons.print_outlined, color: isDark ? colorScheme.onSurface : null),
        trailing: isTestingThisPrinter
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(isDark ? colorScheme.onSurface : colorScheme.primary),
                ),
              )
            : PopupMenuButton<String>(
                enabled: !vm.isTestingPrinter,
                iconColor: isDark ? colorScheme.onSurface : null,
                onSelected: (value) => _onMenuSelected(context, vm, printer, value),
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'test', child: Text(context.l10n.printerConfigTestPrinter)),
                  if (!isDefault) PopupMenuItem(value: 'default', child: Text(context.l10n.printerConfigSetDefault)),
                  PopupMenuItem(value: 'edit', child: Text(context.l10n.edit)),
                  PopupMenuItem(value: 'delete', child: Text(context.l10n.printerConfigRemoveAction)),
                ],
              ),
      ),
    );
  }

  Future<void> _onMenuSelected(BuildContext context, ConfigViewModel vm, PrinterConfig printer, String action) async {
    switch (action) {
      case 'test':
        await _testPrinter(vm, printer);
        break;
      case 'default':
        await vm.setDefaultPrinter(printer.id);
        break;
      case 'edit':
        await _showPrinterDialog(context, printer: printer);
        break;
      case 'delete':
        await _confirmDelete(context, vm, printer);
        break;
    }
  }

  Future<void> _testPrinter(ConfigViewModel vm, PrinterConfig printer) async {
    final result = await vm.testPrinter(printer);
    if (!mounted) {
      return;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = result.isSuccess ? colorScheme.tertiary : colorScheme.error;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message), backgroundColor: backgroundColor, duration: const Duration(seconds: 4)),
    );
  }

  Future<void> _discoverPrinters() async {
    final vm = context.read<ConfigViewModel>();
    final result = await vm.discoverPrintersInNetwork();

    if (!mounted) {
      return;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final successColor = colorScheme.tertiary;
    final backgroundColor = result.isSuccess
        ? (result.addedCount > 0 ? successColor : colorScheme.primary)
        : colorScheme.error;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message), backgroundColor: backgroundColor, duration: const Duration(seconds: 4)),
    );
  }

  Future<void> _showAdvancedDiscoveryDialog() async {
    final vm = context.read<ConfigViewModel>();
    final suggestedPrefix = await vm.getSuggestedSubnetPrefix();
    if (!mounted) {
      return;
    }

    final result = await showDialog<_AdvancedDiscoveryResult>(
      context: context,
      builder: (dialogContext) => _AdvancedDiscoveryDialog(initialPrefix: suggestedPrefix ?? ''),
    );

    if (result == null || !mounted) {
      return;
    }

    final discoveryResult = await vm.discoverPrintersInRange(
      subnetPrefix: result.subnetPrefix,
      startHost: result.startHost,
      endHost: result.endHost,
      port: result.port,
    );

    if (!mounted) {
      return;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final successColor = colorScheme.tertiary;
    final backgroundColor = discoveryResult.isSuccess
        ? (discoveryResult.addedCount > 0 ? successColor : colorScheme.primary)
        : colorScheme.error;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(discoveryResult.message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ConfigViewModel vm, PrinterConfig printer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.printerConfigRemoveTitle),
        content: Text(context.l10n.printerConfigRemoveMessage(printer.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.printerConfigRemoveAction),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await vm.removePrinter(printer.id);
    }
  }

  Future<void> _showPrinterDialog(BuildContext context, {PrinterConfig? printer}) async {
    final vm = context.read<ConfigViewModel>();
    final result = await showDialog<_PrinterDialogResult>(
      context: context,
      builder: (context) => _PrinterDialog(printer: printer),
    );

    if (result == null) {
      return;
    }

    if (printer == null) {
      await vm.addPrinter(name: result.name, ip: result.ip, port: result.port);
      return;
    }

    await vm.updatePrinter(printer.copyWith(name: result.name, ip: result.ip, port: result.port));
  }
}

class _PrinterDialog extends StatefulWidget {
  final PrinterConfig? printer;

  const _PrinterDialog({this.printer});

  @override
  State<_PrinterDialog> createState() => _PrinterDialogState();
}

class _PrinterDialogState extends State<_PrinterDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ipController;
  late final TextEditingController _portController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.printer?.name ?? '');
    _ipController = TextEditingController(text: widget.printer?.ip ?? '');
    _portController = TextEditingController(text: (widget.printer?.port ?? 9100).toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.printer != null;

    return AlertDialog(
      title: Text(isEdit ? context.l10n.printerConfigEditTitle : context.l10n.printerConfigAddTitle),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.printerConfigNameLabel,
                  hintText: context.l10n.printerConfigNameHint,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.l10n.printerConfigNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ipController,
                decoration: InputDecoration(
                  labelText: context.l10n.printerConfigHostLabel,
                  hintText: context.l10n.printerConfigHostHint,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.l10n.printerConfigHostRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _portController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.l10n.printerConfigPortLabel,
                  hintText: context.l10n.printerConfigPortHint,
                ),
                validator: (value) {
                  final parsed = int.tryParse(value?.trim() ?? '');
                  if (parsed == null || parsed < 1 || parsed > 65535) {
                    return context.l10n.printerConfigPortRangeRequired;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.cancel)),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isEdit ? context.l10n.save : context.l10n.printerConfigAddAction),
        ),
      ],
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final result = _PrinterDialogResult(
      name: _nameController.text.trim(),
      ip: _ipController.text.trim(),
      port: int.parse(_portController.text.trim()),
    );

    Navigator.of(context).pop(result);
  }
}

class _PrinterDialogResult {
  final String name;
  final String ip;
  final int port;

  const _PrinterDialogResult({required this.name, required this.ip, required this.port});
}

class _AdvancedDiscoveryDialog extends StatefulWidget {
  final String initialPrefix;

  const _AdvancedDiscoveryDialog({required this.initialPrefix});

  @override
  State<_AdvancedDiscoveryDialog> createState() => _AdvancedDiscoveryDialogState();
}

class _AdvancedDiscoveryDialogState extends State<_AdvancedDiscoveryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _prefixController;
  final TextEditingController _startHostController = TextEditingController(text: '1');
  final TextEditingController _endHostController = TextEditingController(text: '254');
  final TextEditingController _portController = TextEditingController(text: '9100');

  @override
  void initState() {
    super.initState();
    _prefixController = TextEditingController(text: widget.initialPrefix);
  }

  @override
  void dispose() {
    _prefixController.dispose();
    _startHostController.dispose();
    _endHostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.printerConfigAdvancedTitle),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _prefixController,
                decoration: InputDecoration(
                  labelText: context.l10n.printerConfigSubnetLabel,
                  hintText: context.l10n.printerConfigSubnetHint,
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  final parts = text.split('.');
                  if (parts.length != 3) {
                    return context.l10n.printerConfigSubnetFormatError;
                  }
                  for (final part in parts) {
                    final n = int.tryParse(part);
                    if (n == null || n < 0 || n > 255) {
                      return context.l10n.printerConfigSubnetInvalid;
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startHostController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: context.l10n.printerConfigStartHostLabel, hintText: '1'),
                      validator: (value) {
                        final n = int.tryParse(value?.trim() ?? '');
                        if (n == null || n < 1 || n > 254) {
                          return context.l10n.printerConfigHostRangeError;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _endHostController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: context.l10n.printerConfigEndHostLabel, hintText: '254'),
                      validator: (value) {
                        final n = int.tryParse(value?.trim() ?? '');
                        if (n == null || n < 1 || n > 254) {
                          return context.l10n.printerConfigHostRangeError;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _portController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.l10n.printerConfigPortLabel,
                  hintText: context.l10n.printerConfigPortHint,
                ),
                validator: (value) {
                  final n = int.tryParse(value?.trim() ?? '');
                  if (n == null || n < 1 || n > 65535) {
                    return context.l10n.printerConfigPortInvalid;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.cancel)),
        ElevatedButton(onPressed: _submit, child: Text(context.l10n.printerConfigSearchAction)),
      ],
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final startHost = int.parse(_startHostController.text.trim());
    final endHost = int.parse(_endHostController.text.trim());
    if (startHost > endHost) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.printerConfigHostRangeOrderError)));
      return;
    }

    Navigator.of(context).pop(
      _AdvancedDiscoveryResult(
        subnetPrefix: _prefixController.text.trim(),
        startHost: startHost,
        endHost: endHost,
        port: int.parse(_portController.text.trim()),
      ),
    );
  }
}

class _AdvancedDiscoveryResult {
  final String subnetPrefix;
  final int startHost;
  final int endHost;
  final int port;

  const _AdvancedDiscoveryResult({
    required this.subnetPrefix,
    required this.startHost,
    required this.endHost,
    required this.port,
  });
}
