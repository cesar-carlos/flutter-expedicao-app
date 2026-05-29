import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/localization/localization_extensions.dart';
import 'package:data7_expedicao/domain/models/printer_config.dart';

class PrinterFormDialog extends StatefulWidget {
  final PrinterConfig? printer;

  const PrinterFormDialog({super.key, this.printer});

  @override
  State<PrinterFormDialog> createState() => _PrinterFormDialogState();
}

class _PrinterFormDialogState extends State<PrinterFormDialog> {
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

    final result = PrinterFormDialogResult(
      name: _nameController.text.trim(),
      ip: _ipController.text.trim(),
      port: int.parse(_portController.text.trim()),
    );

    Navigator.of(context).pop(result);
  }
}

class PrinterFormDialogResult {
  final String name;
  final String ip;
  final int port;

  const PrinterFormDialogResult({required this.name, required this.ip, required this.port});
}

class AdvancedDiscoveryDialog extends StatefulWidget {
  final String initialPrefix;

  const AdvancedDiscoveryDialog({super.key, required this.initialPrefix});

  @override
  State<AdvancedDiscoveryDialog> createState() => _AdvancedDiscoveryDialogState();
}

class _AdvancedDiscoveryDialogState extends State<AdvancedDiscoveryDialog> {
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
      AdvancedDiscoveryResult(
        subnetPrefix: _prefixController.text.trim(),
        startHost: startHost,
        endHost: endHost,
        port: int.parse(_portController.text.trim()),
      ),
    );
  }
}

class AdvancedDiscoveryResult {
  final String subnetPrefix;
  final int startHost;
  final int endHost;
  final int port;

  const AdvancedDiscoveryResult({
    required this.subnetPrefix,
    required this.startHost,
    required this.endHost,
    required this.port,
  });
}
