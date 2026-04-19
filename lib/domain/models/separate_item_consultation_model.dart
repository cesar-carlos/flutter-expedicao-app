import 'package:data7_expedicao/core/utils/app_helper.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/core/utils/json_parse_helpers.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_unidade_medida_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/tipo_fator_conversao_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_status.dart';
import 'package:data7_expedicao/core/results/index.dart';

class SeparateItemConsultationModel {
  final int codEmpresa;
  final int codSepararEstoque;
  final String item;
  final ExpeditionOrigem origem;
  final int codOrigem;
  final String? itemOrigem;
  final int codProduto;
  final String nomeProduto;
  final Situation ativo;
  final String codTipoProduto;
  final String codUnidadeMedida;
  final String nomeUnidadeMedida;
  final int codGrupoProduto;
  final String nomeGrupoProduto;
  final int? codMarca;
  final String? nomeMarca;
  final int? codSetorEstoque;
  final String? nomeSetorEstoque;
  final String? ncm;
  final String? codigoBarras;
  final String? codigoBarras2;
  final String? codigoReferencia;
  final String? codigoFornecedor;
  final String? codigoFabricante;
  final String? codigoOriginal;
  final String? endereco;
  final String? enderecoDescricao;
  final int codLocalArmazenagem;
  final String nomeLocaArmazenagem;
  final double quantidade;
  final double quantidadeInterna;
  final double quantidadeExterna;
  final double quantidadeSeparacao;

  final List<SeparateItemUnidadeMedidaConsultationModel> unidadeMedidas;

  SeparateItemConsultationModel({
    required this.codEmpresa,
    required this.codSepararEstoque,
    required this.item,
    required this.origem,
    required this.codOrigem,
    this.itemOrigem,
    required this.codProduto,
    required this.nomeProduto,
    required this.ativo,
    required this.codTipoProduto,
    required this.codUnidadeMedida,
    required this.nomeUnidadeMedida,
    required this.codGrupoProduto,
    required this.nomeGrupoProduto,
    this.codMarca,
    this.nomeMarca,
    this.codSetorEstoque,
    this.nomeSetorEstoque,
    this.ncm,
    this.codigoBarras,
    this.codigoBarras2,
    this.codigoReferencia,
    this.codigoFornecedor,
    this.codigoFabricante,
    this.codigoOriginal,
    this.endereco,
    this.enderecoDescricao,
    required this.codLocalArmazenagem,
    required this.nomeLocaArmazenagem,
    required this.quantidade,
    required this.quantidadeInterna,
    required this.quantidadeExterna,
    required this.quantidadeSeparacao,
    required this.unidadeMedidas,
  });

  SeparateItemConsultationModel copyWith({
    int? codEmpresa,
    int? codSepararEstoque,
    String? item,
    ExpeditionOrigem? origem,
    int? codOrigem,
    String? itemOrigem,
    int? codProduto,
    String? nomeProduto,
    Situation? ativo,
    String? codTipoProduto,
    String? codUnidadeMedida,
    String? nomeUnidadeMedida,
    int? codGrupoProduto,
    String? nomeGrupoProduto,
    int? codMarca,
    String? nomeMarca,
    int? codSetorEstoque,
    String? nomeSetorEstoque,
    String? ncm,
    String? codigoBarras,
    String? codigoBarras2,
    String? codigoReferencia,
    String? codigoFornecedor,
    String? codigoFabricante,
    String? codigoOriginal,
    String? endereco,
    String? enderecoDescricao,
    int? codLocalArmazenagem,
    String? nomeLocaArmazenagem,
    double? quantidade,
    double? quantidadeInterna,
    double? quantidadeExterna,
    double? quantidadeSeparacao,
    List<SeparateItemUnidadeMedidaConsultationModel>? unidadeMedidas,
  }) {
    return SeparateItemConsultationModel(
      codEmpresa: codEmpresa ?? this.codEmpresa,
      codSepararEstoque: codSepararEstoque ?? this.codSepararEstoque,
      item: item ?? this.item,
      origem: origem ?? this.origem,
      codOrigem: codOrigem ?? this.codOrigem,
      itemOrigem: itemOrigem ?? this.itemOrigem,
      codProduto: codProduto ?? this.codProduto,
      nomeProduto: nomeProduto ?? this.nomeProduto,
      ativo: ativo ?? this.ativo,
      codTipoProduto: codTipoProduto ?? this.codTipoProduto,
      codUnidadeMedida: codUnidadeMedida ?? this.codUnidadeMedida,
      nomeUnidadeMedida: nomeUnidadeMedida ?? this.nomeUnidadeMedida,
      codGrupoProduto: codGrupoProduto ?? this.codGrupoProduto,
      nomeGrupoProduto: nomeGrupoProduto ?? this.nomeGrupoProduto,
      codMarca: codMarca ?? this.codMarca,
      nomeMarca: nomeMarca ?? this.nomeMarca,
      codSetorEstoque: codSetorEstoque ?? this.codSetorEstoque,
      nomeSetorEstoque: nomeSetorEstoque ?? this.nomeSetorEstoque,
      ncm: ncm ?? this.ncm,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      codigoBarras2: codigoBarras2 ?? this.codigoBarras2,
      codigoReferencia: codigoReferencia ?? this.codigoReferencia,
      codigoFornecedor: codigoFornecedor ?? this.codigoFornecedor,
      codigoFabricante: codigoFabricante ?? this.codigoFabricante,
      codigoOriginal: codigoOriginal ?? this.codigoOriginal,
      endereco: endereco ?? this.endereco,
      enderecoDescricao: enderecoDescricao ?? this.enderecoDescricao,
      codLocalArmazenagem: codLocalArmazenagem ?? this.codLocalArmazenagem,
      nomeLocaArmazenagem: nomeLocaArmazenagem ?? this.nomeLocaArmazenagem,
      quantidade: quantidade ?? this.quantidade,
      quantidadeInterna: quantidadeInterna ?? this.quantidadeInterna,
      quantidadeExterna: quantidadeExterna ?? this.quantidadeExterna,
      quantidadeSeparacao: quantidadeSeparacao ?? this.quantidadeSeparacao,
      unidadeMedidas: unidadeMedidas ?? this.unidadeMedidas,
    );
  }

