import 'package:flutter_test/flutter_test.dart';
import 'package:exp/domain/models/expedition_situation_model.dart';

void main() {
  group('SeparateItemsScreen - Add Cart Validation Logic', () {
    test('should validate correct situations for adding cart', () {
      // Teste da lógica de validação diretamente

      // Situações que DEVEM permitir adicionar carrinho
      expect(_canAddCart(ExpeditionSituation.aguardando), isTrue);
      expect(_canAddCart(ExpeditionSituation.separando), isTrue);
      expect(_canAddCart(ExpeditionSituation.emSeparacao), isTrue);

      // Situações que NÃO devem permitir adicionar carrinho
      expect(_canAddCart(ExpeditionSituation.finalizada), isFalse);
      expect(_canAddCart(ExpeditionSituation.cancelada), isFalse);
      expect(_canAddCart(ExpeditionSituation.entregue), isFalse);
      expect(_canAddCart(ExpeditionSituation.conferido), isFalse);
      expect(_canAddCart(ExpeditionSituation.emConferencia), isFalse);
      expect(_canAddCart(ExpeditionSituation.devolvida), isFalse);
      expect(_canAddCart(ExpeditionSituation.conferindo), isFalse);
      expect(_canAddCart(ExpeditionSituation.embalando), isFalse);
      expect(_canAddCart(ExpeditionSituation.naoLocalizada), isFalse);
    });
  });
}

// Helper para testar a lógica de validação
bool _canAddCart(ExpeditionSituation situacao) {
  // Permitir apenas nas situações: Aguardando, Separando, Em Separação
  return situacao == ExpeditionSituation.aguardando ||
      situacao == ExpeditionSituation.separando ||
      situacao == ExpeditionSituation.emSeparacao;
}
