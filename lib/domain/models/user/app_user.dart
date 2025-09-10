class AppUser {
  final int codLoginApp;
  final String ativo;
  final String nome;
  final int? codUsuario;
  final String? fotoUsuario;
  final String? senha; // Campo opcional para mudança de senha

  AppUser({
    required this.codLoginApp,
    required this.ativo,
    required this.nome,
    this.codUsuario,
    this.fotoUsuario,
    this.senha,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      codLoginApp: json['CodLoginApp'],
      ativo: json['Ativo'],
      nome: json['Nome'],
      codUsuario: json['CodUsuario'],
      fotoUsuario: json['FotoUsuario'],
      senha: json['Senha'], // Inclui senha se presente no JSON
    );
  }

  bool get isActive => ativo.toUpperCase() == 'S';
  bool get hasPhoto => fotoUsuario != null && fotoUsuario!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'CodLoginApp': codLoginApp,
      'Ativo': ativo,
      'Nome': nome,
      if (codUsuario != null) 'CodUsuario': codUsuario,
      'FotoUsuario': fotoUsuario, // Agora permite null explicitamente
      if (senha != null) 'Senha': senha, // Inclui senha apenas se presente
    };
  }

  @override
  String toString() {
    return 'AppUser(codLoginApp: $codLoginApp, ativo: $ativo, nome: $nome, codUsuario: $codUsuario, fotoUsuario: $fotoUsuario, senha: ${senha != null ? '[HIDDEN]' : 'null'})';
  }
}
