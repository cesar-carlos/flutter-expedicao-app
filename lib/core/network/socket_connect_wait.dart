import 'dart:async';

Future<void> waitForSocketConnect({
  required Completer<void> wait,
  required Duration timeout,
  required void Function() onTimeout,
}) async {
  if (wait.isCompleted) {
    return wait.future;
  }

  final timer = Timer(timeout, () {
    if (wait.isCompleted) {
      return;
    }
    wait.completeError(TimeoutException('Conexão não estabelecida em ${timeout.inSeconds}s'));
    onTimeout();
  });

  try {
    await wait.future;
  } finally {
    timer.cancel();
  }
}
