// ignore_for_file: unused_local_variable

import 'package:exp/core/utils/app_logger.dart';
import 'package:exp/domain/viewmodels/add_cart_viewmodel.dart';

/// Exemplo de uso do AddCartViewModel com verificação de separação
///
/// Este exemplo demonstra como o AddCartViewModel agora verifica automaticamente
/// se existe um carrinho percurso iniciado antes de adicionar um carrinho à separação
void main() async {
AppLogger.debug('=== Exemplo: AddCartViewModel com verificação de separação ===\n', tag: 'AddCartExample');

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
  AppLogger.debug('=== Exemplo 1: Escanear código de barras ===\n');

  // Simular código de barras de um carrinho
  const barcode = '1234567890123';

  AppLogger.debug('Escanando código: $barcode');
  await viewModel.scanBarcode(barcode);

  if (viewModel.hasError) {
    AppLogger.debug('❌ Erro ao escanear: ${viewModel.errorMessage}');
  } else if (viewModel.hasCartData) {
    final cart = viewModel.scannedCart!;
    AppLogger.debug('✅ Carrinho encontrado:');
    AppLogger.debug('  Código: ${cart.codCarrinho}');
    AppLogger.debug('  Situação: ${cart.situacao}');
    AppLogger.debug('  Pode adicionar: ${viewModel.canAddCart}');
  } else {
    AppLogger.debug('⚠️ Nenhum carrinho encontrado');
  }

  AppLogger.debug('\n');
}

/// Exemplo 2: Adicionar carrinho à separação
Future<void> _exampleAddCartToSeparation(AddCartViewModel viewModel) async {
  AppLogger.debug('=== Exemplo 2: Adicionar carrinho à separação ===\n');

  if (!viewModel.hasCartData) {
    AppLogger.debug('❌ Nenhum carrinho foi escaneado');
    return;
  }

  if (!viewModel.canAddCart) {
    AppLogger.debug('❌ Carrinho não pode ser adicionado (situação: ${viewModel.scannedCart!.situacao})');
    return;
  }

  AppLogger.debug('Adicionando carrinho à separação...');
  AppLogger.debug('  Empresa: ${viewModel.codEmpresa}');
  AppLogger.debug('  Separação: ${viewModel.codSepararEstoque}');
  AppLogger.debug('  Carrinho: ${viewModel.scannedCart!.codCarrinho}');

  final success = await viewModel.addCartToSeparation();

  if (success) {
    AppLogger.debug('✅ Carrinho adicionado com sucesso!');
    AppLogger.debug('  A verificação de carrinho percurso foi feita automaticamente');
    AppLogger.debug('  Se não existia, a separação foi iniciada automaticamente');
  } else {
    AppLogger.debug('❌ Falha ao adicionar carrinho: ${viewModel.errorMessage}');
  }

  AppLogger.debug('\n');
}

/// Exemplo 3: Fluxo completo
Future<void> _exampleCompleteFlow() async {
  AppLogger.debug('=== Exemplo 3: Fluxo completo ===\n');

  // Criar novo ViewModel para o exemplo
  final viewModel = AddCartViewModel(codEmpresa: 1, codSepararEstoque: 54321);

  AppLogger.debug('Iniciando fluxo completo de adição de carrinho...\n');

  // Passo 1: Escanear carrinho
  AppLogger.debug('1. Escaneando carrinho...');
  await viewModel.scanBarcode('9876543210987');

  if (viewModel.hasError) {
    AppLogger.debug('   ❌ Erro: ${viewModel.errorMessage}');
    return;
  }

  if (!viewModel.hasCartData) {
    AppLogger.debug('   ❌ Carrinho não encontrado');
    return;
  }

  AppLogger.debug('   ✅ Carrinho escaneado: ${viewModel.scannedCart!.codCarrinho}');

  // Passo 2: Verificar se pode adicionar
  AppLogger.debug('\n2. Verificando se pode adicionar...');
  if (!viewModel.canAddCart) {
    AppLogger.debug('   ❌ Carrinho não pode ser adicionado');
    return;
  }
  AppLogger.debug('   ✅ Carrinho pode ser adicionado');

  // Passo 3: Adicionar à separação (com verificação automática)
  AppLogger.debug('\n3. Adicionando à separação...');
  AppLogger.debug('   🔍 Verificando se existe carrinho percurso iniciado...');
  AppLogger.debug('   🔍 Se não existir, iniciando separação automaticamente...');

  final success = await viewModel.addCartToSeparation();

  if (success) {
    AppLogger.debug('   ✅ Sucesso! Carrinho adicionado à separação');
    AppLogger.debug('   📋 Resumo do que aconteceu:');
    AppLogger.debug('      - Verificou se existe carrinho percurso para origem SE');
    AppLogger.debug('      - Se não existia, iniciou a separação automaticamente');
    AppLogger.debug('      - Adicionou o carrinho à separação');
  } else {
    AppLogger.debug('   ❌ Falha: ${viewModel.errorMessage}');
  }

  AppLogger.debug('\n');
}

