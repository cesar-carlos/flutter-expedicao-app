import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/core/results/index.dart';

class UserSystemModel {
  final int codUsuario;
  final String nomeUsuario;
  final Situation ativo;
  final int? codEmpresa;
  final String? nomeEmpresa;
  final int? codVendedor;
  final String? nomeVendedor;
  final int? codLocalArmazenagem;
  final String? nomeLocalArmazenagem;
  final String? codContaFinanceira;
  final String? nomeContaFinanceira;
  final String? nomeCaixaOperador;
  final int? codSetorEstoque;
  final String? nomeSetorEstoque;
  final Situation permiteSepararForaSequencia;
  final Situation visualizaTodasSeparacoes;
  final int? codSetorConferencia;
  final String? nomeSetorConferencia;
  final Situation permiteConferirForaSequencia;
  final Situation visualizaTodasConferencias;
  final int? codSetorArmazenagem;
  final String? nomeSetorArmazenagem;
  final Situation permiteArmazenarForaSequencia;
  final Situation visualizaTodasArmazenagem;
  final Situation editaCarrinhoOutroUsuario;
  final Situation salvaCarrinhoOutroUsuario;
  final Situation excluiCarrinhoOutroUsuario;
  final Situation expedicaoEntregaBalcaoPreVenda;
  final int? codLoginApp;

  const UserSystemModel({
    required this.codUsuario,
    required this.nomeUsuario,
    required this.ativo,
    this.codEmpresa,
    this.nomeEmpresa,
    this.codVendedor,
    this.nomeVendedor,
    this.codLocalArmazenagem,
    this.nomeLocalArmazenagem,
    this.codContaFinanceira,
    this.nomeContaFinanceira,
    this.nomeCaixaOperador,
    this.codSetorEstoque,
    this.nomeSetorEstoque,
    required this.permiteSepararForaSequencia,
    required this.visualizaTodasSeparacoes,
    this.codSetorConferencia,
    this.nomeSetorConferencia,
    required this.permiteConferirForaSequencia,
    required this.visualizaTodasConferencias,
    this.codSetorArmazenagem,
    this.nomeSetorArmazenagem,
    required this.permiteArmazenarForaSequencia,
    required this.visualizaTodasArmazenagem,
    required this.editaCarrinhoOutroUsuario,
    required this.salvaCarrinhoOutroUsuario,
    required this.excluiCarrinhoOutroUsuario,
    required this.expedicaoEntregaBalcaoPreVenda,
    this.codLoginApp,
  });

