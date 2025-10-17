import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/models/pagination/pagination.dart';
import 'package:data7_expedicao/data/dtos/user_system_list_response_dto.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';

abstract class UserSystemRepository {
  Future<Map<String, dynamic>> getUserSystemInfo(int codUsuario);

  Future<UserSystemListResponseDto> getUsers({int? codEmpresa, Situation? apenasAtivos, Pagination? pagination});

  Future<UserSystemModel?> getUserById(int codUsuario);

  Future<UserSystemListResponseDto> searchUsersByName(
    String nome, {
    int? codEmpresa,
    Situation apenasAtivos = Situation.ativo,
    Pagination? pagination,
  });
}
