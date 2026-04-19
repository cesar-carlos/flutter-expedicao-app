import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/validation/schemas/model_schema/create_user_request_schema.dart';

void main() {
  // NOTA: Zard exige todas as chaves do schema mesmo as `optional()`
  // — bug aparente quando `.optional()` precede `.transform()`/`.refine()`.
  // Workaround: passar '' explicitamente. Testes focam apenas em
  // verificar a regex de email (foco da rodada).
  Map<String, dynamic> baseValid({String email = ''}) => {
    'Nome': 'Joao Silva',
    'Username': 'joao',
    'Password': '1234',
    'Email': email,
    'Telefone': '',
    'FotoUsuario': '',
  };

  group('CreateUserRequestSchema - regex de email', () {
    test('aceita emails com TLDs comuns', () {
      expect(() => CreateUserRequestSchema.validate(baseValid(email: 'a@b.com')), returnsNormally);
      expect(() => CreateUserRequestSchema.validate(baseValid(email: 'user@domain.org')), returnsNormally);
      expect(() => CreateUserRequestSchema.validate(baseValid(email: 'user.name@domain.co.uk')), returnsNormally);
    });

    test('aceita emails com TLDs > 4 caracteres (regressao)', () {
      // Bug latente anterior: regex `[\w-]{2,4}` no TLD rejeitava
      // dominios validos modernos. Estes devem passar agora.
      expect(() => CreateUserRequestSchema.validate(baseValid(email: 'user@example.travel')), returnsNormally);
      expect(() => CreateUserRequestSchema.validate(baseValid(email: 'user@example.museum')), returnsNormally);
      expect(() => CreateUserRequestSchema.validate(baseValid(email: 'user@example.design')), returnsNormally);
    });

    test('aceita emails com TLD multi-segmento (.com.br)', () {
      expect(() => CreateUserRequestSchema.validate(baseValid(email: 'user@empresa.com.br')), returnsNormally);
    });

    test('aceita email vazio (campo opcional)', () {
      expect(() => CreateUserRequestSchema.validate(baseValid()), returnsNormally);
      expect(() => CreateUserRequestSchema.validate(baseValid(email: '   ')), returnsNormally);
    });

    test('rejeita emails malformados', () {
      expect(() => CreateUserRequestSchema.validate(baseValid(email: 'invalid')), throwsA(isA<String>()));
      expect(() => CreateUserRequestSchema.validate(baseValid(email: 'user@')), throwsA(isA<String>()));
      expect(() => CreateUserRequestSchema.validate(baseValid(email: '@domain.com')), throwsA(isA<String>()));
      expect(() => CreateUserRequestSchema.validate(baseValid(email: 'user@domain')), throwsA(isA<String>()));
    });
  });
}
