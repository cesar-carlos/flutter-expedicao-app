import 'package:exp/domain/models/user_system_models.dart';
import 'package:exp/domain/models/situation_model.dart';

class UserSystemListResponseDto {
  final List<UserSystemModel> users;
  final int total;
  final int? page;
  final int? limit;
  final int? totalPages;
  final bool success;
  final String? message;

  const UserSystemListResponseDto({
    required this.users,
    required this.total,
    this.page,
    this.limit,
    this.totalPages,
    required this.success,
    this.message,
  });

  factory UserSystemListResponseDto.fromApiResponse(Map<String, dynamic> map) {
    final usersData = map['data'] as List<dynamic>? ?? [];
    final users = usersData.map((item) => UserSystemModel.fromMap(item as Map<String, dynamic>)).toList();

    return UserSystemListResponseDto(
      users: users,
      total: map['total'] as int? ?? users.length,
      page: map['page'] as int?,
      limit: map['limit'] as int?,
      totalPages: map['totalPages'] as int?,
      success: true,
      message: map['message'] as String?,
    );
  }

  factory UserSystemListResponseDto.fromMap(Map<String, dynamic> map) {
    return UserSystemListResponseDto(
      users:
          (map['users'] as List<dynamic>?)
              ?.map((item) => UserSystemModel.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      total: map['total'] as int? ?? 0,
      success: map['success'] as bool? ?? true,
      message: map['message'] as String?,
    );
  }

  factory UserSystemListResponseDto.success({
    required List<UserSystemModel> users,
    int? page,
    int? limit,
    int? totalPages,
    String? message,
  }) {
    return UserSystemListResponseDto(
      users: users,
      total: users.length,
      page: page,
      limit: limit,
      totalPages: totalPages,
      success: true,
      message: message,
    );
  }

  factory UserSystemListResponseDto.error(String message) {
    return UserSystemListResponseDto(
      users: [],
      total: 0,
      page: null,
      limit: null,
      totalPages: null,
      success: false,
      message: message,
    );
  }

  List<UserSystemModel> get activeUsers {
    return users.where((user) => user.ativo == Situation.ativo).toList();
  }

  List<UserSystemModel> getUsersByCompany(int codEmpresa) {
    return users.where((user) => user.codEmpresa == codEmpresa).toList();
  }

  @override
  String toString() {
    return 'UserSystemListResponseDto(total: $total, users: ${users.length}, success: $success)';
  }
}
