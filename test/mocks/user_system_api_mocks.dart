/// Dados mockados para testes da API de usuários do sistema
class UserSystemApiMocks {
  /// Resposta mockada da API GET /usuarios (lista completa)
  static const Map<String, dynamic> userListApiResponse = {
    "message": "2 usuário(s) encontrado(s)",
    "data": [
      {
        "CodEmpresa": 1,
        "CodUsuario": 1,
        "NomeUsuario": "Administrador",
        "Ativo": "S",
        "CodContaFinanceira": "CXG",
        "NomeContaFinanceira": "CAIXA GEYSA",
        "NomeCaixaOperador": "ADMINISTRADOR",
        "PermiteSepararForaSequencia": "S",
        "VisualizaTodasSeparacoes": "S",
        "PermiteConferirForaSequencia": "S",
        "VisualizaTodasConferencias": "S",
        "SalvaCarrinhoOutroUsuario": "S",
        "EditaCarrinhoOutroUsuario": "S",
        "ExcluiCarrinhoOutroUsuario": "S",
      },
      {
        "CodUsuario": 35,
        "NomeUsuario": "Administradores",
        "Ativo": "S",
        "PermiteSepararForaSequencia": "N",
        "VisualizaTodasSeparacoes": "N",
        "PermiteConferirForaSequencia": "N",
        "VisualizaTodasConferencias": "N",
        "SalvaCarrinhoOutroUsuario": "N",
        "EditaCarrinhoOutroUsuario": "N",
        "ExcluiCarrinhoOutroUsuario": "N",
      },
    ],
    "total": 2,
    "page": 1,
    "limit": 100,
    "totalPages": 1,
  };

  /// Resposta mockada para usuário único
  static const Map<String, dynamic> singleUserApiResponse = {
    "CodEmpresa": 1,
    "CodUsuario": 1,
    "NomeUsuario": "Administrador",
    "Ativo": "S",
    "CodContaFinanceira": "CXG",
    "NomeContaFinanceira": "CAIXA GEYSA",
    "NomeCaixaOperador": "ADMINISTRADOR",
    "PermiteSepararForaSequencia": "S",
    "VisualizaTodasSeparacoes": "S",
    "PermiteConferirForaSequencia": "S",
    "VisualizaTodasConferencias": "S",
    "SalvaCarrinhoOutroUsuario": "S",
    "EditaCarrinhoOutroUsuario": "S",
    "ExcluiCarrinhoOutroUsuario": "S",
  };

  /// Resposta mockada para usuário sem campos opcionais
  static const Map<String, dynamic> basicUserApiResponse = {
    "CodUsuario": 35,
    "NomeUsuario": "Usuario Basico",
    "Ativo": "S",
    "PermiteSepararForaSequencia": "N",
    "VisualizaTodasSeparacoes": "N",
    "PermiteConferirForaSequencia": "N",
    "VisualizaTodasConferencias": "N",
    "SalvaCarrinhoOutroUsuario": "N",
    "EditaCarrinhoOutroUsuario": "N",
    "ExcluiCarrinhoOutroUsuario": "N",
  };

  /// Resposta mockada vazia
  static const Map<String, dynamic> emptyListApiResponse = {
    "message": "Nenhum usuário encontrado",
    "data": [],
    "total": 0,
    "page": 1,
    "limit": 100,
    "totalPages": 0,
  };

  /// Lista direta (sem metadados)
  static const List<Map<String, dynamic>> directListApiResponse = [
    {
      "CodUsuario": 1,
      "NomeUsuario": "Usuario 1",
      "Ativo": "S",
      "PermiteSepararForaSequencia": "S",
      "VisualizaTodasSeparacoes": "S",
      "PermiteConferirForaSequencia": "S",
      "VisualizaTodasConferencias": "S",
      "SalvaCarrinhoOutroUsuario": "S",
      "EditaCarrinhoOutroUsuario": "S",
      "ExcluiCarrinhoOutroUsuario": "S",
    },
    {
      "CodUsuario": 2,
      "NomeUsuario": "Usuario 2",
      "Ativo": "N",
      "PermiteSepararForaSequencia": "N",
      "VisualizaTodasSeparacoes": "N",
      "PermiteConferirForaSequencia": "N",
      "VisualizaTodasConferencias": "N",
      "SalvaCarrinhoOutroUsuario": "N",
      "EditaCarrinhoOutroUsuario": "N",
      "ExcluiCarrinhoOutroUsuario": "N",
    },
  ];
}
