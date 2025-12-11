import 'dart:convert';

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
    return SystemQRCodeData(
      codUsuario: json['CodUsuario'] as int,
      nomeUsuario: json['NomeUsuario'] as String,
      senhaUsuario: json['SenhaUsuario'] as String,
      ativo: json['Ativo'] as String? ?? 'S',
      codEmpresa: json['CodEmpresa'] as int,
      nomeEmpresa: json['NomeEmpresa'] as String,
      codVendedor: json['CodVendedor'] as int?,
      nomeVendedor: json['NomeVendedor'] as String?,
      codLocalArmazenagem: json['CodLocalArmazenagem'] as int?,
      nomeLocalArmazenagem: json['NomeLocalArmazenagem'] as String?,
      codContaFinanceira: json['CodContaFinanceira'] as String?,
      nomeContaFinanceira: json['NomeContaFinanceira'] as String?,
      nomeCaixaOperador: json['NomeCaixaOperador'] as String?,
      codSetorEstoque: json['CodSetorEstoque'] as int?,
      nomeSetorEstoque: json['NomeSetorEstoque'] as String?,
      permiteSepararForaSequencia: json['PermiteSepararForaSequencia'] as String? ?? 'N',
      visualizaTodasSeparacoes: json['VisualizaTodasSeparacoes'] as String? ?? 'N',
      codSetorConferencia: json['CodSetorConferencia'] as int?,
      nomeSetorConferencia: json['NomeSetorConferencia'] as String?,
      permiteConferirForaSequencia: json['PermiteConferirForaSequencia'] as String? ?? 'N',
      visualizaTodasConferencias: json['VisualizaTodasConferencias'] as String? ?? 'N',
      codSetorArmazenagem: json['CodSetorArmazenagem'] as int?,
      nomeSetorArmazenagem: json['NomeSetorArmazenagem'] as String?,
      permiteArmazenarForaSequencia: json['PermiteArmazenarForaSequencia'] as String? ?? 'N',
      visualizaTodasArmazenagem: json['VisualizaTodasArmazenagem'] as String? ?? 'N',
      editaCarrinhoOutroUsuario: json['EditaCarrinhoOutroUsuario'] as String? ?? 'N',
      salvaCarrinhoOutroUsuario: json['SalvaCarrinhoOutroUsuario'] as String? ?? 'N',
      excluiCarrinhoOutroUsuario: json['ExcluiCarrinhoOutroUsuario'] as String? ?? 'N',
      expedicaoEntregaBalcaoPreVenda: json['ExpedicaoEntregaBalcaoPreVenda'] as String? ?? 'N',
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
