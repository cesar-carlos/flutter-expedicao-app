import 'dart:convert';

import 'package:data7_expedicao/core/utils/json_parse_helpers.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:result_dart/result_dart.dart';

class SystemQRCodeData {
  final int codUsuario;
  final String nomeUsuario;
  final String senhaUsuario;
  final String ativo;
  final int codEmpresa;
  final String nomeEmpresa;
  final int? codVendedor;
  final String? nomeVendedor;
  final int? codLocalArmazenagem;
  final String? nomeLocalArmazenagem;
  final String? codContaFinanceira;
  final String? nomeContaFinanceira;
  final String? nomeCaixaOperador;
  final int? codSetorEstoque;
  final String? nomeSetorEstoque;
  final String permiteSepararForaSequencia;
  final String visualizaTodasSeparacoes;
  final int? codSetorConferencia;
  final String? nomeSetorConferencia;
  final String permiteConferirForaSequencia;
  final String visualizaTodasConferencias;
  final int? codSetorArmazenagem;
  final String? nomeSetorArmazenagem;
  final String permiteArmazenarForaSequencia;
  final String visualizaTodasArmazenagem;
  final String editaCarrinhoOutroUsuario;
  final String salvaCarrinhoOutroUsuario;
  final String excluiCarrinhoOutroUsuario;
  final String expedicaoEntregaBalcaoPreVenda;

  const SystemQRCodeData({
    required this.codUsuario,
    required this.nomeUsuario,
    required this.senhaUsuario,
    required this.ativo,
    required this.codEmpresa,
    required this.nomeEmpresa,
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
  });

  factory SystemQRCodeData.fromJson(Map<String, dynamic> json) {
    // Bug critico anterior: `as int` direto em campos requeridos
    // (codUsuario, codEmpresa) crashava com TypeError se o QR Code
    // contivesse strings em vez de int (caso comum quando QR e
    // gerado por sistema com tipagem fraca). Agora usa JsonParse
    // defensivo. fromQRCodeString ja valida campos obrigatorios.
    String flag(String key) => JsonParse.parseStringOr(json[key], 'N');
    return SystemQRCodeData(
      codUsuario: JsonParse.parseIntOr(json['CodUsuario'], 0),
      nomeUsuario: JsonParse.parseStringOr(json['NomeUsuario'], ''),
      senhaUsuario: JsonParse.parseStringOr(json['SenhaUsuario'], ''),
      ativo: JsonParse.parseStringOr(json['Ativo'], 'S'),
      codEmpresa: JsonParse.parseIntOr(json['CodEmpresa'], 0),
      nomeEmpresa: JsonParse.parseStringOr(json['NomeEmpresa'], ''),
      codVendedor: JsonParse.parseInt(json['CodVendedor']),
      nomeVendedor: JsonParse.parseStringOrNull(json['NomeVendedor']),
      codLocalArmazenagem: JsonParse.parseInt(json['CodLocalArmazenagem']),
      nomeLocalArmazenagem: JsonParse.parseStringOrNull(json['NomeLocalArmazenagem']),
      codContaFinanceira: JsonParse.parseStringOrNull(json['CodContaFinanceira']),
      nomeContaFinanceira: JsonParse.parseStringOrNull(json['NomeContaFinanceira']),
      nomeCaixaOperador: JsonParse.parseStringOrNull(json['NomeCaixaOperador']),
      codSetorEstoque: JsonParse.parseInt(json['CodSetorEstoque']),
      nomeSetorEstoque: JsonParse.parseStringOrNull(json['NomeSetorEstoque']),
      permiteSepararForaSequencia: flag('PermiteSepararForaSequencia'),
      visualizaTodasSeparacoes: flag('VisualizaTodasSeparacoes'),
      codSetorConferencia: JsonParse.parseInt(json['CodSetorConferencia']),
      nomeSetorConferencia: JsonParse.parseStringOrNull(json['NomeSetorConferencia']),
      permiteConferirForaSequencia: flag('PermiteConferirForaSequencia'),
      visualizaTodasConferencias: flag('VisualizaTodasConferencias'),
      codSetorArmazenagem: JsonParse.parseInt(json['CodSetorArmazenagem']),
      nomeSetorArmazenagem: JsonParse.parseStringOrNull(json['NomeSetorArmazenagem']),
      permiteArmazenarForaSequencia: flag('PermiteArmazenarForaSequencia'),
      visualizaTodasArmazenagem: flag('VisualizaTodasArmazenagem'),
      editaCarrinhoOutroUsuario: flag('EditaCarrinhoOutroUsuario'),
      salvaCarrinhoOutroUsuario: flag('SalvaCarrinhoOutroUsuario'),
      excluiCarrinhoOutroUsuario: flag('ExcluiCarrinhoOutroUsuario'),
      expedicaoEntregaBalcaoPreVenda: flag('ExpedicaoEntregaBalcaoPreVenda'),
    );
  }

  static Result<SystemQRCodeData> fromQRCodeString(String qrCodeContent) {
    try {
      final Map<String, dynamic> json = jsonDecode(qrCodeContent);

      final missingFields = <String>[];
      const requiredFields = ['CodUsuario', 'NomeUsuario', 'SenhaUsuario'];

      for (final field in requiredFields) {
        if (!json.containsKey(field) || json[field] == null) {
          missingFields.add(field);
        }
      }

      if (missingFields.isNotEmpty) {
        return Failure(
          ValidationFailure(message: 'QR Code inválido: campos obrigatórios ausentes: ${missingFields.join(', ')}'),
        );
      }

      final data = SystemQRCodeData.fromJson(json);
      return Success(data);
    } on FormatException catch (e) {
      return Failure(ValidationFailure(message: 'QR Code com formato JSON inválido: ${e.message}'));
    } catch (e) {
      return Failure(ValidationFailure(message: 'Erro ao processar QR Code: ${e.toString()}'));
    }
  }

  UserSystemModel toUserSystemModel() {
    return UserSystemModel.fromJson({
      'CodUsuario': codUsuario,
      'NomeUsuario': nomeUsuario,
      'Ativo': ativo,
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
      'PermiteSepararForaSequencia': permiteSepararForaSequencia,
      'VisualizaTodasSeparacoes': visualizaTodasSeparacoes,
      'CodSetorConferencia': codSetorConferencia,
      'NomeSetorConferencia': nomeSetorConferencia,
      'PermiteConferirForaSequencia': permiteConferirForaSequencia,
      'VisualizaTodasConferencias': visualizaTodasConferencias,
      'CodSetorArmazenagem': codSetorArmazenagem,
      'NomeSetorArmazenagem': nomeSetorArmazenagem,
      'PermiteArmazenarForaSequencia': permiteArmazenarForaSequencia,
      'VisualizaTodasArmazenagem': visualizaTodasArmazenagem,
      'EditaCarrinhoOutroUsuario': editaCarrinhoOutroUsuario,
      'SalvaCarrinhoOutroUsuario': salvaCarrinhoOutroUsuario,
      'ExcluiCarrinhoOutroUsuario': excluiCarrinhoOutroUsuario,
      'ExpedicaoEntregaBalcaoPreVenda': expedicaoEntregaBalcaoPreVenda,
    });
  }

  @override
  String toString() {
    return 'SystemQRCodeData(codUsuario: $codUsuario, nomeUsuario: $nomeUsuario, codEmpresa: $codEmpresa, nomeEmpresa: $nomeEmpresa)';
  }
}
