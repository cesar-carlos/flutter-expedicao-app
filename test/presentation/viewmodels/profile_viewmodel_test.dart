import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/user/user_models.dart';
import 'package:data7_expedicao/domain/repositories/user_repository.dart';
import 'package:data7_expedicao/presentation/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/profile_viewmodel.dart';

class _Auth extends Fake implements AuthViewModel {
  _Auth(this.currentUser);

  @override
  AppUser currentUser;

  @override
  Future<void> updateUserAfterSelection(AppUser user) async {
    currentUser = user;
  }
}

class _Repository extends Fake implements UserRepository {
  AppUser? sentUser;
  bool fail = false;

  @override
  Future<AppUserConsultation> putAppUser(AppUser user) async {
    sentUser = user;
    if (fail) throw UserApiException('Servidor indisponível', statusCode: 503);
    return AppUserConsultation.fromJson(user.toJson());
  }
}

void main() {
  late _Auth auth;
  late _Repository repository;
  late ProfileViewModel viewModel;

  setUp(() {
    auth = _Auth(AppUser(codLoginApp: 1, ativo: Situation.ativo, nome: 'Usuario', fotoUsuario: 'Zm90bw=='));
    repository = _Repository();
    viewModel = ProfileViewModel(repository, auth);
  });

  tearDown(() => viewModel.dispose());

  test('should send explicit null and clear the session photo when removal succeeds', () async {
    viewModel.setSelectedPhoto(null);
    expect(await viewModel.saveProfile(), isTrue);
    expect(repository.sentUser!.toJson(), containsPair('FotoUsuario', null));
    expect(auth.currentUser.hasPhoto, isFalse);
    expect(auth.currentUser.codLoginApp, 1);
    expect(repository.sentUser!.toJson().containsKey('Senha'), isFalse);
  });

  test('should preserve the photo when saving without changing it', () async {
    expect(await viewModel.saveProfile(), isTrue);
    expect(repository.sentUser!.fotoUsuario, 'Zm90bw==');
    expect(auth.currentUser.fotoUsuario, 'Zm90bw==');
  });

  test('should preserve the session photo and expose failure when removal fails', () async {
    repository.fail = true;
    viewModel.setSelectedPhoto(null);
    expect(await viewModel.saveProfile(), isFalse);
    expect(auth.currentUser.fotoUsuario, 'Zm90bw==');
    expect(viewModel.state, ProfileState.error);
    expect(viewModel.errorMessage, contains('Servidor indisponível'));
  });

  test('should preserve copyWith compatibility and support explicit removal and replacement', () {
    final user = auth.currentUser;
    expect(user.copyWith().fotoUsuario, user.fotoUsuario);
    expect(user.copyWith(fotoUsuario: null).fotoUsuario, user.fotoUsuario);
    expect(user.copyWith(fotoUsuario: 'bm92YQ==').fotoUsuario, 'bm92YQ==');
    expect(user.copyWith(clearFotoUsuario: true).fotoUsuario, isNull);
  });
}
