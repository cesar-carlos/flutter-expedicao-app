import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/constants/app_strings.dart';
import 'package:data7_expedicao/ui/widgets/common/index.dart';
import 'package:data7_expedicao/ui/widgets/auth/index.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  const AppHeader(
                    title: AppStrings.appName,
                    subtitle: AppStrings.loginTitle,
                    logoSize: 230,
                    spacing: 8,
                  ),

                  const SizedBox(height: 32),
                  const LoginForm(),
                ],
              ),
            ),

            const FloatingConfigButton(),
          ],
        ),
      ),
    );
  }
}
