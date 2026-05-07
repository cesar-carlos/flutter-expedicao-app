import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/utils/i_logger.dart';
import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/usecases/next_separation_user/next_separation_user_failure.dart';
import 'package:data7_expedicao/domain/usecases/next_separation_user/next_separation_user_params.dart';
import 'package:data7_expedicao/domain/usecases/next_separation_user/next_separation_user_usecase.dart';
import 'package:data7_expedicao/domain/usecases/register_separation_user_sector/register_separation_user_sector_usecase.dart';

void main() {
  setUpAll(() {
    if (locator.isRegistered<ILogger>()) {
      locator.unregister<ILogger>();
    }
    locator.registerLazySingleton<ILogger>(() => _FakeLogger());
  });

  tearDownAll(() {
    if (locator.isRegistered<ILogger>()) {
      locator.unregister<ILogger>();
    }
  });

  group('NextSeparationUserUseCase', () {
    late _FakeSeparationUserSectorConsultationRepository consultationRepository;
    late _FakeSeparationUserSectorRepository registrationRepository;
    late NextSeparationUserUseCase useCase;

    setUp(() {
      consultationRepository = _FakeSeparationUserSectorConsultationRepository();
      registrationRepository = _FakeSeparationUserSectorRepository();
      useCase = NextSeparationUserUseCase(
        separationUserSectorRepository: consultationRepository,
        getRegisterUseCase: () => RegisterSeparationUserSectorUseCase(repository: registrationRepository),
        logger: _FakeLogger(),
      );
      consultationRepository.reset();
      registrationRepository.reset();
    });

    group('parameter validation', () {
      test('should return invalidParams when codUsuario is invalid', () async {
        final params = _createInvalidParams(codUsuario: 0);

        final result = await useCase.call(params);

        expect(result.isError(), isTrue);
        final failure = result.exceptionOrNull() as NextSeparationUserFailure;
        expect(failure.type, equals(NextSeparationUserFailureType.invalidParams));
        expect(failure.details, contains('Código do usuário deve ser maior que zero'));
      });

      test('should return invalidParams when codEmpresa is invalid', () async {
        final params = _createInvalidParams(codEmpresa: 0);

        final result = await useCase.call(params);

        expect(result.isError(), isTrue);
        final failure = result.exceptionOrNull() as NextSeparationUserFailure;
        expect(failure.type, equals(NextSeparationUserFailureType.invalidParams));
      });

      test('should return invalidParams when userSystemModel is null', () async {
        final params = const NextSeparationUserParams(
          codEmpresa: 1,
          codUsuario: 1,
          codSetorEstoque: 100,
          userSystemModel: null,
        );

        final result = await useCase.call(params);

        expect(result.isError(), isTrue);
        final failure = result.exceptionOrNull() as NextSeparationUserFailure;
        expect(failure.type, equals(NextSeparationUserFailureType.invalidParams));
      });

      test('should return userWithoutSector when codSetorEstoque is missing', () async {
        final params = NextSeparationUserParams(
          codEmpresa: 1,
          codUsuario: 1,
          codSetorEstoque: null,
          userSystemModel: _createTestUserSystemModel(),
        );

        final result = await useCase.call(params);

        expect(result.isError(), isTrue);
        final failure = result.exceptionOrNull() as NextSeparationUserFailure;
        expect(failure.type, equals(NextSeparationUserFailureType.userWithoutSector));
      });
    });

    group('completed separation should not be returned', () {
      test('should return notFound when only completed work exists for the sector', () async {
        final completedSeparation = createMockCompletedSeparation(codUsuario: 1, nomeUsuario: 'Test User');
        consultationRepository.setCompletedSeparation(completedSeparation);

        final result = await useCase.call(_createValidParams());

        expect(result.isSuccess(), isTrue);
        final success = result.getOrNull()!;
        expect(success.hasSeparation, isFalse);
        expect(success.message, equals('Não existe separação pendente para este usuário'));
      });

      test('should keep searching other pages until it finds a real pending separation', () async {
        final completedSeparations = List<SeparationUserSectorConsultationModel>.generate(
          20,
          (index) =>
              createMockCompletedSeparation(codUsuario: 1, nomeUsuario: 'Test User', codSepararEstoque: 100 + index),
        );
        final pendingSeparation = createMockSeparationWithPendingItems(
          codUsuario: 1,
          nomeUsuario: 'Test User',
          codSepararEstoque: 999,
        );

        consultationRepository.setExistingSeparations([...completedSeparations, pendingSeparation]);

        final result = await useCase.call(_createValidParams());

        expect(result.isSuccess(), isTrue);
        final success = result.getOrNull()!;
        expect(success.hasSeparation, isTrue);
        expect(success.separation!.codSepararEstoque, equals(999));
      });
    });

    group('priority 1', () {
      test('should return the user separation with pending items', () async {
        final pendingSeparation = createMockSeparationWithPendingItems(codUsuario: 1, nomeUsuario: 'Test User');
        consultationRepository.setPendingItemsSeparation(pendingSeparation);

        final result = await useCase.call(_createValidParams());

        expect(result.isSuccess(), isTrue);
        final success = result.getOrNull()!;
        expect(success.hasSeparation, isTrue);
        expect(success.separation!.codSepararEstoque, equals(pendingSeparation.codSepararEstoque));
        expect(success.separation!.quantidadeItensSetor, equals(10.0));
        expect(success.separation!.quantidadeItensSeparacaoSetor, equals(5.0));
      });

      test('should not register assignment when returning an existing pending separation', () async {
        final pendingSeparation = createMockSeparationWithPendingItems(codUsuario: 1, nomeUsuario: 'Test User');
        consultationRepository.setPendingItemsSeparation(pendingSeparation);

        await useCase.call(_createValidParams());

        expect(registrationRepository.insertCount, equals(0));
      });
    });

    group('priority 2', () {
      test('should find a new separation and register assignment', () async {
        final newSeparation = createMockNewSeparation();
        consultationRepository.setNewSeparations([newSeparation]);

        final result = await useCase.call(_createValidParams());

        expect(result.isSuccess(), isTrue);
        final success = result.getOrNull()!;
        expect(success.hasSeparation, isTrue);
        expect(success.separation!.codSepararEstoque, equals(newSeparation.codSepararEstoque));
        expect(registrationRepository.insertCount, equals(1));
        expect(registrationRepository.lastInsert?.codUsuario, equals(1));
        expect(registrationRepository.lastInsert?.codSepararEstoque, equals(newSeparation.codSepararEstoque));
      });
    });

    group('assignment retry', () {
      test('should try the next available candidate when first assignment fails', () async {
        consultationRepository.setNewSeparations([
          createMockNewSeparation(codSepararEstoque: 301),
          createMockNewSeparation(codSepararEstoque: 302),
        ]);
        registrationRepository.setShouldFailFirstTime(true);

        final result = await useCase.call(_createValidParams());

        expect(registrationRepository.insertCount, equals(2));
        expect(result.isSuccess(), isTrue);
        final success = result.getOrNull()!;
        expect(success.hasSeparation, isTrue);
        expect(success.separation!.codSepararEstoque, equals(302));
      });

      test('should fail explicitly when assignment reaches max retries', () async {
        consultationRepository.setNewSeparations([
          createMockNewSeparation(codSepararEstoque: 301),
          createMockNewSeparation(codSepararEstoque: 302),
          createMockNewSeparation(codSepararEstoque: 303),
        ]);
        registrationRepository.setAlwaysFail(true);

        final result = await useCase.call(_createValidParams());

        expect(registrationRepository.insertCount, equals(3));
        expect(result.isError(), isTrue);
        final failure = result.exceptionOrNull() as NextSeparationUserFailure;
        expect(failure.type, equals(NextSeparationUserFailureType.assignmentFailed));
      });

      test('should fail explicitly when there was a candidate but no assignment succeeded', () async {
        consultationRepository.setNewSeparations([createMockNewSeparation()]);
        registrationRepository.setAlwaysFail(true);

        final result = await useCase.call(_createValidParams());

        expect(result.isError(), isTrue);
        final failure = result.exceptionOrNull() as NextSeparationUserFailure;
        expect(failure.type, equals(NextSeparationUserFailureType.assignmentFailed));
      });
    });

    group('priority precedence', () {
      test('should prefer pending separation over new separation', () async {
        final pendingSeparation = createMockSeparationWithPendingItems(
          codUsuario: 1,
          nomeUsuario: 'Test User',
          codSepararEstoque: 200,
        );
        final newSeparation = createMockNewSeparation(codSepararEstoque: 300);

        consultationRepository.setPendingItemsSeparation(pendingSeparation);
        consultationRepository.setNewSeparations([newSeparation]);

        final result = await useCase.call(_createValidParams());

        final success = result.getOrNull()!;
        expect(success.separation!.codSepararEstoque, equals(200));
      });

      test('should use priority 2 when there is no pending separation', () async {
        final newSeparation = createMockNewSeparation();
        consultationRepository.setNewSeparations([newSeparation]);

        final result = await useCase.call(_createValidParams());

        final success = result.getOrNull()!;
        expect(success.separation!.codSepararEstoque, equals(newSeparation.codSepararEstoque));
      });
    });

    group('not found scenarios', () {
      test('should return notFound when there are no separations', () async {
        final result = await useCase.call(_createValidParams());

        expect(result.isSuccess(), isTrue);
        final success = result.getOrNull()!;
        expect(success.hasSeparation, isFalse);
        expect(success.message, equals('Não existe separação pendente para este usuário'));
      });
    });

    group('error handling', () {
      test('should return networkError when repository throws DataError', () async {
        consultationRepository.setError(DataError(message: 'Erro de conexão'));

        final result = await useCase.call(_createValidParams());

        expect(result.isError(), isTrue);
        final failure = result.exceptionOrNull() as NextSeparationUserFailure;
        expect(failure.type, equals(NextSeparationUserFailureType.networkError));
      });

      test('should return unknownError when repository throws generic exception', () async {
        consultationRepository.setError(Exception('Erro inesperado'));

        final result = await useCase.call(_createValidParams());

        expect(result.isError(), isTrue);
        final failure = result.exceptionOrNull() as NextSeparationUserFailure;
        expect(failure.type, equals(NextSeparationUserFailureType.unknownError));
      });
    });
  });
}

