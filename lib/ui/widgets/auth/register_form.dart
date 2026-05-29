import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/core/localization/localization_extensions.dart';
import 'package:data7_expedicao/ui/widgets/user_profile/profile_photo_selector.dart';
import 'package:data7_expedicao/core/validation/forms/form_validators_localized.dart';
import 'package:data7_expedicao/presentation/viewmodels/register_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/common/index.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    unawaited(
      _performRegister().catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha inesperada no cadastro',
          tag: 'RegisterForm',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  Future<void> _performRegister() async {
    final registerViewModel = context.read<RegisterViewModel>();

    final success = await registerViewModel.register(
      name: _nameController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      profileImage: registerViewModel.profileImage,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.registerSuccess),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );

      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final validators = FormValidatorsLocalized(context.l10n);

    return Consumer<RegisterViewModel>(
      builder: (context, registerViewModel, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ProfilePhotoSelector(
                  initialImage: registerViewModel.profileImage,
                  onImageChanged: (image) {
                    registerViewModel.setProfileImage(image);
                  },
                  size: 140,
                  isRequired: false,
                ),
              ),

              const SizedBox(height: 24),

              CustomTextFormField(
                controller: _nameController,
                enabled: !registerViewModel.isLoading,
                labelText: context.l10n.name,
                hintText: context.l10n.nameHint,
                prefixIcon: Icons.person_outline,
                validator: validators.name,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              CustomTextFormField(
                controller: _passwordController,
                enabled: !registerViewModel.isLoading,
                obscureText: true,
                labelText: context.l10n.password,
                hintText: context.l10n.passwordHint,
                prefixIcon: Icons.lock_outline,
                showVisibilityToggle: true,
                validator: validators.password,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              CustomTextFormField(
                controller: _confirmPasswordController,
                enabled: !registerViewModel.isLoading,
                obscureText: true,
                labelText: context.l10n.confirmPassword,
                hintText: context.l10n.confirmPasswordHint,
                prefixIcon: Icons.lock_outline,
                showVisibilityToggle: true,
                validator: (value) => validators.confirmPassword(value, _passwordController.text),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: _handleRegister,
              ),

              const SizedBox(height: 24),

              LoadingButton(
                text: context.l10n.registerButton,
                onPressed: _handleRegister,
                isLoading: registerViewModel.isLoading,
              ),

              const SizedBox(height: 16),

              if (registerViewModel.errorMessage.isNotEmpty) ...[
                ErrorMessage(message: registerViewModel.errorMessage),
                const SizedBox(height: 16),
              ],

              CustomFlatButton(
                text: context.l10n.backToLogin,
                onPressed: registerViewModel.isLoading ? null : () => context.go('/login'),
                icon: Icons.arrow_back_outlined,
                textColor: Theme.of(context).colorScheme.secondary,
                backgroundColor: AppColors.transparent,
                borderColor: AppColors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                borderRadius: 6,
              ),
            ],
          ),
        );
      },
    );
  }
}
