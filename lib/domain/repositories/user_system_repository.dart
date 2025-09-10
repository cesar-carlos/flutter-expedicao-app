import 'package:exp/domain/models/user_system_models.dart';

abstract class UserSystemRepository {
  Future<Map<String, dynamic>> getUserSystemInfo(int codUsuario);

  Future<UserSystemListResponse> getUsers({
    int? codEmpresa,
    bool? apenasAtivos,
    int? limit,
    int? offset,
  });

  Future<UserSystemData?> getUserById(int codUsuario);

  Future<UserSystemListResponse> searchUsersByName(
    String nome, {
    int? codEmpresa,
    bool apenasAtivos = true,
    int limit = 50,
  });
}
