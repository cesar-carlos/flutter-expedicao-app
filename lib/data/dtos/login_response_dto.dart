import 'package:exp/domain/models/user/user_models.dart';
import 'package:exp/domain/models/situation_model.dart';

class LoginResponseDto {
  final String message;
  final UserDataDto user;

  LoginResponseDto({required this.message, required this.user});

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    if (json['message'] == null) {
      throw FormatException('Message é obrigatório na resposta da API');
    }
    if (json['user'] == null) {
      throw FormatException('User é obrigatório na resposta da API');
    }

    return LoginResponseDto(message: json['message'].toString(), user: UserDataDto.fromJson(json['user']));
  }

  LoginResponse toDomain() {
    return LoginResponse(
      message: message,
      user: AppUser(
        codLoginApp: user.codLoginApp,
        ativo: Situation.fromCodeWithFallback(user.ativo),
        nome: user.nome,
        codUsuario: user.codUsuario,
        fotoUsuario: user.fotoUsuario,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'user': user.toJson()};
  }

  @override
  String toString() {
    return 'LoginResponseDto(message: $message, user: $user)';
  }
}

class UserDataDto {
  final int codLoginApp;
  final String ativo;
  final String nome;
  final int? codUsuario;
  final String? fotoUsuario;

  UserDataDto({required this.codLoginApp, required this.ativo, required this.nome, this.codUsuario, this.fotoUsuario});

  factory UserDataDto.fromJson(Map<String, dynamic> json) {
    if (json['CodLoginApp'] == null) {
      throw FormatException('CodLoginApp é obrigatório na resposta da API');
    }
    if (json['Ativo'] == null) {
      throw FormatException('Ativo é obrigatório na resposta da API');
    }
    if (json['Nome'] == null) {
      throw FormatException('Nome é obrigatório na resposta da API');
    }

    return UserDataDto(
      codLoginApp: json['CodLoginApp'] is int ? json['CodLoginApp'] : int.parse(json['CodLoginApp'].toString()),
      ativo: json['Ativo'].toString(),
      nome: json['Nome'].toString(),
      codUsuario: json['CodUsuario'] != null
          ? (json['CodUsuario'] is int ? json['CodUsuario'] : int.parse(json['CodUsuario'].toString()))
          : null,
      fotoUsuario: json['FotoUsuario']?.toString(),
    );
  }

  Map<String, dynamic> toDomain() {
    return {
      'CodLoginApp': codLoginApp,
      'Ativo': ativo,
      'Nome': nome,
      'CodUsuario': codUsuario,
      'FotoUsuario': fotoUsuario,
    };
  }

  bool get isActive => ativo.toUpperCase() == 'S';

  bool get hasPhoto => fotoUsuario != null && fotoUsuario!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'CodLoginApp': codLoginApp,
      'Ativo': ativo,
      'Nome': nome,
      'CodUsuario': codUsuario,
      'FotoUsuario': fotoUsuario,
    };
  }

  @override
  String toString() {
    return 'UserDataDto(codLoginApp: $codLoginApp, ativo: $ativo, nome: $nome, codUsuario: $codUsuario, fotoUsuario: $fotoUsuario)';
  }
}
