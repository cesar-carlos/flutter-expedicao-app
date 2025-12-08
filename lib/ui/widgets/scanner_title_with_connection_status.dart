import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/domain/viewmodels/socket_viewmodel.dart';
import 'package:data7_expedicao/data/services/socket_service.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';

class ScannerTitleWithConnectionStatus extends StatelessWidget {
  const ScannerTitleWithConnectionStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<SocketViewModel>(
      builder: (context, socketViewModel, child) {
        final connectionState = socketViewModel.connectionState;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Scanner TC60',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),

            _buildConnectionStatus(theme, connectionState),
          ],
        );
      },
    );
  }

  Widget _buildConnectionStatus(ThemeData theme, SocketConnectionState connectionState) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (connectionState) {
      case SocketConnectionState.connected:
        statusColor = AppColors.success;
        statusText = 'Conectado';
        statusIcon = Icons.wifi;
        break;
      case SocketConnectionState.connecting:
      case SocketConnectionState.reconnecting:
        statusColor = AppColors.warning;
        statusText = 'Conectando...';
        statusIcon = Icons.wifi_find;
        break;
      case SocketConnectionState.disconnected:
        statusColor = AppColors.grey;
        statusText = 'Desconectado';
        statusIcon = Icons.wifi_off;
        break;
      case SocketConnectionState.error:
        statusColor = AppColors.error;
        statusText = 'Erro de Conexão';
        statusIcon = Icons.error_outline;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 12, color: statusColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: theme.textTheme.labelSmall?.copyWith(color: statusColor, fontWeight: FontWeight.w600, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
