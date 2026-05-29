import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/models/pagination/pagination.dart';
import 'package:data7_expedicao/domain/models/user_system/user_system_list_page.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';

abstract class UserSystemRepository {
  Future<Map<String, dynamic>> getUserSystemInfo(int codUsuario);

  Future<UserSystemListPage> getUsers({int? codEmpresa, Situation? apenasAtivos, Pagination? pagination});

  Future<UserSystemModel?> getUserById(int codUsuario);

  Future<UserSystemListPage> searchUsersByName(
    String nome, {
    int? codEmpresa,
    Situation apenasAtivos = Situation.ativo,
    Pagination? pagination,
  });
}
