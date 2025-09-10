/// Modelo para requisição de criação de usuário
class CreateUserRequest {
  final String nome;
  final String senha;

  CreateUserRequest({required this.nome, required this.senha});

  Map<String, dynamic> toJson() {
    return {'Nome': nome, 'Senha': senha};
  }
}
