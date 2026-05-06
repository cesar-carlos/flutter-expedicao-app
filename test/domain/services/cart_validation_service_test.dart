import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/services/cart_validation_service.dart';

import '../../mocks/user_system_model_mock.dart';

void main() {
  group('CartValidationService', () {
    late _FakeSeparateItemConsultationRepository repo;
    late CartValidationService service;

    SeparateItemConsultationModel item({
      double qSep = 0,
      double qTotal = 10,
      int? codSetor,
    }) {
      return SeparateItemConsultationModel(
        codEmpresa: 1,
        codSepararEstoque: 100,
        item: 'I1',
        origem: ExpeditionOrigem.separacaoEstoque,
        codOrigem: 100,
        codProduto: 1,
        nomeProduto: 'P',
        ativo: Situation.ativo,
        codTipoProduto: '1',
        codUnidadeMedida: 'UN',
        nomeUnidadeMedida: 'UN',
        codGrupoProduto: 1,
        nomeGrupoProduto: 'G',
        codSetorEstoque: codSetor,
        nomeSetorEstoque: 'S',
        codigoBarras: '1',
        codLocalArmazenagem: 1,
        nomeLocaArmazenagem: 'L',
        quantidade: qTotal,
        quantidadeInterna: qTotal,
        quantidadeExterna: 0,
        quantidadeSeparacao: qSep,
        unidadeMedidas: const [],
      );
    }

    ExpeditionCartRouteInternshipConsultationModel cart({required int codUsuarioInicio, String nome = 'Dono'}) {
      return ExpeditionCartRouteInternshipConsultationModel(
        codEmpresa: 1,
        codCarrinhoPercurso: 1,
        item: '000',
        codPercursoEstagio: 1,
        origem: ExpeditionOrigem.separacaoEstoque,
        codOrigem: 100,
        situacao: ExpeditionSituation.separando,
        carrinhoAgrupador: Situation.inativo,
        codCarrinho: 10,
        nomeCarrinho: 'C',
        codigoBarrasCarrinho: '1',
        ativo: Situation.ativo,
        codUsuarioInicio: codUsuarioInicio,
        nomeUsuarioInicio: nome,
        dataInicio: DateTime(2026, 1, 1),
        horaInicio: '08:00:00',
      );
    }

    setUp(() {
      repo = _FakeSeparateItemConsultationRepository();
      service = CartValidationService(repository: repo);
    });

    test('permissoes outro usuario seguem flags', () {
      final u = createTestUserSystem();
      expect(service.canEditOtherUserCart(u), isFalse);
      expect(service.canSaveOtherUserCart(u), isFalse);
      expect(service.canDeleteOtherUserCart(u), isFalse);
    });

    test('canAccessCart mesmo usuario sem permissao extra', () {
      expect(service.canAccessCart(currentUserCode: 5, cartOwnerCode: 5, hasPermission: false), isTrue);
    });

    test('canAccessCart usuario diferente exige permissao', () {
      expect(service.canAccessCart(currentUserCode: 5, cartOwnerCode: 9, hasPermission: false), isFalse);
      expect(service.canAccessCart(currentUserCode: 5, cartOwnerCode: 9, hasPermission: true), isTrue);
    });

    test('validateCartAccess permite dono para edit', () {
      final r = service.validateCartAccess(
        currentUserCode: 1,
        cart: cart(codUsuarioInicio: 1),
        userModel: createTestUserSystem(),
        accessType: CartAccessType.edit,
      );
      expect(r.canAccess, isTrue);
    });

    test('validateCartAccess nega outro usuario sem permissao de edicao', () {
      final r = service.validateCartAccess(
        currentUserCode: 2,
        cart: cart(codUsuarioInicio: 1, nome: 'Dono'),
        userModel: createTestUserSystem(),
        accessType: CartAccessType.edit,
      );
      expect(r.canAccess, isFalse);
      expect(r.reason, CartAccessDeniedReason.differentUser);
      expect(r.cartOwnerName, equals('Dono'));
    });

    test('hasItemsForUserSector retorna true quando ha pendencia no setor', () async {
      repo.items = [
        item(qSep: 0, qTotal: 5, codSetor: 7),
      ];

      final ok = await service.hasItemsForUserSector(
        codEmpresa: 1,
        codOrigem: 100,
        userSectorCode: 7,
      );

      expect(ok, isTrue);
    });

    test('hasItemsForUserSector retorna false quando setor nao tem pendencia', () async {
      repo.items = [
        item(qSep: 0, qTotal: 5, codSetor: 99),
      ];

      final ok = await service.hasItemsForUserSector(
        codEmpresa: 1,
        codOrigem: 100,
        userSectorCode: 7,
      );

      expect(ok, isFalse);
    });

    test('hasItemsForUserSector fallback true quando repositorio falha', () async {
      repo.throwOnSelect = true;

      final ok = await service.hasItemsForUserSector(
        codEmpresa: 1,
        codOrigem: 100,
        userSectorCode: 7,
      );

      expect(ok, isTrue);
    });
  });
}

class _FakeSeparateItemConsultationRepository
    implements BasicConsultationRepository<SeparateItemConsultationModel> {
  List<SeparateItemConsultationModel> items = [];
  bool throwOnSelect = false;

  @override
  Future<List<SeparateItemConsultationModel>> selectConsultation(QueryBuilder queryBuilder) async {
    if (throwOnSelect) {
      throw Exception('rede');
    }
    return List<SeparateItemConsultationModel>.from(items);
  }
}
