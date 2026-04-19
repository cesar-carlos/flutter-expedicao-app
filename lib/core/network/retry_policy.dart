import 'dart:math' as math;

import 'package:data7_expedicao/core/utils/app_logger.dart';

/// Política de retry com backoff exponencial e jitter.
///
/// Características:
/// - Backoff exponencial: `initialDelay * backoffMultiplier^(attempt-1)`
/// - Cap em `maxDelay` para evitar esperas absurdas em testes longos
/// - Jitter aleatório (50%-150% do delay calculado) para evitar
///   "thundering herd" quando vários clientes falham simultaneamente
/// - `shouldRetry` opcional para filtrar erros que NÃO devem ser
///   retentados (ex.: validation, 4xx, StateError) — economiza tempo
///   do usuário e evita mascarar bugs de regra de negócio
class RetryPolicy {
  final int maxAttempts;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;

  /// Filtro opcional: retorna `true` se o erro deve ser retentado,
  /// `false` para falhar imediatamente sem retry.
  ///
  /// Default: retenta tudo (compatível com comportamento legado).
  final bool Function(Object error)? shouldRetry;

  /// Random source. Default é uma fonte const "zero" (sem jitter real)
  /// para preservar compatibilidade com construtor `const RetryPolicy(...)`.
  /// Para jitter real, use `RetryPolicy.withJitter(...)`.
  final math.Random _random;

  /// Construtor const compatível com call sites legados.
  /// **Não aplica jitter** (factor fixo = 1.5x do delay base).
  const RetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 30),
    this.shouldRetry,
  }) : _random = const _ZeroRandom();

  /// Construtor com jitter aleatório real (50%-150% do delay base).
  /// Use este em produção para evitar thundering herd. O `random`
  /// pode ser provido (ex.: `Random(seed)`) para testes determinísticos.
  RetryPolicy.withJitter({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 30),
    this.shouldRetry,
    math.Random? random,
  }) : _random = random ?? math.Random();

  /// Calcula o delay para a tentativa `attempt` (1-indexed) **sem jitter**.
  /// Útil para testes/inspeção. Use [getDelayForAttemptWithJitter] para
  /// o valor real aplicado pelo `execute`.
  Duration getDelayForAttempt(int attempt) {
    if (attempt <= 0) return Duration.zero;
    final ms = initialDelay.inMilliseconds * math.pow(backoffMultiplier, attempt - 1);
    final duration = Duration(milliseconds: ms.round());
    if (duration > maxDelay) return maxDelay;
    return duration;
  }

  /// Calcula o delay com jitter aleatório (50%-150%).
  /// Bug R: evita thundering herd quando varios clientes falham juntos.
  Duration getDelayForAttemptWithJitter(int attempt) {
    final base = getDelayForAttempt(attempt);
    if (base == Duration.zero) return Duration.zero;
    // Fator entre 0.5 e 1.5
    final factor = 0.5 + _random.nextDouble();
    final jittered = (base.inMilliseconds * factor).round();
    return Duration(milliseconds: jittered);
  }

  Future<T> execute<T>(Future<T> Function() operation, {String? tag}) async {
    // Bug P: validacao de maxAttempts (era posivel cair no `throw lastError`
    // sem nunca executar `operation` quando maxAttempts <= 0).
    if (maxAttempts <= 0) {
      throw ArgumentError.value(maxAttempts, 'maxAttempts', 'deve ser >= 1');
    }

    Object? lastError;
    StackTrace? lastStack;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final result = await operation();
        if (attempt > 1) {
          AppLogger.info('Retry bem-sucedido na tentativa $attempt', tag: tag ?? 'RetryPolicy');
        }
        return result;
      } catch (e, stack) {
        lastError = e;
        lastStack = stack;

        // Bug Q: filtro `shouldRetry` — alguns erros nao fazem sentido
        // retentar (validacao, 4xx, StateError de pre-condicao). Falhar
        // rapido economiza tempo do usuario e evita mascarar bugs.
        if (shouldRetry != null && !shouldRetry!(e)) {
          AppLogger.debug(
            'Erro nao-retentavel (shouldRetry=false) na tentativa $attempt: ${e.runtimeType}',
            tag: tag ?? 'RetryPolicy',
          );
          rethrow;
        }

        if (attempt == maxAttempts) {
          AppLogger.error(
            'Falha após $maxAttempts tentativas',
            tag: tag ?? 'RetryPolicy',
            error: e,
            stackTrace: stack,
          );
          rethrow;
        }
        final delay = getDelayForAttemptWithJitter(attempt);
        AppLogger.warning(
          'Tentativa $attempt/$maxAttempts falhou. Nova tentativa em ${delay.inMilliseconds}ms',
          tag: tag ?? 'RetryPolicy',
          error: e,
        );
        await Future<void>.delayed(delay);
      }
    }

    // Bug O: lastError nunca eh `Object()` agora — ou foi setado dentro
    // do loop (e re-lancado via rethrow), ou o for nem rodou (cobreto
    // pelo Bug P acima). Mas mantemos o throw como ultimo recurso para
    // satisfazer o type system.
    if (lastError != null && lastStack != null) {
      Error.throwWithStackTrace(lastError, lastStack);
    }
    throw StateError('RetryPolicy: estado inesperado apos loop sem rethrow');
  }
}

/// Random "zero" para o construtor const — sempre retorna 1.0,
/// resultando em jitter no MEIO do range (factor = 1.5).
/// Quem quiser jitter real deve usar o construtor não-const.
class _ZeroRandom implements math.Random {
  const _ZeroRandom();

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 1.0;

  @override
  int nextInt(int max) => 0;
}
