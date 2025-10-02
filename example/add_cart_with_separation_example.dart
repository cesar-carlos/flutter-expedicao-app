// ignore_for_file: unused_local_variable, avoid_print

import 'package:exp/domain/viewmodels/add_cart_viewmodel.dart';

/// Exemplo de uso do AddCartViewModel com verificação de separação
///
/// Este exemplo demonstra como o AddCartViewModel agora verifica automaticamente
/// se existe um carrinho percurso iniciado antes de adicionar um carrinho à separação
void main() async {
  print('=== Exemplo: AddCartViewModel com verificação de separação ===\n');

  // Simular dados de uma separação de estoque
  const codEmpresa = 1;
  const codSepararEstoque = 12345;

  // Criar instância do ViewModel
  final viewModel = AddCartViewModel(codEmpresa: codEmpresa, codSepararEstoque: codSepararEstoque);

  // Exemplo 1: Escanear código de barras de um carrinho
  await _exampleScanBarcode(viewModel);

  // Exemplo 2: Adicionar carrinho à separação (com verificação automática)
  await _exampleAddCartToSeparation(viewModel);

  // Exemplo 3: Fluxo completo
  await _exampleCompleteFlow();

  // Exemplo 4: Integração
  await _exampleIntegration();

  // Documentação
  _documentation();
}

/// Exemplo 1: Escanear código de barras
Future<void> _exampleScanBarcode(AddCartViewModel viewModel) async {
  print('=== Exemplo 1: Escanear código de barras ===\n');

  // Simular código de barras de um carrinho
  const barcode = '1234567890123';

  print('Escanando código: $barcode');
  await viewModel.scanBarcode(barcode);

  if (viewModel.hasError) {
    print('❌ Erro ao escanear: ${viewModel.errorMessage}');
  } else if (viewModel.hasCartData) {
    final cart = viewModel.scannedCart!;
    print('✅ Carrinho encontrado:');
    print('  Código: ${cart.codCarrinho}');
    print('  Situação: ${cart.situacao}');
    print('  Pode adicionar: ${viewModel.canAddCart}');
  } else {
    print('⚠️ Nenhum carrinho encontrado');
  }

  print('\n');
}

/// Exemplo 2: Adicionar carrinho à separação
Future<void> _exampleAddCartToSeparation(AddCartViewModel viewModel) async {
  print('=== Exemplo 2: Adicionar carrinho à separação ===\n');

  if (!viewModel.hasCartData) {
    print('❌ Nenhum carrinho foi escaneado');
    return;
  }

  if (!viewModel.canAddCart) {
    print('❌ Carrinho não pode ser adicionado (situação: ${viewModel.scannedCart!.situacao})');
    return;
  }

  print('Adicionando carrinho à separação...');
  print('  Empresa: ${viewModel.codEmpresa}');
  print('  Separação: ${viewModel.codSepararEstoque}');
  print('  Carrinho: ${viewModel.scannedCart!.codCarrinho}');

  final success = await viewModel.addCartToSeparation();

  if (success) {
    print('✅ Carrinho adicionado com sucesso!');
    print('  A verificação de carrinho percurso foi feita automaticamente');
    print('  Se não existia, a separação foi iniciada automaticamente');
  } else {
    print('❌ Falha ao adicionar carrinho: ${viewModel.errorMessage}');
  }

  print('\n');
}

/// Exemplo 3: Fluxo completo
Future<void> _exampleCompleteFlow() async {
  print('=== Exemplo 3: Fluxo completo ===\n');

  // Criar novo ViewModel para o exemplo
  final viewModel = AddCartViewModel(codEmpresa: 1, codSepararEstoque: 54321);

  print('Iniciando fluxo completo de adição de carrinho...\n');

  // Passo 1: Escanear carrinho
  print('1. Escaneando carrinho...');
  await viewModel.scanBarcode('9876543210987');

  if (viewModel.hasError) {
    print('   ❌ Erro: ${viewModel.errorMessage}');
    return;
  }

  if (!viewModel.hasCartData) {
    print('   ❌ Carrinho não encontrado');
    return;
  }

  print('   ✅ Carrinho escaneado: ${viewModel.scannedCart!.codCarrinho}');

  // Passo 2: Verificar se pode adicionar
  print('\n2. Verificando se pode adicionar...');
  if (!viewModel.canAddCart) {
    print('   ❌ Carrinho não pode ser adicionado');
    return;
  }
  print('   ✅ Carrinho pode ser adicionado');

  // Passo 3: Adicionar à separação (com verificação automática)
  print('\n3. Adicionando à separação...');
  print('   🔍 Verificando se existe carrinho percurso iniciado...');
  print('   🔍 Se não existir, iniciando separação automaticamente...');

  final success = await viewModel.addCartToSeparation();

  if (success) {
    print('   ✅ Sucesso! Carrinho adicionado à separação');
    print('   📋 Resumo do que aconteceu:');
    print('      - Verificou se existe carrinho percurso para origem SE');
    print('      - Se não existia, iniciou a separação automaticamente');
    print('      - Adicionou o carrinho à separação');
  } else {
    print('   ❌ Falha: ${viewModel.errorMessage}');
  }

  print('\n');
}

