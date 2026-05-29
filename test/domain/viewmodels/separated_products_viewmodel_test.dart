import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/event_model/basic_event_model.dart';
import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/models/separate_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_item_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/repositories/separate_cart_internship_event_repository.dart';
import 'package:data7_expedicao/domain/usecases/delete_item_separation/delete_item_separation_usecase.dart';
import 'package:data7_expedicao/presentation/viewmodels/separated_products_viewmodel.dart';

import '../../support/fake_user_session_service.dart';

class FakeConsultationRepository<T> implements BasicConsultationRepository<T> {
  FakeConsultationRepository({required this.onSelect});

  Future<List<T>> Function(QueryBuilder queryBuilder) onSelect;
  int selectCallCount = 0;

  @override
  Future<List<T>> selectConsultation(QueryBuilder queryBuilder) {
    selectCallCount += 1;
    return onSelect(queryBuilder);
  }
}

class FakeBasicRepository<T> implements BasicRepository<T> {
  @override
  Future<List<T>> delete(T entity) async => <T>[];

  @override
  Future<List<T>> insert(T entity) async => <T>[];

  @override
  Future<List<T>> select(QueryBuilder queryBuilder) async => <T>[];

  @override
  Future<List<T>> update(T entity) async => <T>[];
}

class FakeSeparateCartInternshipEventRepository implements SeparateCartInternshipEventRepository {
  final List<EventListenerModel> _listeners = <EventListenerModel>[];

  @override
  void addListener(EventListenerModel listener) {
    _listeners.removeWhere((existing) => existing.id == listener.id);
    _listeners.add(listener);
  }

  @override
  void dispose() {
    _listeners.clear();
  }

  void emit(BasicEventModel event) {
    final activeListeners = List<EventListenerModel>.from(_listeners);
    for (final listener in activeListeners) {
      if (listener.event == event.eventType) {
        listener.callback(event);
      }
    }
  }

  @override
  EventListenerModel? getListenerById(String listenerId) {
    for (final listener in _listeners) {
      if (listener.id == listenerId) {
        return listener;
      }
    }
    return null;
  }

  @override
  bool hasListener(String listenerId) => _listeners.any((listener) => listener.id == listenerId);

  @override
  List<EventListenerModel> get listeners => List<EventListenerModel>.unmodifiable(_listeners);

  @override
  void removeAllListeners() {
    _listeners.clear();
  }

  @override
  void removeListener(String listenerId) {
    _listeners.removeWhere((listener) => listener.id == listenerId);
  }

  @override
  void removeListeners(List<String> listenerIds) {
    _listeners.removeWhere((listener) => listenerIds.contains(listener.id));
  }
}

DeleteItemSeparationUseCase buildDeleteUseCase() {
  return DeleteItemSeparationUseCase(
    separateItemRepository: FakeBasicRepository<SeparateItemModel>(),
    separationItemRepository: FakeBasicRepository<SeparationItemModel>(),
    separateRepository: FakeBasicRepository<SeparateModel>(),
    userSessionService: FakeUserSessionService(loggedOut: true),
  );
}

