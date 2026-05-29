import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/localization/localization_extensions.dart';
import 'package:data7_expedicao/core/theme/theme_extensions.dart';
import 'package:data7_expedicao/domain/models/printer_config.dart';
import 'package:data7_expedicao/presentation/viewmodels/config_viewmodel.dart';

class PrinterTile extends StatelessWidget {
  const PrinterTile({
    super.key,
    required this.vm,
    required this.printer,
    required this.onMenuSelected,
  });

  final ConfigViewModel vm;
  final PrinterConfig printer;
  final ValueChanged<String> onMenuSelected;

  @override
  Widget build(BuildContext context) {
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
                onSelected: onMenuSelected,
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
}
