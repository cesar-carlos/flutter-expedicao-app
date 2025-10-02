import 'package:exp/domain/models/user_system_models.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/domain/models/situation/situation_model.dart';
import 'package:exp/domain/repositories/basic_consultation_repository.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/di/locator.dart';

/// Serviço para validações relacionadas a carrinhos de separação
class CartValidationService {
  /// Verifica se o usuário tem permissão para editar/separar carrinho de outro usuário
  static bool canEditOtherUserCart(UserSystemModel? userModel) {
    return userModel?.editaCarrinhoOutroUsuario == Situation.ativo;
  }

  /// Verifica se o usuário tem permissão para salvar carrinho de outro usuário
  static bool canSaveOtherUserCart(UserSystemModel? userModel) {
    return userModel?.salvaCarrinhoOutroUsuario == Situation.ativo;
  }

  /// Verifica se o usuário tem permissão para excluir carrinho de outro usuário
  static bool canDeleteOtherUserCart(UserSystemModel? userModel) {
    return userModel?.excluiCarrinhoOutroUsuario == Situation.ativo;
  }

  /// Verifica se o usuário é o dono do carrinho ou tem permissão especial
  ///
  /// [currentUserCode] - Código do usuário atual
  /// [cartOwnerCode] - Código do usuário que incluiu o carrinho
  /// [hasPermission] - Se o usuário tem permissão especial (editar/salvar/excluir)
  ///
  /// Retorna true se o usuário pode acessar o carrinho, false caso contrário
  static bool canAccessCart({required int? currentUserCode, required int cartOwnerCode, required bool hasPermission}) {
    if (currentUserCode == null) return false;

    // Usuário é o dono do carrinho
    if (currentUserCode == cartOwnerCode) return true;

    // Usuário tem permissão especial
    return hasPermission;
  }

  /// Verifica se há itens disponíveis para o setor do usuário
  ///
  /// [codEmpresa] - Código da empresa
  /// [codOrigem] - Código da origem (separação)
  /// [userSectorCode] - Código do setor do usuário
  ///
  /// Retorna true se há itens disponíveis, false caso contrário
  static Future<bool> hasItemsForUserSector({
    required int codEmpresa,
    required int codOrigem,
    required int userSectorCode,
  }) async {
    try {
      final repository = locator<BasicConsultationRepository<SeparateItemConsultationModel>>();

      // Buscar todos os itens da separação
      final queryBuilder = QueryBuilder()
        ..equals('CodEmpresa', codEmpresa.toString())
        ..equals('CodSepararEstoque', codOrigem.toString());

      final items = await repository.selectConsultation(queryBuilder);

      // Verificar se há itens sem setor ou do setor do usuário
      // Considera apenas itens que não foram completamente separados
      return items.any(
        (item) =>
            item.quantidadeSeparacao < item.quantidade &&
            (item.codSetorEstoque == null || item.codSetorEstoque == userSectorCode),
      );
    } catch (e) {
      // Em caso de erro, permitir acesso (evitar bloquear usuário por erro)
      return true;
    }
  }

  /// Resultado da validação de acesso ao carrinho
  static CartAccessValidationResult validateCartAccess({
    required int? currentUserCode,
    required ExpeditionCartRouteInternshipConsultationModel cart,
    required UserSystemModel? userModel,
    required CartAccessType accessType,
  }) {
    if (currentUserCode == null) {
      return CartAccessValidationResult(canAccess: false, reason: CartAccessDeniedReason.userNotFound);
    }

    // Verificar permissão baseada no tipo de acesso
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

    // Verificar se pode acessar
    final canAccess = CartValidationService.canAccessCart(
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

/// Tipo de acesso ao carrinho
enum CartAccessType {
  edit, // Separar/Editar
  save, // Salvar/Finalizar
  delete, // Cancelar/Excluir
}

/// Motivo da negação de acesso
enum CartAccessDeniedReason {
  userNotFound, // Usuário não encontrado
  differentUser, // Usuário diferente do dono
  noItemsForSector, // Sem itens para o setor
}

/// Resultado da validação de acesso ao carrinho
class CartAccessValidationResult {
  final bool canAccess;
  final CartAccessDeniedReason? reason;
  final String? cartOwnerName;

  const CartAccessValidationResult({required this.canAccess, this.reason, this.cartOwnerName});
}
