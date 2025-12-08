import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/core/constants/app_strings.dart';
import 'package:data7_expedicao/ui/widgets/user_profile/profile_photo_selector.dart';
import 'package:data7_expedicao/core/validation/forms/form_validators.dart';
import 'package:data7_expedicao/domain/viewmodels/register_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/common/index.dart';

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

  void _handleRegister() async {
    final registerViewModel = context.read<RegisterViewModel>();

    if (_formKey.currentState?.validate() ?? false) {
      final success = await registerViewModel.register(
        name: _nameController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        profileImage: registerViewModel.profileImage,
      );

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.registerSuccess),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );

        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                labelText: AppStrings.name,
                hintText: AppStrings.nameHint,
                prefixIcon: Icons.person_outline,
                validator: FormValidators.name,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              CustomTextFormField(
                controller: _passwordController,
                enabled: !registerViewModel.isLoading,
                obscureText: true,
                labelText: AppStrings.password,
                hintText: AppStrings.passwordHint,
                prefixIcon: Icons.lock_outline,
                showVisibilityToggle: true,
                validator: FormValidators.password,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              CustomTextFormField(
                controller: _confirmPasswordController,
                enabled: !registerViewModel.isLoading,
                obscureText: true,
                labelText: AppStrings.confirmPassword,
                hintText: AppStrings.confirmPasswordHint,
                prefixIcon: Icons.lock_outline,
                showVisibilityToggle: true,
                validator: (value) => FormValidators.confirmPassword(value, _passwordController.text),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: _handleRegister,
              ),

              const SizedBox(height: 24),

              LoadingButton(
                text: AppStrings.registerButton,
                onPressed: _handleRegister,
                isLoading: registerViewModel.isLoading,
              ),

              const SizedBox(height: 16),

              if (registerViewModel.errorMessage.isNotEmpty) ...[
                ErrorMessage(message: registerViewModel.errorMessage),
                const SizedBox(height: 16),
              ],

              CustomFlatButton(
                text: AppStrings.backToLogin,
                onPressed: registerViewModel.isLoading ? null : () => context.go('/login'),
                icon: Icons.arrow_back_outlined,
                textColor: Theme.of(context).colorScheme.secondary,
                backgroundColor: Colors.transparent,
                borderColor: Colors.transparent,
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
