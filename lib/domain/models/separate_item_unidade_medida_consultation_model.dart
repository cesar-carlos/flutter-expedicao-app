import 'package:data7_expedicao/core/utils/app_helper.dart';
import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/tipo_fator_conversao_model.dart';

class SeparateItemUnidadeMedidaConsultationModel {
  final int codEmpresa;
  final int codSepararEstoque;
  final String item;
  final int codProduto;
  final String itemUnidadeMedida;
  final String codUnidadeMedida;
  final String unidadeMedidaDescricao;
  final Situation unidadeMedidaPadrao;
  final TipoFatorConversao tipoFatorConversao;
  final double fatorConversao;
  final String? codigoBarras;
  final String? observacao;

  SeparateItemUnidadeMedidaConsultationModel({
    required this.codEmpresa,
    required this.codSepararEstoque,
    required this.item,
    required this.codProduto,
    required this.itemUnidadeMedida,
    required this.codUnidadeMedida,
    required this.unidadeMedidaDescricao,
    required this.unidadeMedidaPadrao,
    required this.tipoFatorConversao,
    required this.fatorConversao,
    this.codigoBarras,
    this.observacao,
  });

  SeparateItemUnidadeMedidaConsultationModel copyWith({
    int? codEmpresa,
    int? codSepararEstoque,
    String? item,
    int? codProduto,
    String? itemUnidadeMedida,
    String? codUnidadeMedida,
    String? unidadeMedidaDescricao,
    Situation? unidadeMedidaPadrao,
    TipoFatorConversao? tipoFatorConversao,
    double? fatorConversao,
    String? codigoBarras,
    String? observacao,
  }) {
    return SeparateItemUnidadeMedidaConsultationModel(
      codEmpresa: codEmpresa ?? this.codEmpresa,
      codSepararEstoque: codSepararEstoque ?? this.codSepararEstoque,
      item: item ?? this.item,
      codProduto: codProduto ?? this.codProduto,
      itemUnidadeMedida: itemUnidadeMedida ?? this.itemUnidadeMedida,
      codUnidadeMedida: codUnidadeMedida ?? this.codUnidadeMedida,
      unidadeMedidaDescricao: unidadeMedidaDescricao ?? this.unidadeMedidaDescricao,
      unidadeMedidaPadrao: unidadeMedidaPadrao ?? this.unidadeMedidaPadrao,
      tipoFatorConversao: tipoFatorConversao ?? this.tipoFatorConversao,
      fatorConversao: fatorConversao ?? this.fatorConversao,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      observacao: observacao ?? this.observacao,
    );
  }

  factory SeparateItemUnidadeMedidaConsultationModel.fromJson(Map<String, dynamic> json) {
    try {
      return SeparateItemUnidadeMedidaConsultationModel(
        codEmpresa: json['CodEmpresa'],
        codSepararEstoque: json['CodSepararEstoque'],
        item: json['Item'],
        codProduto: json['CodProduto'],
        itemUnidadeMedida: json['ItemUnidadeMedida'],
        codUnidadeMedida: json['CodUnidadeMedida'],
        unidadeMedidaDescricao: json['UnidadeMedidaDescricao'],
        unidadeMedidaPadrao: Situation.fromCodeWithFallback(json['UnidadeMedidaPadrao'] ?? 'S'),
        tipoFatorConversao: TipoFatorConversao.fromCodeWithFallback(json['TipoFatorConversao'] ?? 'M'),
        fatorConversao: AppHelper.stringToDouble(json['FatorConversao']),
        codigoBarras: json['CodigoBarras'],
        observacao: json['Observacao'],
      );
    } catch (_) {
      rethrow;
    }
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<SeparateItemUnidadeMedidaConsultationModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => SeparateItemUnidadeMedidaConsultationModel.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodSepararEstoque': codSepararEstoque,
      'Item': item,
      'CodProduto': codProduto,
      'ItemUnidadeMedida': itemUnidadeMedida,
      'CodUnidadeMedida': codUnidadeMedida,
      'UnidadeMedidaDescricao': unidadeMedidaDescricao,
      'UnidadeMedidaPadrao': unidadeMedidaPadrao.code,
      'TipoFatorConversao': tipoFatorConversao.code,
      'FatorConversao': fatorConversao,
      'CodigoBarras': codigoBarras,
      'Observacao': observacao,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeparateItemUnidadeMedidaConsultationModel &&
        other.codEmpresa == codEmpresa &&
        other.codSepararEstoque == codSepararEstoque &&
        other.item == item &&
        other.codProduto == codProduto &&
        other.itemUnidadeMedida == itemUnidadeMedida;
  }

  @override
  int get hashCode =>
      codEmpresa.hashCode ^
      codSepararEstoque.hashCode ^
      item.hashCode ^
      codProduto.hashCode ^
      itemUnidadeMedida.hashCode;

  @override
  String toString() {
    return '''
      ExpedicaoSepararItemUnidadeMedidaConsultaModel(
        codEmpresa: $codEmpresa, 
        codSepararEstoque: $codSepararEstoque, 
        item: $item, 
        codProduto: $codProduto, 
        itemUnidadeMedida: $itemUnidadeMedida, 
        codUnidadeMedida: $codUnidadeMedida, 
        unidadeMedidaDescricao: $unidadeMedidaDescricao, 
        unidadeMedidaPadrao: $unidadeMedidaPadrao, 
        tipoFatorConversao: $tipoFatorConversao, 
        fatorConversao: $fatorConversao, 
        codigoBarras: $codigoBarras, 
        observacao: $observacao
    )''';
  }
}
