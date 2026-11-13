import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';
import 'package:data7_expedicao/core/theme/theme_extensions.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/servidor_emergencia_aviso_model.dart';

class ServidorEmergenciaAvisoDialog extends StatelessWidget {
  final ServidorEmergenciaAvisoModel aviso;

  const ServidorEmergenciaAvisoDialog({super.key, required this.aviso});

  static Future<void> show(BuildContext context, ServidorEmergenciaAvisoModel aviso) {
    return showDialog<void>(
      context: context,
      barrierDismissible: !aviso.vaiDesconectar,
      builder: (_) => ServidorEmergenciaAvisoDialog(aviso: aviso),
    ).catchError((Object e, StackTrace s) {
      AppLogger.warning(
        'Falha ao exibir aviso de emergencia',
        tag: 'ServidorEmergenciaAvisoDialog',
        error: e,
        stackTrace: s,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = aviso.vaiDesconectar || aviso.nivel == 'urgente' ? AppColors.error : AppColors.warning;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              aviso.titulo,
              style: AppFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: iconColor),
            ),
          ),
        ],
      ),
      content: Text(
        aviso.detalhe,
        style: AppFonts.inter(fontSize: 16, color: theme.isDark ? AppColors.light : AppColors.black87),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Entendi'))],
    );
  }
}
