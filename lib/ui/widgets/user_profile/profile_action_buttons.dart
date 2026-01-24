import 'package:flutter/material.dart';

import 'package:data7_expedicao/domain/viewmodels/profile_viewmodel.dart';
import 'package:data7_expedicao/core/localization/localization_extensions.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';

class ProfileActionButtons extends StatelessWidget {
  final ProfileViewModel viewModel;
  final VoidCallback onSave;
  final VoidCallback onBack;
  final bool hasChanges;

  const ProfileActionButtons({
    super.key,
    required this.viewModel,
    required this.onSave,
    required this.onBack,
    required this.hasChanges,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = viewModel.state == ProfileState.loading;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildSaveButton(context, isLoading, colorScheme),
        const SizedBox(height: 16),
        _buildBackButton(context, isLoading, colorScheme),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, bool isLoading, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: hasChanges
            ? LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)])
            : null,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: isLoading || !hasChanges ? null : onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: hasChanges ? AppColors.transparent : null,
          foregroundColor: hasChanges ? colorScheme.onPrimary : null,
          shadowColor: AppColors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(hasChanges ? colorScheme.onPrimary : colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Salvando...',
                    style: AppFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: hasChanges ? colorScheme.onPrimary : null,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(hasChanges ? Icons.save : Icons.save_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    hasChanges ? context.l10n.saveProfile : 'Nenhuma alteração',
                    style: AppFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isLoading, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onBack,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_back, size: 20, color: colorScheme.onSurface),
            const SizedBox(width: 8),
            Text(
              context.l10n.back,
              style: AppFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileSaveButton extends StatelessWidget {
  final ProfileViewModel viewModel;
  final VoidCallback onSave;
  final bool hasChanges;

  const ProfileSaveButton({super.key, required this.viewModel, required this.onSave, required this.hasChanges});

  @override
  Widget build(BuildContext context) {
    final isLoading = viewModel.state == ProfileState.loading;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: hasChanges
            ? LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)])
            : null,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: isLoading || !hasChanges ? null : onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: hasChanges ? AppColors.transparent : null,
          foregroundColor: hasChanges ? colorScheme.onPrimary : null,
          shadowColor: AppColors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(hasChanges ? colorScheme.onPrimary : colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Salvando...',
                    style: AppFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: hasChanges ? colorScheme.onPrimary : null,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(hasChanges ? Icons.save : Icons.save_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    hasChanges ? context.l10n.saveProfile : 'Nenhuma alteração',
                    style: AppFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}