  factory SeparateItemConsultationModel.fromJson(Map<String, dynamic> json) {
    // Bug anterior critico: parseamento da lista UnidadeMedidas
    // crashava inteira se UM item viesse mal-formado
    // (`map().toList()` propaga). Agora parsing item-by-item:
    // logamos e ignoramos itens invalidos, mantendo o restante.
    final unidadesRaw = json['UnidadeMedidas'];
    final unidades = <SeparateItemUnidadeMedidaConsultationModel>[];
    if (unidadesRaw is List) {
      for (var i = 0; i < unidadesRaw.length; i++) {
        final entry = unidadesRaw[i];
        if (entry is! Map) {
          AppLogger.warning(
            'SeparateItemConsultationModel: UnidadeMedidas[$i] nao e Map (${entry.runtimeType}); ignorando',
            tag: 'SeparateItemConsultationModel',
          );
          continue;
        }
        try {
          unidades.add(SeparateItemUnidadeMedidaConsultationModel.fromJson(Map<String, dynamic>.from(entry)));
        } catch (e, st) {
          AppLogger.warning(
            'SeparateItemConsultationModel: falha ao parsear UnidadeMedidas[$i]; ignorando',
            tag: 'SeparateItemConsultationModel',
            error: e,
            stackTrace: st,
          );
        }
      }
    }

    return SeparateItemConsultationModel(
      codEmpresa: JsonParse.parseIntOr(json['CodEmpresa'], 0),
      codSepararEstoque: JsonParse.parseIntOr(json['CodSepararEstoque'], 0),
      item: JsonParse.parseStringOr(json['Item'], ''),
      origem: ExpeditionOrigem.fromCodeWithFallback(JsonParse.parseStringOr(json['Origem'], '')),
      codOrigem: JsonParse.parseIntOr(json['CodOrigem'], 0),
      itemOrigem: JsonParse.parseStringOrNull(json['ItemOrigem']),
      codProduto: JsonParse.parseIntOr(json['CodProduto'], 0),
      nomeProduto: JsonParse.parseStringOr(json['NomeProduto'], ''),
      ativo: Situation.fromCodeWithFallback(JsonParse.parseStringOr(json['Ativo'], 'N')),
      codTipoProduto: JsonParse.parseStringOr(json['CodTipoProduto'], ''),
      codUnidadeMedida: JsonParse.parseStringOr(json['CodUnidadeMedida'], ''),
      nomeUnidadeMedida: JsonParse.parseStringOr(json['NomeUnidadeMedida'], ''),
      codGrupoProduto: JsonParse.parseIntOr(json['CodGrupoProduto'], 0),
      nomeGrupoProduto: JsonParse.parseStringOr(json['NomeGrupoProduto'], ''),
      codMarca: JsonParse.parseInt(json['CodMarca']),
      nomeMarca: JsonParse.parseStringOrNull(json['NomeMarca']),
      codSetorEstoque: JsonParse.parseInt(json['CodSetorEstoque']),
      nomeSetorEstoque: JsonParse.parseStringOrNull(json['NomeSetorEstoque']),
      ncm: JsonParse.parseStringOr(json['NCM'], '00000000'),
      codigoBarras: JsonParse.parseStringOrNull(json['CodigoBarras']),
      codigoBarras2: JsonParse.parseStringOrNull(json['CodigoBarras2']),
      codigoReferencia: JsonParse.parseStringOrNull(json['CodigoReferencia']),
      codigoFornecedor: JsonParse.parseStringOrNull(json['CodigoFornecedor']),
      codigoFabricante: JsonParse.parseStringOrNull(json['CodigoFabricante']),
      codigoOriginal: JsonParse.parseStringOrNull(json['CodigoOriginal']),
      endereco: JsonParse.parseStringOrNull(json['Endereco']),
      enderecoDescricao: JsonParse.parseStringOrNull(json['EnderecoDescricao']),
      codLocalArmazenagem: JsonParse.parseIntOr(json['CodLocalArmazenagem'], 0),
      nomeLocaArmazenagem: JsonParse.parseStringOr(json['NomeLocaArmazenagem'], ''),
      quantidade: AppHelper.stringToDouble(json['Quantidade']),
      quantidadeInterna: AppHelper.stringToDouble(json['QuantidadeInterna']),
      quantidadeExterna: AppHelper.stringToDouble(json['QuantidadeExterna']),
      quantidadeSeparacao: AppHelper.stringToDouble(json['QuantidadeSeparacao']),
      unidadeMedidas: unidades,
    );
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<SeparateItemConsultationModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => SeparateItemConsultationModel.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodSepararEstoque': codSepararEstoque,
      'Item': item,
      'Origem': origem.code,
      'CodOrigem': codOrigem,
      'ItemOrigem': itemOrigem,
      'CodProduto': codProduto,
      'NomeProduto': nomeProduto,
      'Ativo': ativo.code,
      'CodTipoProduto': codTipoProduto,
      'CodUnidadeMedida': codUnidadeMedida,
      'NomeUnidadeMedida': nomeUnidadeMedida,
      'CodGrupoProduto': codGrupoProduto,
      'NomeGrupoProduto': nomeGrupoProduto,
      'CodMarca': codMarca,
      'NomeMarca': nomeMarca,
      'CodSetorEstoque': codSetorEstoque,
      'NomeSetorEstoque': nomeSetorEstoque,
      'NCM': ncm,
      'CodigoBarras': codigoBarras,
      'CodigoBarras2': codigoBarras2,
      'CodigoReferencia': codigoReferencia,
      'CodigoFornecedor': codigoFornecedor,
      'CodigoFabricante': codigoFabricante,
      'CodigoOriginal': codigoOriginal,
      'Endereco': endereco,
      'EnderecoDescricao': enderecoDescricao,
      'CodLocalArmazenagem': codLocalArmazenagem,
      'NomeLocaArmazenagem': nomeLocaArmazenagem,
      'Quantidade': quantidade.toStringAsFixed(4),
      'QuantidadeInterna': quantidadeInterna.toStringAsFixed(4),
      'QuantidadeExterna': quantidadeExterna.toStringAsFixed(4),
      'QuantidadeSeparacao': quantidadeSeparacao.toStringAsFixed(4),
      'UnidadeMedidas': unidadeMedidas.map((unidade) => unidade.toJson()).toList(),
    };
  }

  // === GETTERS PARA ENUMS ===

  /// Retorna o código da origem
  String get origemCode => origem.code;

  /// Retorna a descrição da origem
  String get origemDescription => origem.description;

  /// Retorna o código do ativo
  String get ativoCode => ativo.code;

  /// Retorna a descrição do ativo
  String get ativoDescription => ativo.description;

  /// Verifica se o produto está ativo
  bool get isAtivo => ativo == Situation.ativo;

  /// Retorna a situação de separação do item
  SeparationItemStatus get situacaoSeparacao =>
      SeparationItemStatus.fromQuantities(quantidadeTotal: quantidade, quantidadeSeparacao: quantidadeSeparacao);

  /// Retorna a quantidade restante para separar
  double get quantidadeRestante => quantidade - quantidadeSeparacao;

  /// Verifica se o item está completamente separado
  bool get isCompletamenteSeparado => quantidadeSeparacao >= quantidade;

  /// Verifica se o item está pendente (não foi separado)
  bool get isPendente => quantidadeSeparacao <= 0;

  /// Verifica se o item está parcialmente separado
  bool get isParcialmenteSeparado => quantidadeSeparacao > 0 && quantidadeSeparacao < quantidade;

  /// Retorna a unidade de medida padrão (onde unidadeMedidaPadrao == Situation.ativo)
  SeparateItemUnidadeMedidaConsultationModel? get unidadeMedidaPadrao =>
      unidadeMedidas.where((unidade) => unidade.unidadeMedidaPadrao == Situation.ativo).firstOrNull;

  /// Retorna todas as unidades de medida diferentes da padrão
  List<SeparateItemUnidadeMedidaConsultationModel> get unidadesMedidaAlternativas =>
      unidadeMedidas.where((unidade) => unidade.unidadeMedidaPadrao == Situation.inativo).toList();

  /// Converte a quantidade baseada no código de barras fornecido
  /// Procura pela unidade de medida que corresponde ao código de barras
  /// e aplica a conversão baseada no tipo de fator (multiplicação ou divisão)
  ///
  /// [codigoBarras] - O código de barras escaneado
  /// [quantidadeRecebida] - A quantidade recebida para ser convertida
  ///
  /// Retorna a quantidade convertida ou null se o código de barras não for encontrado
  double? converterQuantidadePorCodigoBarras(String codigoBarras, double quantidadeRecebida) {
    try {
      // Procura pela unidade de medida que corresponde ao código de barras
      final unidadeMedida = unidadeMedidas.firstWhere(
        (unidade) => unidade.codigoBarras != null && unidade.codigoBarras!.trim() == codigoBarras.trim(),
        orElse: () => throw StateError('Código de barras não encontrado: $codigoBarras'),
      );

      // Aplica a conversão baseada no tipo de fator
      switch (unidadeMedida.tipoFatorConversao) {
        case TipoFatorConversao.multiplicacao:
          return quantidadeRecebida * unidadeMedida.fatorConversao;
        case TipoFatorConversao.divisao:
          return unidadeMedida.fatorConversao != 0
              ? quantidadeRecebida / unidadeMedida.fatorConversao
              : throw ArgumentError('Fator de conversão não pode ser zero para divisão');
      }
    } catch (e) {
      return null;
    }
  }

  /// Busca a unidade de medida pelo código de barras
  ///
  /// [codigoBarras] - O código de barras para buscar
  ///
  /// Retorna a unidade de medida correspondente ou null se não encontrada
  SeparateItemUnidadeMedidaConsultationModel? buscarUnidadeMedidaPorCodigoBarras(String codigoBarras) {
    try {
      return unidadeMedidas.firstWhere(
        (unidade) => unidade.codigoBarras != null && unidade.codigoBarras!.trim() == codigoBarras.trim(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return '''
      ExpedicaoSepararItemConsultaModel(
        codEmpresa: $codEmpresa, 
        codSepararEstoque: $codSepararEstoque, 
        item: $item, 
        origem: ${origem.description} (${origem.code}), 
        codOrigem: $codOrigem, 
        itemOrigem: $itemOrigem, 
        codProduto: $codProduto, 
        nomeProduto: $nomeProduto, 
        ativo: ${ativo.description} (${ativo.code}), 
        codTipoProduto: $codTipoProduto, 
        codUnidadeMedida: $codUnidadeMedida, 
        nomeUnidadeMedida: $nomeUnidadeMedida, 
        codGrupoProduto: $codGrupoProduto, 
        nomeGrupoProduto: $nomeGrupoProduto, 
        codMarca: $codMarca, 
        nomeMarca: $nomeMarca, 
        codSetorEstoque: $codSetorEstoque, 
        nomeSetorEstoque: $nomeSetorEstoque, 
        ncm: $ncm, 
        codigoBarras: $codigoBarras, 
        codigoBarras2: $codigoBarras2, 
        codigoReferencia: $codigoReferencia, 
        codigoFornecedor: $codigoFornecedor, 
        codigoFabricante: $codigoFabricante, 
        codigoOriginal: $codigoOriginal, 
        endereco: $endereco, 
        enderecoDescricao: $enderecoDescricao, 
        codLocalArmazenagem: $codLocalArmazenagem, 
        nomeLocaArmazenagem: $nomeLocaArmazenagem, 
        quantidade: $quantidade, 
        quantidadeInterna: $quantidadeInterna, 
        quantidadeExterna: $quantidadeExterna, 
        quantidadeSeparacao: $quantidadeSeparacao
    )''';
  }
}
