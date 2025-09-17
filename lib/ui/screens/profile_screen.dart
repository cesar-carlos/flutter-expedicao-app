import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:exp/domain/viewmodels/profile_viewmodel.dart';
import 'package:exp/ui/widgets/common/index.dart';
import 'package:exp/ui/widgets/user_profile/index.dart';
import 'package:exp/ui/widgets/user_profile/user_info_chips.dart';
import 'package:exp/core/constants/app_strings.dart';
import 'package:exp/core/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isNavigatingAway = false;

  @override
  void initState() {
    super.initState();
    // Adicionar listeners para forçar rebuild quando os campos mudarem
    _currentPasswordController.addListener(_onFieldChanged);
    _newPasswordController.addListener(_onFieldChanged);
    _confirmPasswordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    // Usar addPostFrameCallback para garantir que o viewModel já foi atualizado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        // Só processar mudanças de estado se o widget ainda estiver montado e não navegando
        if (mounted && !_isNavigatingAway) {
          _handleViewModelState(context, viewModel);
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            await _handleBack(viewModel);
          },
          child: Scaffold(
            appBar: CustomAppBar.withoutSocket(
              title: AppStrings.profileTitle,
              elevation: 0,
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              leading: IconButton(
                onPressed: () => _handleBack(viewModel),
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                tooltip: 'Voltar',
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileHeader(viewModel: viewModel),

                    const SizedBox(height: 24),

                    if (viewModel.currentUser != null) UserInfoChips(user: viewModel.currentUser!),

                    const SizedBox(height: 32),

                    PasswordSection(
                      viewModel: viewModel,
                      currentPasswordController: _currentPasswordController,
                      newPasswordController: _newPasswordController,
                      confirmPasswordController: _confirmPasswordController,
                    ),

                    const SizedBox(height: 40),

                    ProfileSaveButton(
                      viewModel: viewModel,
                      hasChanges: _hasChanges(viewModel),
                      onSave: () => _handleSave(viewModel),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _hasChanges(ProfileViewModel viewModel) {
    final hasPhotoChange = viewModel.selectedPhoto != null;
    final hasPhotoRemoval = viewModel.photoWasRemoved;

    // Verificar mudanças de senha usando controllers (mais confiável)
    final hasCurrentPassword = _currentPasswordController.text.trim().isNotEmpty;
    final hasNewPassword = _newPasswordController.text.trim().isNotEmpty;
    final hasConfirmPassword = _confirmPasswordController.text.trim().isNotEmpty;

    final hasPasswordChange = hasCurrentPassword || hasNewPassword || hasConfirmPassword;

    return hasPhotoChange || hasPhotoRemoval || hasPasswordChange;
  }

  void _handleViewModelState(BuildContext context, ProfileViewModel viewModel) {
    // Verificar se o widget ainda está montado e não está navegando
    if (!mounted || _isNavigatingAway) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Verificar novamente se o widget ainda está montado
      if (!mounted || _isNavigatingAway) return;

      switch (viewModel.state) {
        case ProfileState.success:
          if (_isNavigatingAway) return; // Evita processar múltiplas vezes
          _isNavigatingAway = true;

          // Armazenar a mensagem antes de resetar o viewModel
          final successMsg = viewModel.successMessage ?? AppStrings.profileSaved;

          // Resetar o estado do viewModel imediatamente
          viewModel.resetState();
          _clearPasswordFields();

          // Mostrar mensagem de sucesso e navegar imediatamente
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMsg),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );

          // Navegar imediatamente para evitar uso após dispose
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go('/home');
            }
          });
          break;
        case ProfileState.error:
          if (viewModel.errorMessage != null) {
            ErrorDialog.showServerError(
              context,
              message: AppStrings.profileError,
              details: viewModel.errorMessage!,
              showRetryButton: false,
            );
          }
          break;
        default:
          break;
      }
    });
  }

  Future<void> _handleSave(ProfileViewModel viewModel) async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await viewModel.saveProfile();
      if (success) {}
    }
  }

  Future<void> _handleBack(ProfileViewModel viewModel) async {
    final hasChanges = _hasChanges(viewModel);

    if (hasChanges) {
      final shouldDiscard = await DiscardChangesDialog.show(context);
      if (shouldDiscard == true) {
        _discardChanges(viewModel);
        if (mounted) {
          context.go('/home');
        }
      }
    } else {
      context.go('/home');
    }
  }

  void _clearPasswordFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _discardChanges(ProfileViewModel viewModel) {
    viewModel.setSelectedPhoto(null);

    _clearPasswordFields();

    viewModel.setCurrentPassword(null);
    viewModel.setNewPassword(null);
    viewModel.setConfirmPassword(null);
  }
}
