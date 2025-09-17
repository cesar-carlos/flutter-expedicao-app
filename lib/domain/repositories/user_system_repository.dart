import 'package:exp/domain/models/user_system_models.dart';
import 'package:exp/domain/models/pagination/pagination.dart';

abstract class UserSystemRepository {
  Future<Map<String, dynamic>> getUserSystemInfo(int codUsuario);

  Future<UserSystemListResponse> getUsers({
    int? codEmpresa,
    bool? apenasAtivos,
    Pagination? pagination,
  });

  Future<UserSystemModel?> getUserById(int codUsuario);

  Future<UserSystemListResponse> searchUsersByName(
    String nome, {
    int? codEmpresa,
    bool apenasAtivos = true,
    Pagination? pagination,
  });
}
