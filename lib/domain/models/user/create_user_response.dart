/// Modelo para resposta de criação de usuário (sucesso)
class CreateUserResponse {
  final int codLoginApp;
  final String ativo;
  final String nome;

  CreateUserResponse({
    required this.codLoginApp,
    required this.ativo,
    required this.nome,
  });

  factory CreateUserResponse.fromJson(Map<String, dynamic> json) {
    // Validações dos campos obrigatórios
    if (json['CodLoginApp'] == null) {
      throw FormatException('CodLoginApp é obrigatório na resposta da API');
    }
    if (json['Ativo'] == null) {
      throw FormatException('Ativo é obrigatório na resposta da API');
    }
    if (json['Nome'] == null) {
      throw FormatException('Nome é obrigatório na resposta da API');
    }

    return CreateUserResponse(
      codLoginApp: json['CodLoginApp'] is int
          ? json['CodLoginApp']
          : int.parse(json['CodLoginApp'].toString()),
      ativo: json['Ativo'].toString(),
      nome: json['Nome'].toString(),
    );
  }

  /// Verifica se o usuário está ativo (Ativo == "S")
  bool get isActive => ativo.toUpperCase() == 'S';

  /// Converte para JSON (útil para logs)
  Map<String, dynamic> toJson() {
    return {'CodLoginApp': codLoginApp, 'Ativo': ativo, 'Nome': nome};
  }

  @override
  String toString() {
    return 'CreateUserResponse(codLoginApp: $codLoginApp, ativo: $ativo, nome: $nome)';
  }
}
