import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/core/localization/localization_extensions.dart';
import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/presentation/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/common/custom_app_bar.dart';
import 'package:data7_expedicao/ui/widgets/config/printer_config_form.dart';

class PrinterConfigScreen extends StatelessWidget {
  const PrinterConfigScreen({super.key});

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    final authStatus = context.read<AuthViewModel>().status;
    if (authStatus == AuthStatus.authenticated) {
      context.go(AppRouter.home);
      return;
    }

    context.go(AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.withoutSocket(
        title: context.l10n.printerConfigTitle,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => _handleBack(context)),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(padding: EdgeInsets.all(24.0), child: PrinterConfigForm()),
      ),
    );
  }
}
