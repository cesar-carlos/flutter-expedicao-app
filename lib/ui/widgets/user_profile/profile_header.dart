import 'package:flutter/material.dart';
import 'package:exp/domain/viewmodels/profile_viewmodel.dart';
import 'package:exp/core/theme/app_colors.dart';
import 'editable_avatar.dart';
import 'user_info_chips.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileViewModel viewModel;

  const ProfileHeader({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final user = viewModel.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          EditableAvatar(viewModel: viewModel),
          const SizedBox(height: 20),

          if (user != null) ...[
            Text(
              user.nome,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: user.isActive
                    ? AppColors.successWithOpacity(0.2)
                    : AppColors.withOpacity(AppColors.error, 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: user.isActive ? AppColors.success : AppColors.error,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    user.isActive ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: user.isActive ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    user.isActive ? 'Ativo' : 'Inativo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: user.isActive
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            UserInfoChips(user: user),
          ],
        ],
      ),
    );
  }
}
