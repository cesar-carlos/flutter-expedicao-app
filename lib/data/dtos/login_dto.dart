class LoginDto {
  final String nome;
  final String senha;

  LoginDto({required this.nome, required this.senha});

  Map<String, dynamic> toApiRequest() {
    return {'Nome': nome.trim(), 'Senha': senha.toLowerCase()};
  }

  factory LoginDto.fromDomainParams({required String nome, required String senha}) {
    return LoginDto(nome: nome, senha: senha);
  }

  bool get isValid {
    return nome.trim().isNotEmpty &&
        senha.isNotEmpty &&
        nome.trim().length <= 30 &&
        senha.length >= 4 &&
        senha.length <= 60;
  }

  @override
  String toString() {
    return 'LoginDto(nome: $nome)';
  }
}
