import 'package:exp/domain/repositories/user_repository.dart';
import 'package:exp/domain/repositories/user_system_repository.dart';
import 'package:exp/domain/viewmodels/auth_viewmodel.dart';
import 'package:exp/domain/viewmodels/user_selection_viewmodel.dart';
import 'package:exp/di/locator.dart';

/// Exemplo completo do fluxo de login com seleção de usuário
void main() async {
  // Configurar dependências (normalmente feito no main.dart)
  setupLocator();

  final userRepository = locator<UserRepository>();
  final userSystemRepository = locator<UserSystemRepository>();
  final authViewModel = locator<AuthViewModel>();

  print('=== FLUXO COMPLETO: LOGIN + SELEÇÃO DE USUÁRIO ===\n');

  // PASSO 1: Login normal
  print('🔐 PASSO 1: Realizando login...');
  try {
    await authViewModel.login('cesar', '1234');

    if (authViewModel.needsUserSelection) {
      print('✅ Login realizado, mas CodUsuario é null');
      print('📋 Status: needsUserSelection');
      print('👤 Usuário atual: ${authViewModel.currentUser?.nome}');
      print('🔢 CodLoginApp: ${authViewModel.currentUser?.codLoginApp}');
      print('❓ CodUsuario: ${authViewModel.currentUser?.codUsuario}\n');

      // PASSO 2: Buscar usuários do sistema
      print('🔍 PASSO 2: Buscando usuários do sistema...');

      final userSelectionViewModel = UserSelectionViewModel(
        userSystemRepository,
        userRepository,
      );

      userSelectionViewModel.initialize(authViewModel.currentUser!);
      await userSelectionViewModel.searchUsers('cesar');

      if (userSelectionViewModel.state == UserSelectionState.loaded) {
        print('✅ Usuários encontrados: ${userSelectionViewModel.users.length}');

        for (var user in userSelectionViewModel.users) {
          print(
            '   • ${user.nomeUsuario} (ID: ${user.codUsuario}) - ${user.ativo ? "Ativo" : "Inativo"}',
          );
        }

        // PASSO 3: Selecionar usuário
        print('\n🎯 PASSO 3: Selecionando primeiro usuário...');
        final selectedUser = userSelectionViewModel.users.first;
        userSelectionViewModel.selectUser(selectedUser);

        print('✅ Usuário selecionado: ${selectedUser.nomeUsuario}');
        print('🔢 CodUsuario: ${selectedUser.codUsuario}');

        // PASSO 4: Confirmar seleção (PUT request)
        print('\n💾 PASSO 4: Confirmando seleção (PUT AppUser)...');
        final success = await userSelectionViewModel.confirmUserSelection();

        if (success) {
          print('✅ Usuário vinculado com sucesso!');

          // PASSO 5: Atualizar AuthViewModel
          print('\n🔄 PASSO 5: Atualizando AuthViewModel...');
          authViewModel.updateUserAfterSelection(
            userSelectionViewModel.currentAppUser!,
          );

          print('✅ Status final: ${authViewModel.status}');
          print('👤 Usuário final: ${authViewModel.currentUser?.nome}');
          print('🔢 CodLoginApp: ${authViewModel.currentUser?.codLoginApp}');
          print('✨ CodUsuario: ${authViewModel.currentUser?.codUsuario}');

          print('\n🎉 FLUXO COMPLETO FINALIZADO COM SUCESSO!');
        } else {
          print(
            '❌ Erro ao vincular usuário: ${userSelectionViewModel.errorMessage}',
          );
        }
      } else {
        print(
          '❌ Erro ao buscar usuários: ${userSelectionViewModel.errorMessage}',
        );
      }
    } else if (authViewModel.isAuthenticated) {
      print('✅ Login realizado com usuário já vinculado');
      print('👤 Usuário: ${authViewModel.currentUser?.nome}');
      print('🔢 CodUsuario: ${authViewModel.currentUser?.codUsuario}');
    }
  } catch (e) {
    print('❌ Erro no login: $e');
  }
}

/// Documentação do fluxo completo
/// 
/// FLUXO DE LOGIN COM SELEÇÃO DE USUÁRIO:
/// 
/// 1. LOGIN INICIAL
///    - Usuário digita nome/senha na LoginScreen
///    - AuthViewModel.login() é chamado
///    - Se login bem-sucedido, verifica LoginResponse.user.codUsuario
///
/// 2. VERIFICAÇÃO CODUSARIO
///    - Se CodUsuario != null: AuthStatus.authenticated (fluxo normal)
///    - Se CodUsuario == null: AuthStatus.needsUserSelection
///
/// 3. NAVEGAÇÃO AUTOMÁTICA
///    - AppRouter detecta needsUserSelection
///    - Navega automaticamente para /user-selection
///    - UserSelectionScreen é exibida
///
/// 4. BUSCA DE USUÁRIOS
///    - UserSelectionViewModel.searchUsers(nome) 
///    - Chama UserSystemRepository.searchUsersByName()
///    - Endpoint: GET /sistema-usuarios/search?nome={nome}
///
/// 5. SELEÇÃO DE USUÁRIO
///    - Usuário escolhe da lista exibida
///    - UserSelectionViewModel.selectUser(usuario)
///    - UserSelectionViewModel.confirmUserSelection()
///
/// 6. VINCULAÇÃO (PUT REQUEST)
///    - Cria AppUser com CodUsuario selecionado
///    - UserRepository.putAppUser(appUser)
///    - Endpoint: PUT /expedicao/login-app?CodLoginApp={id}
///
/// 7. FINALIZAÇÃO
///    - AuthViewModel.updateUserAfterSelection(novoAppUser)
///    - AuthStatus muda para authenticated
///    - AppRouter redireciona para /home
///
/// TELAS ENVOLVIDAS:
/// - LoginScreen: Login inicial
/// - UserSelectionScreen: Busca e seleção de usuário
/// - HomeShell: Tela principal pós-autenticação
///
/// VIEWMODELS:
/// - AuthViewModel: Gerencia estado de autenticação
/// - UserSelectionViewModel: Gerencia seleção de usuários
///
/// REPOSITÓRIOS:
/// - UserRepository: Operações de AppUser (login, putAppUser)
/// - UserSystemRepository: Operações de usuários do sistema (search)
///
/// ENDPOINTS UTILIZADOS:
/// - POST /expedicao/login-app (login inicial)
/// - GET /sistema-usuarios/search?nome={nome} (buscar usuários)
/// - PUT /expedicao/login-app?CodLoginApp={id} (vincular usuário)
