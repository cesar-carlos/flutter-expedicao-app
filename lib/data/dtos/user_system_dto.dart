class UserSystemDto {
  final int? codEmpresa;
  final int codUsuario;
  final String nomeUsuario;
  final String ativo;
  final String? codContaFinanceira;
  final String? nomeContaFinanceira;
  final String? nomeCaixaOperador;
  final int? codLoginApp;
  final String permiteSepararForaSequencia;
  final String visualizaTodasSeparacoes;
  final String permiteConferirForaSequencia;
  final String visualizaTodasConferencias;
  final String salvaCarrinhoOutroUsuario;
  final String editaCarrinhoOutroUsuario;
  final String excluiCarrinhoOutroUsuario;

  const UserSystemDto({
    this.codEmpresa,
    required this.codUsuario,
    required this.nomeUsuario,
    required this.ativo,
    this.codContaFinanceira,
    this.nomeContaFinanceira,
    this.nomeCaixaOperador,
    this.codLoginApp,
    required this.permiteSepararForaSequencia,
    required this.visualizaTodasSeparacoes,
    required this.permiteConferirForaSequencia,
    required this.visualizaTodasConferencias,
    required this.salvaCarrinhoOutroUsuario,
    required this.editaCarrinhoOutroUsuario,
    required this.excluiCarrinhoOutroUsuario,
  });

  factory UserSystemDto.fromApiResponse(Map<String, dynamic> json) {
    return UserSystemDto(
      codEmpresa: json['CodEmpresa'] as int?,
      codUsuario: json['CodUsuario'] as int,
      nomeUsuario: json['NomeUsuario'] as String,
      ativo: json['Ativo'] as String,
      codContaFinanceira: json['CodContaFinanceira'] as String?,
      nomeContaFinanceira: json['NomeContaFinanceira'] as String?,
      nomeCaixaOperador: json['NomeCaixaOperador'] as String?,
      codLoginApp: json['CodLoginApp'] as int?,
      permiteSepararForaSequencia: json['PermiteSepararForaSequencia'] as String,
      visualizaTodasSeparacoes: json['VisualizaTodasSeparacoes'] as String,
      permiteConferirForaSequencia: json['PermiteConferirForaSequencia'] as String,
      visualizaTodasConferencias: json['VisualizaTodasConferencias'] as String,
      salvaCarrinhoOutroUsuario: json['SalvaCarrinhoOutroUsuario'] as String,
      editaCarrinhoOutroUsuario: json['EditaCarrinhoOutroUsuario'] as String,
      excluiCarrinhoOutroUsuario: json['ExcluiCarrinhoOutroUsuario'] as String,
    );
  }

  Map<String, dynamic> toApiRequest() {
    final map = <String, dynamic>{
      'CodUsuario': codUsuario,
      'NomeUsuario': nomeUsuario,
      'Ativo': ativo,
      'PermiteSepararForaSequencia': permiteSepararForaSequencia,
      'VisualizaTodasSeparacoes': visualizaTodasSeparacoes,
      'PermiteConferirForaSequencia': permiteConferirForaSequencia,
      'VisualizaTodasConferencias': visualizaTodasConferencias,
      'SalvaCarrinhoOutroUsuario': salvaCarrinhoOutroUsuario,
      'EditaCarrinhoOutroUsuario': editaCarrinhoOutroUsuario,
      'ExcluiCarrinhoOutroUsuario': excluiCarrinhoOutroUsuario,
    };

    if (codEmpresa != null) map['CodEmpresa'] = codEmpresa;
    if (codContaFinanceira != null) map['CodContaFinanceira'] = codContaFinanceira;
    if (nomeContaFinanceira != null) map['NomeContaFinanceira'] = nomeContaFinanceira;
    if (nomeCaixaOperador != null) map['NomeCaixaOperador'] = nomeCaixaOperador;

    return map;
  }

  Map<String, dynamic> toDomain() {
    return {
      'codEmpresa': codEmpresa,
      'codUsuario': codUsuario,
      'nomeUsuario': nomeUsuario,
      'ativo': ativo == 'S',
      'codContaFinanceira': codContaFinanceira,
      'nomeContaFinanceira': nomeContaFinanceira,
      'nomeCaixaOperador': nomeCaixaOperador,
      'codLoginApp': codLoginApp,
      'permiteSepararForaSequencia': permiteSepararForaSequencia == 'S',
      'visualizaTodasSeparacoes': visualizaTodasSeparacoes == 'S',
      'permiteConferirForaSequencia': permiteConferirForaSequencia == 'S',
      'visualizaTodasConferencias': visualizaTodasConferencias == 'S',
      'salvaCarrinhoOutroUsuario': salvaCarrinhoOutroUsuario == 'S',
      'editaCarrinhoOutroUsuario': editaCarrinhoOutroUsuario == 'S',
      'excluiCarrinhoOutroUsuario': excluiCarrinhoOutroUsuario == 'S',
    };
  }

  bool get isValid {
    return codUsuario > 0 && nomeUsuario.isNotEmpty && ativo.isNotEmpty;
  }

  bool get isAtivo => ativo == 'S';
  bool get canSepararForaSequencia => permiteSepararForaSequencia == 'S';
  bool get canVisualizaTodasSeparacoes => visualizaTodasSeparacoes == 'S';
  bool get canConferirForaSequencia => permiteConferirForaSequencia == 'S';
  bool get canVisualizaTodasConferencias => visualizaTodasConferencias == 'S';
  bool get canSalvaCarrinhoOutroUsuario => salvaCarrinhoOutroUsuario == 'S';
  bool get canEditaCarrinhoOutroUsuario => editaCarrinhoOutroUsuario == 'S';
  bool get canExcluiCarrinhoOutroUsuario => excluiCarrinhoOutroUsuario == 'S';

  @override
  String toString() {
    return 'UserSystemDto(codUsuario: $codUsuario, nomeUsuario: $nomeUsuario, codEmpresa: $codEmpresa)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSystemDto &&
        other.codEmpresa == codEmpresa &&
        other.codUsuario == codUsuario &&
        other.nomeUsuario == nomeUsuario;
  }

  @override
  int get hashCode {
    return codEmpresa.hashCode ^ codUsuario.hashCode ^ nomeUsuario.hashCode;
  }
}
