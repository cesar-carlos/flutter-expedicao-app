import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:data7_expedicao/core/localization/localization_extensions.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';

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

  /// Bug KKKKKKKK: lock anti-race contra cliques rapidos no botao.
  /// _picker.pickImage abre dialog do sistema (camera/galeria); sem
  /// guard, multiplos cliques rapidos abriam VARIOS pickers
  /// simultaneamente — o primeiro sobreescrevia o resultado do segundo.
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage;
  }

  @override
  void didUpdateWidget(covariant ProfilePhotoSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Bug IIIIIIII: antes _selectedImage so era setado em initState.
    // Se o parent reconstruisse com nova initialImage (ex.: viewModel
    // emitir novo state), a UI nao atualizava — usuario via foto antiga.
    if (oldWidget.initialImage != widget.initialImage) {
      _selectedImage = widget.initialImage;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPicking) return;
    _isPicking = true;
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 80, maxWidth: 800, maxHeight: 800);

      if (image != null && mounted) {
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
            // Bug JJJJJJJJ: usar AppColors.error em vez de Colors.red para
            // consistencia com o tema (acessibilidade e modo escuro).
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      _isPicking = false;
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
    widget.onImageChanged?.call(null);
  }

  void _showImageOptions() {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (modalContext) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Câmera'),
                onTap: () {
                  Navigator.of(modalContext).pop();
                  unawaited(
                    _pickImage(ImageSource.camera).catchError((Object e, StackTrace s) {
                      AppLogger.warning(
                        'Falha ao abrir câmera (foto perfil)',
                        tag: 'ProfilePhotoSelector',
                        error: e,
                        stackTrace: s,
                      );
                    }),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.of(modalContext).pop();
                  unawaited(
                    _pickImage(ImageSource.gallery).catchError((Object e, StackTrace s) {
                      AppLogger.warning(
                        'Falha ao abrir galeria (foto perfil)',
                        tag: 'ProfilePhotoSelector',
                        error: e,
                        stackTrace: s,
                      );
                    }),
                  );
                },
              ),
              if (_selectedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: AppColors.error),
                  title: Text(modalContext.l10n.removePhoto),
                  textColor: AppColors.error,
                  onTap: () {
                    Navigator.of(modalContext).pop();
                    _removeImage();
                  },
                ),
            ],
          ),
        ),
      ).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao exibir opções de foto (cadastro)',
          tag: 'ProfilePhotoSelector',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
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

        TextButton.icon(
          onPressed: _showImageOptions,
          icon: Icon(_selectedImage != null ? Icons.edit : Icons.add_a_photo, size: 18),
          label: Text(_selectedImage != null ? context.l10n.changePhoto : context.l10n.addPhoto),
        ),

        if (widget.isRequired) ...[
          const SizedBox(height: 4),
          Text('* Obrigatório', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.error)),
        ],
      ],
    );
  }
}

class ProfilePhotoValidator {
  static String? validate(File? image, {bool isRequired = false}) {
    if (isRequired && image == null) {
      return 'Por favor, adicione uma foto de perfil';
    }
    return null;
  }
}
