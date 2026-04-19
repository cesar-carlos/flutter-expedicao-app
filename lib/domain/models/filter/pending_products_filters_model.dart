import 'package:data7_expedicao/core/utils/json_parse_helpers.dart';
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
    final situacaoRaw = json['situacao'];
    final setorRaw = json['setorEstoque'];
    return PendingProductsFiltersModel(
      codProduto: JsonParse.parseStringOrNull(json['codProduto']),
      codigoBarras: JsonParse.parseStringOrNull(json['codigoBarras']),
      nomeProduto: JsonParse.parseStringOrNull(json['nomeProduto']),
      enderecoDescricao: JsonParse.parseStringOrNull(json['enderecoDescricao']),
      situacao: situacaoRaw != null
          ? SeparationItemStatus.values.firstWhere(
              (e) => e.code == situacaoRaw.toString(),
              orElse: () => SeparationItemStatus.pendente,
            )
          : null,
      setorEstoque: setorRaw is Map ? ExpeditionSectorStockModel.fromJson(Map<String, dynamic>.from(setorRaw)) : null,
    );
  }

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
