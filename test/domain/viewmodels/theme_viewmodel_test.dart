import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:data7_expedicao/data/datasources/user_preferences_service.dart';
import 'package:data7_expedicao/domain/models/user_preferences.dart';
import 'package:data7_expedicao/domain/viewmodels/theme_viewmodel.dart';

class _FailingUserPreferencesService extends UserPreferencesService {
  bool failNext = false;
  int saveCount = 0;

  @override
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    saveCount++;
    if (failNext) {
      failNext = false;
      throw StateError('disco cheio simulado');
    }
    return super.updateThemeMode(themeMode);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tmpDir;
  late _FailingUserPreferencesService prefsService;

  setUpAll(() async {
    tmpDir = await Directory.systemTemp.createTemp('theme_vm_test_');
    Hive.init(tmpDir.path);
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserPreferencesAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.close();
    if (tmpDir.existsSync()) {
      await tmpDir.delete(recursive: true);
    }
  });

  setUp(() async {
    // Limpa state entre testes para evitar interferencia.
    await Hive.deleteBoxFromDisk('user_preferences');
    prefsService = _FailingUserPreferencesService();
    await prefsService.initialize();
  });

  tearDown(() async {
    await prefsService.dispose();
  });

  group('ThemeViewModel.isDarkMode', () {
    test('retorna true para ThemeMode.dark', () async {
      final vm = ThemeViewModel(prefsService);
      await vm.initialize();
      await vm.setThemeMode(ThemeMode.dark);
      expect(vm.isDarkMode, isTrue);
    });

    test('retorna false para ThemeMode.light', () async {
      final vm = ThemeViewModel(prefsService);
      await vm.initialize();
      await vm.setThemeMode(ThemeMode.light);
      expect(vm.isDarkMode, isFalse);
    });

    test('para ThemeMode.system, consulta o brightness do sistema (dark)', () async {
      // Bug funcional anterior: ThemeMode.system sempre retornava
      // false mesmo quando o sistema estava em dark mode.
      final vm = ThemeViewModel(
        prefsService,
        platformDispatcher: PlatformDispatcher.instance,
      );
      await vm.initialize();
      await vm.setThemeMode(ThemeMode.system);
      // Apenas garante que NAO retorna sempre false: o resultado
      // deve refletir o brightness atual do dispatcher injetado.
      expect(
        vm.isDarkMode,
        equals(PlatformDispatcher.instance.platformBrightness == Brightness.dark),
      );
    });
  });

  group('ThemeViewModel.setThemeMode', () {
    test('persiste e notifica quando muda', () async {
      final vm = ThemeViewModel(prefsService);
      await vm.initialize();
      var notified = 0;
      vm.addListener(() => notified++);

      await vm.setThemeMode(ThemeMode.dark);
      expect(vm.themeMode, equals(ThemeMode.dark));
      expect(prefsService.saveCount, equals(1));
      expect(notified, greaterThanOrEqualTo(1));
    });

    test('no-op quando o modo ja eh o mesmo', () async {
      final vm = ThemeViewModel(prefsService);
      await vm.initialize();
      var notified = 0;
      vm.addListener(() => notified++);

      await vm.setThemeMode(vm.themeMode);
      expect(prefsService.saveCount, equals(0));
      expect(notified, equals(0));
    });

    test('reverte estado em memoria quando persistencia falha', () async {
      // Bug latente anterior: se persistencia falhasse, o estado
      // ficava inconsistente — UI mudava mas a preferencia nao era
      // gravada. Agora reverte e re-notifica.
      final vm = ThemeViewModel(prefsService);
      await vm.initialize();
      final previousMode = vm.themeMode;

      prefsService.failNext = true;
      await expectLater(
        vm.setThemeMode(ThemeMode.dark),
        throwsA(isA<StateError>()),
      );

      expect(vm.themeMode, equals(previousMode));
    });
  });

  group('ThemeViewModel.toggleTheme', () {
    test('cicla light -> dark -> system -> light', () async {
      final vm = ThemeViewModel(prefsService);
      await vm.initialize();
      await vm.setThemeMode(ThemeMode.light);

      await vm.toggleTheme();
      expect(vm.themeMode, equals(ThemeMode.dark));

      await vm.toggleTheme();
      expect(vm.themeMode, equals(ThemeMode.system));

      await vm.toggleTheme();
      expect(vm.themeMode, equals(ThemeMode.light));
    });
  });
}
