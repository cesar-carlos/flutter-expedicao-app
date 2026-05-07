import 'dart:io';

void main() {
  const roots = <String>['lib', 'test', 'integration_test'];
  const forbidden = '\u00c3\u0192\u00c2';

  final violations = <String>[];

  for (final root in roots) {
    final dir = Directory(root);
    if (!dir.existsSync()) {
      continue;
    }

    final dartFiles = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).where((f) {
      final p = f.uri.pathSegments;
      return !p.contains('.dart_tool') && !p.contains('build');
    });

    for (final file in dartFiles) {
      final text = file.readAsStringSync();
      if (text.contains(forbidden)) {
        violations.add(file.path);
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('OK: no double-encoded UTF-8 mojibake pattern found.');
    exit(0);
  }

  stderr.writeln('UTF-8 mojibake pattern detected (likely double-encoded source). Fix files:');
  for (final path in violations) {
    stderr.writeln('  $path');
  }
  exit(1);
}
