import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/utils/json_parse_helpers.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';

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
  final Situation expedicaoObrigaEscanearPrateleira;
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
    required this.expedicaoObrigaEscanearPrateleira,
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
    // Bug latente anterior: `as int? ??` crashava com TypeError se a
    // API enviasse string ("123") em vez de int. Persistencia em
    // SharedPreferences (AppUser.userSystem) podia ter dados
    // corrompidos. Agora todos campos com JsonParse defensivo.
    Situation flag(String key) => Situation.fromCodeWithFallback(JsonParse.parseStringOr(map[key], 'N'));
    return UserSystemModel(
      codUsuario: JsonParse.parseIntOr(map['CodUsuario'], 0),
      nomeUsuario: JsonParse.parseStringOr(map['NomeUsuario'], ''),
      ativo: Situation.fromCodeWithFallback(JsonParse.parseStringOr(map['Ativo'], 'N')),
      codEmpresa: JsonParse.parseInt(map['CodEmpresa']),
      nomeEmpresa: JsonParse.parseStringOrNull(map['NomeEmpresa']),
      codVendedor: JsonParse.parseInt(map['CodVendedor']),
      nomeVendedor: JsonParse.parseStringOrNull(map['NomeVendedor']),
      codLocalArmazenagem: JsonParse.parseInt(map['CodLocalArmazenagem']),
      nomeLocalArmazenagem: JsonParse.parseStringOrNull(map['NomeLocalArmazenagem']),
      codContaFinanceira: JsonParse.parseStringOrNull(map['CodContaFinanceira']),
      nomeContaFinanceira: JsonParse.parseStringOrNull(map['NomeContaFinanceira']),
      nomeCaixaOperador: JsonParse.parseStringOrNull(map['NomeCaixaOperador']),
      codSetorEstoque: JsonParse.parseInt(map['CodSetorEstoque']),
      nomeSetorEstoque: JsonParse.parseStringOrNull(map['NomeSetorEstoque']),
      permiteSepararForaSequencia: flag('PermiteSepararForaSequencia'),
      visualizaTodasSeparacoes: flag('VisualizaTodasSeparacoes'),
      expedicaoObrigaEscanearPrateleira: flag('ExpedicaoObrigaEscanearPrateleira'),
      codSetorConferencia: JsonParse.parseInt(map['CodSetorConferencia']),
      nomeSetorConferencia: JsonParse.parseStringOrNull(map['NomeSetorConferencia']),
      permiteConferirForaSequencia: flag('PermiteConferirForaSequencia'),
      visualizaTodasConferencias: flag('VisualizaTodasConferencias'),
      codSetorArmazenagem: JsonParse.parseInt(map['CodSetorArmazenagem']),
      nomeSetorArmazenagem: JsonParse.parseStringOrNull(map['NomeSetorArmazenagem']),
      permiteArmazenarForaSequencia: flag('PermiteArmazenarForaSequencia'),
      visualizaTodasArmazenagem: flag('VisualizaTodasArmazenagem'),
      editaCarrinhoOutroUsuario: flag('EditaCarrinhoOutroUsuario'),
      salvaCarrinhoOutroUsuario: flag('SalvaCarrinhoOutroUsuario'),
      excluiCarrinhoOutroUsuario: flag('ExcluiCarrinhoOutroUsuario'),
      expedicaoEntregaBalcaoPreVenda: flag('ExpedicaoEntregaBalcaoPreVenda'),
      codLoginApp: JsonParse.parseInt(map['CodLoginApp']),
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
      'ExpedicaoObrigaEscanearPrateleira': expedicaoObrigaEscanearPrateleira.code,
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
