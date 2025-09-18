import 'package:exp/domain/models/user_system_models.dart';
import 'package:exp/domain/models/pagination/pagination.dart';
import 'package:exp/data/dtos/user_system_list_response_dto.dart';

abstract class UserSystemRepository {
  Future<Map<String, dynamic>> getUserSystemInfo(int codUsuario);

  Future<UserSystemListResponseDto> getUsers({int? codEmpresa, bool? apenasAtivos, Pagination? pagination});

  Future<UserSystemModel?> getUserById(int codUsuario);

  Future<UserSystemListResponseDto> searchUsersByName(
    String nome, {
    int? codEmpresa,
    bool apenasAtivos = true,
    Pagination? pagination,
  });
}
