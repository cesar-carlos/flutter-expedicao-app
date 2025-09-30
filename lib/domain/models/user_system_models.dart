import 'package:exp/domain/models/situation_model.dart';
import 'package:exp/core/results/index.dart';

class UserSystemModel {
  final int? codEmpresa;
  final int codUsuario;
  final String nomeUsuario;
  final Situation ativo;
  final String? codContaFinanceira;
  final String? nomeContaFinanceira;
  final String? nomeCaixaOperador;
  final int? codSetorEstoque;
  final String? nomeSetorEstoque;
  final int? codSetorConferencia;
  final String? nomeSetorConferencia;
  final int? codSetorArmazenagem;
  final String? nomeSetorArmazenagem;
  final int? codLoginApp;
  final Situation permiteSepararForaSequencia;
  final Situation visualizaTodasSeparacoes;
  final Situation permiteConferirForaSequencia;
  final Situation visualizaTodasConferencias;
  final Situation salvaCarrinhoOutroUsuario;
  final Situation editaCarrinhoOutroUsuario;
  final Situation excluiCarrinhoOutroUsuario;

  const UserSystemModel({
    this.codEmpresa,
    required this.codUsuario,
    required this.nomeUsuario,
    required this.ativo,
    this.codContaFinanceira,
    this.nomeContaFinanceira,
    this.nomeCaixaOperador,
    this.codSetorEstoque,
    this.nomeSetorEstoque,
    this.codSetorConferencia,
    this.nomeSetorConferencia,
    this.codSetorArmazenagem,
    this.nomeSetorArmazenagem,
    this.codLoginApp,
    required this.permiteSepararForaSequencia,
    required this.visualizaTodasSeparacoes,
    required this.permiteConferirForaSequencia,
    required this.visualizaTodasConferencias,
    required this.salvaCarrinhoOutroUsuario,
    required this.editaCarrinhoOutroUsuario,
    required this.excluiCarrinhoOutroUsuario,
  });

  factory UserSystemModel.fromJson(Map<String, dynamic> map) {
    return UserSystemModel(
      codEmpresa: map['CodEmpresa'] as int?,
      codUsuario: map['CodUsuario'] as int? ?? 0,
      nomeUsuario: map['NomeUsuario'] as String? ?? '',
      ativo: Situation.fromCodeWithFallback(map['Ativo'] as String? ?? 'N'),
      codContaFinanceira: map['CodContaFinanceira'] as String?,
      nomeContaFinanceira: map['NomeContaFinanceira'] as String?,
      nomeCaixaOperador: map['NomeCaixaOperador'] as String?,
      codSetorEstoque: map['CodSetorEstoque'] as int?,
      nomeSetorEstoque: map['NomeSetorEstoque'] as String?,
      codSetorConferencia: map['CodSetorConferencia'] as int?,
      nomeSetorConferencia: map['NomeSetorConferencia'] as String?,
      codSetorArmazenagem: map['CodSetorArmazenagem'] as int?,
      nomeSetorArmazenagem: map['NomeSetorArmazenagem'] as String?,
      codLoginApp: map['CodLoginApp'] as int?,
      permiteSepararForaSequencia: Situation.fromCodeWithFallback(map['PermiteSepararForaSequencia'] as String? ?? 'N'),
      visualizaTodasSeparacoes: Situation.fromCodeWithFallback(map['VisualizaTodasSeparacoes'] as String? ?? 'N'),
      permiteConferirForaSequencia: Situation.fromCodeWithFallback(
        map['PermiteConferirForaSequencia'] as String? ?? 'N',
      ),
      visualizaTodasConferencias: Situation.fromCodeWithFallback(map['VisualizaTodasConferencias'] as String? ?? 'N'),
      salvaCarrinhoOutroUsuario: Situation.fromCodeWithFallback(map['SalvaCarrinhoOutroUsuario'] as String? ?? 'N'),
      editaCarrinhoOutroUsuario: Situation.fromCodeWithFallback(map['EditaCarrinhoOutroUsuario'] as String? ?? 'N'),
      excluiCarrinhoOutroUsuario: Situation.fromCodeWithFallback(map['ExcluiCarrinhoOutroUsuario'] as String? ?? 'N'),
    );
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<UserSystemModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => UserSystemModel.fromJson(json));
  }

  Map<String, dynamic> toMap() {
    return {
      'CodEmpresa': codEmpresa,
      'CodUsuario': codUsuario,
      'NomeUsuario': nomeUsuario,
      'Ativo': ativo.code,
      'CodContaFinanceira': codContaFinanceira,
      'NomeContaFinanceira': nomeContaFinanceira,
      'NomeCaixaOperador': nomeCaixaOperador,
      'CodSetorEstoque': codSetorEstoque,
      'NomeSetorEstoque': nomeSetorEstoque,
      'CodSetorConferencia': codSetorConferencia,
      'NomeSetorConferencia': nomeSetorConferencia,
      'CodSetorArmazenagem': codSetorArmazenagem,
      'NomeSetorArmazenagem': nomeSetorArmazenagem,
      'CodLoginApp': codLoginApp,
      'PermiteSepararForaSequencia': permiteSepararForaSequencia.code,
      'VisualizaTodasSeparacoes': visualizaTodasSeparacoes.code,
      'PermiteConferirForaSequencia': permiteConferirForaSequencia.code,
      'VisualizaTodasConferencias': visualizaTodasConferencias.code,
      'SalvaCarrinhoOutroUsuario': salvaCarrinhoOutroUsuario.code,
      'EditaCarrinhoOutroUsuario': editaCarrinhoOutroUsuario.code,
      'ExcluiCarrinhoOutroUsuario': excluiCarrinhoOutroUsuario.code,
    };
  }

  bool get hasBasicPermissions {
    return ativo == Situation.ativo &&
        (codContaFinanceira?.isNotEmpty ?? false) &&
        (nomeContaFinanceira?.isNotEmpty ?? false);
  }

  bool get canWorkWithSeparations {
    return permiteSepararForaSequencia == Situation.ativo || visualizaTodasSeparacoes == Situation.ativo;
  }

  bool get canWorkWithConferences {
    return permiteConferirForaSequencia == Situation.ativo || visualizaTodasConferencias == Situation.ativo;
  }

  bool get canManageOtherCarts {
    return salvaCarrinhoOutroUsuario == Situation.ativo ||
        editaCarrinhoOutroUsuario == Situation.ativo ||
        excluiCarrinhoOutroUsuario == Situation.ativo;
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
