import 'package:flutter/material.dart';

import 'package:exp/domain/viewmodels/profile_viewmodel.dart';
import 'package:exp/core/constants/app_strings.dart';
import 'package:exp/core/theme/app_colors.dart';

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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.secondaryContainer.withOpacity(0.3), colorScheme.tertiaryContainer.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.secondary.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: colorScheme.secondary.withOpacity(0.1), offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isPasswordSectionExpanded = !_isPasswordSectionExpanded;
              });
            },
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(20),
              bottom: _isPasswordSectionExpanded ? Radius.zero : const Radius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: _isPasswordSectionExpanded
                    ? LinearGradient(
                        colors: [colorScheme.secondary.withOpacity(0.15), colorScheme.secondary.withOpacity(0.08)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(20),
                  bottom: _isPasswordSectionExpanded ? Radius.zero : const Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.secondary, colorScheme.secondary.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: colorScheme.secondary.withOpacity(0.3), offset: const Offset(0, 2))],
                    ),
                    child: Icon(Icons.shield_outlined, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Segurança da Conta',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Altere sua senha de acesso ao sistema',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AnimatedRotation(
                      turns: _isPasswordSectionExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(Icons.expand_more, color: colorScheme.secondary, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isPasswordSectionExpanded
                ? Container(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      children: [
                        Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.secondary.withOpacity(0.2),
                                colorScheme.secondary.withOpacity(0.1),
                                colorScheme.secondary.withOpacity(0.2),
                              ],
                            ),
                          ),
                        ),

                        _buildSecurityWarning(theme, colorScheme),

                        const SizedBox(height: 20),

                        _buildCurrentPasswordField(colorScheme),

                        const SizedBox(height: 16),

                        _buildNewPasswordField(colorScheme),

                        const SizedBox(height: 16),

                        _buildConfirmPasswordField(colorScheme),
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
        color: AppColors.withOpacity(AppColors.warning, 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.withOpacity(AppColors.warning, 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.warning, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Use uma senha forte com pelo menos 4 caracteres',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPasswordField(ColorScheme colorScheme) {
    return TextFormField(
      controller: widget.currentPasswordController,
      obscureText: !_showCurrentPassword,
      onChanged: widget.viewModel.setCurrentPassword,
      decoration: InputDecoration(
        labelText: AppStrings.currentPasswordLabel,
        hintText: AppStrings.currentPasswordHint,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_showCurrentPassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _showCurrentPassword = !_showCurrentPassword;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (widget.newPasswordController.text.isNotEmpty) {
          if (value == null || value.isEmpty) {
            return AppStrings.currentPasswordRequired;
          }
        }
        return null;
      },
    );
  }

  Widget _buildNewPasswordField(ColorScheme colorScheme) {
    return TextFormField(
      controller: widget.newPasswordController,
      obscureText: !_showNewPassword,
      onChanged: widget.viewModel.setNewPassword,
      decoration: InputDecoration(
        labelText: AppStrings.newPasswordLabel,
        hintText: AppStrings.newPasswordHint,
        prefixIcon: const Icon(Icons.lock_reset),
        suffixIcon: IconButton(
          icon: Icon(_showNewPassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _showNewPassword = !_showNewPassword;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty && value.length < 4) {
          return AppStrings.passwordMinLengthProfile;
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField(ColorScheme colorScheme) {
    return TextFormField(
      controller: widget.confirmPasswordController,
      obscureText: !_showConfirmPassword,
      onChanged: widget.viewModel.setConfirmPassword,
      decoration: InputDecoration(
        labelText: AppStrings.confirmNewPasswordLabel,
        hintText: AppStrings.confirmNewPasswordHint,
        prefixIcon: const Icon(Icons.verified_user),
        suffixIcon: IconButton(
          icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _showConfirmPassword = !_showConfirmPassword;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (widget.newPasswordController.text.isNotEmpty) {
          if (value != widget.newPasswordController.text) {
            return AppStrings.passwordsDoNotMatchProfile;
          }
        }
        return null;
      },
    );
  }
}
