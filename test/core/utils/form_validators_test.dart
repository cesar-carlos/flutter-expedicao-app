import 'package:flutter_test/flutter_test.dart';
import 'package:data7_expedicao/core/validation/forms/form_validators.dart';

void main() {
  group('FormValidators - Zard Integration Tests', () {
    group('Username Validation', () {
      test('should return null for valid username', () {
        expect(FormValidators.username('valid_user'), isNull);
        expect(FormValidators.username('user123'), isNull);
      });

      test('should return error for empty username', () {
        expect(FormValidators.username(''), isNotNull);
        expect(FormValidators.username(null), isNotNull);
        expect(FormValidators.username('   '), isNotNull);
      });
    });

    group('Password Validation', () {
      test('should return null for valid password', () {
        expect(FormValidators.password('1234'), isNull);
        expect(FormValidators.password('password123'), isNull);
      });

      test('should return error for invalid password', () {
        expect(FormValidators.password(''), isNotNull);
        expect(FormValidators.password(null), isNotNull);
        expect(FormValidators.password('123'), isNotNull); // Too short
        expect(FormValidators.password('a' * 61), isNotNull); // Too long
      });
    });

    group('Email Validation', () {
      test('should return null for valid email', () {
        expect(FormValidators.email('test@example.com'), isNull);
        expect(FormValidators.email('user.name@domain.co.uk'), isNull);
      });

      test('should return error for invalid email', () {
        expect(FormValidators.email(''), isNotNull);
        expect(FormValidators.email(null), isNotNull);
        expect(FormValidators.email('invalid-email'), isNotNull);
        expect(FormValidators.email('test@'), isNotNull);
        expect(FormValidators.email('@domain.com'), isNotNull);
      });
    });

    group('Name Validation', () {
      test('should return null for valid name', () {
        expect(FormValidators.name('João Silva'), isNull);
        expect(FormValidators.name('Ana'), isNull);
      });

      test('should return error for invalid name', () {
        expect(FormValidators.name(''), isNotNull);
        expect(FormValidators.name(null), isNotNull);
        expect(FormValidators.name('   '), isNotNull);
        expect(FormValidators.name('A' * 31), isNotNull); // Too long
      });
    });

    group('Confirm Password Validation', () {
      test('should return null when passwords match', () {
        expect(FormValidators.confirmPassword('password', 'password'), isNull);
      });

      test('should return error when passwords do not match', () {
        expect(FormValidators.confirmPassword('password1', 'password2'), isNotNull);
        expect(FormValidators.confirmPassword('', 'password'), isNotNull);
        expect(FormValidators.confirmPassword(null, 'password'), isNotNull);
      });

      test('should return error when original password is null', () {
        expect(FormValidators.confirmPassword('password', null), isNotNull);
      });
    });

    group('Numeric Validation', () {
      test('should return null for valid numbers', () {
        expect(FormValidators.numeric('123'), isNull);
        expect(FormValidators.numeric('123.45'), isNull);
        expect(FormValidators.numeric('-123'), isNull);
      });

      test('should return error for invalid numbers', () {
        expect(FormValidators.numeric(''), isNotNull);
        expect(FormValidators.numeric(null), isNotNull);
        expect(FormValidators.numeric('abc'), isNotNull);
        expect(FormValidators.numeric('12.34.56'), isNotNull);
      });
    });

    group('Business Validators', () {
      test('codSepararEstoque should accept valid codes', () {
        expect(FormValidators.codSepararEstoque('123'), isNull);
        expect(FormValidators.codSepararEstoque(''), isNull); // Optional
        expect(FormValidators.codSepararEstoque(null), isNull); // Optional
      });

      test('codSepararEstoque should reject invalid codes', () {
        expect(FormValidators.codSepararEstoque('abc'), isNotNull);
        expect(FormValidators.codSepararEstoque('12.3'), isNotNull);
      });
    });

    group('Schema Validation', () {
      test('should validate login data correctly', () {
        final validLogin = {'username': 'testuser', 'password': 'password123'};

        expect(() => FormValidators.validateLogin(validLogin), returnsNormally);
      });

      test('should throw error for invalid login data', () {
        final invalidLogin = {
          'username': '',
          'password': '123', // Too short
        };

        expect(() => FormValidators.validateLogin(invalidLogin), throwsA(isA<String>()));
      });

      test('should safely parse login data', () {
        final validLogin = {'username': 'testuser', 'password': 'password123'};

        final result = FormValidators.safeParseLogin(validLogin);
        expect(result.success, isTrue);
        expect(result.data, isNotNull);
        expect(result.error, isNull);
      });

      test('should return error for invalid login in safe parse', () {
        final invalidLogin = {'username': '', 'password': '123'};

        final result = FormValidators.safeParseLogin(invalidLogin);
        expect(result.success, isFalse);
        expect(result.data, isNull);
        expect(result.error, isNotNull);
      });
    });

    group('Edge Cases - Guards manuais antes do schema', () {
      test('maxLength should accept null and empty (campo opcional)', () {
        expect(FormValidators.maxLength(null, 10), isNull);
        expect(FormValidators.maxLength('', 10), isNull);
      });

      test('maxLength should reject string acima do limite', () {
        expect(FormValidators.maxLength('a' * 11, 10), isNotNull);
      });

      test('maxLength should accept string dentro do limite', () {
        expect(FormValidators.maxLength('hello', 10), isNull);
      });

      test('apiUrl should return mensagem amigavel para null/empty', () {
        expect(FormValidators.apiUrl(null), contains('URL'));
        expect(FormValidators.apiUrl(''), contains('URL'));
        expect(FormValidators.apiUrl('   '), contains('URL'));
      });

      test('apiPort should return mensagem amigavel para null/empty', () {
        expect(FormValidators.apiPort(null), contains('porta'));
        expect(FormValidators.apiPort(''), contains('porta'));
      });

      test('apiPort should reject porta fora do range', () {
        expect(FormValidators.apiPort('0'), contains('1 e 65535'));
        expect(FormValidators.apiPort('65536'), contains('1 e 65535'));
        expect(FormValidators.apiPort('abc'), contains('1 e 65535'));
      });

      test('apiPort should accept porta valida', () {
        expect(FormValidators.apiPort('80'), isNull);
        expect(FormValidators.apiPort('8080'), isNull);
      });

      test('email should return mensagem amigavel para null/empty', () {
        expect(FormValidators.email(null), contains('email'));
        expect(FormValidators.email(''), contains('email'));
      });

      test('password should return mensagens amigaveis estaveis', () {
        expect(FormValidators.password(null), contains('senha'));
        expect(FormValidators.password(''), contains('senha'));
        expect(FormValidators.password('123'), contains('4 caracteres'));
        expect(FormValidators.password('a' * 61), contains('60 caracteres'));
      });
    });

    group('Utility Functions', () {
      test('parseIntSafely should work correctly', () {
        expect(FormValidators.parseIntSafely('123'), equals(123));
        expect(FormValidators.parseIntSafely('abc'), isNull);
        expect(FormValidators.parseIntSafely(''), isNull);
        expect(FormValidators.parseIntSafely(null), isNull);
      });

      test('parseDoubleSafely should work correctly', () {
        expect(FormValidators.parseDoubleSafely('123.45'), equals(123.45));
        expect(FormValidators.parseDoubleSafely('abc'), isNull);
        expect(FormValidators.parseDoubleSafely(''), isNull);
        expect(FormValidators.parseDoubleSafely(null), isNull);
      });

      test('normalizeString should work correctly', () {
        expect(FormValidators.normalizeString('  test  '), equals('test'));
        expect(FormValidators.normalizeString(''), isNull);
        expect(FormValidators.normalizeString('   '), isNull);
        expect(FormValidators.normalizeString(null), isNull);
      });
    });
  });
}
