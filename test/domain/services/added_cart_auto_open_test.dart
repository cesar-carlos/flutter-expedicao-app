import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/services/added_cart_auto_open.dart';

void main() {
  ExpeditionCartRouteInternshipConsultationModel buildCart({
    int codCarrinho = 5,
    int codCarrinhoPercurso = 289597,
    int codOrigem = 290901,
    String item = '00003',
    ExpeditionSituation situacao = ExpeditionSituation.separando,
    DateTime? dataInicio,
  }) {
    return ExpeditionCartRouteInternshipConsultationModel(
      codEmpresa: 1,
      codCarrinhoPercurso: codCarrinhoPercurso,
      item: item,
      codPercursoEstagio: 1,
      origem: ExpeditionOrigem.separacaoEstoque,
      codOrigem: codOrigem,
      situacao: situacao,
      carrinhoAgrupador: Situation.inativo,
      codCarrinho: codCarrinho,
      nomeCarrinho: 'Carrinho $codCarrinho',
      codigoBarrasCarrinho: 'BC$codCarrinho',
      ativo: Situation.ativo,
      codUsuarioInicio: 10,
      nomeUsuarioInicio: 'Usuario',
      dataInicio: dataInicio ?? DateTime(2026, 11, 13, 14, 18, 26),
      horaInicio: '14:18:26',
    );
  }

  group('isCartAvailableForAutoOpen', () {
    test('should allow aguardando and separando', () {
      expect(isCartAvailableForAutoOpen(ExpeditionSituation.aguardando), isTrue);
      expect(isCartAvailableForAutoOpen(ExpeditionSituation.separando), isTrue);
    });

    test('should reject finished internships', () {
      expect(isCartAvailableForAutoOpen(ExpeditionSituation.separado), isFalse);
      expect(isCartAvailableForAutoOpen(ExpeditionSituation.conferido), isFalse);
      expect(isCartAvailableForAutoOpen(ExpeditionSituation.cancelada), isFalse);
    });
  });

  group('findAddedCartForAutoOpen', () {
    test('should open the separating internship instead of a finished cart 5', () {
      final separado = buildCart(
        codCarrinhoPercurso: 289467,
        codOrigem: 290534,
        item: '00002',
        situacao: ExpeditionSituation.separado,
        dataInicio: DateTime(2026, 11, 13, 8),
      );
      final separando = buildCart();

      final selected = findAddedCartForAutoOpen(carts: [separado, separando], codCarrinho: 5);

      expect(selected, same(separando));
    });

    test('should not open a finished internship of the same physical cart', () {
      final selected = findAddedCartForAutoOpen(
        carts: [
          buildCart(situacao: ExpeditionSituation.separado),
          buildCart(item: '00004', situacao: ExpeditionSituation.conferido),
        ],
        codCarrinho: 5,
        codCarrinhoPercurso: 289597,
      );

      expect(selected, isNull);
    });

    test('should keep the match inside the current route', () {
      final otherRoute = buildCart(codCarrinhoPercurso: 289467, codOrigem: 290534, item: '00002');
      final currentRoute = buildCart();

      final selected = findAddedCartForAutoOpen(
        carts: [otherRoute, currentRoute],
        codCarrinho: 5,
        codCarrinhoPercurso: 289597,
      );

      expect(selected, same(currentRoute));
    });

    test('should prefer separando over aguardando', () {
      final aguardando = buildCart(
        item: '00001',
        situacao: ExpeditionSituation.aguardando,
        dataInicio: DateTime(2026, 11, 13, 15),
      );
      final separando = buildCart();

      final selected = findAddedCartForAutoOpen(carts: [aguardando, separando], codCarrinho: 5);

      expect(selected, same(separando));
    });
  });
}
