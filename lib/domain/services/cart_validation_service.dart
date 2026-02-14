import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';

class CartValidationService {
  final BasicConsultationRepository<SeparateItemConsultationModel> _repository;

  CartValidationService({
    required BasicConsultationRepository<SeparateItemConsultationModel> repository,
  }) : _repository = repository;

  bool canEditOtherUserCart(UserSystemModel? userModel) {
    return userModel?.editaCarrinhoOutroUsuario == Situation.ativo;
  }

  bool canSaveOtherUserCart(UserSystemModel? userModel) {
    return userModel?.salvaCarrinhoOutroUsuario == Situation.ativo;
  }

  bool canDeleteOtherUserCart(UserSystemModel? userModel) {
    return userModel?.excluiCarrinhoOutroUsuario == Situation.ativo;
  }

  bool canAccessCart({required int? currentUserCode, required int cartOwnerCode, required bool hasPermission}) {
    if (currentUserCode == null) return false;
    if (currentUserCode == cartOwnerCode) return true;
    return hasPermission;
  }

  Future<bool> hasItemsForUserSector({
    required int codEmpresa,
    required int codOrigem,
    required int userSectorCode,
  }) async {
    try {
      final queryBuilder = QueryBuilder()
        ..equals('CodEmpresa', codEmpresa.toString())
        ..equals('CodSepararEstoque', codOrigem.toString());

      final items = await _repository.selectConsultation(queryBuilder);

      return items.any(
        (item) =>
            item.quantidadeSeparacao < item.quantidade &&
            (item.codSetorEstoque == null || item.codSetorEstoque == userSectorCode),
      );
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Falha ao verificar itens por setor; acesso permitido por fallback.',
        tag: 'CartValidationService',
        error: e,
        stackTrace: stackTrace,
      );
      return true;
    }
  }

  CartAccessValidationResult validateCartAccess({
    required int? currentUserCode,
    required ExpeditionCartRouteInternshipConsultationModel cart,
    required UserSystemModel? userModel,
    required CartAccessType accessType,
  }) {
    if (currentUserCode == null) {
      return CartAccessValidationResult(canAccess: false, reason: CartAccessDeniedReason.userNotFound);
    }

    bool hasPermission = false;
    switch (accessType) {
      case CartAccessType.edit:
        hasPermission = canEditOtherUserCart(userModel);
        break;
      case CartAccessType.save:
        hasPermission = canSaveOtherUserCart(userModel);
        break;
      case CartAccessType.delete:
        hasPermission = canDeleteOtherUserCart(userModel);
        break;
    }

    final canAccess = canAccessCart(
      currentUserCode: currentUserCode,
      cartOwnerCode: cart.codUsuarioInicio,
      hasPermission: hasPermission,
    );

    if (!canAccess) {
      return CartAccessValidationResult(
        canAccess: false,
        reason: CartAccessDeniedReason.differentUser,
        cartOwnerName: cart.nomeUsuarioInicio,
      );
    }

    return CartAccessValidationResult(canAccess: true);
  }
}

enum CartAccessType {
  edit,
  save,
  delete,
}

enum CartAccessDeniedReason {
  userNotFound,
  differentUser,
  noItemsForSector,
}

class CartAccessValidationResult {
  final bool canAccess;
  final CartAccessDeniedReason? reason;
  final String? cartOwnerName;

  const CartAccessValidationResult({required this.canAccess, this.reason, this.cartOwnerName});
}
