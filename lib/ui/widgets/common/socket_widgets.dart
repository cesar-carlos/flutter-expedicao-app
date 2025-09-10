import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exp/domain/viewmodels/socket_viewmodel.dart';
import 'package:exp/data/services/socket_service.dart';

/// Widget que exibe o status da conexão WebSocket em tempo real
class SocketStatusIndicator extends StatelessWidget {
  final bool showLabel;
  final double size;
  final EdgeInsetsGeometry? padding;

  const SocketStatusIndicator({
    super.key,
    this.showLabel = true,
    this.size = 12.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SocketViewModel>(
      builder: (context, socketViewModel, child) {
        final isConnecting =
            socketViewModel.connectionState ==
                SocketConnectionState.connecting ||
            socketViewModel.connectionState ==
                SocketConnectionState.reconnecting;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding:
              padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador visual com animação
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(socketViewModel.connectionStateColor),
                    ),
                  ),
                  // Animação de pulsação quando conectando
                  if (isConnecting)
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Container(
                          width: size * (1.0 + (value * 0.5)),
                          height: size * (1.0 + (value * 0.5)),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(
                              socketViewModel.connectionStateColor,
                            ).withOpacity(0.3 * (1.0 - value)),
                          ),
                        );
                      },
                      onEnd: () {
                        // Reinicia a animação
                        if (isConnecting) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (context.mounted) {
                              (context as Element).markNeedsBuild();
                            }
                          });
                        }
                      },
                    ),
                ],
              ),
              if (showLabel) ...[
                const SizedBox(width: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    socketViewModel.connectionStateDescription,
                    key: ValueKey(socketViewModel.connectionStateDescription),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Color(socketViewModel.connectionStateColor),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Widget de botão para conectar/desconectar WebSocket com feedback visual
class SocketConnectionButton extends StatelessWidget {
  final String? label;
  final IconData? icon;

  const SocketConnectionButton({super.key, this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Consumer<SocketViewModel>(
      builder: (context, socketViewModel, child) {
        final isConnected = socketViewModel.isConnected;
        final isConnecting =
            socketViewModel.connectionState ==
                SocketConnectionState.connecting ||
            socketViewModel.connectionState ==
                SocketConnectionState.reconnecting;
        final hasError =
            socketViewModel.connectionState == SocketConnectionState.error;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: ElevatedButton.icon(
            onPressed: isConnecting
                ? null
                : () async {
                    try {
                      if (isConnected) {
                        socketViewModel.disconnect();
                      } else {
                        await socketViewModel.connect();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro na conexão: $e'),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                          ),
                        );
                      }
                    }
                  },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _buildIcon(isConnected, isConnecting, hasError),
            ),
            label: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _getButtonLabel(socketViewModel.connectionState, label),
                key: ValueKey(
                  _getButtonLabel(socketViewModel.connectionState, label),
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getButtonColor(
                context,
                socketViewModel.connectionState,
              ),
              foregroundColor: _getButtonTextColor(
                context,
                socketViewModel.connectionState,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon(bool isConnected, bool isConnecting, bool hasError) {
    if (isConnecting) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (hasError) {
      return const Icon(Icons.error_outline, key: ValueKey('error'));
    }

    if (isConnected) {
      return Icon(icon ?? Icons.wifi_off, key: const ValueKey('connected'));
    }

    return Icon(icon ?? Icons.wifi, key: const ValueKey('disconnected'));
  }

  String _getButtonLabel(SocketConnectionState state, String? customLabel) {
    if (customLabel != null) return customLabel;

    switch (state) {
      case SocketConnectionState.connecting:
        return 'Conectando...';
      case SocketConnectionState.reconnecting:
        return 'Reconectando...';
      case SocketConnectionState.connected:
        return 'Desconectar';
      case SocketConnectionState.error:
        return 'Tentar Novamente';
      case SocketConnectionState.disconnected:
        return 'Conectar';
    }
  }

  Color _getButtonColor(BuildContext context, SocketConnectionState state) {
    switch (state) {
      case SocketConnectionState.connected:
        return Theme.of(context).colorScheme.error;
      case SocketConnectionState.error:
        return Theme.of(context).colorScheme.errorContainer;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Color _getButtonTextColor(BuildContext context, SocketConnectionState state) {
    switch (state) {
      case SocketConnectionState.connected:
        return Theme.of(context).colorScheme.onError;
      case SocketConnectionState.error:
        return Theme.of(context).colorScheme.onErrorContainer;
      default:
        return Theme.of(context).colorScheme.onPrimary;
    }
  }
}

// AppBarWithSocketStatus removido - usar CustomAppBar em vez disso
/// Widget de card para exibir informações detalhadas do WebSocket
class SocketStatusCard extends StatelessWidget {
  const SocketStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SocketViewModel>(
      builder: (context, socketViewModel, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.wifi,
                      color: Color(socketViewModel.connectionStateColor),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Status WebSocket',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStatusRow(
                  context,
                  'Status',
                  socketViewModel.connectionStateDescription,
                  Color(socketViewModel.connectionStateColor),
                ),
                const SizedBox(height: 8),
                if (socketViewModel.userId != null)
                  _buildStatusRow(
                    context,
                    'Usuário ID',
                    socketViewModel.userId!,
                    Theme.of(context).colorScheme.onSurface,
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SocketConnectionButton(
                        label: socketViewModel.isConnected
                            ? 'Desconectar'
                            : 'Conectar',
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (socketViewModel.connectionState ==
                        SocketConnectionState.error)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => socketViewModel.reconnect(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar Novamente'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusRow(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
