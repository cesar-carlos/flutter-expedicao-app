class UserSystemModel {
  final int? codEmpresa;
  final int codUsuario;
  final String nomeUsuario;
  final bool ativo;
  final String? codContaFinanceira;
  final String? nomeContaFinanceira;
  final String? nomeCaixaOperador;
  final int? codLoginApp;
  final bool permiteSepararForaSequencia;
  final bool visualizaTodasSeparacoes;
  final bool permiteConferirForaSequencia;
  final bool visualizaTodasConferencias;
  final bool salvaCarrinhoOutroUsuario;
  final bool editaCarrinhoOutroUsuario;
  final bool excluiCarrinhoOutroUsuario;

  const UserSystemModel({
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

  factory UserSystemModel.fromMap(Map<String, dynamic> map) {
    return UserSystemModel(
      codEmpresa: (map['CodEmpresa'] ?? map['codEmpresa']) as int?,
      codUsuario: (map['CodUsuario'] ?? map['codUsuario']) as int,
      nomeUsuario: (map['NomeUsuario'] ?? map['nomeUsuario']) as String,
      ativo: (map['Ativo'] ?? map['ativo']) as bool,
      codContaFinanceira: (map['CodContaFinanceira'] ?? map['codContaFinanceira']) as String?,
      nomeContaFinanceira: (map['NomeContaFinanceira'] ?? map['nomeContaFinanceira']) as String?,
      nomeCaixaOperador: (map['NomeCaixaOperador'] ?? map['nomeCaixaOperador']) as String?,
      codLoginApp: (map['CodLoginApp'] ?? map['codLoginApp']) as int?,
      permiteSepararForaSequencia: (map['PermiteSepararForaSequencia'] ?? map['permiteSepararForaSequencia']) as bool,
      visualizaTodasSeparacoes: (map['VisualizaTodasSeparacoes'] ?? map['visualizaTodasSeparacoes']) as bool,
      permiteConferirForaSequencia:
          (map['PermiteConferirForaSequencia'] ?? map['permiteConferirForaSequencia']) as bool,
      visualizaTodasConferencias: (map['VisualizaTodasConferencias'] ?? map['visualizaTodasConferencias']) as bool,
      salvaCarrinhoOutroUsuario: (map['SalvaCarrinhoOutroUsuario'] ?? map['salvaCarrinhoOutroUsuario']) as bool,
      editaCarrinhoOutroUsuario: (map['EditaCarrinhoOutroUsuario'] ?? map['editaCarrinhoOutroUsuario']) as bool,
      excluiCarrinhoOutroUsuario: (map['ExcluiCarrinhoOutroUsuario'] ?? map['excluiCarrinhoOutroUsuario']) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'CodEmpresa': codEmpresa,
      'CodUsuario': codUsuario,
      'NomeUsuario': nomeUsuario,
      'Ativo': ativo,
      'CodContaFinanceira': codContaFinanceira,
      'NomeContaFinanceira': nomeContaFinanceira,
      'NomeCaixaOperador': nomeCaixaOperador,
      'CodLoginApp': codLoginApp,
      'PermiteSepararForaSequencia': permiteSepararForaSequencia,
      'VisualizaTodasSeparacoes': visualizaTodasSeparacoes,
      'PermiteConferirForaSequencia': permiteConferirForaSequencia,
      'VisualizaTodasConferencias': visualizaTodasConferencias,
      'SalvaCarrinhoOutroUsuario': salvaCarrinhoOutroUsuario,
      'EditaCarrinhoOutroUsuario': editaCarrinhoOutroUsuario,
      'ExcluiCarrinhoOutroUsuario': excluiCarrinhoOutroUsuario,
    };
  }

  bool get hasBasicPermissions {
    return ativo && (codContaFinanceira?.isNotEmpty ?? false) && (nomeContaFinanceira?.isNotEmpty ?? false);
  }

  bool get canWorkWithSeparations {
    return permiteSepararForaSequencia || visualizaTodasSeparacoes;
  }

  bool get canWorkWithConferences {
    return permiteConferirForaSequencia || visualizaTodasConferencias;
  }

  bool get canManageOtherCarts {
    return salvaCarrinhoOutroUsuario || editaCarrinhoOutroUsuario || excluiCarrinhoOutroUsuario;
  }

  @override
  String toString() {
    return 'UserSystemData(codUsuario: $codUsuario, nomeUsuario: $nomeUsuario, ativo: $ativo, codloginApp: $codLoginApp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSystemModel &&
        other.codEmpresa == codEmpresa &&
        other.codUsuario == codUsuario &&
        other.nomeUsuario == nomeUsuario;
  }

  @override
  int get hashCode {
    return codEmpresa.hashCode ^ codUsuario.hashCode ^ nomeUsuario.hashCode;
  }
}

class UserSystemListResponse {
  final List<UserSystemModel> users;
  final int total;
  final int? page;
  final int? limit;
  final int? totalPages;
  final bool success;
  final String? message;

  const UserSystemListResponse({
    required this.users,
    required this.total,
    this.page,
    this.limit,
    this.totalPages,
    required this.success,
    this.message,
  });

  factory UserSystemListResponse.fromApiResponse(Map<String, dynamic> map) {
    final usersData = map['data'] as List<dynamic>? ?? [];
    final users = usersData.map((item) => UserSystemModel.fromMap(item as Map<String, dynamic>)).toList();

    return UserSystemListResponse(
      users: users,
      total: map['total'] as int? ?? users.length,
      page: map['page'] as int?,
      limit: map['limit'] as int?,
      totalPages: map['totalPages'] as int?,
      success: true,
      message: map['message'] as String?,
    );
  }

  factory UserSystemListResponse.fromMap(Map<String, dynamic> map) {
    return UserSystemListResponse(
      users:
          (map['users'] as List<dynamic>?)
              ?.map((item) => UserSystemModel.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      total: map['total'] as int? ?? 0,
      success: map['success'] as bool? ?? true,
      message: map['message'] as String?,
    );
  }

  factory UserSystemListResponse.success({
    required List<UserSystemModel> users,
    int? page,
    int? limit,
    int? totalPages,
    String? message,
  }) {
    return UserSystemListResponse(
      users: users,
      total: users.length,
      page: page,
      limit: limit,
      totalPages: totalPages,
      success: true,
      message: message,
    );
  }

  factory UserSystemListResponse.error(String message) {
    return UserSystemListResponse(
      users: [],
      total: 0,
      page: null,
      limit: null,
      totalPages: null,
      success: false,
      message: message,
    );
  }

  List<UserSystemModel> get activeUsers {
    return users.where((user) => user.ativo).toList();
  }

  List<UserSystemModel> getUsersByCompany(int codEmpresa) {
    return users.where((user) => user.codEmpresa == codEmpresa).toList();
  }

  @override
  String toString() {
    return 'UserSystemListResponse(total: $total, users: ${users.length}, success: $success)';
  }
}
