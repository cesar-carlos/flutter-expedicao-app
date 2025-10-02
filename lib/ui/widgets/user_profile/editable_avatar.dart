import 'package:flutter/material.dart';

import 'package:exp/domain/viewmodels/profile_viewmodel.dart';
import 'package:exp/ui/widgets/user_profile/photo_options_modal.dart';

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
          // Container principal do avatar
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [colorScheme.primary.withOpacity(0.2), colorScheme.secondary.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: colorScheme.primary.withOpacity(0.3), width: 3),
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(shape: BoxShape.circle, color: colorScheme.surface),
              child: _buildDynamicAvatar(colorScheme),
            ),
          ),

          // Botão de edição
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 3),
              ),
              child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicAvatar(ColorScheme colorScheme) {
    final selectedPhoto = viewModel.selectedPhoto;
    final user = viewModel.currentUser;

    if (selectedPhoto != null) {
      return ClipOval(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(shape: BoxShape.circle, color: colorScheme.surface),
          child: Image.file(
            selectedPhoto,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultAvatar(colorScheme, user);
            },
          ),
        ),
      );
    }

    // Se tem foto salva, usar avatar padrão por enquanto
    // TODO: Implementar conversão de base64 para Image.memory

    return _buildDefaultAvatar(colorScheme, user);
  }

  Widget _buildDefaultAvatar(ColorScheme colorScheme, dynamic user) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [colorScheme.primary.withOpacity(0.8), colorScheme.secondary.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          user?.nome?.isNotEmpty == true ? user.nome.substring(0, 1).toUpperCase() : 'U',
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1),
        ),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context) {
    PhotoOptionsModal.show(context, viewModel);
  }
}
