// ignore_for_file: unused_local_variable

import 'package:exp/domain/models/user/system_qrcode_data.dart';
import 'package:exp/domain/usecases/user/register_via_qrcode_usecase.dart';
import 'package:exp/di/locator.dart';

/// Exemplo de JSON que virá no QR Code
const String qrCodeJsonExample = '''
{
  "CodUsuario": 123,
  "NomeUsuario": "João Silva",
  "SenhaUsuario": "senha123",
  "Ativo": "S",
  "CodEmpresa": 1,
  "NomeEmpresa": "Empresa ABC",
  "CodVendedor": 10,
  "NomeVendedor": "Vendedor X",
  "CodLocalArmazenagem": 5,
  "NomeLocalArmazenagem": "Armazém Principal",
  "CodContaFinanceira": "001",
  "NomeContaFinanceira": "Conta Principal",
  "NomeCaixaOperador": "Caixa 01",
  "CodSetorEstoque": 1,
  "NomeSetorEstoque": "Setor A",
  "PermiteSepararForaSequencia": "S",
  "VisualizaTodasSeparacoes": "N",
  "CodSetorConferencia": 2,
  "NomeSetorConferencia": "Conferência Central",
  "PermiteConferirForaSequencia": "S",
  "VisualizaTodasConferencias": "N",
  "CodSetorArmazenagem": 3,
  "NomeSetorArmazenagem": "Armazenagem Principal",
  "PermiteArmazenarForaSequencia": "N",
  "VisualizaTodasArmazenagem": "S",
  "EditaCarrinhoOutroUsuario": "N",
  "SalvaCarrinhoOutroUsuario": "N",
  "ExcluiCarrinhoOutroUsuario": "N",
  "ExpedicaoEntregaBalcaoPreVenda": "S"
}
''';

/// Exemplo de JSON mínimo (apenas campos obrigatórios)
const String qrCodeMinimalJsonExample = '''
{
  "CodUsuario": 456,
  "NomeUsuario": "Maria Santos",
  "SenhaUsuario": "senha456",
  "Ativo": "S",
  "CodEmpresa": 2,
  "NomeEmpresa": "Empresa XYZ"
}
''';

/// ===================================================================
/// EXEMPLO 1: Parse de QR Code com todos os campos
/// ===================================================================
void example1ParseFullQRCode() {
  print('\n=== EXEMPLO 1: Parse de QR Code Completo ===\n');

  // Parse do JSON do QR Code
  final result = SystemQRCodeData.fromQRCodeString(qrCodeJsonExample);

  result.fold(
    (qrCodeData) {
      print('✅ QR Code válido!');
      print('Usuário: ${qrCodeData.nomeUsuario}');
      print('Empresa: ${qrCodeData.nomeEmpresa}');
      print('Vendedor: ${qrCodeData.nomeVendedor}');
      print('Setor Estoque: ${qrCodeData.nomeSetorEstoque}');

      // Converter para UserSystemModel
      final userSystemModel = qrCodeData.toUserSystemModel();
      print('\nConvertido para UserSystemModel:');
      print('CodUsuario: ${userSystemModel.codUsuario}');
      print('Permite separar fora de sequência: ${userSystemModel.permiteSepararForaSequencia}');
    },
    (failure) {
      print('❌ Erro ao processar QR Code: ${failure.toString()}');
    },
  );
}

/// ===================================================================
/// EXEMPLO 2: Parse de QR Code mínimo (apenas campos obrigatórios)
/// ===================================================================
void example2ParseMinimalQRCode() {
  print('\n=== EXEMPLO 2: Parse de QR Code Mínimo ===\n');

  final result = SystemQRCodeData.fromQRCodeString(qrCodeMinimalJsonExample);

  result.fold(
    (qrCodeData) {
      print('✅ QR Code válido!');
      print('Usuário: ${qrCodeData.nomeUsuario}');
      print('Empresa: ${qrCodeData.nomeEmpresa}');
      print('Vendedor: ${qrCodeData.nomeVendedor ?? "Não informado"}');
      print('Setor Estoque: ${qrCodeData.nomeSetorEstoque ?? "Não informado"}');
    },
    (failure) {
      print('❌ Erro ao processar QR Code: ${failure.toString()}');
    },
  );
}

/// ===================================================================
/// EXEMPLO 3: Parse de QR Code inválido
/// ===================================================================
void example3ParseInvalidQRCode() {
  print('\n=== EXEMPLO 3: Parse de QR Code Inválido ===\n');

  const invalidJson = '''
  {
    "NomeUsuario": "Teste",
    "SenhaUsuario": "123"
  }
  ''';

  final result = SystemQRCodeData.fromQRCodeString(invalidJson);

  result.fold(
    (qrCodeData) {
      print('✅ QR Code válido (não deveria chegar aqui)');
    },
    (failure) {
      print('❌ Erro esperado: ${failure.toString()}');
    },
  );
}

