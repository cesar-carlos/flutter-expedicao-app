import 'package:data7_expedicao/core/validation/common/socket_validation_helper.dart';

class AddItemSeparationParams {
  final int codEmpresa;
  final int codSepararEstoque;
  final String sessionId;
  final int codCarrinhoPercurso;
  final String itemCarrinhoPercurso;
  final int codSeparador;
  final String nomeSeparador;
  final int codProduto;
  final String codUnidadeMedida;
  final double quantidade;

  const AddItemSeparationParams({
    required this.codEmpresa,
    required this.codSepararEstoque,
    required this.sessionId,
    required this.codCarrinhoPercurso,
    required this.itemCarrinhoPercurso,
    required this.codSeparador,
    required this.nomeSeparador,
    required this.codProduto,
    required this.codUnidadeMedida,
    required this.quantidade,
  });

  bool get isValid => validationErrors.isEmpty;

  List<String> get validationErrors {
    final errors = <String>[];

    if (codEmpresa <= 0) {
      errors.add('Código da empresa deve ser maior que zero');
    }

    if (codSepararEstoque <= 0) {
      errors.add('Código de separar estoque deve ser maior que zero');
    }

    if (sessionId.isEmpty) {
      errors.add('Session ID não pode estar vazio');
    } else {
      if (!SocketValidationHelper.isValidSocketSessionId(sessionId)) {
        errors.add('Session ID não possui formato válido do Socket.IO');
      }
    }

    if (codCarrinhoPercurso <= 0) {
      errors.add('Código do carrinho percurso deve ser maior que zero');
    }

    if (itemCarrinhoPercurso.isEmpty) {
      errors.add('Item carrinho percurso não pode estar vazio');
    } else if (itemCarrinhoPercurso.length > 5) {
      errors.add('Item carrinho percurso deve ter no máximo 5 caracteres');
    }

    if (codSeparador <= 0) {
      errors.add('Código do separador deve ser maior que zero');
    }

    if (nomeSeparador.isEmpty) {
      errors.add('Nome do separador não pode estar vazio');
    } else if (nomeSeparador.length > 30) {
      errors.add('Nome do separador deve ter no máximo 30 caracteres');
    }

    if (codProduto <= 0) {
      errors.add('Código do produto deve ser maior que zero');
    }

    if (codUnidadeMedida.isEmpty) {
      errors.add('Código da unidade de medida não pode estar vazio');
    } else if (codUnidadeMedida.length > 6) {
      errors.add('Código da unidade de medida deve ter no máximo 6 caracteres');
    }

    if (quantidade <= 0) {
      errors.add('Quantidade deve ser maior que zero');
    }

    if (quantidade > 9999.9999) {
      errors.add('Quantidade não pode exceder 9999.9999');
    }

    final quantidadeStr = quantidade.toStringAsFixed(4);
    final quantidadeParsed = double.parse(quantidadeStr);
    if ((quantidade - quantidadeParsed).abs() > 0.0001) {
      errors.add('Quantidade deve ter no máximo 4 casas decimais');
    }

    return errors;
  }

  String get description {
    return 'AddItemSeparationParams('
        'codEmpresa: $codEmpresa, '
        'codSepararEstoque: $codSepararEstoque, '
        'sessionId: $sessionId, '
        'codCarrinhoPercurso: $codCarrinhoPercurso, '
        'itemCarrinhoPercurso: $itemCarrinhoPercurso, '
        'codSeparador: $codSeparador, '
        'nomeSeparador: $nomeSeparador, '
        'codProduto: $codProduto, '
        'codUnidadeMedida: $codUnidadeMedida, '
        'quantidade: $quantidade'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddItemSeparationParams &&
        other.codEmpresa == codEmpresa &&
        other.codSepararEstoque == codSepararEstoque &&
        other.sessionId == sessionId &&
        other.codCarrinhoPercurso == codCarrinhoPercurso &&
        other.itemCarrinhoPercurso == itemCarrinhoPercurso &&
        other.codSeparador == codSeparador &&
        other.nomeSeparador == nomeSeparador &&
        other.codProduto == codProduto &&
        other.codUnidadeMedida == codUnidadeMedida &&
        other.quantidade == quantidade;
  }

  @override
  int get hashCode => Object.hash(
    codEmpresa,
    codSepararEstoque,
    sessionId,
    codCarrinhoPercurso,
    itemCarrinhoPercurso,
    codSeparador,
    nomeSeparador,
    codProduto,
    codUnidadeMedida,
    quantidade,
  );

  @override
  String toString() => description;
}
