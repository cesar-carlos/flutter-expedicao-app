import 'dart:io';
import 'dart:convert';

class CreateUserDto {
  final String nome;
  final String senha;
  final File? profileImage;
  final int? codUsuario;

  CreateUserDto({required this.nome, required this.senha, this.profileImage, this.codUsuario});

  Future<Map<String, dynamic>> toApiRequest() async {
    final Map<String, dynamic> request = {'Nome': nome.trim(), 'Senha': senha};

    // Adicionar CodUsuario se fornecido (caso de cadastro via QR Code)
    if (codUsuario != null) {
      request['CodUsuario'] = codUsuario!;
    }

    if (hasProfileImage) {
      try {
        final bytes = await profileImage!.readAsBytes();
        final base64Image = base64Encode(bytes);
        request['FotoUsuario'] = base64Image;
      } catch (e) {
        throw Exception('Erro ao converter foto para base64: $e');
      }
    }

    return request;
  }

  factory CreateUserDto.fromDomainParams({
    required String nome,
    required String senha,
    File? profileImage,
    int? codUsuario,
  }) {
    return CreateUserDto(nome: nome, senha: senha, profileImage: profileImage, codUsuario: codUsuario);
  }

  bool get hasProfileImage => profileImage != null;

  bool get isValid {
    return nome.trim().isNotEmpty &&
        senha.isNotEmpty &&
        nome.trim().length <= 30 &&
        senha.length >= 4 &&
        senha.length <= 60;
  }

  @override
  String toString() {
    return 'CreateUserDto(nome: $nome, hasProfileImage: $hasProfileImage)';
  }
}
