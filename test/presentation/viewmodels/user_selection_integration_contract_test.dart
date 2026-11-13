import 'package:flutter_test/flutter_test.dart';
import 'package:data7_expedicao/domain/models/pagination/pagination.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/user/user_api_exception.dart';
import 'package:data7_expedicao/domain/models/user_system/user_system_list_page.dart';
import 'package:data7_expedicao/domain/repositories/user_repository.dart';
import 'package:data7_expedicao/domain/repositories/user_system_repository.dart';
import 'package:data7_expedicao/presentation/viewmodels/user_selection_viewmodel.dart';
import '../../mocks/user_system_model_mock.dart';

class _Users implements UserSystemRepository {
  late UserSystemListPage page;
  UserApiException? error;
  @override
  Future<UserSystemListPage> getUsers({int? codEmpresa, Situation? apenasAtivos, Pagination? pagination}) async {
    if (error case final failure?) throw failure;
    return page;
  }

  @override
  Future<UserSystemListPage> searchUsersByName(
    String nome, {
    int? codEmpresa,
    Situation apenasAtivos = Situation.ativo,
    Pagination? pagination,
  }) => getUsers();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Login implements UserRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('should expose partial data and keep pagination when received page is full', () async {
    final user = createTestUserSystem();
    final repo = _Users()..page = UserSystemListPage(users: [user], total: 30, success: true, invalidItemCount: 19);
    final vm = UserSelectionViewModel(repo, _Login());
    addTearDown(vm.dispose);
    await vm.loadAllUsers();
    expect(vm.users, [user]);
    expect(vm.errorMessage, contains('Lista incompleta'));
    expect(vm.hasMoreData, isTrue);
    expect(vm.isUserAvailable(user), isFalse);
    vm.selectUser(user);
    expect(vm.selectedUser, isNull);
  });

  test('should leave loading with an actionable error when user parsing fails', () async {
    final repo = _Users()..error = UserApiException('Resposta contém registros inválidos. Tente novamente.');
    final vm = UserSelectionViewModel(repo, _Login());
    addTearDown(vm.dispose);
    await vm.searchUsers('Joao');
    expect(vm.state, UserSelectionState.loaded);
    expect(vm.errorMessage, repo.error!.message);
    expect(vm.users, isEmpty);
  });
}
