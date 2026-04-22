import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/event_model/basic_event_model.dart';
import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/separate_cart_internship_event_repository.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/cart_event_listener_controller.dart';

void main() {
  late _FakeEventRepository fakeRepo;
  late List<ExpeditionCartRouteInternshipConsultationModel> updates;
  late List<String> errors;

  setUp(() {
    fakeRepo = _FakeEventRepository();
    updates = [];
    errors = [];
  });

  CartEventListenerController makeController() {
    return CartEventListenerController(
      eventRepository: fakeRepo,
      onCartUpdated: updates.add,
      onProcessingError: errors.add,
    );
  }

  group('CartEventListenerController', () {
    test('start registra listener uma vez', () {
      final ctrl = makeController();
      ctrl.start(_buildCart(codCarrinhoPercurso: 1, item: '1'));

      expect(fakeRepo.registeredListeners.length, equals(1));
      expect(fakeRepo.registeredListeners.single.allEvent, isTrue);
      expect(ctrl.isListening, isTrue);

      // Segunda chamada nao re-registra (idempotente).
      ctrl.start(_buildCart(codCarrinhoPercurso: 1, item: '1'));
      expect(fakeRepo.registeredListeners.length, equals(1));

      ctrl.dispose();
    });

    test('stop remove o listener (idempotente)', () {
      final ctrl = makeController();
      ctrl.start(_buildCart(codCarrinhoPercurso: 1, item: '1'));
      expect(fakeRepo.registeredListeners.length, equals(1));

      ctrl.stop();
      expect(ctrl.isListening, isFalse);
      expect(fakeRepo.removedIds, contains('card_picking_viewmodel_cart_update'));

      // stop redundante eh no-op
      ctrl.stop();
      expect(fakeRepo.removedIds.length, equals(1));
    });

    test('encaminha update apenas se for o mesmo cart (mesmo codEmpresa/codCarrinhoPercurso/item)', () {
      final ctrl = makeController();
      ctrl.start(_buildCart(codEmpresa: 1, codCarrinhoPercurso: 100, item: '1'));

      // Evento do MESMO cart (situacao trocada de aguardando para emSeparacao)
      _emitUpdate(fakeRepo, _buildCartJson(
        codEmpresa: 1,
        codCarrinhoPercurso: 100,
        item: '1',
        situacao: 'EM SEPARACAO',
      ));
      expect(updates.length, equals(1));
      expect(updates.first.codCarrinhoPercurso, equals(100));

      // Evento de OUTRO cart (codCarrinhoPercurso diferente) deve ser ignorado
      _emitUpdate(fakeRepo, _buildCartJson(
        codEmpresa: 1,
        codCarrinhoPercurso: 999,
        item: '1',
        situacao: 'EM SEPARACAO',
      ));
      expect(updates.length, equals(1), reason: 'cart diferente nao deve disparar callback');

      ctrl.dispose();
    });

    test('processa Mutation List quando o evento vem em batch', () {
      final ctrl = makeController();
      ctrl.start(_buildCart(codEmpresa: 1, codCarrinhoPercurso: 100, item: '1'));

      _emitUpdate(fakeRepo, {
        'Mutation': [
          _buildCartJson(codEmpresa: 1, codCarrinhoPercurso: 100, item: '1', situacao: 'EM SEPARACAO'),
          _buildCartJson(codEmpresa: 1, codCarrinhoPercurso: 999, item: '1', situacao: 'EM SEPARACAO'),
          _buildCartJson(codEmpresa: 1, codCarrinhoPercurso: 100, item: '1', situacao: 'SEPARANDO'),
        ],
      });

      // Apenas as 2 mutations do mesmo cart sao encaminhadas.
      expect(updates.length, equals(2));
      expect(updates.every((u) => u.codCarrinhoPercurso == 100), isTrue);

      ctrl.dispose();
    });

    test('updateCurrentCart troca a referencia para futuras checagens "is same cart"', () {
      final ctrl = makeController();
      ctrl.start(_buildCart(codEmpresa: 1, codCarrinhoPercurso: 100, item: '1'));

      final newer = _buildCart(codEmpresa: 1, codCarrinhoPercurso: 100, item: '1');
      ctrl.updateCurrentCart(newer);

      // Continua reconhecendo o mesmo cart
      _emitUpdate(fakeRepo, _buildCartJson(
        codEmpresa: 1,
        codCarrinhoPercurso: 100,
        item: '1',
        situacao: 'EM SEPARACAO',
      ));
      expect(updates.length, equals(1));

      ctrl.dispose();
    });

    test('ignora evento sem data', () {
      final ctrl = makeController();
      ctrl.start(_buildCart(codEmpresa: 1, codCarrinhoPercurso: 100, item: '1'));

      fakeRepo.fire(BasicEventModel(
        timestamp: DateTime.now(),
        eventType: Event.update,
        data: null,
      ));

      expect(updates, isEmpty);
      expect(errors, isEmpty);
      ctrl.dispose();
    });

    test('JSON invalido eh logado silenciosamente sem disparar onProcessingError nem onCartUpdated', () {
      // Comportamento herdado do CardPickingViewModel original: erros de
      // _processEventData (fromJson) sao logados mas nao propagam erro para
      // a UI. onProcessingError so dispara em excecoes nao previstas.
      final ctrl = makeController();
      ctrl.start(_buildCart(codEmpresa: 1, codCarrinhoPercurso: 100, item: '1'));

      fakeRepo.fire(BasicEventModel(
        timestamp: DateTime.now(),
        eventType: Event.update,
        data: const {'invalid': 'shape'},
      ));

      expect(updates, isEmpty);
      expect(errors, isEmpty);
      ctrl.dispose();
    });

    test('dispose libera o listener mesmo sem stop explicito', () {
      final ctrl = makeController();
      ctrl.start(_buildCart(codEmpresa: 1, codCarrinhoPercurso: 100, item: '1'));
      ctrl.dispose();
      expect(ctrl.isListening, isFalse);
      expect(fakeRepo.removedIds, contains('card_picking_viewmodel_cart_update'));
    });
  });
}

