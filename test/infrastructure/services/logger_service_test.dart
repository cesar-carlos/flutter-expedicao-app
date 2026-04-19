import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

import 'package:data7_expedicao/infrastructure/services/logger_service.dart';

void main() {
  // Bug latente anterior: o parametro `tag` era ignorado em
  // `info`/`debug` (e tambem nao chegava no output de
  // warning/error/severe). Estes testes garantem que o tag
  // aparece no `LogRecord.message` em todos os 5 niveis.
  group('LoggerService - tag agora chega ao output', () {
    late List<LogRecord> records;
    late StreamSubscription<LogRecord> sub;
    late LoggerService service;

    setUp(() {
      records = <LogRecord>[];
      Logger.root.level = Level.ALL;
      sub = Logger.root.onRecord.listen(records.add);
      service = LoggerService(name: 'TestLogger');
    });

    tearDown(() async {
      await sub.cancel();
    });

    test('debug com tag aparece como "[tag] message"', () {
      service.debug('hello', tag: 'MyTag');
      expect(records, hasLength(1));
      expect(records.single.message, equals('[MyTag] hello'));
      expect(records.single.level, equals(Level.FINE));
    });

    test('info com tag aparece como "[tag] message"', () {
      service.info('hello', tag: 'MyTag');
      expect(records, hasLength(1));
      expect(records.single.message, equals('[MyTag] hello'));
      expect(records.single.level, equals(Level.INFO));
    });

    test('warning com tag aparece como "[tag] message"', () {
      service.warning('hello', tag: 'MyTag');
      expect(records, hasLength(1));
      expect(records.single.message, equals('[MyTag] hello'));
      expect(records.single.level, equals(Level.WARNING));
    });

    test('error com tag aparece como "[tag] message"', () {
      service.error('hello', tag: 'MyTag');
      expect(records, hasLength(1));
      expect(records.single.message, equals('[MyTag] hello'));
      expect(records.single.level, equals(Level.SEVERE));
    });

    test('severe com tag aparece como "[tag] message"', () {
      service.severe('hello', tag: 'MyTag');
      expect(records, hasLength(1));
      expect(records.single.message, equals('[MyTag] hello'));
      expect(records.single.level, equals(Level.SHOUT));
    });

    test('sem tag, mensagem nao tem prefixo', () {
      service.info('hello');
      expect(records, hasLength(1));
      expect(records.single.message, equals('hello'));
    });

    test('tag vazio nao adiciona prefixo "[]"', () {
      service.info('hello', tag: '');
      expect(records, hasLength(1));
      expect(records.single.message, equals('hello'));
    });

    test('error/stackTrace sao propagados ao Logger', () {
      final err = Exception('boom');
      final stack = StackTrace.current;
      service.warning('msg', tag: 'T', error: err, stackTrace: stack);
      expect(records, hasLength(1));
      expect(records.single.error, equals(err));
      expect(records.single.stackTrace, equals(stack));
    });
  });
}
