import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:data7_expedicao/domain/viewmodels/profile_viewmodel.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';

class PhotoOptionsModal extends StatelessWidget {
  final ProfileViewModel viewModel;

  const PhotoOptionsModal({super.key, required this.viewModel});

  static void show(BuildContext context, ProfileViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => PhotoOptionsModal(viewModel: viewModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(2)),
            ),

            const SizedBox(height: 20),

            Text('Alterar Foto de Perfil', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),

            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.camera_alt, color: theme.colorScheme.primary),
              ),
              title: const Text('Tirar Foto'),
              subtitle: const Text('Usar câmera do dispositivo'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(context, ImageSource.camera);
              },
            ),

            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.photo_library, color: theme.colorScheme.secondary),
              ),
              title: const Text('Escolher da Galeria'),
              subtitle: const Text('Selecionar foto existente'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(context, ImageSource.gallery);
              },
            ),

            if (viewModel.currentUser?.hasPhoto == true || viewModel.selectedPhoto != null)
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.delete_outline, color: AppColors.error),
                ),
                title: const Text('Remover Foto'),
                subtitle: const Text('Usar avatar padrão'),
                onTap: () {
                  Navigator.of(context).pop();
                  viewModel.setSelectedPhoto(null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 800, maxHeight: 800);

      if (image != null) {
        final File imageFile = File(image.path);
        viewModel.setSelectedPhoto(imageFile);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