void _emitUpdate(_FakeEventRepository repo, Map<String, dynamic> data) {
  repo.fire(BasicEventModel(
    timestamp: DateTime.now(),
    eventType: Event.update,
    data: data,
  ));
}

ExpeditionCartRouteInternshipConsultationModel _buildCart({
  int codEmpresa = 1,
  int codCarrinhoPercurso = 100,
  String item = '1',
  String situacao = 'AGUARDANDO',
}) {
  return ExpeditionCartRouteInternshipConsultationModel.fromJson(
    _buildCartJson(
      codEmpresa: codEmpresa,
      codCarrinhoPercurso: codCarrinhoPercurso,
      item: item,
      situacao: situacao,
    ),
  );
}

Map<String, dynamic> _buildCartJson({
  required int codEmpresa,
  required int codCarrinhoPercurso,
  required String item,
  String situacao = 'AGUARDANDO',
}) {
  return <String, dynamic>{
    'CodEmpresa': codEmpresa,
    'CodCarrinhoPercurso': codCarrinhoPercurso,
    'Item': item,
    'CodPercursoEstagio': 1,
    'Origem': 'SEPARACAO_ESTOQUE',
    'CodOrigem': 1,
    'Situacao': situacao,
    'CarrinhoAgrupador': 'INATIVO',
    'CodCarrinhoAgrupador': null,
    'CodCarrinho': 1,
    'NomeCarrinho': 'Carrinho 1',
    'CodigoBarrasCarrinho': '0001',
    'Ativo': 'ATIVO',
    'CodUsuarioInicio': 1,
    'NomeUsuarioInicio': 'TESTE',
    'DataInicio': '2026-01-01',
    'HoraInicio': '08:00:00',
  };
}

/// Repositório fake mínimo: aceita addListener/removeListener e emite eventos
/// manualmente via `fire()`.
class _FakeEventRepository implements SeparateCartInternshipEventRepository {
  final List<EventListenerModel> registeredListeners = [];
  final List<String> removedIds = [];

  @override
  void addListener(EventListenerModel listener) {
    registeredListeners.add(listener);
  }

  @override
  void removeListener(String listenerId) {
    removedIds.add(listenerId);
    registeredListeners.removeWhere((l) => l.id == listenerId);
  }

  void fire(BasicEventModel event) {
    for (final l in registeredListeners) {
      if (l.listensTo(event.eventType)) {
        l.callback(event);
      }
    }
  }

  @override
  void removeListeners(List<String> listenerIds) => listenerIds.forEach(removeListener);

  @override
  void removeAllListeners() => registeredListeners.clear();

  @override
  bool hasListener(String listenerId) => registeredListeners.any((l) => l.id == listenerId);

  @override
  EventListenerModel? getListenerById(String listenerId) {
    for (final l in registeredListeners) {
      if (l.id == listenerId) return l;
    }
    return null;
  }

  @override
  List<EventListenerModel> get listeners => List.unmodifiable(registeredListeners);

  @override
  void dispose() {
    registeredListeners.clear();
  }
}
