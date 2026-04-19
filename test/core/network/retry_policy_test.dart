import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/network/retry_policy.dart';

void main() {
  group('RetryPolicy - construtor const (sem jitter real)', () {
    test('execute com sucesso na primeira tentativa', () async {
      const policy = RetryPolicy(maxAttempts: 3, initialDelay: Duration(milliseconds: 1));

      var calls = 0;
      final result = await policy.execute(() async {
        calls++;
        return 'ok';
      });

      expect(result, equals('ok'));
      expect(calls, equals(1));
    });

    test('retenta ate sucesso', () async {
      const policy = RetryPolicy(maxAttempts: 3, initialDelay: Duration(milliseconds: 1));

      var calls = 0;
      final result = await policy.execute(() async {
        calls++;
        if (calls < 3) throw Exception('falha $calls');
        return 'ok';
      });

      expect(result, equals('ok'));
      expect(calls, equals(3));
    });

    test('falha apos esgotar tentativas re-lanca o ultimo erro', () async {
      const policy = RetryPolicy(maxAttempts: 2, initialDelay: Duration(milliseconds: 1));

      var calls = 0;
      Object? caught;
      try {
        await policy.execute(() async {
          calls++;
          throw Exception('falha $calls');
        });
      } catch (e) {
        caught = e;
      }

      expect(calls, equals(2));
      expect(caught, isA<Exception>());
      expect(caught.toString(), contains('falha 2'));
    });
  });

  group('RetryPolicy - validacao (Bug P)', () {
    test('maxAttempts <= 0 lanca ArgumentError', () async {
      const policy = RetryPolicy(maxAttempts: 0, initialDelay: Duration(milliseconds: 1));

      expect(
        () => policy.execute(() async => 'nunca chega aqui'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('RetryPolicy - shouldRetry (Bug Q)', () {
    test('shouldRetry=false faz fail-fast sem retry', () async {
      var calls = 0;
      final policy = RetryPolicy.withJitter(
        maxAttempts: 5,
        initialDelay: const Duration(milliseconds: 1),
        shouldRetry: (e) => e is! StateError, // StateError = nao retentar
      );

      Object? caught;
      try {
        await policy.execute(() async {
          calls++;
          throw StateError('erro de pre-condicao');
        });
      } catch (e) {
        caught = e;
      }

      expect(calls, equals(1), reason: 'deve falhar imediatamente sem retry');
      expect(caught, isA<StateError>());
    });

    test('shouldRetry=true mantem retry normal', () async {
      var calls = 0;
      final policy = RetryPolicy.withJitter(
        maxAttempts: 3,
        initialDelay: const Duration(milliseconds: 1),
        shouldRetry: (e) => e is Exception, // Exception = retentar
      );

      try {
        await policy.execute(() async {
          calls++;
          throw Exception('rede caiu');
        });
      } catch (_) {}

      expect(calls, equals(3));
    });

    test('sem shouldRetry, retenta tudo (default)', () async {
      var calls = 0;
      const policy = RetryPolicy(maxAttempts: 3, initialDelay: Duration(milliseconds: 1));

      try {
        await policy.execute(() async {
          calls++;
          throw StateError('erro');
        });
      } catch (_) {}

      expect(calls, equals(3));
    });
  });

  group('RetryPolicy.withJitter - jitter aleatorio (Bug R)', () {
    test('com Random determinístico, jitter eh reproduzível', () {
      final policy = RetryPolicy.withJitter(
        initialDelay: const Duration(milliseconds: 1000),
        random: math.Random(42),
      );

      final delays = List.generate(5, (i) => policy.getDelayForAttemptWithJitter(1));
      // Com random determinístico, valores sao reproduziveis (mas variam
      // entre chamadas porque cada nextDouble() consome do gerador).
      expect(delays.toSet().length, greaterThan(1), reason: 'jitter deve variar entre chamadas');
    });

    test('jitter mantem valores entre 50% e 150% do delay base', () {
      final policy = RetryPolicy.withJitter(
        initialDelay: const Duration(milliseconds: 1000),
      );

      // 100 amostras devem todas estar dentro do range
      for (var i = 0; i < 100; i++) {
        final delay = policy.getDelayForAttemptWithJitter(1);
        expect(delay.inMilliseconds, greaterThanOrEqualTo(500));
        expect(delay.inMilliseconds, lessThanOrEqualTo(1500));
      }
    });

    test('attempt=0 retorna Duration.zero (sem retry agendado)', () {
      final policy = RetryPolicy.withJitter(initialDelay: const Duration(seconds: 1));
      expect(policy.getDelayForAttemptWithJitter(0), equals(Duration.zero));
    });
  });

  group('RetryPolicy - backoff exponencial', () {
    test('aplica multiplier corretamente', () {
      const policy = RetryPolicy(
        initialDelay: Duration(milliseconds: 100),
        backoffMultiplier: 2.0,
      );

      expect(policy.getDelayForAttempt(1).inMilliseconds, equals(100));
      expect(policy.getDelayForAttempt(2).inMilliseconds, equals(200));
      expect(policy.getDelayForAttempt(3).inMilliseconds, equals(400));
      expect(policy.getDelayForAttempt(4).inMilliseconds, equals(800));
    });

    test('cap em maxDelay', () {
      const policy = RetryPolicy(
        initialDelay: Duration(milliseconds: 100),
        backoffMultiplier: 10.0,
        maxDelay: Duration(milliseconds: 500),
      );

      expect(policy.getDelayForAttempt(2).inMilliseconds, equals(500), reason: '1000ms capped to 500ms');
      expect(policy.getDelayForAttempt(5).inMilliseconds, equals(500), reason: 'sempre capped');
    });
  });
}
