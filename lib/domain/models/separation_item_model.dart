import 'package:flutter/material.dart';

import 'package:exp/core/utils/app_helper.dart';
import 'package:exp/domain/models/expedition_item_situation_model.dart';
import 'package:exp/core/results/index.dart';

class SeparationItemModel {
  final int codEmpresa;
  final int codSepararEstoque;
  final String item;
  final String sessionId;
  final ExpeditionItemSituation situacao;
  final int codCarrinhoPercurso;
  final String itemCarrinhoPercurso;
  final int codSeparador;
  final String nomeSeparador;
  final DateTime dataSeparacao;
  final String horaSeparacao;
  final int codProduto;
  final String codUnidadeMedida;
  final double quantidade;

  SeparationItemModel({
    required this.codEmpresa,
    required this.codSepararEstoque,
    required this.item,
    required this.sessionId,
    required this.situacao,
    required this.codCarrinhoPercurso,
    required this.itemCarrinhoPercurso,
    required this.codSeparador,
    required this.nomeSeparador,
    required this.dataSeparacao,
    required this.horaSeparacao,
    required this.codProduto,
    required this.codUnidadeMedida,
    required this.quantidade,
  });

  SeparationItemModel copyWith({
    int? codEmpresa,
    int? codSepararEstoque,
    String? item,
    String? sessionId,
    ExpeditionItemSituation? situacao,
    int? codCarrinhoPercurso,
    String? itemCarrinhoPercurso,
    int? codSeparador,
    String? nomeSeparador,
    DateTime? dataSeparacao,
    String? horaSeparacao,
    int? codProduto,
    String? codUnidadeMedida,
    double? quantidade,
  }) {
    return SeparationItemModel(
      codEmpresa: codEmpresa ?? this.codEmpresa,
      codSepararEstoque: codSepararEstoque ?? this.codSepararEstoque,
      item: item ?? this.item,
      sessionId: sessionId ?? this.sessionId,
      situacao: situacao ?? this.situacao,
      codCarrinhoPercurso: codCarrinhoPercurso ?? this.codCarrinhoPercurso,
      itemCarrinhoPercurso: itemCarrinhoPercurso ?? this.itemCarrinhoPercurso,
      codSeparador: codSeparador ?? this.codSeparador,
      nomeSeparador: nomeSeparador ?? this.nomeSeparador,
      dataSeparacao: dataSeparacao ?? this.dataSeparacao,
      horaSeparacao: horaSeparacao ?? this.horaSeparacao,
      codProduto: codProduto ?? this.codProduto,
      codUnidadeMedida: codUnidadeMedida ?? this.codUnidadeMedida,
      quantidade: quantidade ?? this.quantidade,
    );
  }

  factory SeparationItemModel.fromConsulta(SeparationItemModel model) {
    return SeparationItemModel(
      codEmpresa: model.codEmpresa,
      codSepararEstoque: model.codSepararEstoque,
      item: model.item,
      sessionId: model.sessionId,
      situacao: model.situacao,
      codCarrinhoPercurso: model.codCarrinhoPercurso,
      itemCarrinhoPercurso: model.itemCarrinhoPercurso,
      codSeparador: model.codSeparador,
      nomeSeparador: model.nomeSeparador,
      dataSeparacao: model.dataSeparacao,
      horaSeparacao: model.horaSeparacao,
      codProduto: model.codProduto,
      codUnidadeMedida: model.codUnidadeMedida,
      quantidade: model.quantidade,
    );
  }

  factory SeparationItemModel.fromJson(Map<String, dynamic> json) {
    try {
      return SeparationItemModel(
        codEmpresa: json['CodEmpresa'],
        codSepararEstoque: json['CodSepararEstoque'],
        item: json['Item'],
        sessionId: json['SessionId'],
        situacao:
            ExpeditionItemSituation.fromCode(json['Situacao'] as String? ?? '') ?? ExpeditionItemSituation.pendente,
        codCarrinhoPercurso: json['CodCarrinhoPercurso'],
        itemCarrinhoPercurso: json['ItemCarrinhoPercurso'],
        codSeparador: json['CodSeparador'],
        nomeSeparador: json['NomeSeparador'],
        dataSeparacao: AppHelper.tryStringToDate(json['DataSeparacao']),
        horaSeparacao: json['HoraSeparacao'] ?? '00:00:00',
        codProduto: json['CodProduto'],
        codUnidadeMedida: json['CodUnidadeMedida'],
        quantidade: AppHelper.stringToDouble(json['Quantidade']),
      );
    } catch (_) {
      rethrow;
    }
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<SeparationItemModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => SeparationItemModel.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return {
      "CodEmpresa": codEmpresa,
      "CodSepararEstoque": codSepararEstoque,
      "Item": item,
      "SessionId": sessionId,
      "Situacao": situacao.code,
      "CodCarrinhoPercurso": codCarrinhoPercurso,
      "ItemCarrinhoPercurso": itemCarrinhoPercurso,
      "CodSeparador": codSeparador,
      "NomeSeparador": nomeSeparador,
      "DataSeparacao": dataSeparacao.toIso8601String(),
      "HoraSeparacao": horaSeparacao,
      "CodProduto": codProduto,
      "CodUnidadeMedida": codUnidadeMedida,
      "Quantidade": quantidade.toStringAsFixed(4),
    };
  }

  /// Retorna o código da situação
  String get situacaoCode => situacao.code;

  /// Retorna a descrição da situação
  String get situacaoDescription => situacao.description;

  /// Retorna a cor da situação
  Color get situacaoColor => situacao.color;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeparationItemModel &&
        other.codEmpresa == codEmpresa &&
        other.codSepararEstoque == codSepararEstoque &&
        other.item == item;
  }

  @override
  int get hashCode => codEmpresa.hashCode ^ codSepararEstoque.hashCode ^ item.hashCode;

  @override
  String toString() {
    return '''
      ExpedicaoSeparacaoItemModel(
        codEmpresa: $codEmpresa, 
        codSepararEstoque: $codSepararEstoque, 
        item: $item, 
        sessionId: $sessionId, 
        situacao: ${situacao.description}, 
        codCarrinhoPercurso: $codCarrinhoPercurso, 
        itemCarrinhoPercurso: $itemCarrinhoPercurso, 
        codSeparador: $codSeparador, 
        nomeSeparador: $nomeSeparador, 
        dataSeparacao: $dataSeparacao, 
        horaSeparacao: $horaSeparacao, 
        codProduto: $codProduto, 
        codUnidadeMedida: $codUnidadeMedida, 
        quantidade: $quantidade
    )''';
  }
}
