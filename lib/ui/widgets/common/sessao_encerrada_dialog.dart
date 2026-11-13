import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';
import 'package:data7_expedicao/core/theme/theme_extensions.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/servidor_emergencia_aviso_model.dart';

class SessaoEncerradaDialog extends StatefulWidget {
  final ServidorEmergenciaAvisoModel aviso;
  final Future<void> Function() onReconnect;

  const SessaoEncerradaDialog({super.key, required this.aviso, required this.onReconnect});

  static Future<void> show({
    required BuildContext context,
    required ServidorEmergenciaAvisoModel aviso,
    required Future<void> Function() onReconnect,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SessaoEncerradaDialog(aviso: aviso, onReconnect: onReconnect),
    ).catchError((Object e, StackTrace s) {
      AppLogger.warning(
        'Falha ao exibir dialog de sessao encerrada',
        tag: 'SessaoEncerradaDialog',
        error: e,
        stackTrace: s,
      );
    });
  }

  @override
  State<SessaoEncerradaDialog> createState() => _SessaoEncerradaDialogState();
}

class _SessaoEncerradaDialogState extends State<SessaoEncerradaDialog> {
  bool _reconnecting = false;

  Future<void> _reconnect() async {
    if (_reconnecting) {
      return;
    }
    setState(() => _reconnecting = true);
    try {
      await widget.onReconnect();
    } finally {
      if (mounted) {
        setState(() => _reconnecting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mensagem = widget.aviso.mensagem.trim().isEmpty
        ? 'O servidor encerrou a sessão. Reconecte para continuar.'
        : widget.aviso.mensagem;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.link_off, color: AppColors.error, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sessão encerrada',
              style: AppFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.error),
            ),
          ),
        ],
      ),
      content: Text(
        mensagem,
        style: AppFonts.inter(fontSize: 16, color: theme.isDark ? AppColors.light : AppColors.black87),
      ),
      actions: [
        FilledButton(
          onPressed: _reconnecting ? null : _reconnect,
          child: Text(_reconnecting ? 'Reconectando...' : 'Reconectar'),
        ),
      ],
    );
  }
}
