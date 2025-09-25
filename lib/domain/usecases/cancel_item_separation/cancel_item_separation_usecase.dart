import 'package:exp/core/results/index.dart';
import 'package:exp/core/errors/app_error.dart';
import 'package:exp/domain/models/separate_item_model.dart';
import 'package:exp/domain/models/separation_item_model.dart';
import 'package:exp/domain/models/expedition_item_situation_model.dart';
import 'package:exp/domain/usecases/cancel_item_separation/cancel_item_separation_params.dart';
import 'package:exp/domain/usecases/cancel_item_separation/cancel_item_separation_success.dart';
import 'package:exp/domain/usecases/cancel_item_separation/cancel_item_separation_failure.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/domain/repositories/basic_repository.dart';
import 'package:exp/data/services/user_session_service.dart';

/// Use case para cancelar itens de separação
///
/// Este use case é responsável por:
/// - Validar parâmetros de entrada
/// - Buscar itens de separação a serem cancelados
/// - Calcular quantidades canceladas por produto
/// - Atualizar quantidades em separate_item (subtraindo)
/// - Atualizar situação em separation_item para CA (cancelado)
class CancelItemSeparationUseCase {
  final BasicRepository<SeparateItemModel> _separateItemRepository;
  final BasicRepository<SeparationItemModel> _separationItemRepository;
  final UserSessionService _userSessionService;

  CancelItemSeparationUseCase({
    required BasicRepository<SeparateItemModel> separateItemRepository,
    required BasicRepository<SeparationItemModel> separationItemRepository,
    required UserSessionService userSessionService,
  }) : _separateItemRepository = separateItemRepository,
       _separationItemRepository = separationItemRepository,
       _userSessionService = userSessionService;

  /// Cancela itens de separação
  ///
  /// [params] - Parâmetros para cancelamento
  ///
  /// Retorna [Result<CancelItemSeparationSuccess>] com sucesso ou falha
  Future<Result<CancelItemSeparationSuccess>> call(CancelItemSeparationParams params) async {
    try {
      // 1. Validar parâmetros
      if (!params.isValid) {
        final errors = params.validationErrors;
        return failure(CancelItemSeparationFailure.invalidParams('Parâmetros inválidos: ${errors.join(', ')}'));
      }

      // 2. Verificar usuário autenticado
      final appUser = await _userSessionService.loadUserSession();
      if (appUser?.userSystemModel == null) {
        return failure(CancelItemSeparationFailure.userNotFound());
      }

      // 3. Buscar itens de separação a serem cancelados
      final separationItems = await _findSeparationItems(params);
      if (separationItems.isEmpty) {
        return failure(CancelItemSeparationFailure.itemsNotFound());
      }

      // 4. Calcular quantidades canceladas por produto
      final cancelledQuantitiesByProduct = _calculateCancelledQuantitiesByProduct(separationItems);

      // 5. Buscar e atualizar separate_items (subtrair quantidades)
      final updatedSeparateItems = await _updateSeparateItemQuantities(params, cancelledQuantitiesByProduct);
      if (updatedSeparateItems.isEmpty) {
        return failure(
          CancelItemSeparationFailure.updateSeparateItemFailed('Falha ao atualizar quantidades de separação'),
        );
      }

      // 6. Atualizar separation_items para situação CA (cancelado)
      final cancelledSeparationItems = await _updateSeparationItemsToCancel(separationItems);
      if (cancelledSeparationItems.isEmpty) {
        return failure(CancelItemSeparationFailure.updateSeparationItemFailed('Falha ao cancelar itens de separação'));
      }

      return success(
        CancelItemSeparationSuccess.create(
          updatedSeparateItems: updatedSeparateItems,
          cancelledSeparationItems: cancelledSeparationItems,
          cancelledQuantitiesByProduct: cancelledQuantitiesByProduct,
        ),
      );
    } on DataError catch (e) {
      return failure(CancelItemSeparationFailure.networkError(e.message, Exception(e.message)));
    } on Exception catch (e) {
      return failure(CancelItemSeparationFailure.unknown(e.toString(), e));
    }
  }

