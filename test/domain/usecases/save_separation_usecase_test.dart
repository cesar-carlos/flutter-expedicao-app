import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/models/entity_type_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_model.dart';
import 'package:data7_expedicao/domain/models/separate_progress_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/usecases/save_separation/save_separation_params.dart';
import 'package:data7_expedicao/domain/usecases/save_separation/save_separation_usecase.dart';

void main() {
  group('SaveSeparationUseCase', () {
    test('retorna ValidationFailure quando parametros invalidos', () async {
      final uc = SaveSeparationUseCase(
        separateProgressRepository: _MemProgress([]),
        cartRouteRepository: _MemCartRoute([]),
        separateRepository: _MemSeparate([]),
      );

      final result = await uc.call(const SaveSeparationParams(codEmpresa: 0, codSepararEstoque: 1));

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<ValidationFailure>());
    });

    test('retorna DataFailure quando separacao nao existe', () async {
      final uc = SaveSeparationUseCase(
        separateProgressRepository: _MemProgress([_progress()]),
        cartRouteRepository: _MemCartRoute([_cart()]),
        separateRepository: _MemSeparate([]),
      );

      final result = await uc.call(const SaveSeparationParams(codEmpresa: 1, codSepararEstoque: 100));

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<DataFailure>());
    });

    test('retorna BusinessFailure quando situacao da separacao nao e SEPARANDO', () async {
      final uc = SaveSeparationUseCase(
        separateProgressRepository: _MemProgress([_progress()]),
        cartRouteRepository: _MemCartRoute([_cart()]),
        separateRepository: _MemSeparate([_separate(situacao: ExpeditionSituation.separado)]),
      );

      final result = await uc.call(const SaveSeparationParams(codEmpresa: 1, codSepararEstoque: 100));

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<BusinessFailure>());
    });

    test('retorna BusinessFailure quando processoSeparacao nao e SEPARANDO', () async {
      final uc = SaveSeparationUseCase(
        separateProgressRepository: _MemProgress([_progress(processoSeparacao: ExpeditionSituation.aguardando)]),
        cartRouteRepository: _MemCartRoute([_cart()]),
        separateRepository: _MemSeparate([_separate()]),
      );

      final result = await uc.call(const SaveSeparationParams(codEmpresa: 1, codSepararEstoque: 100));

      expect(result.isError(), isTrue);
      final err = result.exceptionOrNull();
      expect(err, isA<BusinessFailure>());
      expect((err as BusinessFailure).message, contains('Processo de separação'));
    });

    test('retorna BusinessFailure quando situacao do progresso nao e SEPARANDO', () async {
      final uc = SaveSeparationUseCase(
        separateProgressRepository: _MemProgress([_progress(situacao: ExpeditionSituation.separado)]),
        cartRouteRepository: _MemCartRoute([_cart()]),
        separateRepository: _MemSeparate([_separate()]),
      );

      final result = await uc.call(const SaveSeparationParams(codEmpresa: 1, codSepararEstoque: 100));

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<BusinessFailure>());
    });

    test('retorna DataFailure quando progresso nao existe', () async {
      final uc = SaveSeparationUseCase(
        separateProgressRepository: _MemProgress([]),
        cartRouteRepository: _MemCartRoute([_cart()]),
        separateRepository: _MemSeparate([_separate()]),
      );

      final result = await uc.call(const SaveSeparationParams(codEmpresa: 1, codSepararEstoque: 100));

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<DataFailure>());
    });

    test('retorna DataFailure quando carrinho percurso nao existe', () async {
      final uc = SaveSeparationUseCase(
        separateProgressRepository: _MemProgress([_progress()]),
        cartRouteRepository: _MemCartRoute([]),
        separateRepository: _MemSeparate([_separate()]),
      );

      final result = await uc.call(const SaveSeparationParams(codEmpresa: 1, codSepararEstoque: 100));

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<DataFailure>());
    });

    test('persiste SEPARADO na separacao e no percurso quando dados ok', () async {
      final cart = _cart();
      final sep = _separate();
      final cartRepo = _MemCartRoute([cart]);
      final sepRepo = _MemSeparate([sep]);

      final uc = SaveSeparationUseCase(
        separateProgressRepository: _MemProgress([_progress()]),
        cartRouteRepository: cartRepo,
        separateRepository: sepRepo,
      );

      final result = await uc.call(const SaveSeparationParams(codEmpresa: 1, codSepararEstoque: 100));

      expect(result.isSuccess(), isTrue);
      expect(cartRepo.singleRow.situacao, ExpeditionCartSituation.separado);
      expect(sepRepo.singleRow.situacao, ExpeditionSituation.separado);
    });

    test('rollback do percurso quando update da separacao retorna vazio', () async {
      final originalCart = _cart();
      final cartRepo = _MemCartRoute([originalCart]);
      final sepRepo = _MemSeparate([_separate()], emptyUpdate: true);

      final uc = SaveSeparationUseCase(
        separateProgressRepository: _MemProgress([_progress()]),
        cartRouteRepository: cartRepo,
        separateRepository: sepRepo,
      );

      final result = await uc.call(const SaveSeparationParams(codEmpresa: 1, codSepararEstoque: 100));

      expect(result.isError(), isTrue);
      expect(cartRepo.singleRow.situacao, ExpeditionCartSituation.emSeparacao);
    });

    test('mapeia DataError da rede para NetworkFailure', () async {
      final uc = SaveSeparationUseCase(
        separateProgressRepository: _MemProgress([_progress()]),
        cartRouteRepository: _MemCartRoute([_cart()]),
        separateRepository: _ThrowingSeparate(DataError(message: 'socket')),
      );

      final result = await uc.call(const SaveSeparationParams(codEmpresa: 1, codSepararEstoque: 100));

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull(), isA<NetworkFailure>());
    });
  });
}

