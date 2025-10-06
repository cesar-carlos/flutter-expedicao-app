import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:exp/domain/viewmodels/socket_viewmodel.dart';
import 'package:exp/data/services/socket_service.dart';
import 'package:exp/core/theme/app_colors.dart';

/// Widget que exibe o título "Produtos Pendentes" com status de conexão abaixo
class PendingProductsTitleWithConnectionStatus extends StatelessWidget {
  const PendingProductsTitleWithConnectionStatus({super.key});

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
            // Título "Produtos Pendentes"
            Text(
              'Produtos Pendentes',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),

            // Status de conexão abaixo do título
            _buildConnectionStatus(theme, connectionState),
          ],
        );
      },
    );
  }

  /// Constrói o status de conexão
  Widget _buildConnectionStatus(ThemeData theme, SocketConnectionState connectionState) {
    // Determinar cor e texto baseado no estado
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
