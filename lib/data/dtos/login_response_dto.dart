import 'package:data7_expedicao/domain/models/user/user_models.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';

class LoginResponseDto {
  final String message;
  final UserDataDto user;

  LoginResponseDto({required this.message, required this.user});

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    if (json['message'] == null) {
      throw FormatException('Message é obrigatório na resposta da API');
    }
    final userField = json['user'];
    if (userField == null) {
      throw FormatException('User é obrigatório na resposta da API');
    }
    // Bug KKKKKKKKKKK: antes era `UserDataDto.fromJson(json['user'])`
    // sem type check. Se servidor retornasse `user` como String/List/etc
    // (caso comum em respostas de erro mal formatadas), o
    // UserDataDto.fromJson crashava com TypeError em vez de
    // FormatException tratado.
    if (userField is! Map) {
      throw FormatException('User deve ser um objeto, recebido ${userField.runtimeType}');
    }

    return LoginResponseDto(
      message: json['message'].toString(),
      user: UserDataDto.fromJson(Map<String, dynamic>.from(userField)),
    );
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

    // Bug LLLLLLLLLLL: antes era `int.parse(json['CodLoginApp'].toString())`
    // sem catch. Se o valor viesse com formato inesperado (ex.: float
    // serializado como "123.45", string com espaco, vazio), int.parse
    // lancava FormatException generico sem indicar QUAL campo era. Agora
    // usamos helper que retorna FormatException com nome do campo.
    return UserDataDto(
      codLoginApp: _parseRequiredInt(json['CodLoginApp'], 'CodLoginApp'),
      ativo: json['Ativo'].toString(),
      nome: json['Nome'].toString(),
      codUsuario: json['CodUsuario'] != null ? _parseRequiredInt(json['CodUsuario'], 'CodUsuario') : null,
      fotoUsuario: json['FotoUsuario']?.toString(),
    );
  }

  static int _parseRequiredInt(dynamic value, String fieldName) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value.toString());
    if (parsed == null) {
      throw FormatException(
        'Campo "$fieldName" deve ser numerico, recebido ${value.runtimeType}: $value',
      );
    }
    return parsed;
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
