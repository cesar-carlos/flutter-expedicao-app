import 'package:flutter/material.dart';
import 'package:exp/domain/viewmodels/profile_viewmodel.dart';
import 'user_profile_widgets.dart';
import 'photo_options_modal.dart';

class EditableAvatar extends StatelessWidget {
  final ProfileViewModel viewModel;

  const EditableAvatar({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _showPhotoOptions(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: _buildDynamicAvatar(colorScheme),
          ),

          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 3),
              ),
              child: Icon(Icons.edit, color: colorScheme.onPrimary, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicAvatar(ColorScheme colorScheme) {
    final selectedPhoto = viewModel.selectedPhoto;

    if (selectedPhoto != null) {
      return CircleAvatar(
        radius: 100,
        backgroundImage: FileImage(selectedPhoto),
        backgroundColor: colorScheme.primaryContainer,
      );
    }

    return UserProfileAvatar(radius: 60);
  }

  void _showPhotoOptions(BuildContext context) {
    PhotoOptionsModal.show(context, viewModel);
  }
}
