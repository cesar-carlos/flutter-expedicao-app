class CreateUserResponseDto {
  final String message;
  final UserCreatedDto user;

  CreateUserResponseDto({required this.message, required this.user});

  factory CreateUserResponseDto.fromApiResponse(Map<String, dynamic> json) {
    if (json['message'] == null) {
      throw FormatException('Message é obrigatório na resposta da API');
    }
    if (json['user'] == null) {
      throw FormatException('User é obrigatório na resposta da API');
    }

    return CreateUserResponseDto(
      message: json['message'].toString(),
      user: UserCreatedDto.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toDomain() {
    return {
      'CodLoginApp': user.codLoginApp,
      'Ativo': user.ativo,
      'Nome': user.nome,
    };
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

  UserCreatedDto({
    required this.codLoginApp,
    required this.ativo,
    required this.nome,
    this.fotoUsuario,
  });

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

    return UserCreatedDto(
      codLoginApp: json['CodLoginApp'] is int
          ? json['CodLoginApp']
          : int.parse(json['CodLoginApp'].toString()),
      ativo: json['Ativo'].toString(),
      nome: json['Nome'].toString(),
      fotoUsuario: json['FotoUsuario']?.toString(),
    );
  }

  bool get isActive => ativo.toUpperCase() == 'S';

  bool get hasPhoto => fotoUsuario != null && fotoUsuario!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'CodLoginApp': codLoginApp,
      'Ativo': ativo,
      'Nome': nome,
      'FotoUsuario': fotoUsuario,
    };
  }

  @override
  String toString() {
    return 'UserCreatedDto(codLoginApp: $codLoginApp, ativo: $ativo, nome: $nome, fotoUsuario: $fotoUsuario)';
  }
}
