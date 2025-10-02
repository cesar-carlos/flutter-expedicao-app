// ignore_for_file: unused_local_variable, avoid_print

import 'package:exp/domain/models/expedition_origem_model.dart';
import 'package:exp/domain/usecases/start_separation/start_separation_params.dart';
import 'package:exp/domain/usecases/start_separation/start_separation_usecase.dart';
import 'package:exp/domain/usecases/start_separation/start_separation_failure.dart';
import 'package:exp/di/locator.dart';

/// Exemplo de uso do StartSeparationUseCase
///
/// Este exemplo demonstra como iniciar uma separação de estoque
void main() async {
  // Simular inicialização do locator
  // setupLocator(); // Em produção, isso seria chamado no main.dart

  // Obter instância do use case via DI
  final useCase = locator<StartSeparationUseCase>();

  // Exemplo 1: Iniciar separação para uma separação de estoque
  await _exampleStartSeparationFromStock(useCase);

  // Exemplo 2: Iniciar separação para um orçamento de balcão
  await _exampleStartSeparationFromBudget(useCase);

  // Exemplo 3: Tratamento de erros
  await _exampleErrorHandling(useCase);

  // Exemplo 4: Integração completa
  await _exampleCompleteIntegration();
}

/// Exemplo 1: Iniciar separação de estoque
Future<void> _exampleStartSeparationFromStock(StartSeparationUseCase useCase) async {
  print('=== Exemplo 1: Iniciar separação de estoque ===\n');

  // Criar parâmetros
  final params = StartSeparationParams(
    codEmpresa: 1,
    origem: ExpeditionOrigem.separacaoEstoque,
    codOrigem: 12345, // Código da separação de estoque
  );

  // Executar use case
  final result = await useCase(params);

  // Tratar resultado
  result.fold(
    (success) {
      print('✓ Separação iniciada com sucesso!');
      print('  Carrinho Percurso: ${success.codCarrinhoPercurso}');
      print('  Código Separação: ${success.codSepararEstoque}');
      print('  Situação: ${success.situacaoDescription}');
      print('  Entidade: ${success.nomeEntidade}');
      print('  Data/Hora Início: ${success.dataInicio} ${success.horaInicio}');
      print('\n  Resumo: ${success.operationSummary}');
      print('\n  Notificações:');
      for (var notification in success.notifications) {
        print('    - $notification');
      }
      print('\n  Auditoria:');
      success.auditInfo.forEach((key, value) {
        print('    $key: $value');
      });
    },
    (failure) {
      final error = failure as StartSeparationFailure;
      print('✗ Falha ao iniciar separação:');
      print('  ${error.userMessage}');
      if (error.details != null) {
        print('  Detalhes: ${error.details}');
      }
    },
  );

  print('\n');
}

/// Exemplo 2: Iniciar separação de orçamento balcão
Future<void> _exampleStartSeparationFromBudget(StartSeparationUseCase useCase) async {
  print('=== Exemplo 2: Iniciar separação de orçamento balcão ===\n');

  final params = StartSeparationParams(
    codEmpresa: 1,
    origem: ExpeditionOrigem.orcamentoBalcao,
    codOrigem: 98765, // Código do orçamento balcão
  );

  final result = await useCase(params);

  result.fold(
    (success) {
      print('✓ Separação de balcão iniciada!');
      print('  ${success.cartRouteInfo}');
      print('  ${success.separationInfo}');
    },
    (failure) {
      final error = failure as StartSeparationFailure;
      print('✗ Erro: ${error.userMessage}');
    },
  );

  print('\n');
}