void main() {
  ExpeditionCartRouteInternshipConsultationModel buildCart({
    int codOrigem = 123,
    int codCarrinho = 100,
    int codCarrinhoPercurso = 200,
    String item = '1',
    ExpeditionSituation situacao = ExpeditionSituation.separando,
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
      dataInicio: DateTime(2026, 5, 6, 10),
      horaInicio: '10:00:00',
      codSetorEstoque: 1,
      nomeSetorEstoque: 'Setor',
    );
  }

  SeparationItemConsultationModel buildSeparatedItem({
    String item = '1',
    int codCarrinhoPercurso = 200,
    DateTime? dataSeparacao,
    String horaSeparacao = '10:00:00',
    int codProduto = 1,
  }) {
    return SeparationItemConsultationModel(
      codEmpresa: 1,
      codSepararEstoque: 123,
      item: item,
      sessionId: 'session',
      situacao: ExpeditionItemSituation.separado,
      codCarrinho: 100,
      nomeCarrinho: 'Carrinho 100',
      codigoBarrasCarrinho: 'BC100',
      codCarrinhoPercurso: codCarrinhoPercurso,
      itemCarrinhoPercurso: '1',
      codProduto: codProduto,
      nomeProduto: 'Produto $codProduto',
      codUnidadeMedida: 'UN',
      nomeUnidadeMedida: 'Unidade',
      codGrupoProduto: 1,
      nomeGrupoProduto: 'Grupo',
      codSetorEstoque: 1,
      nomeSetorEstoque: 'Setor',
      codSeparador: 7,
      nomeSeparador: 'Separador',
      dataSeparacao: dataSeparacao ?? DateTime(2026, 5, 6),
      horaSeparacao: horaSeparacao,
      quantidade: 2,
    );
  }

  group('SeparatedProductsViewModel', () {
    late FakeConsultationRepository<SeparationItemConsultationModel> repository;
    late FakeSeparateCartInternshipEventRepository eventRepository;
    late SeparatedProductsViewModel viewModel;

    setUp(() {
      repository = FakeConsultationRepository<SeparationItemConsultationModel>(
        onSelect: (_) async => <SeparationItemConsultationModel>[],
      );
      eventRepository = FakeSeparateCartInternshipEventRepository();
      viewModel = SeparatedProductsViewModel.withDependencies(repository, buildDeleteUseCase(), eventRepository);
    });

    tearDown(() {
      viewModel.dispose();
      eventRepository.dispose();
    });

    test('resyncVisibleDataSilently updates items without entering loading state', () async {
      final cart = buildCart();
      final firstItem = buildSeparatedItem(item: '1', horaSeparacao: '10:00:00');
      final newerItem = buildSeparatedItem(item: '2', horaSeparacao: '11:00:00', codProduto: 2);

      var callCount = 0;
      repository.onSelect = (_) async {
        callCount += 1;
        if (callCount == 1) {
          return <SeparationItemConsultationModel>[firstItem];
        }
        return <SeparationItemConsultationModel>[newerItem, firstItem];
      };

      await viewModel.loadSeparatedProducts(cart);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.items, hasLength(1));

      await viewModel.resyncVisibleDataSilently();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.items.first.item, '2');
      expect(viewModel.items, hasLength(2));
    });

    test('cart event for the current cart triggers authoritative resync even when status is unchanged', () async {
      final cart = buildCart(situacao: ExpeditionSituation.separando);
      final firstItem = buildSeparatedItem(item: '1', horaSeparacao: '10:00:00');
      final newerItem = buildSeparatedItem(item: '2', horaSeparacao: '11:00:00', codProduto: 2);

      var callCount = 0;
      repository.onSelect = (_) async {
        callCount += 1;
        if (callCount == 1) {
          return <SeparationItemConsultationModel>[firstItem];
        }
        return <SeparationItemConsultationModel>[newerItem, firstItem];
      };

      await viewModel.loadSeparatedProducts(cart);
      viewModel.startCartEventMonitoring();

      eventRepository.emit(
        BasicEventModel(
          timestamp: DateTime.now(),
          eventType: Event.update,
          data: <String, dynamic>{
            'Mutation': <Map<String, dynamic>>[buildCart(situacao: ExpeditionSituation.separando).toJson()],
          },
        ),
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.items.first.item, '2');
      expect(viewModel.hasCartStatusChanged, isFalse);
      expect(repository.selectCallCount, 2);
    });

    test('cart event ignores unrelated carts', () async {
      final cart = buildCart();
      final firstItem = buildSeparatedItem(item: '1');

      repository.onSelect = (_) async => <SeparationItemConsultationModel>[firstItem];

      await viewModel.loadSeparatedProducts(cart);
      viewModel.startCartEventMonitoring();

      eventRepository.emit(
        BasicEventModel(
          timestamp: DateTime.now(),
          eventType: Event.update,
          data: <String, dynamic>{
            'Mutation': <Map<String, dynamic>>[
              buildCart(codOrigem: 999, codCarrinho: 777, codCarrinhoPercurso: 999).toJson(),
            ],
          },
        ),
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(repository.selectCallCount, 1);
      expect(viewModel.items, hasLength(1));
      expect(viewModel.items.first.item, '1');
    });
  });
}
