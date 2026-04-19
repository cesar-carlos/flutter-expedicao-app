import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/data/services/socket_service.dart';
import 'package:data7_expedicao/domain/viewmodels/socket_viewmodel.dart';

Future<void> _performSocketConnectionButtonTap({
  required BuildContext context,
  required SocketViewModel socketViewModel,
  required bool isConnected,
}) async {
  try {
    if (isConnected) {
      socketViewModel.disconnect();
    } else {
      await socketViewModel.connect();
    }
  } catch (e, stackTrace) {
    AppLogger.warning(
      'Erro ao alternar conexão WebSocket',
      tag: 'SocketConnectionButton',
      error: e,
      stackTrace: stackTrace,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro na conexão: $e'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

/// Indicador visual do status do socket.
///
/// Bug TTTTTTTT (refatoracao): a versao anterior usava
/// `TweenAnimationBuilder` com hack de `(context as Element).markNeedsBuild()`
/// no `onEnd` para criar um pseudo-loop de pulsacao enquanto isConnecting.
/// Problemas:
/// 1. Cast forçado `as Element` e `markNeedsBuild()` em widget tree e
///    extremamente custoso (re-anima todo o subtree do Consumer).
/// 2. Cada ciclo provocava 1 rebuild completo + addPostFrameCallback,
///    multiplicando o trabalho do framework.
/// 3. Em cenarios de rede ruim onde isConnecting fica true por muito
///    tempo, o efeito poluia o thread de UI causando jank visivel.
///
/// Refatorado para `StatefulWidget` com `AnimationController` proprio
/// que gerencia o loop de pulso de forma eficiente:
/// * O controller so existe enquanto isConnecting=true
/// * `repeat()` nativo do AnimationController e otimizado
/// * Quando volta a connected/disconnected/error, o controller e
///   parado e a animacao some sem rebuilds desnecessarios
class SocketStatusIndicator extends StatefulWidget {
  final bool showLabel;
  final double size;
  final EdgeInsetsGeometry? padding;

  const SocketStatusIndicator({super.key, this.showLabel = true, this.size = 12.0, this.padding});

  @override
  State<SocketStatusIndicator> createState() => _SocketStatusIndicatorState();
}

class _SocketStatusIndicatorState extends State<SocketStatusIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _syncAnimationWithState(bool isConnecting) {
    if (isConnecting) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat();
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SocketViewModel>(
      builder: (context, socketViewModel, child) {
        final isConnecting =
            socketViewModel.connectionState == SocketConnectionState.connecting ||
            socketViewModel.connectionState == SocketConnectionState.reconnecting;

        // Sincroniza o controller com o estado APOS o build (nao podemos
        // chamar repeat()/stop() durante build).
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _syncAnimationWithState(isConnecting);
        });

        final stateColor = Color(socketViewModel.connectionStateColor);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: stateColor,
                    ),
                  ),

                  if (isConnecting)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) {
                        final value = _pulseController.value;
                        return Container(
                          width: widget.size * (1.0 + (value * 0.5)),
                          height: widget.size * (1.0 + (value * 0.5)),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: stateColor.withValues(alpha: 0.3 * (1.0 - value)),
                          ),
                        );
                      },
                    ),
                ],
              ),
              if (widget.showLabel) ...[
                const SizedBox(width: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    socketViewModel.connectionStateDescription,
                    key: ValueKey(socketViewModel.connectionStateDescription),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: stateColor,
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
            socketViewModel.connectionState == SocketConnectionState.connecting ||
            socketViewModel.connectionState == SocketConnectionState.reconnecting;
        final hasError = socketViewModel.connectionState == SocketConnectionState.error;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: ElevatedButton.icon(
            onPressed: isConnecting
                ? null
                : () {
                    unawaited(
                      _performSocketConnectionButtonTap(
                        context: context,
                        socketViewModel: socketViewModel,
                        isConnected: isConnected,
                      ).catchError((Object e, StackTrace s) {
                        AppLogger.warning(
                          'Falha não tratada ao alternar WebSocket',
                          tag: 'SocketConnectionButton',
                          error: e,
                          stackTrace: s,
                        );
                      }),
                    );
                  },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _buildIcon(isConnected, isConnecting, hasError),
            ),
            label: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _getButtonLabel(socketViewModel.connectionState, label),
                key: ValueKey(_getButtonLabel(socketViewModel.connectionState, label)),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getButtonColor(context, socketViewModel.connectionState),
              foregroundColor: _getButtonTextColor(context, socketViewModel.connectionState),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon(bool isConnected, bool isConnecting, bool hasError) {
    if (isConnecting) {
      return const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2));
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
                    Icon(Icons.wifi, color: Color(socketViewModel.connectionStateColor)),
                    const SizedBox(width: 8),
                    Text(
                      'Status WebSocket',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                      child: SocketConnectionButton(label: socketViewModel.isConnected ? 'Desconectar' : 'Conectar'),
                    ),
                    const SizedBox(width: 8),
                    if (socketViewModel.connectionState == SocketConnectionState.error)
                      Expanded(
                        child: ElevatedButton.icon(
                          // Bug latente anterior: `reconnect()` retorna
                          // Future. Sem await/catch, qualquer erro
                          // durante reconnect virava "Unhandled Future
                          // error" silencioso. O ViewModel ja loga
                          // internamente, entao envolvemos em
                          // `unawaited` + catchError defensivo.
                          onPressed: () {
                            unawaited(
                              socketViewModel.reconnect().catchError((Object e, StackTrace s) {
                                AppLogger.warning(
                                  'Falha ao reconectar socket',
                                  tag: 'SocketStatusCard',
                                  error: e,
                                  stackTrace: s,
                                );
                              }),
                            );
                          },
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

  Widget _buildStatusRow(BuildContext context, String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: valueColor, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