/// ===================================================================
/// EXEMPLO 4: Uso completo do RegisterViaQRCodeUseCase
/// ===================================================================
Future<void> example4RegisterViaQRCodeUseCase() async {
  print('\n=== EXEMPLO 4: Uso do RegisterViaQRCodeUseCase ===\n');

  // 1. Parse do QR Code
  final parseResult = SystemQRCodeData.fromQRCodeString(qrCodeJsonExample);

  await parseResult.fold(
    (qrCodeData) async {
      print('✅ QR Code parseado com sucesso');
      print('Registrando usuário: ${qrCodeData.nomeUsuario}');

      // 2. Criar parâmetros
      final params = RegisterViaQRCodeParams(qrCodeData: qrCodeData);

      // 3. Executar UseCase
      final useCase = locator<RegisterViaQRCodeUseCase>();
      final result = await useCase(params);

      // 4. Processar resultado
      result.fold(
        (success) {
          print('✅ Usuário registrado com sucesso!');
          print('Nome: ${success.user.nome}');
          print('CodLoginApp: ${success.user.codLoginApp}');
          print('CodUsuario: ${success.user.codUsuario}');
          print('Mensagem: ${success.message}');
        },
        (failure) {
          if (failure is RegisterViaQRCodeFailure) {
            print('❌ Erro no registro: ${failure.userMessage}');
            print('Código: ${failure.code}');
          } else {
            print('❌ Erro no registro: ${failure.toString()}');
          }
        },
      );
    },
    (failure) {
      print('❌ Erro ao parsear QR Code: ${failure.toString()}');
    },
  );
}

/// ===================================================================
/// EXEMPLO 5: Validação de parâmetros
/// ===================================================================
void example5ValidateParams() {
  print('\n=== EXEMPLO 5: Validação de Parâmetros ===\n');

  // Parse do QR Code
  final result = SystemQRCodeData.fromQRCodeString(qrCodeJsonExample);

  result.fold((qrCodeData) {
    final params = RegisterViaQRCodeParams(qrCodeData: qrCodeData);

    print('Parâmetros válidos? ${params.isValid}');

    if (!params.isValid) {
      print('Erros de validação:');
      for (var error in params.validationErrors) {
        print('  - $error');
      }
    } else {
      print('✅ Todos os parâmetros estão válidos');
    }
  }, (failure) => print('❌ Erro: ${failure.toString()}'));
}

/// ===================================================================
/// EXEMPLO 6: Conversão para UserSystemModel
/// ===================================================================
void example6ConvertToUserSystemModel() {
  print('\n=== EXEMPLO 6: Conversão para UserSystemModel ===\n');

  final result = SystemQRCodeData.fromQRCodeString(qrCodeJsonExample);

  result.fold((qrCodeData) {
    final userSystemModel = qrCodeData.toUserSystemModel();

    print('UserSystemModel criado:');
    print('  CodUsuario: ${userSystemModel.codUsuario}');
    print('  NomeUsuario: ${userSystemModel.nomeUsuario}');
    print('  Ativo: ${userSystemModel.ativo}');
    print('  CodEmpresa: ${userSystemModel.codEmpresa}');
    print('  NomeEmpresa: ${userSystemModel.nomeEmpresa}');
    print('  Permite separar fora sequência: ${userSystemModel.permiteSepararForaSequencia}');
    print('  Visualiza todas separações: ${userSystemModel.visualizaTodasSeparacoes}');
    print('  Pode trabalhar com separações? ${userSystemModel.canWorkWithSeparations}');
    print('  Pode gerenciar carrinhos de outros? ${userSystemModel.canManageOtherCarts}');
  }, (failure) => print('❌ Erro: ${failure.toString()}'));
}

/// ===================================================================
/// EXEMPLO 7: Tratamento de erros específicos
/// ===================================================================
void example7ErrorHandling() {
  print('\n=== EXEMPLO 7: Tratamento de Erros Específicos ===\n');

  // Exemplo com JSON mal formado
  const malformedJson = '{ invalid json }';

  final result = SystemQRCodeData.fromQRCodeString(malformedJson);

  result.fold((qrCodeData) => print('✅ Sucesso (não deveria chegar aqui)'), (failure) {
    print('Tipo de erro: ${failure.runtimeType}');
    print('Mensagem: ${failure.toString()}');

    // Você pode tratar erros específicos
    if (failure.toString().contains('formato JSON inválido')) {
      print('⚠️ QR Code não contém JSON válido');
    } else if (failure.toString().contains('não encontrado')) {
      print('⚠️ QR Code não contém campos obrigatórios');
    }
  });
}

/// ===================================================================
/// MAIN - Executar todos os exemplos
/// ===================================================================
Future<void> main() async {
  print('╔══════════════════════════════════════════════════════════╗');
  print('║     EXEMPLOS DE USO: QR CODE LOGIN SYSTEM               ║');
  print('╚══════════════════════════════════════════════════════════╝');

  example1ParseFullQRCode();
  example2ParseMinimalQRCode();
  example3ParseInvalidQRCode();

  // Exemplos que precisam do locator inicializado
  // await example4RegisterViaQRCodeUseCase();

  example5ValidateParams();
  example6ConvertToUserSystemModel();
  example7ErrorHandling();

  print('\n╔══════════════════════════════════════════════════════════╗');
  print('║                    FIM DOS EXEMPLOS                      ║');
  print('╚══════════════════════════════════════════════════════════╝\n');
}