NextSeparationUserParams _createValidParams() {
  return NextSeparationUserParams(
    codEmpresa: 1,
    codUsuario: 1,
    codSetorEstoque: 100,
    userSystemModel: _createTestUserSystemModel(),
  );
}

NextSeparationUserParams _createInvalidParams({int? codEmpresa, int? codUsuario}) {
  return NextSeparationUserParams(
    codEmpresa: codEmpresa ?? 0,
    codUsuario: codUsuario ?? 0,
    codSetorEstoque: 100,
    userSystemModel: _createTestUserSystemModel(),
  );
}

UserSystemModel _createTestUserSystemModel() {
  return UserSystemModel(
    codUsuario: 1,
    nomeUsuario: 'Test User',
    ativo: Situation.ativo,
    codSetorEstoque: 100,
    nomeSetorEstoque: 'Setor Teste',
    codEmpresa: 1,
    nomeEmpresa: 'Empresa Teste',
    codVendedor: 1,
    nomeVendedor: 'Vendedor Teste',
    codLocalArmazenagem: 1,
    nomeLocalArmazenagem: 'Armazem Teste',
    codContaFinanceira: '001',
    nomeContaFinanceira: 'Conta Teste',
    nomeCaixaOperador: 'Caixa Teste',
    permiteSepararForaSequencia: Situation.ativo,
    visualizaTodasSeparacoes: Situation.ativo,
    expedicaoObrigaEscanearPrateleira: Situation.inativo,
    permiteConferirForaSequencia: Situation.ativo,
    visualizaTodasConferencias: Situation.ativo,
    codSetorConferencia: 100,
    nomeSetorConferencia: 'Setor Conferencia',
    codSetorArmazenagem: 100,
    nomeSetorArmazenagem: 'Setor Armazenagem',
    permiteArmazenarForaSequencia: Situation.ativo,
    visualizaTodasArmazenagem: Situation.ativo,
    editaCarrinhoOutroUsuario: Situation.inativo,
    salvaCarrinhoOutroUsuario: Situation.inativo,
    excluiCarrinhoOutroUsuario: Situation.inativo,
    expedicaoEntregaBalcaoPreVenda: Situation.inativo,
  );
}

