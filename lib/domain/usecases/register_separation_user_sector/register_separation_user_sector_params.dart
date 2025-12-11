class RegisterSeparationUserSectorParams {
  final int codEmpresa;
  final int codSepararEstoque;
  final int codSetorEstoque;
  final int codUsuario;
  final String nomeUsuario;

  const RegisterSeparationUserSectorParams({
    required this.codEmpresa,
    required this.codSepararEstoque,
    required this.codSetorEstoque,
    required this.codUsuario,
    required this.nomeUsuario,
  });

  bool get isValid {
    return codEmpresa > 0 && codSepararEstoque > 0 && codSetorEstoque > 0 && codUsuario > 0 && nomeUsuario.isNotEmpty;
  }

  List<String> get validationErrors {
    final errors = <String>[];

    if (codEmpresa <= 0) errors.add('Código da empresa inválido');
    if (codSepararEstoque <= 0) errors.add('Código da separação inválido');
    if (codSetorEstoque <= 0) errors.add('Código do setor inválido');
    if (codUsuario <= 0) errors.add('Código do usuário inválido');
    if (nomeUsuario.isEmpty) errors.add('Nome do usuário não pode ser vazio');

    return errors;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RegisterSeparationUserSectorParams &&
        other.codEmpresa == codEmpresa &&
        other.codSepararEstoque == codSepararEstoque &&
        other.codSetorEstoque == codSetorEstoque &&
        other.codUsuario == codUsuario &&
        other.nomeUsuario == nomeUsuario;
  }

  @override
  int get hashCode {
    return Object.hash(codEmpresa, codSepararEstoque, codSetorEstoque, codUsuario, nomeUsuario);
  }

  @override
  String toString() {
    return 'RegisterSeparationUserSectorParams('
        'codEmpresa: $codEmpresa, '
        'codSepararEstoque: $codSepararEstoque, '
        'codSetorEstoque: $codSetorEstoque, '
        'codUsuario: $codUsuario, '
        'nomeUsuario: $nomeUsuario'
        ')';
  }
}
