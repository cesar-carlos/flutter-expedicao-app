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

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isPasswordSectionExpanded = !_isPasswordSectionExpanded;
              });
            },
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: _isPasswordSectionExpanded
                  ? Radius.zero
                  : const Radius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isPasswordSectionExpanded
                    ? theme.colorScheme.primary.withOpacity(0.05)
                    : null,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(16),
                  bottom: _isPasswordSectionExpanded
                      ? Radius.zero
                      : const Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.security,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.changePasswordSection,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Altere sua senha de acesso',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isPasswordSectionExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.colorScheme.primary,
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
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        const Divider(),
                        const SizedBox(height: 20),

                        _buildSecurityWarning(theme),

                        const SizedBox(height: 16),

                        _buildCurrentPasswordField(),

                        const SizedBox(height: 16),

                        _buildNewPasswordField(),

                        const SizedBox(height: 16),

                        _buildConfirmPasswordField(),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityWarning(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.withOpacity(AppColors.warning, 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.withOpacity(AppColors.warning, 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.warning, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Use uma senha forte com pelo menos 4 caracteres',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPasswordField() {
    return TextFormField(
      controller: widget.currentPasswordController,
      obscureText: !_showCurrentPassword,
      onChanged: widget.viewModel.setCurrentPassword,
      decoration: InputDecoration(
        labelText: AppStrings.currentPasswordLabel,
        hintText: AppStrings.currentPasswordHint,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _showCurrentPassword ? Icons.visibility : Icons.visibility_off,
          ),
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

  Widget _buildNewPasswordField() {
    return TextFormField(
      controller: widget.newPasswordController,
      obscureText: !_showNewPassword,
      onChanged: widget.viewModel.setNewPassword,
      decoration: InputDecoration(
        labelText: AppStrings.newPasswordLabel,
        hintText: AppStrings.newPasswordHint,
        prefixIcon: const Icon(Icons.lock_reset),
        suffixIcon: IconButton(
          icon: Icon(
            _showNewPassword ? Icons.visibility : Icons.visibility_off,
          ),
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

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: widget.confirmPasswordController,
      obscureText: !_showConfirmPassword,
      onChanged: widget.viewModel.setConfirmPassword,
      decoration: InputDecoration(
        labelText: AppStrings.confirmNewPasswordLabel,
        hintText: AppStrings.confirmNewPasswordHint,
        prefixIcon: const Icon(Icons.verified_user),
        suffixIcon: IconButton(
          icon: Icon(
            _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
          ),
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