  factory UserSystemModel.fromJson(Map<String, dynamic> map) {
    return UserSystemModel(
      codUsuario: map['CodUsuario'] as int? ?? 0,
      nomeUsuario: map['NomeUsuario'] as String? ?? '',
      ativo: Situation.fromCodeWithFallback(map['Ativo'] as String? ?? 'N'),
      codEmpresa: map['CodEmpresa'] as int?,
      nomeEmpresa: map['NomeEmpresa'] as String?,
      codVendedor: map['CodVendedor'] as int?,
      nomeVendedor: map['NomeVendedor'] as String?,
      codLocalArmazenagem: map['CodLocalArmazenagem'] as int?,
      nomeLocalArmazenagem: map['NomeLocalArmazenagem'] as String?,
      codContaFinanceira: map['CodContaFinanceira'] as String?,
      nomeContaFinanceira: map['NomeContaFinanceira'] as String?,
      nomeCaixaOperador: map['NomeCaixaOperador'] as String?,
      codSetorEstoque: map['CodSetorEstoque'] as int?,
      nomeSetorEstoque: map['NomeSetorEstoque'] as String?,
      permiteSepararForaSequencia: Situation.fromCodeWithFallback(map['PermiteSepararForaSequencia'] as String? ?? 'N'),
      visualizaTodasSeparacoes: Situation.fromCodeWithFallback(map['VisualizaTodasSeparacoes'] as String? ?? 'N'),
      codSetorConferencia: map['CodSetorConferencia'] as int?,
      nomeSetorConferencia: map['NomeSetorConferencia'] as String?,
      permiteConferirForaSequencia: Situation.fromCodeWithFallback(
        map['PermiteConferirForaSequencia'] as String? ?? 'N',
      ),
      visualizaTodasConferencias: Situation.fromCodeWithFallback(map['VisualizaTodasConferencias'] as String? ?? 'N'),
      codSetorArmazenagem: map['CodSetorArmazenagem'] as int?,
      nomeSetorArmazenagem: map['NomeSetorArmazenagem'] as String?,
      permiteArmazenarForaSequencia: Situation.fromCodeWithFallback(
        map['PermiteArmazenarForaSequencia'] as String? ?? 'N',
      ),
      visualizaTodasArmazenagem: Situation.fromCodeWithFallback(map['VisualizaTodasArmazenagem'] as String? ?? 'N'),
      editaCarrinhoOutroUsuario: Situation.fromCodeWithFallback(map['EditaCarrinhoOutroUsuario'] as String? ?? 'N'),
      salvaCarrinhoOutroUsuario: Situation.fromCodeWithFallback(map['SalvaCarrinhoOutroUsuario'] as String? ?? 'N'),
      excluiCarrinhoOutroUsuario: Situation.fromCodeWithFallback(map['ExcluiCarrinhoOutroUsuario'] as String? ?? 'N'),
      expedicaoEntregaBalcaoPreVenda: Situation.fromCodeWithFallback(
        map['ExpedicaoEntregaBalcaoPreVenda'] as String? ?? 'N',
      ),
      codLoginApp: map['CodLoginApp'] as int?,
    );
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<UserSystemModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => UserSystemModel.fromJson(json));
  }

  Map<String, dynamic> toMap() {
    return {
      'CodUsuario': codUsuario,
      'NomeUsuario': nomeUsuario,
      'Ativo': ativo.code,
      'CodEmpresa': codEmpresa,
      'NomeEmpresa': nomeEmpresa,
      'CodVendedor': codVendedor,
      'NomeVendedor': nomeVendedor,
      'CodLocalArmazenagem': codLocalArmazenagem,
      'NomeLocalArmazenagem': nomeLocalArmazenagem,
      'CodContaFinanceira': codContaFinanceira,
      'NomeContaFinanceira': nomeContaFinanceira,
      'NomeCaixaOperador': nomeCaixaOperador,
      'CodSetorEstoque': codSetorEstoque,
      'NomeSetorEstoque': nomeSetorEstoque,
      'PermiteSepararForaSequencia': permiteSepararForaSequencia.code,
      'VisualizaTodasSeparacoes': visualizaTodasSeparacoes.code,
      'CodSetorConferencia': codSetorConferencia,
      'NomeSetorConferencia': nomeSetorConferencia,
      'PermiteConferirForaSequencia': permiteConferirForaSequencia.code,
      'VisualizaTodasConferencias': visualizaTodasConferencias.code,
      'CodSetorArmazenagem': codSetorArmazenagem,
      'NomeSetorArmazenagem': nomeSetorArmazenagem,
      'PermiteArmazenarForaSequencia': permiteArmazenarForaSequencia.code,
      'VisualizaTodasArmazenagem': visualizaTodasArmazenagem.code,
      'EditaCarrinhoOutroUsuario': editaCarrinhoOutroUsuario.code,
      'SalvaCarrinhoOutroUsuario': salvaCarrinhoOutroUsuario.code,
      'ExcluiCarrinhoOutroUsuario': excluiCarrinhoOutroUsuario.code,
      'ExpedicaoEntregaBalcaoPreVenda': expedicaoEntregaBalcaoPreVenda.code,
      'CodLoginApp': codLoginApp,
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

  bool get canWorkWithStorage {
    return permiteArmazenarForaSequencia == Situation.ativo || visualizaTodasArmazenagem == Situation.ativo;
  }

  bool get canManageOtherCarts {
    return salvaCarrinhoOutroUsuario == Situation.ativo ||
        editaCarrinhoOutroUsuario == Situation.ativo ||
        excluiCarrinhoOutroUsuario == Situation.ativo;
  }

  @override
  String toString() {
    return 'UserSystemModel(codUsuario: $codUsuario, nomeUsuario: $nomeUsuario, ativo: $ativo, codLoginApp: $codLoginApp)';
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
