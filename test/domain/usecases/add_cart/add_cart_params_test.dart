import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/usecases/add_cart/add_cart_params.dart';

void main() {
  group('AddCartParams', () {
    test('isValid retorna true quando todos os codigos sao positivos', () {
      const params = AddCartParams(
        codEmpresa: 1,
        origem: ExpeditionOrigem.separacaoEstoque,
        codOrigem: 100,
        codCarrinho: 50,
      );

      expect(params.isValid, isTrue);
      expect(params.validationErrors, isEmpty);
    });

    test('isValid retorna false quando codEmpresa <= 0', () {
      const params = AddCartParams(
        codEmpresa: 0,
        origem: ExpeditionOrigem.separacaoEstoque,
        codOrigem: 100,
        codCarrinho: 50,
      );

      expect(params.isValid, isFalse);
      expect(params.validationErrors.join(' '), contains('empresa'));
    });

    test('isValid retorna false quando codOrigem <= 0', () {
      const params = AddCartParams(
        codEmpresa: 1,
        origem: ExpeditionOrigem.separacaoEstoque,
        codOrigem: 0,
        codCarrinho: 50,
      );

      expect(params.isValid, isFalse);
      expect(params.validationErrors.join(' '), contains('origem'));
    });

    test('isValid retorna false quando codCarrinho <= 0', () {
      const params = AddCartParams(
        codEmpresa: 1,
        origem: ExpeditionOrigem.separacaoEstoque,
        codOrigem: 100,
        codCarrinho: 0,
      );

      expect(params.isValid, isFalse);
      expect(params.validationErrors.join(' '), contains('Código do carrinho'));
    });
  });
}