  /// Busca os itens de separação que devem ser cancelados
  Future<List<SeparationItemModel>> _findSeparationItems(CancelItemSeparationParams params) async {
    try {
      final separationItems = await _separationItemRepository.select(
        QueryBuilder()
            .equals('CodEmpresa', params.codEmpresa)
            .equals('CodSepararEstoque', params.codSepararEstoque)
            .equals('CodCarrinhoPercurso', params.codCarrinhoPercurso)
            .equals('ItemCarrinhoPercurso', params.itemCarrinhoPercurso)
            .notEquals('Situacao', ExpeditionItemSituation.cancelado.code),
      );

      return separationItems;
    } catch (e) {
      rethrow;
    }
  }

  /// Calcula as quantidades canceladas agrupadas por produto
  Map<int, double> _calculateCancelledQuantitiesByProduct(List<SeparationItemModel> separationItems) {
    final Map<int, double> quantitiesByProduct = {};

    for (final item in separationItems) {
      final codProduto = item.codProduto;
      final quantidade = item.quantidade;

      quantitiesByProduct[codProduto] = (quantitiesByProduct[codProduto] ?? 0.0) + quantidade;
    }

    return quantitiesByProduct;
  }

  /// Atualiza as quantidades dos separate_items (subtrai as quantidades canceladas)
  Future<List<SeparateItemModel>> _updateSeparateItemQuantities(
    CancelItemSeparationParams params,
    Map<int, double> cancelledQuantitiesByProduct,
  ) async {
    try {
      final List<SeparateItemModel> updatedItems = [];

      for (final codProduto in cancelledQuantitiesByProduct.keys) {
        final cancelledQuantity = cancelledQuantitiesByProduct[codProduto]!;

        // Buscar o separate_item correspondente
        final separateItems = await _separateItemRepository.select(
          QueryBuilder()
              .equals('CodEmpresa', params.codEmpresa)
              .equals('CodSepararEstoque', params.codSepararEstoque)
              .equals('CodProduto', codProduto),
        );

        if (separateItems.isNotEmpty) {
          final separateItem = separateItems.first;

          // Calcular nova quantidade de separação (subtraindo a quantidade cancelada)
          final newQuantidadeSeparacao = separateItem.quantidadeSeparacao - cancelledQuantity;

          // Garantir que não fique negativo
          final finalQuantidadeSeparacao = newQuantidadeSeparacao < 0 ? 0.0 : newQuantidadeSeparacao;

          // Atualizar o item
          final updatedItem = separateItem.copyWith(quantidadeSeparacao: finalQuantidadeSeparacao);

          final updateResult = await _separateItemRepository.update(updatedItem);
          if (updateResult.isNotEmpty) {
            updatedItems.addAll(updateResult);
          }
        }
      }

      return updatedItems;
    } catch (e) {
      rethrow;
    }
  }

  /// Atualiza os separation_items para situação CA (cancelado)
  Future<List<SeparationItemModel>> _updateSeparationItemsToCancel(List<SeparationItemModel> separationItems) async {
    try {
      final List<SeparationItemModel> updatedItems = [];

      for (final item in separationItems) {
        final updatedItem = item.copyWith(situacao: ExpeditionItemSituation.cancelado);

        final updateResult = await _separationItemRepository.update(updatedItem);
        if (updateResult.isNotEmpty) {
          updatedItems.addAll(updateResult);
        }
      }

      return updatedItems;
    } catch (e) {
      rethrow;
    }
  }

  /// Verifica se existem itens para cancelar (método público)
  Future<bool> canCancelItems(CancelItemSeparationParams params) async {
    try {
      if (!params.isValid) return false;
      final separationItems = await _findSeparationItems(params);
      return separationItems.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Retorna informações sobre os itens que seriam cancelados (método público para preview)
  Future<Map<int, double>> getItemsToBeCancelled(CancelItemSeparationParams params) async {
    try {
      if (!params.isValid) return {};
      final separationItems = await _findSeparationItems(params);
      return _calculateCancelledQuantitiesByProduct(separationItems);
    } catch (e) {
      return {};
    }
  }
}
