import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:data7_expedicao/core/constants/app_strings.dart';

/// Widget para seleção e exibição de foto de perfil
class ProfilePhotoSelector extends StatefulWidget {
  final File? initialImage;
  final ValueChanged<File?>? onImageChanged;
  final double size;
  final bool isRequired;

  const ProfilePhotoSelector({
    super.key,
    this.initialImage,
    this.onImageChanged,
    this.size = 120,
    this.isRequired = false,
  });

  @override
  State<ProfilePhotoSelector> createState() => _ProfilePhotoSelectorState();
}

class _ProfilePhotoSelectorState extends State<ProfilePhotoSelector> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 80, maxWidth: 800, maxHeight: 800);

      if (image != null) {
        final File imageFile = File(image.path);
        setState(() {
          _selectedImage = imageFile;
        });
        widget.onImageChanged?.call(imageFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
    widget.onImageChanged?.call(null);
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(AppStrings.removePhoto),
                textColor: Colors.red,
                onTap: () {
                  Navigator.of(context).pop();
                  _removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Container da foto
        GestureDetector(
          onTap: _showImageOptions,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surfaceContainerHighest,
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3), width: 2),
            ),
            child: _selectedImage != null
                ? ClipOval(
                    child: Image.file(_selectedImage!, width: widget.size, height: widget.size, fit: BoxFit.cover),
                  )
                : Icon(Icons.person, size: widget.size * 0.5, color: colorScheme.onSurfaceVariant),
          ),
        ),

        const SizedBox(height: 12),

        // Botão de ação
        TextButton.icon(
          onPressed: _showImageOptions,
          icon: Icon(_selectedImage != null ? Icons.edit : Icons.add_a_photo, size: 18),
          label: Text(_selectedImage != null ? AppStrings.changePhoto : AppStrings.addPhoto),
        ),

        // Texto opcional/obrigatório
        if (widget.isRequired) ...[
          const SizedBox(height: 4),
          Text('* Obrigatório', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.error)),
        ],
      ],
    );
  }
}

/// Validador para foto de perfil
class ProfilePhotoValidator {
  static String? validate(File? image, {bool isRequired = false}) {
    if (isRequired && image == null) {
      return 'Por favor, adicione uma foto de perfil';
    }
    return null;
  }
}
