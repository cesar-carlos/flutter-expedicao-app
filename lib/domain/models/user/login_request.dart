/// Modelo para requisição de login
class LoginRequest {
  final String nome;
  final String senha;

  LoginRequest({required this.nome, required this.senha});

  Map<String, dynamic> toJson() {
    return {'Nome': nome, 'Senha': senha};
  }
}
