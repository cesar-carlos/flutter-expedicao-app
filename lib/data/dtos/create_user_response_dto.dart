class CreateUserResponseDto {
  final String message;
  final UserCreatedDto user;

  CreateUserResponseDto({required this.message, required this.user});

  factory CreateUserResponseDto.fromApiResponse(Map<String, dynamic> json) {
    if (json['message'] == null) {
      throw FormatException('Message é obrigatório na resposta da API');
    }
    final userField = json['user'];
    if (userField == null) {
      throw FormatException('User é obrigatório na resposta da API');
    }
    // Bug similar ao KKKKKKKKKKK em LoginResponseDto: type check
    // antes de delegar para UserCreatedDto.fromJson.
    if (userField is! Map) {
      throw FormatException('User deve ser um objeto, recebido ${userField.runtimeType}');
    }

    return CreateUserResponseDto(
      message: json['message'].toString(),
      user: UserCreatedDto.fromJson(Map<String, dynamic>.from(userField)),
    );
  }

  Map<String, dynamic> toDomain() {
    return {'CodLoginApp': user.codLoginApp, 'Ativo': user.ativo, 'Nome': user.nome};
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'user': user.toJson()};
  }

  @override
  String toString() {
    return 'CreateUserResponseDto(message: $message, user: $user)';
  }
}

class UserCreatedDto {
  final int codLoginApp;
  final String ativo;
  final String nome;
  final String? fotoUsuario;

  UserCreatedDto({required this.codLoginApp, required this.ativo, required this.nome, this.fotoUsuario});

  factory UserCreatedDto.fromJson(Map<String, dynamic> json) {
    if (json['CodLoginApp'] == null) {
      throw FormatException('CodLoginApp é obrigatório na resposta da API');
    }
    if (json['Ativo'] == null) {
      throw FormatException('Ativo é obrigatório na resposta da API');
    }
    if (json['Nome'] == null) {
      throw FormatException('Nome é obrigatório na resposta da API');
    }

    // Bug similar ao LLLLLLLLLLL em UserDataDto: parse defensivo de int
    // que indica QUAL campo falhou.
    final rawCodLoginApp = json['CodLoginApp'];
    final int codLoginApp;
    if (rawCodLoginApp is int) {
      codLoginApp = rawCodLoginApp;
    } else if (rawCodLoginApp is num) {
      codLoginApp = rawCodLoginApp.toInt();
    } else {
      final parsed = int.tryParse(rawCodLoginApp.toString());
      if (parsed == null) {
        throw FormatException(
          'Campo "CodLoginApp" deve ser numerico, recebido ${rawCodLoginApp.runtimeType}: $rawCodLoginApp',
        );
      }
      codLoginApp = parsed;
    }

    return UserCreatedDto(
      codLoginApp: codLoginApp,
      ativo: json['Ativo'].toString(),
      nome: json['Nome'].toString(),
      fotoUsuario: json['FotoUsuario']?.toString(),
    );
  }

  bool get isActive => ativo.toUpperCase() == 'S';

  bool get hasPhoto => fotoUsuario != null && fotoUsuario!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {'CodLoginApp': codLoginApp, 'Ativo': ativo, 'Nome': nome, 'FotoUsuario': fotoUsuario};
  }

  @override
  String toString() {
    return 'UserCreatedDto(codLoginApp: $codLoginApp, ativo: $ativo, nome: $nome, fotoUsuario: $fotoUsuario)';
  }
}
