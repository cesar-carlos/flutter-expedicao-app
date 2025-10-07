import 'package:flutter/material.dart';

import 'package:exp/domain/viewmodels/user_selection_viewmodel.dart';
import 'package:exp/core/theme/app_colors.dart';

class SearchStatusInfo extends StatelessWidget {
  final UserSelectionViewModel viewModel;

  const SearchStatusInfo({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel.isWaitingForSearch) {
      return _buildStatusContainer(
        color: AppColors.warning.withValues(alpha: 0.1),
        icon: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
          ),
        ),
        text: 'Aguardando digitação...',
        textColor: AppColors.warning,
      );
    } else if (viewModel.state == UserSelectionState.loading) {
      return _buildStatusContainer(
        color: AppColors.primaryWithOpacity(0.1),
        icon: const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
        text: 'Buscando usuários no servidor...',
        textColor: AppColors.primary,
      );
    } else if (viewModel.state == UserSelectionState.loaded) {
      final allUsers = viewModel.filteredUsers;
      final availableUsers = allUsers.where((user) => viewModel.isUserAvailable(user)).length;
      final blockedUsers = allUsers.length - availableUsers;

      return Column(
        children: [
          _buildStatusContainer(
            color: AppColors.successWithOpacity(0.1),
            icon: Icon(Icons.check_circle, size: 16, color: AppColors.success),
            text:
                '$availableUsers disponível${availableUsers != 1 ? 'is' : ''}, $blockedUsers vinculado${blockedUsers != 1 ? 's' : ''}',
            textColor: AppColors.success,
          ),
          const SizedBox(height: 8),
          _buildStatusContainer(
            color: AppColors.primaryWithOpacity(0.1),
            icon: Icon(Icons.info_outline, size: 16, color: AppColors.primary),
            text: 'Usuários vinculados aparecem bloqueados na lista',
            textColor: AppColors.primary,
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStatusContainer({
    required Color color,
    required Widget icon,
    required String text,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(7)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