/// Exemplo de uso em uma tela/widget
class AddCartScreen {
  final AddCartViewModel viewModel;

  AddCartScreen({required this.viewModel});

  /// Método chamado quando o usuário escaneia um código
  Future<void> onBarcodeScanned(String barcode) async {
    AppLogger.debug('📱 Tela: Código escaneado: $barcode');

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

    AppLogger.debug('📱 Tela: Confirmando adição do carrinho...');

    final success = await viewModel.addCartToSeparation();

    if (success) {
      _showSuccess('Carrinho adicionado com sucesso!');
      _navigateToNextScreen();
    } else {
      _showError(viewModel.errorMessage ?? 'Erro desconhecido');
    }
  }

  void _showCartInfo(dynamic cart) {
    AppLogger.debug('📱 Tela: Mostrando informações do carrinho');
    AppLogger.debug('   Código: ${cart.codCarrinho}');
    AppLogger.debug('   Situação: ${cart.situacao}');
  }

  void _showSuccess(String message) {
    AppLogger.debug('📱 Tela: ✅ $message');
  }

  void _showError(String message) {
    AppLogger.debug('📱 Tela: ❌ $message');
  }

  void _navigateToNextScreen() {
    AppLogger.debug('📱 Tela: Navegando para próxima tela...');
  }
}

/// Exemplo de integração com o sistema
Future<void> _exampleIntegration() async {
  AppLogger.debug('=== Exemplo de integração ===\n');

  // Simular dados reais
  const codEmpresa = 1;
  const codSepararEstoque = 12345;

  // Criar ViewModel
  final viewModel = AddCartViewModel(codEmpresa: codEmpresa, codSepararEstoque: codSepararEstoque);

  // Criar tela
  final screen = AddCartScreen(viewModel: viewModel);

  // Simular fluxo do usuário
  AppLogger.debug('👤 Usuário escaneia código de barras...');
  await screen.onBarcodeScanned('1234567890123');

  if (viewModel.hasCartData && viewModel.canAddCart) {
    AppLogger.debug('\n👤 Usuário confirma adição...');
    await screen.onAddCartConfirmed();
  }

  AppLogger.debug('\n');
}

/// Documentação da nova funcionalidade
void _documentation() {
  AppLogger.debug('=== Documentação da Nova Funcionalidade ===\n');

  AppLogger.debug('📋 O que foi implementado:');
  AppLogger.debug('   1. Verificação automática de carrinho percurso existente');
  AppLogger.debug('   2. Início automático de separação se necessário');
  AppLogger.debug('   3. Integração com StartSeparationUseCase');
  AppLogger.debug('   4. Tratamento de erros específicos');

  AppLogger.debug('\n🔄 Fluxo de execução:');
  AppLogger.debug('   1. Usuário escaneia código de barras');
  AppLogger.debug('   2. ViewModel busca informações do carrinho');
  AppLogger.debug('   3. Usuário confirma adição');
  AppLogger.debug('   4. ViewModel verifica se existe carrinho percurso (origem SE)');
  AppLogger.debug('   5. Se não existir, inicia separação automaticamente');
  AppLogger.debug('   6. Adiciona carrinho à separação');

  AppLogger.debug('\n✅ Benefícios:');
  AppLogger.debug('   - Automatiza o processo de início de separação');
  AppLogger.debug('   - Evita erros de carrinho percurso não iniciado');
  AppLogger.debug('   - Melhora a experiência do usuário');
  AppLogger.debug('   - Mantém consistência dos dados');

  AppLogger.debug('\n⚠️ Considerações:');
  AppLogger.debug('   - Funciona apenas para origem "SE" (Separação Estoque)');
  AppLogger.debug('   - Requer usuário autenticado para iniciar separação');
  AppLogger.debug('   - Pode falhar se a separação não estiver em situação AGUARDANDO');

  AppLogger.debug('\n');
}
