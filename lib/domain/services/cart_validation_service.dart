import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';

class CartValidationService {
  static const int _probePageSize = 20;

  final BasicConsultationRepository<SeparateItemConsultationModel> _repository;

  CartValidationService({required BasicConsultationRepository<SeparateItemConsultationModel> repository})
    : _repository = repository;

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

  bool hasPendingItemsForUserSector({
    required Iterable<SeparateItemConsultationModel> items,
    required int userSectorCode,
  }) {
    for (final item in items) {
      final sector = item.codSetorEstoque;
      if (sector != null && sector != userSectorCode) {
        continue;
      }
      if (_isPendingForSector(item)) {
        return true;
      }
    }
    return false;
  }

  Future<bool> hasItemsForUserSector({
    required int codEmpresa,
    required int codOrigem,
    required int userSectorCode,
  }) async {
    try {
      final bySector = await _hasPendingOnQuery(
        QueryBuilder()
          ..equals('CodEmpresa', codEmpresa.toString())
          ..equals('CodSepararEstoque', codOrigem.toString())
          ..equals('CodSetorEstoque', userSectorCode.toString()),
      );
      if (bySector) {
        return true;
      }

      return await _hasPendingOnQuery(
        QueryBuilder()
          ..equals('CodEmpresa', codEmpresa.toString())
          ..equals('CodSepararEstoque', codOrigem.toString())
          ..isNull('CodSetorEstoque'),
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

  Future<bool> _hasPendingOnQuery(QueryBuilder base) async {
    for (var pageIndex = 0; ; pageIndex++) {
      final query = base.copy()
        ..paginate(limit: _probePageSize, offset: pageIndex * _probePageSize, page: pageIndex + 1)
        ..orderByAsc('Item')
        ..orderByAsc('CodProduto');
      final items = await _repository.selectConsultation(query);
      if (items.any(_isPendingForSector)) {
        return true;
      }
      if (items.length < _probePageSize) {
        return false;
      }
    }
  }

  bool _isPendingForSector(SeparateItemConsultationModel item) {
    return item.quantidadeSeparacao < item.quantidade;
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

enum CartAccessType { edit, save, delete }

enum CartAccessDeniedReason { userNotFound, differentUser, noItemsForSector }

class CartAccessValidationResult {
  final bool canAccess;
  final CartAccessDeniedReason? reason;
  final String? cartOwnerName;

  const CartAccessValidationResult({required this.canAccess, this.reason, this.cartOwnerName});
}