SeparationUserSectorConsultationModel createMockCompletedSeparation({
  required int codUsuario,
  required String nomeUsuario,
  int codSepararEstoque = 100,
}) {
  return SeparationUserSectorConsultationModel(
    codEmpresa: 1,
    codSepararEstoque: codSepararEstoque,
    separarEstoqueSituacao: ExpeditionSituation.separando,
    codSetorEstoque: 100,
    descricaoSetorEstoque: 'Setor Teste',
    codPrioridade: 1,
    descricaoPrioridade: 'Normal',
    prioridade: 1,
    quantidadeItens: 10.0,
    quantidadeItensSeparacao: 10.0,
    quantidadeItensSetor: 10.0,
    quantidadeItensSeparacaoSetor: 10.0,
    carrinhosAbertosUsuario: 'N',
    codUsuario: codUsuario,
    nomeUsuario: nomeUsuario,
    estacaoSeparacao: null,
  );
}

SeparationUserSectorConsultationModel createMockSeparationWithPendingItems({
  required int codUsuario,
  required String nomeUsuario,
  int codSepararEstoque = 200,
}) {
  return SeparationUserSectorConsultationModel(
    codEmpresa: 1,
    codSepararEstoque: codSepararEstoque,
    separarEstoqueSituacao: ExpeditionSituation.separando,
    codSetorEstoque: 100,
    descricaoSetorEstoque: 'Setor Teste',
    codPrioridade: 1,
    descricaoPrioridade: 'Normal',
    prioridade: 1,
    quantidadeItens: 10.0,
    quantidadeItensSeparacao: 5.0,
    quantidadeItensSetor: 10.0,
    quantidadeItensSeparacaoSetor: 5.0,
    carrinhosAbertosUsuario: 'N',
    codUsuario: codUsuario,
    nomeUsuario: nomeUsuario,
    estacaoSeparacao: null,
  );
}

