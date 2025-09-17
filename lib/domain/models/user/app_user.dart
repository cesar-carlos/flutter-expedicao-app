import 'package:exp/domain/models/user_system_models.dart';

class AppUser {
  final int codLoginApp;
  final String ativo;
  final String nome;
  final int? codUsuario;
  final String? fotoUsuario;
  final String? senha;
  final UserSystemModel? userSystemModel;

  AppUser({
    required this.codLoginApp,
    required this.ativo,
    required this.nome,
    this.codUsuario,
    this.fotoUsuario,
    this.senha,
    this.userSystemModel,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      codLoginApp: json['CodLoginApp'],
      ativo: json['Ativo'],
      nome: json['Nome'],
      codUsuario: json['CodUsuario'],
      fotoUsuario: json['FotoUsuario'],
      senha: json['Senha'],
    );
  }

  bool get isActive => ativo.toUpperCase() == 'S';
  bool get hasPhoto => fotoUsuario != null && fotoUsuario!.isNotEmpty;

  AppUser copyWith({
    int? codLoginApp,
    String? ativo,
    String? nome,
    int? codUsuario,
    String? fotoUsuario,
    String? senha,
    UserSystemModel? userSystemModel,
  }) {
    return AppUser(
      codLoginApp: codLoginApp ?? this.codLoginApp,
      ativo: ativo ?? this.ativo,
      nome: nome ?? this.nome,
      codUsuario: codUsuario ?? this.codUsuario,
      fotoUsuario: fotoUsuario ?? this.fotoUsuario,
      senha: senha ?? this.senha,
      userSystemModel: userSystemModel ?? this.userSystemModel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CodLoginApp': codLoginApp,
      'Ativo': ativo,
      'Nome': nome,
      if (codUsuario != null) 'CodUsuario': codUsuario,
      'FotoUsuario': fotoUsuario,
      if (senha != null) 'Senha': senha,
      'UserSystemData': userSystemModel?.toMap(),
    };
  }

  @override
  String toString() {
    return 'AppUser(codLoginApp: $codLoginApp, ativo: $ativo, nome: $nome, codUsuario: $codUsuario, fotoUsuario: $fotoUsuario, senha: ${senha != null ? '[HIDDEN]' : 'null'}, hasSystemData: $userSystemModel)';
  }
}
