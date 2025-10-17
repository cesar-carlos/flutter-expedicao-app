import 'package:data7_expedicao/domain/models/separation_item_status.dart';
import 'package:data7_expedicao/domain/models/expedition_sector_stock_model.dart';
import 'package:data7_expedicao/core/results/index.dart';

class PendingProductsFiltersModel {
  final String? codProduto;
  final String? codigoBarras;
  final String? nomeProduto;
  final String? enderecoDescricao;
  final SeparationItemStatus? situacao;
  final ExpeditionSectorStockModel? setorEstoque;

  const PendingProductsFiltersModel({
    this.codProduto,
    this.codigoBarras,
    this.nomeProduto,
    this.enderecoDescricao,
    this.situacao,
    this.setorEstoque,
  });

  factory PendingProductsFiltersModel.fromJson(Map<String, dynamic> json) {
    return PendingProductsFiltersModel(
      codProduto: json['codProduto'],
      codigoBarras: json['codigoBarras'],
      nomeProduto: json['nomeProduto'],
      enderecoDescricao: json['enderecoDescricao'],
      situacao: json['situacao'] != null
          ? SeparationItemStatus.values.firstWhere(
              (e) => e.code == json['situacao'],
              orElse: () => SeparationItemStatus.pendente,
            )
          : null,
      setorEstoque: json['setorEstoque'] != null ? ExpeditionSectorStockModel.fromJson(json['setorEstoque']) : null,
    );
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<PendingProductsFiltersModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => PendingProductsFiltersModel.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return {
      'codProduto': codProduto,
      'codigoBarras': codigoBarras,
      'nomeProduto': nomeProduto,
      'enderecoDescricao': enderecoDescricao,
      'situacao': situacao?.code,
      'setorEstoque': setorEstoque?.toJson(),
    };
  }

  bool get isEmpty =>
      codProduto == null &&
      codigoBarras == null &&
      nomeProduto == null &&
      enderecoDescricao == null &&
      situacao == null &&
      setorEstoque == null;

  bool get isNotEmpty => !isEmpty;

  PendingProductsFiltersModel copyWith({
    String? codProduto,
    String? codigoBarras,
    String? nomeProduto,
    String? enderecoDescricao,
    SeparationItemStatus? situacao,
    ExpeditionSectorStockModel? setorEstoque,
  }) {
    return PendingProductsFiltersModel(
      codProduto: codProduto ?? this.codProduto,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      nomeProduto: nomeProduto ?? this.nomeProduto,
      enderecoDescricao: enderecoDescricao ?? this.enderecoDescricao,
      situacao: situacao ?? this.situacao,
      setorEstoque: setorEstoque ?? this.setorEstoque,
    );
  }

  PendingProductsFiltersModel clear() {
    return const PendingProductsFiltersModel();
  }

  @override
  String toString() {
    return 'PendingProductsFiltersModel('
        'codProduto: $codProduto, '
        'codigoBarras: $codigoBarras, '
        'nomeProduto: $nomeProduto, '
        'enderecoDescricao: $enderecoDescricao, '
        'situacao: ${situacao?.description}, '
        'setorEstoque: ${setorEstoque?.descricao}'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PendingProductsFiltersModel &&
        other.codProduto == codProduto &&
        other.codigoBarras == codigoBarras &&
        other.nomeProduto == nomeProduto &&
        other.enderecoDescricao == enderecoDescricao &&
        other.situacao == situacao &&
        other.setorEstoque == setorEstoque;
  }

  @override
  int get hashCode {
    return Object.hash(codProduto, codigoBarras, nomeProduto, enderecoDescricao, situacao, setorEstoque);
  }
}
