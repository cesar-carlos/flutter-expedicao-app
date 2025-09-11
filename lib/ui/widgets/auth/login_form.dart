import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:exp/core/constants/app_strings.dart';
import 'package:exp/core/utils/form_validators.dart';
import 'package:exp/domain/viewmodels/auth_viewmodel.dart';
import 'package:exp/domain/viewmodels/config_viewmodel.dart';
import 'package:exp/ui/widgets/common/index.dart';

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
        _showServerConfigDialog(AppStrings.serverNotConfigured);
        return;
      }

      if (!configViewModel.connectionTested) {
        _showServerConfigDialog(AppStrings.serverNotTested);
        return;
      }

      context.read<AuthViewModel>().login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _showServerConfigDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning, color: Colors.orange, size: 32),
        title: const Text('Configuração Necessária'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            child: const Text('Configurar'),
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/config');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                labelText: AppStrings.username,
                hintText: AppStrings.usernameHint,
                prefixIcon: Icons.person_outline,
                validator: FormValidators.username,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              CustomTextFormField(
                controller: _passwordController,
                enabled: !authViewModel.isLoginLoading,
                obscureText: true,
                labelText: AppStrings.password,
                hintText: AppStrings.passwordHint,
                prefixIcon: Icons.lock_outline,
                showVisibilityToggle: true,
                validator: FormValidators.password,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: _handleLogin,
              ),

              const SizedBox(height: 24),

              LoadingButton(
                text: AppStrings.loginButton,
                onPressed: _handleLogin,
                isLoading: authViewModel.isLoginLoading,
              ),

              const SizedBox(height: 5),

              CustomFlatButton(
                text: AppStrings.registerText,
                onPressed: authViewModel.isLoginLoading
                    ? null
                    : () => context.go('/register'),
                icon: Icons.person_add_outlined,
                textColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Colors.transparent,
                borderColor: Colors.transparent,
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
