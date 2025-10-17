import 'package:flutter/material.dart';

import 'package:data7_expedicao/domain/viewmodels/profile_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/user_profile/widgets/index.dart';
import 'package:data7_expedicao/core/constants/app_strings.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';

class PasswordSection extends StatefulWidget {
  final ProfileViewModel viewModel;
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;

  const PasswordSection({
    super.key,
    required this.viewModel,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
  });

  @override
  State<PasswordSection> createState() => _PasswordSectionState();
}

class _PasswordSectionState extends State<PasswordSection> {
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isPasswordSectionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ProfileSectionContainer(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header clicável usando ExpandableSectionHeader
          ExpandableSectionHeader(
            title: 'Segurança da Conta',
            subtitle: 'Altere sua senha de acesso ao sistema',
            icon: Icons.shield_outlined,
            iconBackgroundColor: colorScheme.errorContainer,
            iconColor: colorScheme.error,
            isExpanded: _isPasswordSectionExpanded,
            onTap: () {
              setState(() {
                _isPasswordSectionExpanded = !_isPasswordSectionExpanded;
              });
            },
          ),

          // Conteúdo expansível
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _isPasswordSectionExpanded
                ? Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        // Divisor
                        Container(
                          height: 1,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                colorScheme.outline.withValues(alpha: 0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        // Aviso de segurança
                        _buildSecurityWarning(theme, colorScheme),

                        const SizedBox(height: 20),

                        // Campos de senha
                        _buildCurrentPasswordField(colorScheme, theme),
                        const SizedBox(height: 16),
                        _buildNewPasswordField(colorScheme, theme),
                        const SizedBox(height: 16),
                        _buildConfirmPasswordField(colorScheme, theme),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityWarning(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.warning, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Use uma senha forte com pelo menos 4 caracteres',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.warning.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPasswordField(ColorScheme colorScheme, ThemeData theme) {
    return _buildPasswordField(
      controller: widget.currentPasswordController,
      labelText: AppStrings.currentPasswordLabel,
      hintText: AppStrings.currentPasswordHint,
      prefixIcon: Icons.lock_outline,
      obscureText: !_showCurrentPassword,
      onVisibilityToggle: () {
        setState(() {
          _showCurrentPassword = !_showCurrentPassword;
        });
      },
      onChanged: widget.viewModel.setCurrentPassword,
      validator: (value) {
        if (widget.newPasswordController.text.isNotEmpty) {
          if (value == null || value.isEmpty) {
            return AppStrings.currentPasswordRequired;
          }
        }
        return null;
      },
      colorScheme: colorScheme,
      theme: theme,
    );
  }

  Widget _buildNewPasswordField(ColorScheme colorScheme, ThemeData theme) {
    return _buildPasswordField(
      controller: widget.newPasswordController,
      labelText: AppStrings.newPasswordLabel,
      hintText: AppStrings.newPasswordHint,
      prefixIcon: Icons.lock_reset,
      obscureText: !_showNewPassword,
      onVisibilityToggle: () {
        setState(() {
          _showNewPassword = !_showNewPassword;
        });
      },
      onChanged: widget.viewModel.setNewPassword,
      validator: (value) {
        if (value != null && value.isNotEmpty && value.length < 4) {
          return AppStrings.passwordMinLengthProfile;
        }
        return null;
      },
      colorScheme: colorScheme,
      theme: theme,
    );
  }

  Widget _buildConfirmPasswordField(ColorScheme colorScheme, ThemeData theme) {
    return _buildPasswordField(
      controller: widget.confirmPasswordController,
      labelText: AppStrings.confirmNewPasswordLabel,
      hintText: AppStrings.confirmNewPasswordHint,
      prefixIcon: Icons.verified_user,
      obscureText: !_showConfirmPassword,
      onVisibilityToggle: () {
        setState(() {
          _showConfirmPassword = !_showConfirmPassword;
        });
      },
      onChanged: widget.viewModel.setConfirmPassword,
      validator: (value) {
        if (widget.newPasswordController.text.isNotEmpty) {
          if (value != widget.newPasswordController.text) {
            return AppStrings.passwordsDoNotMatchProfile;
          }
        }
        return null;
      },
      colorScheme: colorScheme,
      theme: theme,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    required bool obscureText,
    required VoidCallback onVisibilityToggle,
    required Function(String?) onChanged,
    required String? Function(String?) validator,
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: colorScheme.onSurfaceVariant),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: colorScheme.onSurfaceVariant),
          onPressed: onVisibilityToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      validator: validator,
    );
  }
}
