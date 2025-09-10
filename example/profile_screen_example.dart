import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exp/domain/viewmodels/profile_viewmodel.dart';
import 'package:exp/domain/viewmodels/auth_viewmodel.dart';
import 'package:exp/domain/repositories/user_repository.dart';
import 'package:exp/ui/screens/profile_screen.dart';
import 'package:exp/di/locator.dart';

/// Exemplo de como usar a tela de perfil do usuário
///
/// Este exemplo demonstra como integrar a ProfileScreen
/// com os ViewModels necessários usando Provider
class ProfileScreenExample extends StatelessWidget {
  const ProfileScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exemplo - Tela de Perfil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Este é um exemplo de como abrir a tela de perfil.\n'
              'Na aplicação real, isso é feito através do GoRouter.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () => _openProfileScreen(context),
              child: const Text('Abrir Tela de Perfil'),
            ),
          ],
        ),
      ),
    );
  }

  /// Abre a tela de perfil usando navegação manual
  void _openProfileScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => ProfileViewModel(
            locator<UserRepository>(),
            Provider.of<AuthViewModel>(context, listen: false),
          ),
          child: const ProfileScreen(),
        ),
      ),
    );
  }
}

/// Exemplo de uso completo da funcionalidade de perfil
class CompleteProfileExample extends StatefulWidget {
  const CompleteProfileExample({super.key});

  @override
  State<CompleteProfileExample> createState() => _CompleteProfileExampleState();
}

class _CompleteProfileExampleState extends State<CompleteProfileExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Funcionalidades do Perfil')),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          final currentUser = authViewModel.currentUser;

          if (currentUser == null) {
            return const Center(
              child: Text(
                'Usuário não logado.\n'
                'Faça login para acessar o perfil.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informações atuais do usuário
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Usuário Atual:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text('Nome: ${currentUser.nome}'),
                        Text('ID: ${currentUser.codLoginApp}'),
                        if (currentUser.codUsuario != null)
                          Text('Código: ${currentUser.codUsuario}'),
                        Text(
                          'Status: ${currentUser.isActive ? "Ativo" : "Inativo"}',
                        ),
                        Text(
                          'Tem foto: ${currentUser.hasPhoto ? "Sim" : "Não"}',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Funcionalidades disponíveis
                const Text(
                  'Funcionalidades do Perfil:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: Icon(Icons.camera_alt),
                          title: Text('Alterar Foto de Perfil'),
                          subtitle: Text('Selecione foto da câmera ou galeria'),
                          contentPadding: EdgeInsets.zero,
                        ),

                        ListTile(
                          leading: Icon(Icons.lock),
                          title: Text('Alterar Senha'),
                          subtitle: Text(
                            'Seção expansível para mudança de senha',
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),

                        ListTile(
                          leading: Icon(Icons.save),
                          title: Text('Salvar Alterações'),
                          subtitle: Text('Atualiza dados via API PUT'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Botão para abrir a tela de perfil
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _openProfileScreen(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text(
                      'Abrir Tela de Perfil',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openProfileScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => ProfileViewModel(
            locator<UserRepository>(),
            Provider.of<AuthViewModel>(context, listen: false),
          ),
          child: const ProfileScreen(),
        ),
      ),
    );
  }
}

/// Demonstração das validações do formulário de perfil
class ProfileValidationExample {
  /// Exemplo de validação de senha
  static String? validateCurrentPassword(
    String? value, {
    required bool hasNewPassword,
  }) {
    if (hasNewPassword && (value == null || value.isEmpty)) {
      return 'Senha atual é obrigatória para alterar a senha';
    }
    return null;
  }

  /// Exemplo de validação de nova senha
  static String? validateNewPassword(String? value) {
    if (value != null && value.isNotEmpty && value.length < 4) {
      return 'A nova senha deve ter pelo menos 4 caracteres';
    }
    return null;
  }

  /// Exemplo de validação de confirmação
  static String? validateConfirmPassword(String? value, String? newPassword) {
    if (newPassword != null && newPassword.isNotEmpty) {
      if (value != newPassword) {
        return 'As senhas não coincidem';
      }
    }
    return null;
  }
}