SeparationUserSectorConsultationModel createMockNewSeparation({int codSepararEstoque = 300}) {
  return SeparationUserSectorConsultationModel(
    codEmpresa: 1,
    codSepararEstoque: codSepararEstoque,
    separarEstoqueSituacao: ExpeditionSituation.aguardando,
    codSetorEstoque: 100,
    descricaoSetorEstoque: 'Setor Teste',
    codPrioridade: 1,
    descricaoPrioridade: 'Normal',
    prioridade: 1,
    quantidadeItens: 10.0,
    quantidadeItensSeparacao: 0.0,
    quantidadeItensSetor: 10.0,
    quantidadeItensSeparacaoSetor: 0.0,
    carrinhosAbertosUsuario: 'N',
    codUsuario: null,
    nomeUsuario: null,
    estacaoSeparacao: null,
  );
}

class _FakeSeparationUserSectorConsultationRepository
    implements BasicConsultationRepository<SeparationUserSectorConsultationModel> {
  final List<SeparationUserSectorConsultationModel> _existingSeparations = [];
  final List<SeparationUserSectorConsultationModel> _newSeparations = [];
  Object? _error;

  void setCompletedSeparation(SeparationUserSectorConsultationModel separation) {
    _existingSeparations
      ..clear()
      ..add(separation);
  }

  void setPendingItemsSeparation(SeparationUserSectorConsultationModel separation) {
    _existingSeparations
      ..clear()
      ..add(separation);
  }

  void setExistingSeparations(List<SeparationUserSectorConsultationModel> separations) {
    _existingSeparations
      ..clear()
      ..addAll(separations);
  }

  void setNewSeparation(SeparationUserSectorConsultationModel separation) {
    _newSeparations
      ..clear()
      ..add(separation);
  }

  void setNewSeparations(List<SeparationUserSectorConsultationModel> separations) {
    _newSeparations
      ..clear()
      ..addAll(separations);
  }

  void setError(Object error) {
    _error = error;
  }

  void reset() {
    _existingSeparations.clear();
    _newSeparations.clear();
    _error = null;
  }

  @override
  Future<List<SeparationUserSectorConsultationModel>> selectConsultation(dynamic queryBuilder) async {
    if (_error != null) {
      throw _error!;
    }

    final builder = queryBuilder as QueryBuilder;
    final isNewSeparationQuery = builder.params.any(
      (param) => param.key == 'CodUsuario' && param.operator == 'IS' && param.value == null,
    );
    final limit = builder.pagination?.limit ?? 1000;
    final offset = builder.pagination?.offset ?? 0;

    if (isNewSeparationQuery) {
      return _slicePage(_newSeparations, offset: offset, limit: limit);
    }

    return _slicePage(_existingSeparations, offset: offset, limit: limit);
  }

  List<SeparationUserSectorConsultationModel> _slicePage(
    List<SeparationUserSectorConsultationModel> source, {
    required int offset,
    required int limit,
  }) {
    if (offset >= source.length) {
      return [];
    }

    final end = (offset + limit) > source.length ? source.length : offset + limit;
    return source.sublist(offset, end);
  }
}

