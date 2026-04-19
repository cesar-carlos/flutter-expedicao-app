import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';

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
    // Bug MMMMMMMMMMM: antes era `usersData.map((item) => UserSystemModel.fromJson(item as Map<String, dynamic>))`
    // que crashava lista inteira se 1 item fosse null/tipo errado. Agora
    // parseia item-por-item com log (mesmo padrao do SocketRequestHelper).
    final users = _parseUsersList(map['data']);

    return UserSystemListResponseDto(
      users: users,
      total: map['total'] is int ? map['total'] as int : users.length,
      page: map['page'] is int ? map['page'] as int : null,
      limit: map['limit'] is int ? map['limit'] as int : null,
      totalPages: map['totalPages'] is int ? map['totalPages'] as int : null,
      success: true,
      message: map['message']?.toString(),
    );
  }

  factory UserSystemListResponseDto.fromMap(Map<String, dynamic> map) {
    return UserSystemListResponseDto(
      users: _parseUsersList(map['users']),
      total: map['total'] is int ? map['total'] as int : 0,
      success: map['success'] is bool ? map['success'] as bool : true,
      message: map['message']?.toString(),
    );
  }

  /// Bug NNNNNNNNNNN: parse defensivo da lista de usuarios. Items
  /// invalidos (null, tipo errado, fromJson falhou) sao logados e
  /// ignorados — outros items continuam validos.
  static List<UserSystemModel> _parseUsersList(dynamic raw) {
    if (raw is! List) return const [];
    final result = <UserSystemModel>[];
    for (var i = 0; i < raw.length; i++) {
      final item = raw[i];
      if (item is! Map) {
        AppLogger.warning(
          'UserSystemListResponseDto: item $i nao e Map (${item.runtimeType}) — ignorado',
          tag: 'UserSystemListDto',
        );
        continue;
      }
      try {
        result.add(UserSystemModel.fromJson(Map<String, dynamic>.from(item)));
      } catch (e, s) {
        AppLogger.warning(
          'UserSystemListResponseDto: falha ao parsear item $i — ignorado',
          tag: 'UserSystemListDto',
          error: e,
          stackTrace: s,
        );
      }
    }
    return result;
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
