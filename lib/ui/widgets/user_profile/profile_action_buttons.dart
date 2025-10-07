import 'package:flutter/material.dart';

import 'package:exp/domain/viewmodels/profile_viewmodel.dart';
import 'package:exp/core/constants/app_strings.dart';
import 'package:exp/core/theme/app_colors.dart';

/// Widget com botões de ação do perfil (Salvar e Voltar)
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
        _buildSaveButton(isLoading, colorScheme),
        const SizedBox(height: 16),
        _buildBackButton(isLoading, colorScheme),
      ],
    );
  }

  Widget _buildSaveButton(bool isLoading, ColorScheme colorScheme) {
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
          foregroundColor: hasChanges ? AppColors.white : null,
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
                      valueColor: AlwaysStoppedAnimation(hasChanges ? AppColors.white : colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Salvando...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: hasChanges ? AppColors.white : null,
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
                    hasChanges ? AppStrings.saveProfile : 'Nenhuma alteração',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBackButton(bool isLoading, ColorScheme colorScheme) {
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
              'Voltar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget apenas com o botão de salvar (para usar sem o botão voltar)
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
          foregroundColor: hasChanges ? AppColors.white : null,
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
                      valueColor: AlwaysStoppedAnimation(hasChanges ? AppColors.white : colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Salvando...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: hasChanges ? AppColors.white : null,
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
                    hasChanges ? AppStrings.saveProfile : 'Nenhuma alteração',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}
