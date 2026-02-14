import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:result_dart/result_dart.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/user/app_user.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/usecases/resolve_separation_user_link/resolve_separation_user_link_params.dart';
import 'package:data7_expedicao/domain/usecases/resolve_separation_user_link/resolve_separation_user_link_usecase.dart';
import 'package:data7_expedicao/domain/viewmodels/separation_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/socket_viewmodel.dart';
import 'package:data7_expedicao/ui/screens/separation_screen.dart';
import 'package:data7_expedicao/data/services/filters_storage_service.dart';
import 'package:data7_expedicao/domain/models/expedition_sector_stock_model.dart';
import 'package:data7_expedicao/domain/models/filter/separation_filters_model.dart';
import 'package:data7_expedicao/domain/repositories/separate_event_repository.dart';
import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/core/services/notification_service.dart';
import 'package:data7_expedicao/data/services/user_session_service.dart';

import 'separation_screen_not_linked_test.mocks.dart';

@GenerateMocks([
  BasicConsultationRepository,
  BasicRepository,
  FiltersStorageService,
  SeparateEventRepository,
  AudioService,
  NotificationService,
  UserSessionService,
  ResolveSeparationUserLinkUseCase,
])
void main() {
  late MockBasicConsultationRepository<SeparateConsultationModel> mockRepository;
  late MockBasicRepository<ExpeditionSectorStockModel> mockSectorRepository;
  late MockFiltersStorageService mockFiltersStorage;
  late MockSeparateEventRepository mockEventRepository;
  late MockAudioService mockAudioService;
  late MockNotificationService mockNotificationService;
  late MockUserSessionService mockUserSessionService;
  late MockResolveSeparationUserLinkUseCase mockResolveUseCase;

  late SeparationViewModel viewModel;

  AppUser createAppUserWithSector({int codUsuario = 1, int codSetorEstoque = 10}) {
    final userSystemMap = <String, dynamic>{
      'CodUsuario': codUsuario,
      'CodSetorEstoque': codSetorEstoque,
      'NomeUsuario': 'Test User',
    };
    final userSystem = UserSystemModel.fromJson(userSystemMap);
    return AppUser(
      codLoginApp: 1,
      ativo: Situation.ativo,
      nome: 'Test',
      codUsuario: codUsuario,
      userSystemModel: userSystem,
    );
  }

  SeparateConsultationModel createSeparation({String codUsuariosSeparacao = '2'}) {
    return SeparateConsultationModel.fromJson({
      'CodEmpresa': 1,
      'CodSepararEstoque': 100,
      'Origem': 'SE',
      'CodOrigem': 1,
      'CodTipoOperacaoExpedicao': 1,
      'NomeTipoOperacaoExpedicao': 'Op Test',
      'Situacao': 'AGUARDANDO',
      'TipoEntidade': 'C',
      'DataEmissao': '2024-01-15',
      'HoraEmissao': '10:00',
      'CodEntidade': 1,
      'NomeEntidade': 'Ent Test',
      'CodPrioridade': 1,
      'NomePrioridade': 'Normal',
      'CodSetoresEstoque': '1',
      'CodUsuariosSeparacao': codUsuariosSeparacao,
    });
  }

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    provideDummy<Result<bool>>(Success(false));
    if (!GetIt.I.isRegistered<BasicConsultationRepository<SeparateConsultationModel>>()) {
      setupLocator();
    }
  });

  setUp(() {
    mockRepository = MockBasicConsultationRepository<SeparateConsultationModel>();
    mockSectorRepository = MockBasicRepository<ExpeditionSectorStockModel>();
    mockFiltersStorage = MockFiltersStorageService();
    mockEventRepository = MockSeparateEventRepository();
    mockAudioService = MockAudioService();
    mockNotificationService = MockNotificationService();
    mockUserSessionService = MockUserSessionService();
    mockResolveUseCase = MockResolveSeparationUserLinkUseCase();

    when(mockFiltersStorage.loadSeparationFilters()).thenAnswer((_) async => const SeparationFiltersModel());
    when(mockFiltersStorage.saveSeparationFilters(any)).thenAnswer((_) async {});
    when(mockEventRepository.listeners).thenReturn([]);
    when(mockEventRepository.hasListener(any)).thenReturn(false);

    when(mockRepository.selectConsultation(any)).thenAnswer((_) async => [createSeparation()]);

    viewModel = SeparationViewModel.withDependencies(
      mockRepository,
      mockFiltersStorage,
      mockSectorRepository,
      mockEventRepository,
      mockAudioService,
      mockNotificationService,
    );

    GetIt.I.pushNewScope(
      init: (GetIt scope) {
        scope.registerSingleton<UserSessionService>(mockUserSessionService);
        scope.registerSingleton<ResolveSeparationUserLinkUseCase>(mockResolveUseCase);
      },
    );

    when(mockUserSessionService.loadUserSession()).thenAnswer((_) async => createAppUserWithSector());
    when(mockResolveUseCase.call(any)).thenAnswer((_) async => Success(false));
  });

  tearDown(() {
    viewModel.dispose();
    GetIt.I.popScope();
  });

  testWidgets('when user has sector and separation is not linked tapping Abrir Separação shows SnackBar and does not navigate', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<SeparationViewModel>.value(value: viewModel),
            ChangeNotifierProvider<SocketViewModel>.value(
              value: locator<SocketViewModel>(),
            ),
          ],
          child: const SeparationScreen(),
        ),
      ),
    );

    viewModel.loadSeparations();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Abrir Separação'), findsOneWidget);
    await tester.tap(find.text('Abrir Separação'));
    await tester.pumpAndSettle();

    expect(find.text(UIConstants.separationNotAssignedToUserMessage), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
  });
}
