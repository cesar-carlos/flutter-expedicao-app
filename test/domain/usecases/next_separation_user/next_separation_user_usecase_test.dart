import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/usecases/next_separation_user/next_separation_user_params.dart';
import 'package:data7_expedicao/domain/usecases/next_separation_user/next_separation_user_failure.dart';
import 'package:data7_expedicao/domain/usecases/next_separation_user/next_separation_user_usecase.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';

import 'package:data7_expedicao/domain/models/separation_user_sector_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/usecases/register_separation_user_sector/register_separation_user_sector_usecase.dart';
import 'package:data7_expedicao/core/utils/i_logger.dart';
import 'package:data7_expedicao/di/locator.dart';

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
  group('NextSeparationUserUseCase Tests', () {
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

    group('Validação de Parâmetros', () {
      test('deve retornar erro quando codUsuario for inválido', () async {
        final params = _createInvalidParams(codUsuario: 0);

        final result = await useCase.call(params);

        expect(result.isError(), isTrue);
        expect(result.exceptionOrNull(), isA<NextSeparationUserFailure>());
        final failure = result.exceptionOrNull() as NextSeparationUserFailure;
        expect(failure.type, equals(NextSeparationUserFailureType.invalidParams));
        expect(failure.details, contains('Código do usuário deve ser maior que zero'));
      });

      test('deve retornar erro quando codEmpresa for inválido', () async {
        final params = _createInvalidParams(codEmpresa: 0);

        final result = await useCase.call(params);

        expect(result.isError(), isTrue);
        final failure = result.exceptionOrNull() as NextSeparationUserFailure;
        expect(failure.type, equals(NextSeparationUserFailureType.invalidParams));
      });

      test('deve retornar erro quando userSystemModel for null', () async {
        final params = NextSeparationUserParams(
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

      test('deve retornar erro quando codSetorEstoque não for informado', () async {
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

    group('PRIORIDADE 2: Separação 100% Completada', () {
      test('deve retornar separação 100% completada pelo usuário atual', () async {
        final completedSeparation = createMockCompletedSeparation(codUsuario: 1, nomeUsuario: 'Test User');
        consultationRepository.setCompletedSeparation(completedSeparation);

        final params = _createValidParams();
        final result = await useCase.call(params);

        expect(result.isSuccess(), isTrue);
        final success = result.getOrNull()!;
        expect(success.hasSeparation, isTrue);
        expect(success.separation!.codSepararEstoque, equals(completedSeparation.codSepararEstoque));
        expect(success.separation!.codUsuario, equals(1));
      });

      test('não deve registrar atribuição quando retornar separação completada', () async {
        final completedSeparation = createMockCompletedSeparation(codUsuario: 1, nomeUsuario: 'Test User');
        consultationRepository.setCompletedSeparation(completedSeparation);

        final params = _createValidParams();
        await useCase.call(params);

        expect(registrationRepository.insertCount, equals(0));
      });
    });

    group('PRIORIDADE 1: Separação com itens/carrinhos pendentes', () {
      test('deve retornar separação com itens pendentes no setor', () async {
        final pendingSeparation = createMockSeparationWithPendingItems(codUsuario: 1, nomeUsuario: 'Test User');
        consultationRepository.setPendingItemsSeparation(pendingSeparation);

        final params = _createValidParams();
        final result = await useCase.call(params);

        expect(result.isSuccess(), isTrue);
        final success = result.getOrNull()!;
        expect(success.hasSeparation, isTrue);
        expect(success.separation!.codSepararEstoque, equals(pendingSeparation.codSepararEstoque));
        expect(success.separation!.quantidadeItensSetor, equals(10.0));
        expect(success.separation!.quantidadeItensSeparacaoSetor, equals(5.0));
      });

      test('não deve registrar atribuição quando retornar separação pendente', () async {
        final pendingSeparation = createMockSeparationWithPendingItems(codUsuario: 1, nomeUsuario: 'Test User');
        consultationRepository.setPendingItemsSeparation(pendingSeparation);

        final params = _createValidParams();
        await useCase.call(params);

        expect(registrationRepository.insertCount, equals(0));
      });
    });

    group('PRIORIDADE 3: Nova Separação', () {
      test('deve buscar nova separação disponível e registrar atribuição', () async {
        final newSeparation = createMockNewSeparation();
        consultationRepository.setNewSeparation(newSeparation);

        final params = _createValidParams();
        final result = await useCase.call(params);

        expect(result.isSuccess(), isTrue);
        final success = result.getOrNull()!;
        expect(success.hasSeparation, isTrue);
        expect(success.separation!.codSepararEstoque, equals(newSeparation.codSepararEstoque));

        // Verificar se a atribuição foi registrada
        expect(registrationRepository.insertCount, greaterThan(0));
        expect(registrationRepository.lastInsert?.codUsuario, equals(1));
        expect(registrationRepository.lastInsert?.codSepararEstoque, equals(newSeparation.codSepararEstoque));
      });
    });

    group('Mecanismo de Retry', () {
      test('deve fazer retry quando atribuição falhar na primeira tentativa', () async {
        final newSeparation1 = createMockNewSeparation(codSepararEstoque: 301);
        final newSeparation2 = createMockNewSeparation(codSepararEstoque: 302);

        // Configurar repositório para retornar separações diferentes
        consultationRepository.setNewSeparations([newSeparation1, newSeparation2]);

        // Falha na primeira tentativa, sucesso na segunda
        registrationRepository.setShouldFailFirstTime(true);

        final params = _createValidParams();
        final result = await useCase.call(params);

        // Deve tentar registrar 2 vezes (falhou na primeira, retryou)
        expect(registrationRepository.insertCount, equals(2));

        // Deve ter retornado a segunda separação (porque a primeira falhou)
        if (result.isSuccess()) {
          final success = result.getOrNull()!;
          expect(success.hasSeparation, isTrue);
          expect(success.separation!.codSepararEstoque, equals(302));
        }
      });

      test('deve parar após máximo de tentativas', () async {
        consultationRepository.setNewSeparations([
          createMockNewSeparation(codSepararEstoque: 301),
          createMockNewSeparation(codSepararEstoque: 302),
          createMockNewSeparation(codSepararEstoque: 303),
        ]);

        // Sempre falha
        registrationRepository.setAlwaysFail(true);

        final params = _createValidParams();
        final result = await useCase.call(params);

        // Deve tentar no máximo 3 vezes (1 inicial + 2 retries)
        expect(registrationRepository.insertCount, lessThanOrEqualTo(3));

        // Deve retornar notFound
        expect(result.isSuccess(), isTrue);
        final success = result.getOrNull()!;
        expect(success.hasSeparation, isFalse);
      });

      test('deve retornar null quando não há mais separações após retry', () async {
        final newSeparation = createMockNewSeparation();
        consultationRepository.setNewSeparations([newSeparation]);

        // Atribuição falha
        registrationRepository.setAlwaysFail(true);

        final params = _createValidParams();
        final result = await useCase.call(params);

        expect(result.isSuccess(), isTrue);
        final success = result.getOrNull()!;
        expect(success.hasSeparation, isFalse);
      });
    });

    group('Precedência de Prioridades', () {
      test('PRIORIDADE 1 tem precedência sobre PRIORIDADE 2', () async {
        final completedSeparation = createMockCompletedSeparation(
          codUsuario: 1,
          nomeUsuario: 'Test User',
          codSepararEstoque: 100,
        );
        final pendingSeparation = createMockSeparationWithPendingItems(
          codUsuario: 1,
          nomeUsuario: 'Test User',
          codSepararEstoque: 200,
        );

        consultationRepository.setCompletedSeparation(completedSeparation);
        consultationRepository.setPendingItemsSeparation(pendingSeparation);

        final params = _createValidParams();
        final result = await useCase.call(params);

        final success = result.getOrNull()!;
        expect(success.separation!.codSepararEstoque, equals(200)); // PRIORIDADE 1 (pendentes)
      });

      test('PRIORIDADE 1 (pendentes) tem precedência sobre PRIORIDADE 3', () async {
        final pendingSeparation = createMockSeparationWithPendingItems(
          codUsuario: 1,
          nomeUsuario: 'Test User',
          codSepararEstoque: 200,
        );
        final newSeparation = createMockNewSeparation(codSepararEstoque: 300);

        consultationRepository.setPendingItemsSeparation(pendingSeparation);
        consultationRepository.setNewSeparation(newSeparation);

        final params = _createValidParams();
        final result = await useCase.call(params);

        final success = result.getOrNull()!;
        expect(success.separation!.codSepararEstoque, equals(200)); // PRIORIDADE 1 (pendentes)
      });

      test('quando PRIORIDADE 1 não existe, usa PRIORIDADE 2', () async {
        final pendingSeparation = createMockSeparationWithPendingItems(codUsuario: 1, nomeUsuario: 'Test User');

        consultationRepository.setPendingItemsSeparation(pendingSeparation);

        final params = _createValidParams();
        final result = await useCase.call(params);

        final success = result.getOrNull()!;
        expect(success.separation!.codSepararEstoque, equals(pendingSeparation.codSepararEstoque));
      });

      test('quando PRIORIDADE 1 e 2 não existem, usa PRIORIDADE 3', () async {
        final newSeparation = createMockNewSeparation();
        consultationRepository.setNewSeparation(newSeparation);

        final params = _createValidParams();
        final result = await useCase.call(params);

        final success = result.getOrNull()!;
        expect(success.separation!.codSepararEstoque, equals(newSeparation.codSepararEstoque));
      });
    });

    group('Cenários de Não Encontrado', () {
      test('deve retornar notFound quando não há separações', () async {
        // Nenhuma separação configurada

        final params = _createValidParams();
        final result = await useCase.call(params);

        expect(result.isSuccess(), isTrue);
        final success = result.getOrNull()!;
        expect(success.hasSeparation, isFalse);
        expect(success.message, equals('Não existe separação pendente para este usuário'));
      });
    });

    group('Tratamento de Erros', () {
      test('deve retornar erro quando repositório lançar DataError', () async {
        consultationRepository.setError(DataError(message: 'Erro de conexão'));

        final params = _createValidParams();
        final result = await useCase.call(params);

        expect(result.isError(), isTrue);
        final failure = result.exceptionOrNull() as NextSeparationUserFailure;
        expect(failure.type, equals(NextSeparationUserFailureType.networkError));
      });

      test('deve retornar erro quando ocorrer exceção genérica', () async {
        consultationRepository.setError(Exception('Erro inesperado'));

        final params = _createValidParams();
        final result = await useCase.call(params);

        expect(result.isError(), isTrue);
        final failure = result.exceptionOrNull() as NextSeparationUserFailure;
        expect(failure.type, equals(NextSeparationUserFailureType.unknownError));
      });
    });
  });
}

// Helpers para criar parâmetros e mocks

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
    nomeLocalArmazenagem: 'Armazém Teste',
    codContaFinanceira: '001',
    nomeContaFinanceira: 'Conta Teste',
    nomeCaixaOperador: 'Caixa Teste',
    permiteSepararForaSequencia: Situation.ativo,
    visualizaTodasSeparacoes: Situation.ativo,
    expedicaoObrigaEscanearPrateleira: Situation.inativo,
    permiteConferirForaSequencia: Situation.ativo,
    visualizaTodasConferencias: Situation.ativo,
    codSetorConferencia: 100,
    nomeSetorConferencia: 'Setor Conferência',
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

// Funções de criação de mocks de separação

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
    quantidadeItensSeparacaoSetor: 10.0, // 100% separado
    carrinhosAbertosUsuario: 'N', // Sem carrinhos abertos
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
    quantidadeItensSeparacaoSetor: 5.0, // 50% separado
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
    codUsuario: null, // Disponível
    nomeUsuario: null,
    estacaoSeparacao: null,
  );
}

// Fake implementations

class _FakeSeparationUserSectorConsultationRepository
    implements BasicConsultationRepository<SeparationUserSectorConsultationModel> {
  SeparationUserSectorConsultationModel? _completedSeparation;
  SeparationUserSectorConsultationModel? _pendingItemsSeparation;
  final List<SeparationUserSectorConsultationModel> _newSeparations = [];
  Object? _error;
  int _callCount = 0;

  void setCompletedSeparation(SeparationUserSectorConsultationModel separation) {
    _completedSeparation = separation;
  }

  void setPendingItemsSeparation(SeparationUserSectorConsultationModel separation) {
    _pendingItemsSeparation = separation;
  }

  void setNewSeparation(SeparationUserSectorConsultationModel separation) {
    _newSeparations.clear();
    _newSeparations.add(separation);
  }

  void setNewSeparations(List<SeparationUserSectorConsultationModel> separations) {
    _newSeparations.clear();
    _newSeparations.addAll(separations);
  }

  void setError(Object error) {
    _error = error;
  }

  void reset() {
    _callCount = 0;
  }

  @override
  Future<List<SeparationUserSectorConsultationModel>> selectConsultation(dynamic queryBuilder) async {
    _callCount++;
    if (_error != null) {
      throw _error!;
    }

    // PRIORIDADE 1: Primeira consulta (busca separação com itens/carrinhos pendentes)
    // PRIORIDADE 2: Segunda consulta (busca separação 100% completada)
    // PRIORIDADE 3: Terceira consulta em diante (busca nova separação)

    if (_callCount == 1 && _pendingItemsSeparation != null) {
      return [_pendingItemsSeparation!];
    }

    if (_callCount == 2 && _completedSeparation != null) {
      return [_completedSeparation!];
    }

    if (_callCount >= 3 && _newSeparations.isNotEmpty) {
      final result = _newSeparations.first;
      _newSeparations.removeAt(0);
      return [result];
    }

    return [];
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
  }

  @override
  Future<List<SeparationUserSectorModel>> select(QueryBuilder queryBuilder) async {
    return [];
  }

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
  Future<List<SeparationUserSectorModel>> update(SeparationUserSectorModel model) async {
    return [];
  }

  @override
  Future<List<SeparationUserSectorModel>> delete(SeparationUserSectorModel model) async {
    return [];
  }

  int get insertCount => _insertCount;
  SeparationUserSectorModel? get lastInsert => _lastInsert;
}

class _FakeLogger implements ILogger {
  @override
  void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    // Do nothing for tests
  }

  @override
  void info(String message, {String? tag}) {
    // Do nothing for tests
  }

  @override
  void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    // Do nothing for tests
  }

  @override
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    // Do nothing for tests
  }

  @override
  void severe(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    // Do nothing for tests
  }
}
