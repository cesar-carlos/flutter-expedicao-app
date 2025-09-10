import 'package:flutter/material.dart';
import 'package:exp/domain/viewmodels/user_selection_viewmodel.dart';
import 'package:exp/core/theme/app_colors.dart';

class UserConfirmButton extends StatelessWidget {
  final UserSelectionViewModel viewModel;
  final VoidCallback onConfirm;

  const UserConfirmButton({
    super.key,
    required this.viewModel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: viewModel.state == UserSelectionState.selecting
            ? null
            : onConfirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: viewModel.state == UserSelectionState.selecting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Confirmar Seleção',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
