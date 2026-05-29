import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/core/localization/localization_extensions.dart';
import 'package:data7_expedicao/core/validation/forms/form_validators_localized.dart';
import 'package:data7_expedicao/presentation/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/common/index.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginForm({super.key, this.onLoginSuccess});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final configViewModel = context.read<ConfigViewModel>();

      if (!configViewModel.hasConfig) {
        _showServerConfigDialog(context.l10n.serverNotConfigured);
        return;
      }

      if (!configViewModel.connectionTested) {
        _showServerConfigDialog(context.l10n.serverNotTested);
        return;
      }

      unawaited(
        context.read<AuthViewModel>().login(_usernameController.text.trim(), _passwordController.text).catchError((
          Object e,
          StackTrace s,
        ) {
          AppLogger.warning(
            'Falha inesperada no fluxo de login',
            tag: 'LoginForm',
            error: e,
            stackTrace: s,
          );
        }),
      );
    }
  }

  void _showServerConfigDialog(String message) {
    if (!mounted) return;

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.warning, color: AppColors.warning, size: 32),
          title: Text(dialogContext.l10n.configurationNeeded),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(dialogContext.l10n.cancel)),
            FilledButton(
              child: Text(dialogContext.l10n.configure),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                dialogContext.go('/config');
              },
            ),
          ],
        ),
      ).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao exibir dialog de configuração do servidor',
          tag: 'LoginForm',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final validators = FormValidatorsLocalized(context.l10n);

    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextFormField(
                controller: _usernameController,
                enabled: !authViewModel.isLoginLoading,
                labelText: context.l10n.username,
                hintText: context.l10n.usernameHint,
                prefixIcon: Icons.person_outline,
                validator: validators.username,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              CustomTextFormField(
                controller: _passwordController,
                enabled: !authViewModel.isLoginLoading,
                obscureText: true,
                labelText: context.l10n.password,
                hintText: context.l10n.passwordHint,
                prefixIcon: Icons.lock_outline,
                showVisibilityToggle: true,
                validator: validators.password,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: _handleLogin,
              ),

              const SizedBox(height: 24),

              LoadingButton(
                text: context.l10n.loginButton,
                onPressed: _handleLogin,
                isLoading: authViewModel.isLoginLoading,
              ),

              const SizedBox(height: 8),

              // Botão Login System
              CustomFlatButton(
                text: context.l10n.loginSystem,
                onPressed: authViewModel.isLoginLoading ? null : () => context.go('/qrcode-login'),
                icon: Icons.qr_code_scanner,
                textColor: Theme.of(context).colorScheme.secondary,
                backgroundColor: AppColors.transparent,
                borderColor: AppColors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                borderRadius: 6,
              ),

              if (authViewModel.errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                ErrorMessage(message: authViewModel.errorMessage),
              ],
            ],
          ),
        );
      },
    );
  }
}
