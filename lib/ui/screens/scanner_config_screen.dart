import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/core/constants/app_strings.dart';
import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/ui/widgets/config/scanner_config_form.dart';

class ScannerConfigScreen extends StatelessWidget {
  const ScannerConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.scannerConfigMenu),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(AppRouter.home)),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: ScannerConfigForm(),
        ),
      ),
    );
  }
}


