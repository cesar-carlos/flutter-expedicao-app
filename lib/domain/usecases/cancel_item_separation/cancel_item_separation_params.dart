import 'package:exp/core/validation/common/socket_validation_helper.dart';

/// Parâmetros para cancelar um item específico da separação
class CancelItemSeparationParams {
  final int codEmpresa;
  final int codSepararEstoque;
  final String item;
  final String sessionId;

  const CancelItemSeparationParams({
    required this.codEmpresa,
    required this.codSepararEstoque,
    required this.item,
    required this.sessionId,
  });

  /// Valida se os parâmetros são válidos
  bool get isValid => validationErrors.isEmpty;

  /// Retorna uma lista de erros de validação
  List<String> get validationErrors {
    final errors = <String>[];

    if (codEmpresa <= 0) {
      errors.add('Código da empresa deve ser maior que zero');
    }

    if (codSepararEstoque <= 0) {
      errors.add('Código de separar estoque deve ser maior que zero');
    }

    if (item.isEmpty) {
      errors.add('Item não pode estar vazio');
    } else if (item.length > 5) {
      errors.add('Item deve ter no máximo 5 caracteres');
    }

    // Validação robusta do sessionId
    if (sessionId.isEmpty) {
      errors.add('Session ID não pode estar vazio');
    } else {
      // Validação de formato do sessionId do Socket.IO
      if (!SocketValidationHelper.isValidSocketSessionId(sessionId)) {
        errors.add('Session ID não possui formato válido do Socket.IO');
      }
    }

    return errors;
  }

  /// Retorna uma descrição dos parâmetros para logging
  String get description {
    return 'CancelItemSeparationParams('
        'codEmpresa: $codEmpresa, '
        'codSepararEstoque: $codSepararEstoque, '
        'item: $item, '
        'sessionId: $sessionId'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CancelItemSeparationParams &&
        other.codEmpresa == codEmpresa &&
        other.codSepararEstoque == codSepararEstoque &&
        other.item == item &&
        other.sessionId == sessionId;
  }

  @override
  int get hashCode => Object.hash(codEmpresa, codSepararEstoque, item, sessionId);

  @override
  String toString() => description;
}
