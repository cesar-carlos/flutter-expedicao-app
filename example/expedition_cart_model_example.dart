import 'package:exp/domain/models/expedition_cart_model.dart';
import 'package:exp/domain/models/expedition_cart_situation_model.dart';
import 'package:exp/domain/models/situation_model.dart';

void main() {
  // Exemplo de uso do ExpeditionCartModel refatorado

  print('=== Exemplos de Uso do ExpeditionCartModel Refatorado ===\n');

  // 1. Criação de um modelo com Situation
  print('1. Criação de um modelo com Situation:');
  final cartModel = ExpeditionCartModel(
    codEmpresa: 1,
    codCarrinho: 100,
    descricao: 'Carrinho de Teste',
    ativo: Situation.ativo,
    codigoBarras: '123456789',
    situacao: ExpeditionCartSituation.emSeparacao,
  );
  print('Modelo: $cartModel');
  print('');

  // 2. Uso dos getters
  print('2. Uso dos getters:');
  print('Código ativo: ${cartModel.ativoCode}'); // S
  print('Descrição ativo: ${cartModel.ativoDescription}'); // Sim
  print('Código situação: ${cartModel.situacaoCode}'); // EM SEPARACAO
  print('Descrição situação: ${cartModel.situacaoDescription}'); // Em Separação
  print('');

  // 3. Serialização JSON
  print('3. Serialização JSON:');
  final json = cartModel.toJson();
  print('JSON: $json');
  print('');

  // 4. Deserialização JSON
  print('4. Deserialização JSON:');
  final jsonData = {
    'CodEmpresa': 2,
    'CodCarrinho': 200,
    'Descricao': 'Carrinho JSON',
    'Ativo': 'N', // String que será convertida para Situation.inativo
    'CodigoBarras': '987654321',
    'Situacao': 'LIBERADO',
  };

  final cartFromJson = ExpeditionCartModel.fromJson(jsonData);
  print('Modelo do JSON: $cartFromJson');
  print('Ativo: ${cartFromJson.ativoDescription}'); // Não
  print('Situação: ${cartFromJson.situacaoDescription}'); // Liberado
  print('');

  // 5. Uso do copyWith
  print('5. Uso do copyWith:');
  final updatedCart = cartModel.copyWith(
    descricao: 'Carrinho Atualizado',
    ativo: Situation.inativo,
    situacao: ExpeditionCartSituation.separado,
  );
  print('Modelo atualizado: $updatedCart');
  print('');

  // 6. Comparação de modelos
  print('6. Comparação de modelos:');
  final sameCart = ExpeditionCartModel(
    codEmpresa: 1,
    codCarrinho: 100,
    descricao: 'Outro Carrinho',
    ativo: Situation.inativo,
    codigoBarras: '999999999',
    situacao: ExpeditionCartSituation.cancelado,
  );

  print(
    'cartModel == sameCart: ${cartModel == sameCart}',
  ); // true (mesmo codEmpresa e codCarrinho)
  print('');

  // 7. Exemplo prático de uso
  print('7. Exemplo prático de uso:');
  final carts = [
    ExpeditionCartModel(
      codEmpresa: 1,
      codCarrinho: 101,
      descricao: 'Carrinho Ativo',
      ativo: Situation.ativo,
      codigoBarras: '111111111',
      situacao: ExpeditionCartSituation.emSeparacao,
    ),
    ExpeditionCartModel(
      codEmpresa: 1,
      codCarrinho: 102,
      descricao: 'Carrinho Inativo',
      ativo: Situation.inativo,
      codigoBarras: '222222222',
      situacao: ExpeditionCartSituation.cancelado,
    ),
  ];

  print('Carrinhos ativos:');
  for (final cart in carts) {
    if (cart.ativo == Situation.ativo) {
      print('  - ${cart.descricao} (${cart.situacaoDescription})');
    }
  }

  print('\nCarrinhos inativos:');
  for (final cart in carts) {
    if (cart.ativo == Situation.inativo) {
      print('  - ${cart.descricao} (${cart.situacaoDescription})');
    }
  }
}

/// Exemplo de função que trabalha com ExpeditionCartModel
void processCart(ExpeditionCartModel cart) {
  print('Processando carrinho: ${cart.descricao}');
  print('Status: ${cart.ativoDescription}');
  print('Situação: ${cart.situacaoDescription}');

  if (cart.ativo == Situation.ativo) {
    print('Carrinho está ativo, pode ser processado');
  } else {
    print('Carrinho está inativo, não pode ser processado');
  }
}