/// Exemplo de uso em uma tela/widget
class AddCartScreen {
  final AddCartViewModel viewModel;

  AddCartScreen({required this.viewModel});

  /// Método chamado quando o usuário escaneia um código
  Future<void> onBarcodeScanned(String barcode) async {
    print('📱 Tela: Código escaneado: $barcode');

    await viewModel.scanBarcode(barcode);

    if (viewModel.hasError) {
      _showError(viewModel.errorMessage!);
    } else if (viewModel.hasCartData) {
      _showCartInfo(viewModel.scannedCart!);
    }
  }

  /// Método chamado quando o usuário confirma a adição
  Future<void> onAddCartConfirmed() async {
    if (!viewModel.canAddCart) {
      _showError('Carrinho não pode ser adicionado');
      return;
    }

    print('📱 Tela: Confirmando adição do carrinho...');

    final success = await viewModel.addCartToSeparation();

    if (success) {
      _showSuccess('Carrinho adicionado com sucesso!');
      _navigateToNextScreen();
    } else {
      _showError(viewModel.errorMessage ?? 'Erro desconhecido');
    }
  }

  void _showCartInfo(dynamic cart) {
    print('📱 Tela: Mostrando informações do carrinho');
    print('   Código: ${cart.codCarrinho}');
    print('   Situação: ${cart.situacao}');
  }

  void _showSuccess(String message) {
    print('📱 Tela: ✅ $message');
  }

  void _showError(String message) {
    print('📱 Tela: ❌ $message');
  }

  void _navigateToNextScreen() {
    print('📱 Tela: Navegando para próxima tela...');
  }
}

/// Exemplo de integração com o sistema
Future<void> _exampleIntegration() async {
  print('=== Exemplo de integração ===\n');

  // Simular dados reais
  const codEmpresa = 1;
  const codSepararEstoque = 12345;

  // Criar ViewModel
  final viewModel = AddCartViewModel(codEmpresa: codEmpresa, codSepararEstoque: codSepararEstoque);

  // Criar tela
  final screen = AddCartScreen(viewModel: viewModel);

  // Simular fluxo do usuário
  print('👤 Usuário escaneia código de barras...');
  await screen.onBarcodeScanned('1234567890123');

  if (viewModel.hasCartData && viewModel.canAddCart) {
    print('\n👤 Usuário confirma adição...');
    await screen.onAddCartConfirmed();
  }

  print('\n');
}

/// Documentação da nova funcionalidade
void _documentation() {
  print('=== Documentação da Nova Funcionalidade ===\n');

  print('📋 O que foi implementado:');
  print('   1. Verificação automática de carrinho percurso existente');
  print('   2. Início automático de separação se necessário');
  print('   3. Integração com StartSeparationUseCase');
  print('   4. Tratamento de erros específicos');

  print('\n🔄 Fluxo de execução:');
  print('   1. Usuário escaneia código de barras');
  print('   2. ViewModel busca informações do carrinho');
  print('   3. Usuário confirma adição');
  print('   4. ViewModel verifica se existe carrinho percurso (origem SE)');
  print('   5. Se não existir, inicia separação automaticamente');
  print('   6. Adiciona carrinho à separação');

  print('\n✅ Benefícios:');
  print('   - Automatiza o processo de início de separação');
  print('   - Evita erros de carrinho percurso não iniciado');
  print('   - Melhora a experiência do usuário');
  print('   - Mantém consistência dos dados');

  print('\n⚠️ Considerações:');
  print('   - Funciona apenas para origem "SE" (Separação Estoque)');
  print('   - Requer usuário autenticado para iniciar separação');
  print('   - Pode falhar se a separação não estiver em situação AGUARDANDO');

  print('\n');
}
