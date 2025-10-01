import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:exp/domain/viewmodels/socket_viewmodel.dart';
import 'package:exp/data/services/socket_service.dart';
import 'package:exp/core/theme/app_colors.dart';

/// Widget de faixa de status de conexão para barras de navegação
class ConnectionStatusBar extends StatelessWidget {
  const ConnectionStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<SocketViewModel>(
      builder: (context, socketViewModel, child) {
        final connectionState = socketViewModel.connectionState;

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
          height: 24,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.withOpacity(statusColor, 0.1),
            border: Border(
              top: BorderSide(color: AppColors.withOpacity(statusColor, 0.3), width: 1),
              bottom: BorderSide(color: AppColors.withOpacity(statusColor, 0.3), width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(statusIcon, size: 14, color: statusColor),
              const SizedBox(width: 6),
              Text(
                statusText,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