SeparateProgressConsultationModel _progress({
  ExpeditionSituation situacao = ExpeditionSituation.separando,
  ExpeditionSituation processoSeparacao = ExpeditionSituation.separando,
}) {
  return SeparateProgressConsultationModel(
    codEmpresa: 1,
    codSepararEstoque: 100,
    origem: ExpeditionOrigem.separacaoEstoque,
    codOrigem: 100,
    situacao: situacao,
    processoSeparacao: processoSeparacao,
  );
}

SeparateModel _separate({ExpeditionSituation situacao = ExpeditionSituation.separando}) {
  return SeparateModel(
    codEmpresa: 1,
    codSepararEstoque: 100,
    origem: ExpeditionOrigem.separacaoEstoque,
    codOrigem: 100,
    codTipoOperacaoExpedicao: 1,
    tipoEntidade: EntityType.cliente,
    codEntidade: 1,
    nomeEntidade: 'Cliente',
    situacao: situacao,
    data: DateTime(2026, 1, 1),
    hora: '08:00:00',
    codPrioridade: 1,
  );
}

ExpeditionCartRouteModel _cart() {
  return ExpeditionCartRouteModel(
    codEmpresa: 1,
    codCarrinhoPercurso: 200,
    origem: ExpeditionOrigem.separacaoEstoque,
    codOrigem: 100,
    situacao: ExpeditionCartSituation.emSeparacao,
    dataInicio: DateTime(2026, 1, 1),
    horaInicio: '08:00:00',
  );
}

class _MemProgress implements BasicConsultationRepository<SeparateProgressConsultationModel> {
  _MemProgress(this.rows);

  final List<SeparateProgressConsultationModel> rows;

  @override
  Future<List<SeparateProgressConsultationModel>> selectConsultation(QueryBuilder queryBuilder) async {
    return List<SeparateProgressConsultationModel>.from(rows);
  }
}

class _MemSeparate implements BasicRepository<SeparateModel> {
  _MemSeparate(List<SeparateModel> rows, {this.emptyUpdate = false}) : _rows = List<SeparateModel>.from(rows);

  final List<SeparateModel> _rows;
  final bool emptyUpdate;

  SeparateModel get singleRow => _rows.first;

  @override
  Future<List<SeparateModel>> delete(SeparateModel entity) async => <SeparateModel>[];

  @override
  Future<List<SeparateModel>> insert(SeparateModel entity) async => <SeparateModel>[];

  @override
  Future<List<SeparateModel>> select(QueryBuilder queryBuilder) async => List<SeparateModel>.from(_rows);

  @override
  Future<List<SeparateModel>> update(SeparateModel entity) async {
    if (emptyUpdate) {
      return <SeparateModel>[];
    }
    final i = _rows.indexWhere(
      (r) => r.codEmpresa == entity.codEmpresa && r.codSepararEstoque == entity.codSepararEstoque,
    );
    if (i >= 0) {
      _rows[i] = entity;
      return <SeparateModel>[entity];
    }
    return <SeparateModel>[];
  }
}

class _MemCartRoute implements BasicRepository<ExpeditionCartRouteModel> {
  _MemCartRoute(List<ExpeditionCartRouteModel> rows) : _rows = List<ExpeditionCartRouteModel>.from(rows);

  final List<ExpeditionCartRouteModel> _rows;

  ExpeditionCartRouteModel get singleRow => _rows.first;

  @override
  Future<List<ExpeditionCartRouteModel>> delete(ExpeditionCartRouteModel entity) async => <ExpeditionCartRouteModel>[];

  @override
  Future<List<ExpeditionCartRouteModel>> insert(ExpeditionCartRouteModel entity) async => <ExpeditionCartRouteModel>[];

  @override
  Future<List<ExpeditionCartRouteModel>> select(QueryBuilder queryBuilder) async =>
      List<ExpeditionCartRouteModel>.from(_rows);

  @override
  Future<List<ExpeditionCartRouteModel>> update(ExpeditionCartRouteModel entity) async {
    final i = _rows.indexWhere(
      (r) =>
          r.codEmpresa == entity.codEmpresa &&
          r.codCarrinhoPercurso == entity.codCarrinhoPercurso &&
          r.origem == entity.origem &&
          r.codOrigem == entity.codOrigem,
    );
    if (i >= 0) {
      _rows[i] = entity;
      return <ExpeditionCartRouteModel>[entity];
    }
    return <ExpeditionCartRouteModel>[];
  }
}

class _ThrowingSeparate implements BasicRepository<SeparateModel> {
  _ThrowingSeparate(this.error);

  final DataError error;

  @override
  Future<List<SeparateModel>> delete(SeparateModel entity) async => <SeparateModel>[];

  @override
  Future<List<SeparateModel>> insert(SeparateModel entity) async => <SeparateModel>[];

  @override
  Future<List<SeparateModel>> select(QueryBuilder queryBuilder) async => throw error;

  @override
  Future<List<SeparateModel>> update(SeparateModel entity) async => <SeparateModel>[];
}
