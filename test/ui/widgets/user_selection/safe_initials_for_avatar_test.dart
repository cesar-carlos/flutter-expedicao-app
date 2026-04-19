import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/ui/widgets/user_selection/users_list_widget.dart';

void main() {
  // Bug latente anterior: `nomeUsuario.substring(0, 2)` crashava com
  // RangeError se o nome tivesse < 2 chars. Garantia de degrade
  // graceful para o avatar.
  group('safeInitialsForAvatar', () {
    test('string vazia retorna "?"', () {
      expect(safeInitialsForAvatar(''), equals('?'));
    });

    test('apenas espacos retorna "?"', () {
      expect(safeInitialsForAvatar('   '), equals('?'));
    });

    test('1 char retorna o char em maiusculas (sem RangeError)', () {
      expect(safeInitialsForAvatar('a'), equals('A'));
      expect(safeInitialsForAvatar('Z'), equals('Z'));
    });

    test('2 chars retorna ambos em maiusculas', () {
      expect(safeInitialsForAvatar('jo'), equals('JO'));
      expect(safeInitialsForAvatar('AB'), equals('AB'));
    });

    test('nome longo retorna apenas primeiros 2 chars em maiusculas', () {
      expect(safeInitialsForAvatar('Joao Silva'), equals('JO'));
      expect(safeInitialsForAvatar('Maria'), equals('MA'));
    });

    test('faz trim antes de extrair', () {
      expect(safeInitialsForAvatar('  Joao  '), equals('JO'));
      expect(safeInitialsForAvatar('  A  '), equals('A'));
    });

    test('lida com chars especiais sem crash', () {
      expect(safeInitialsForAvatar('Ó'), equals('Ó'));
      expect(safeInitialsForAvatar('ãe'), equals('ÃE'));
    });
  });
}