/// Exemplo 3: Tratamento de diferentes tipos de erro
Future<void> _exampleErrorHandling(StartSeparationUseCase useCase) async {
  print('=== Exemplo 3: Tratamento de erros ===\n');

  // Parâmetros inválidos
  final invalidParams = StartSeparationParams(
    codEmpresa: -1, // Empresa inválida
    origem: ExpeditionOrigem.separacaoEstoque,
    codOrigem: 0, // Origem inválida
  );

  final result = await useCase(invalidParams);

  result.fold((_) => print('Sucesso inesperado'), (failure) {
    final error = failure as StartSeparationFailure;
    print('Tipo de erro identificado:');

    if (error.isValidationError) {
      print('  → Erro de validação');
      print('    Mensagem: ${error.message}');
      print('    Detalhes: ${error.details}');
    } else if (error.isBusinessError) {
      print('  → Erro de regra de negócio');
      print('    ${error.userMessage}');
    } else if (error.isOperationError) {
      print('  → Erro de operação');
      print('    ${error.message}');
    } else if (error.isNetworkError) {
      print('  → Erro de rede');
      print('    ${error.userMessage}');
    }

    print('\n  Código do erro: ${error.code}');
    print('  toString(): $error');
  });

  print('\n');
}

/// Exemplo 4: Uso em um ViewModel ou Controller
class SeparationController {
  final StartSeparationUseCase _useCase;

  SeparationController(this._useCase);

  Future<void> startSeparation({
    required int codEmpresa,
    required ExpeditionOrigem origem,
    required int codOrigem,
  }) async {
    // Criar parâmetros
    final params = StartSeparationParams(codEmpresa: codEmpresa, origem: origem, codOrigem: codOrigem);

    // Executar use case
    final result = await _useCase(params);

    // Tratar resultado
    result.fold((success) => _handleSuccess(success), (failure) => _handleFailure(failure));
  }

  void _handleSuccess(dynamic success) {
    // Exibir mensagem de sucesso
    print('Separação iniciada: ${success.message}');

    // Atualizar estado da UI
    // notifyListeners();

    // Navegar para tela de separação de itens
    // navigationService.navigateTo('/separate-items', arguments: {
    //   'codCarrinhoPercurso': success.codCarrinhoPercurso,
    //   'codSepararEstoque': success.codSepararEstoque,
    // });

    // Emitir evento
    // eventService.emit('separation_started', success.auditInfo);
  }

  void _handleFailure(dynamic failure) {
    // Exibir mensagem de erro
    print('Erro: ${failure.userMessage}');

    // Log de erro
    // logger.error('Falha ao iniciar separação', failure);

    // Tratar erros específicos
    if (failure.isBusinessError) {
      // Mostrar diálogo específico
      // showDialog(...)
    } else if (failure.isNetworkError) {
      // Mostrar aviso de conexão
      // showNetworkError();
    }
  }
}

/// Validações antes de iniciar separação
class StartSeparationValidator {
  /// Valida se os parâmetros são válidos antes de chamar o use case
  static bool validate(StartSeparationParams params, {required Function(String) onError}) {
    if (!params.isValid) {
      final errors = params.validationErrors;
      onError('Dados inválidos:\n${errors.map((e) => '- $e').join('\n')}');
      return false;
    }

    return true;
  }

  /// Confirma com o usuário antes de iniciar
  static Future<bool> confirm({required String nomeEntidade, required String origemDescription}) async {
    // Simular confirmação do usuário
    // Em produção, seria um Dialog
    print('Confirmar início de separação?');
    print('  Entidade: $nomeEntidade');
    print('  Origem: $origemDescription');

    // return await showDialog<bool>(...) ?? false;
    return true;
  }
}

/// Exemplo de integração completa
Future<void> _exampleCompleteIntegration() async {
  print('=== Exemplo de integração completa ===\n');

  final useCase = locator<StartSeparationUseCase>();
  final controller = SeparationController(useCase);

  // Criar parâmetros
  final params = StartSeparationParams(codEmpresa: 1, origem: ExpeditionOrigem.separacaoEstoque, codOrigem: 12345);

  // Validar
  final isValid = StartSeparationValidator.validate(params, onError: (message) => print('Erro: $message'));

  if (!isValid) return;

  // Confirmar com usuário
  final confirmed = await StartSeparationValidator.confirm(
    nomeEntidade: 'Cliente XYZ',
    origemDescription: params.origem.description,
  );

  if (!confirmed) {
    print('Operação cancelada pelo usuário');
    return;
  }

  // Executar
  await controller.startSeparation(codEmpresa: params.codEmpresa, origem: params.origem, codOrigem: params.codOrigem);
}
