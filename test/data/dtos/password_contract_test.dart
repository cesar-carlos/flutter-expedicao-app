import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/validation/forms/form_validators.dart';
import 'package:data7_expedicao/core/validation/schemas/model_schema/create_user_request_schema.dart';
import 'package:data7_expedicao/core/validation/schemas/model_schema/login_request_schema.dart';
import 'package:data7_expedicao/data/dtos/create_user_dto.dart';
import 'package:data7_expedicao/data/dtos/login_dto.dart';
import 'package:data7_expedicao/presentation/viewmodels/register_viewmodel.dart';

void main() {
  for (final length in [4, 20, 21, 60]) {
    test('should consistently validate password length $length while preserving lowercase normalization', () async {
      final password = 'A' * length;
      final valid = length <= 20;
      final login = LoginDto(nome: 'user', senha: password);
      final create = CreateUserDto(nome: 'user', senha: password);
      final vm = RegisterViewModel();
      addTearDown(vm.dispose);
      expect(login.isValid, valid);
      expect(create.isValid, valid);
      expect(FormValidators.password(password) == null, valid);
      expect(vm.validateForm(name: 'user', password: password, confirmPassword: password), valid);
      expect(LoginRequestSchema.safeValidate({'username': 'user', 'password': password}).isSuccess(), valid);
      expect(
        CreateUserRequestSchema.safeValidate({
          'Nome': 'user',
          'Username': 'user',
          'Password': password,
          'Email': '',
          'Telefone': '',
          'FotoUsuario': '',
        }).isSuccess(),
        valid,
      );
      expect(login.toApiRequest()['Senha'], password.toLowerCase());
      expect((await create.toApiRequest())['Senha'], password.toLowerCase());
    });
  }
  test('should keep the existing minimum password length', () {
    expect(FormValidators.password('abc'), contains('4 caracteres'));
    expect(CreateUserDto(nome: 'user', senha: 'abc').isValid, isFalse);
    expect(LoginDto(nome: 'user', senha: 'abc').isValid, isFalse);
  });
}
