import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/core/localization/localization_extensions.dart';
import 'package:data7_expedicao/core/theme/theme_extensions.dart';
import 'package:data7_expedicao/domain/models/printer_config.dart';
import 'package:data7_expedicao/presentation/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/common/error_message.dart';
import 'package:data7_expedicao/ui/widgets/config/printer_config_form/index.dart';

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
      if (!mounted) return;
      final vm = context.read<ConfigViewModel>();
      unawaited(
        vm.loadPrinters().catchError((Object e, StackTrace s) {
          AppLogger.warning(
            'Falha ao carregar impressoras',
            tag: 'PrinterConfigForm',
            error: e,
            stackTrace: s,
          );
        }),
      );
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
                      onPressed: vm.isLoadingPrinters
                          ? null
                          : () {
                              unawaited(
                                vm.loadPrinters().catchError((Object e, StackTrace s) {
                                  AppLogger.warning(
                                    'Falha ao atualizar lista de impressoras',
                                    tag: 'PrinterConfigForm',
                                    error: e,
                                    stackTrace: s,
                                  );
                                }),
                              );
                            },
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
                  const PrinterEmptyState()
                else
                  ...vm.printers.map(
                    (printer) => PrinterTile(
                      vm: vm,
                      printer: printer,
                      onMenuSelected: (value) {
                        unawaited(
                          _onMenuSelected(context, vm, printer, value).catchError((Object e, StackTrace s) {
                            AppLogger.warning(
                              'Falha na ação do menu da impressora',
                              tag: 'PrinterConfigForm',
                              error: e,
                              stackTrace: s,
                            );
                          }),
                        );
                      },
                    ),
                  ),
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
                        onPressed: vm.isDiscoveringPrinters
                            ? null
                            : () {
                                unawaited(
                                  _discoverPrinters().catchError((Object e, StackTrace s) {
                                    AppLogger.warning(
                                      'Falha na descoberta de impressoras',
                                      tag: 'PrinterConfigForm',
                                      error: e,
                                      stackTrace: s,
                                    );
                                  }),
                                );
                              },
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
                        onPressed: vm.isDiscoveringPrinters
                            ? null
                            : () {
                                unawaited(
                                  _showAdvancedDiscoveryDialog().catchError((Object e, StackTrace s) {
                                    AppLogger.warning(
                                      'Falha na busca avançada de impressoras',
                                      tag: 'PrinterConfigForm',
                                      error: e,
                                      stackTrace: s,
                                    );
                                  }),
                                );
                              },
                        icon: const Icon(Icons.tune),
                        label: Text(context.l10n.printerConfigAdvancedSearch),
                      ),
                      OutlinedButton.icon(
                        style: actionButtonStyle,
                        onPressed: () {
                          unawaited(
                            _showPrinterDialog(context).catchError((Object e, StackTrace s) {
                              AppLogger.warning(
                                'Falha ao abrir dialog de impressora',
                                tag: 'PrinterConfigForm',
                                error: e,
                                stackTrace: s,
                              );
                            }),
                          );
                        },
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

    final result = await showDialog<AdvancedDiscoveryResult>(
      context: context,
      builder: (dialogContext) => AdvancedDiscoveryDialog(initialPrefix: suggestedPrefix ?? ''),
    ).catchError((Object e, StackTrace s) {
      AppLogger.warning(
        'Falha ao exibir dialog de descoberta avançada de impressoras',
        tag: 'PrinterConfigForm',
        error: e,
        stackTrace: s,
      );
      return null;
    });

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
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.printerConfigRemoveTitle),
        content: Text(dialogContext.l10n.printerConfigRemoveMessage(printer.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(dialogContext.l10n.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(dialogContext.l10n.printerConfigRemoveAction),
          ),
        ],
      ),
    ).catchError((Object e, StackTrace s) {
      AppLogger.warning(
        'Falha ao exibir confirmação de remoção de impressora',
        tag: 'PrinterConfigForm',
        error: e,
        stackTrace: s,
      );
      return false;
    });

    if (confirmed == true) {
      await vm.removePrinter(printer.id);
    }
  }

  Future<void> _showPrinterDialog(BuildContext context, {PrinterConfig? printer}) async {
    final vm = context.read<ConfigViewModel>();
    final result = await showDialog<PrinterFormDialogResult>(
      context: context,
      builder: (context) => PrinterFormDialog(printer: printer),
    ).catchError((Object e, StackTrace s) {
      AppLogger.warning(
        'Falha ao exibir dialog de impressora',
        tag: 'PrinterConfigForm',
        error: e,
        stackTrace: s,
      );
      return null;
    });

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
