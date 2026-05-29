import 'package:data7_expedicao/domain/models/user_system_models.dart';

/// Modelo de dominio que representa uma pagina de usuarios do sistema.
///
/// Mantem os mesmos campos e semantica consumidos pelos callers do antigo
/// DTO de `data/`, preservando o comportamento de sucesso/erro (`success`
/// e `message`) sem acoplar o dominio a camada de dados.
class UserSystemListPage {
  final List<UserSystemModel> users;
  final int total;
  final int? page;
  final int? limit;
  final int? totalPages;
  final bool success;
  final String? message;

  const UserSystemListPage({
    required this.users,
    required this.total,
    this.page,
    this.limit,
    this.totalPages,
    required this.success,
    this.message,
  });
}