class _FakeSeparationUserSectorRepository implements BasicRepository<SeparationUserSectorModel> {
  int _insertCount = 0;
  SeparationUserSectorModel? _lastInsert;
  bool _shouldFailFirstTime = false;
  bool _alwaysFail = false;

  void setShouldFailFirstTime(bool shouldFail) {
    _shouldFailFirstTime = shouldFail;
  }

  void setAlwaysFail(bool alwaysFail) {
    _alwaysFail = alwaysFail;
  }

  void reset() {
    _insertCount = 0;
    _lastInsert = null;
    _shouldFailFirstTime = false;
    _alwaysFail = false;
  }

  @override
  Future<List<SeparationUserSectorModel>> select(QueryBuilder queryBuilder) async => [];

  @override
  Future<List<SeparationUserSectorModel>> insert(SeparationUserSectorModel model) async {
    _insertCount++;
    _lastInsert = model;

    if (_alwaysFail || (_shouldFailFirstTime && _insertCount == 1)) {
      throw DataError(message: 'Erro de inserção simulado');
    }

    return [model];
  }

  @override
  Future<List<SeparationUserSectorModel>> update(SeparationUserSectorModel model) async => [];

  @override
  Future<List<SeparationUserSectorModel>> delete(SeparationUserSectorModel model) async => [];

  int get insertCount => _insertCount;
  SeparationUserSectorModel? get lastInsert => _lastInsert;
}

class _FakeLogger implements ILogger {
  @override
  void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {}

  @override
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {}

  @override
  void info(String message, {String? tag}) {}

  @override
  void severe(String message, {String? tag, Object? error, StackTrace? stackTrace}) {}

  @override
  void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {}
}
