import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/servidor_emergencia_aviso_model.dart';
import 'package:data7_expedicao/presentation/viewmodels/servidor_emergencia_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/common/servidor_emergencia_aviso_dialog.dart';
import 'package:data7_expedicao/ui/widgets/common/sessao_encerrada_dialog.dart';

class ServidorEmergenciaHost extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  const ServidorEmergenciaHost({super.key, required this.navigatorKey, required this.child});

  @override
  State<ServidorEmergenciaHost> createState() => _ServidorEmergenciaHostState();
}

class _ServidorEmergenciaHostState extends State<ServidorEmergenciaHost> {
  ServidorEmergenciaViewModel? _viewModel;
  bool _syncScheduled = false;
  bool _avisoVisible = false;
  bool _sessaoVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final viewModel = context.read<ServidorEmergenciaViewModel>();
    if (identical(_viewModel, viewModel)) {
      return;
    }

    _viewModel?.removeListener(_syncDialogs);
    _viewModel = viewModel;
    viewModel.addListener(_syncDialogs);
    _syncDialogs();
  }

  @override
  void dispose() {
    _viewModel?.removeListener(_syncDialogs);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  void _syncDialogs() {
    if (_syncScheduled) {
      return;
    }
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!mounted) {
        return;
      }
      _presentPendingDialogs();
    });
  }

  void _presentPendingDialogs() {
    final viewModel = _viewModel;
    final dialogContext = widget.navigatorKey.currentContext;
    if (viewModel == null || dialogContext == null || !dialogContext.mounted) {
      return;
    }

    if (!viewModel.isSessionEndedByServer && _sessaoVisible) {
      Navigator.of(dialogContext, rootNavigator: true).pop();
      _sessaoVisible = false;
    }

    if (viewModel.isSessionEndedByServer) {
      if (_avisoVisible || _sessaoVisible) {
        return;
      }
      _sessaoVisible = true;
      unawaited(_showSessaoEncerrada(dialogContext, viewModel));
      return;
    }

    final aviso = viewModel.pendingAviso;
    if (aviso != null && !_avisoVisible && !_sessaoVisible) {
      _avisoVisible = true;
      unawaited(_showAviso(dialogContext, viewModel, aviso));
    }
  }

  Future<void> _showAviso(
    BuildContext dialogContext,
    ServidorEmergenciaViewModel viewModel,
    ServidorEmergenciaAvisoModel aviso,
  ) async {
    try {
      await ServidorEmergenciaAvisoDialog.show(dialogContext, aviso);
    } finally {
      _avisoVisible = false;
      viewModel.consumePendingAviso();
      _syncDialogs();
    }
  }

  Future<void> _showSessaoEncerrada(BuildContext dialogContext, ServidorEmergenciaViewModel viewModel) async {
    try {
      await SessaoEncerradaDialog.show(
        context: dialogContext,
        aviso:
            viewModel.lastAviso ??
            const ServidorEmergenciaAvisoModel(
              nivel: 'desconectar',
              codigo: 'SERVIDOR_DESCONECTAR',
              mensagem: '',
              acao: 'desconectar',
              prazoMs: 0,
            ),
        onReconnect: () => _reconnect(viewModel),
      );
    } finally {
      _sessaoVisible = false;
    }
  }

  Future<void> _reconnect(ServidorEmergenciaViewModel viewModel) async {
    try {
      await viewModel.reconnectAfterServerEnd();
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Falha ao reconectar apos sessao encerrada pelo servidor',
        tag: 'ServidorEmergenciaHost',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
