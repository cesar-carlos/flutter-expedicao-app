import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_item_situation_model.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart_item_separation/cancel_cart_item_separation_params.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart_item_separation/cancel_cart_item_separation_success.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart_item_separation/cancel_cart_item_separation_failure.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';

class CancelCardItemSeparationUseCase {
  final BasicRepository<SeparateItemModel> _separateItemRepository;
  final BasicRepository<SeparationItemModel> _separationItemRepository;
  final IUserSessionService _userSessionService;

  CancelCardItemSeparationUseCase({
    required BasicRepository<SeparateItemModel> separateItemRepository,
    required BasicRepository<SeparationItemModel> separationItemRepository,
    required IUserSessionService userSessionService,
  }) : _separateItemRepository = separateItemRepository,
       _separationItemRepository = separationItemRepository,
       _userSessionService = userSessionService;

  Future<Result<CancelCardItemSeparationSuccess>> call(CancelCardItemSeparationParams params) async {
    try {
      if (!params.isValid) {
        final errors = params.validationErrors;
        return failure(CancelCardItemSeparationFailure.invalidParams('Parâmetros inválidos: ${errors.join(', ')}'));
      }

      final appUser = await _userSessionService.loadUserSession();
      if (appUser?.userSystemModel == null) {
        return failure(CancelCardItemSeparationFailure.userNotFound());
      }

      final separationItems = await _findSeparationItems(params);
      if (separationItems.isEmpty) {
        return failure(CancelCardItemSeparationFailure.itemsNotFound());
      }
      final originalSeparationItems = List<SeparationItemModel>.from(separationItems);

      final cancelledQuantitiesByProduct = _calculateCancelledQuantitiesByProduct(separationItems);

      final updateSeparateItemsResult = await _updateSeparateItemQuantities(params, cancelledQuantitiesByProduct);
      if (updateSeparateItemsResult.updatedItems.isEmpty) {
        return failure(
          CancelCardItemSeparationFailure.updateSeparateItemFailed('Falha ao atualizar quantidades de separação'),
        );
      }

      final cancelledSeparationItems = await _updateSeparationItemsToCancel(separationItems);
      if (cancelledSeparationItems.isEmpty) {
        return failure(
          CancelCardItemSeparationFailure.updateSeparationItemFailed('Falha ao cancelar itens de separação'),
        );
      }

      return success(
        CancelCardItemSeparationSuccess.create(
          updatedSeparateItems: updateSeparateItemsResult.updatedItems,
          originalSeparateItems: updateSeparateItemsResult.originalItems,
          cancelledSeparationItems: cancelledSeparationItems,
          originalSeparationItems: originalSeparationItems,
          cancelledQuantitiesByProduct: cancelledQuantitiesByProduct,
        ),
      );
    } on DataError catch (e) {
      return failure(CancelCardItemSeparationFailure.networkError(e.message, Exception(e.message)));
    } on Exception catch (e) {
      return failure(CancelCardItemSeparationFailure.unknown(e.toString(), e));
    }
  }

  Future<List<SeparationItemModel>> _findSeparationItems(CancelCardItemSeparationParams params) async {
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

  Map<int, double> _calculateCancelledQuantitiesByProduct(List<SeparationItemModel> separationItems) {
    final Map<int, double> quantitiesByProduct = {};

    for (final item in separationItems) {
      final codProduto = item.codProduto;
      final quantidade = item.quantidade;

      quantitiesByProduct[codProduto] = (quantitiesByProduct[codProduto] ?? 0.0) + quantidade;
    }

    return quantitiesByProduct;
  }

  Future<_SeparateItemsUpdateResult> _updateSeparateItemQuantities(
    CancelCardItemSeparationParams params,
    Map<int, double> cancelledQuantitiesByProduct,
  ) async {
    try {
      final List<SeparateItemModel> updatedItems = [];
      final List<SeparateItemModel> originalItems = [];
      final separateItems = await _separateItemRepository.select(
        QueryBuilder().equals('CodEmpresa', params.codEmpresa).equals('CodSepararEstoque', params.codSepararEstoque),
      );
      final separateItemsByProduct = <int, SeparateItemModel>{
        for (final separateItem in separateItems) separateItem.codProduto: separateItem,
      };
      final updates = <Future<List<SeparateItemModel>>>[];

      for (final codProduto in cancelledQuantitiesByProduct.keys) {
        final cancelledQuantity = cancelledQuantitiesByProduct[codProduto]!;
        final separateItem = separateItemsByProduct[codProduto];
        if (separateItem == null) continue;
        originalItems.add(separateItem);
        final newQuantidadeSeparacao = separateItem.quantidadeSeparacao - cancelledQuantity;
        final finalQuantidadeSeparacao = newQuantidadeSeparacao < 0 ? 0.0 : newQuantidadeSeparacao;
        final updatedItem = separateItem.copyWith(quantidadeSeparacao: finalQuantidadeSeparacao);
        updates.add(_separateItemRepository.update(updatedItem));
      }

      if (updates.isNotEmpty) {
        const batchSize = 10;
        for (int i = 0; i < updates.length; i += batchSize) {
          final batch = updates.skip(i).take(batchSize);
          final results = await Future.wait(batch);
          for (final updateResult in results) {
            if (updateResult.isNotEmpty) {
              updatedItems.addAll(updateResult);
            }
          }
        }
      }

      return _SeparateItemsUpdateResult(updatedItems: updatedItems, originalItems: originalItems);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SeparationItemModel>> _updateSeparationItemsToCancel(List<SeparationItemModel> separationItems) async {
    try {
      final List<SeparationItemModel> updatedItems = [];
      final updates = separationItems
          .map((item) => _separationItemRepository.update(item.copyWith(situacao: ExpeditionItemSituation.cancelado)))
          .toList();

      if (updates.isNotEmpty) {
        const batchSize = 10;
        for (int i = 0; i < updates.length; i += batchSize) {
          final batch = updates.skip(i).take(batchSize);
          final results = await Future.wait(batch);
          for (final updateResult in results) {
            if (updateResult.isNotEmpty) {
              updatedItems.addAll(updateResult);
            }
          }
        }
      }

      return updatedItems;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> canCancelItems(CancelCardItemSeparationParams params) async {
    try {
      if (!params.isValid) return false;
      final separationItems = await _findSeparationItems(params);
      return separationItems.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<Map<int, double>> getItemsToBeCancelled(CancelCardItemSeparationParams params) async {
    try {
      if (!params.isValid) return {};
      final separationItems = await _findSeparationItems(params);
      return _calculateCancelledQuantitiesByProduct(separationItems);
    } catch (e) {
      return {};
    }
  }

  Future<bool> rollbackCancellation(CancelCardItemSeparationSuccess success) async {
    try {
      final separateUpdates = success.originalSeparateItems.map(_separateItemRepository.update).toList();
      final separationUpdates = success.originalSeparationItems.map(_separationItemRepository.update).toList();

      await _runInBatches(separateUpdates);
      await _runInBatches(separationUpdates);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _runInBatches(List<Future<List<dynamic>>> operations) async {
    if (operations.isEmpty) return;
    const batchSize = 10;
    for (int i = 0; i < operations.length; i += batchSize) {
      final batch = operations.skip(i).take(batchSize);
      await Future.wait(batch);
    }
  }
}

class _SeparateItemsUpdateResult {
  final List<SeparateItemModel> updatedItems;
  final List<SeparateItemModel> originalItems;

  const _SeparateItemsUpdateResult({required this.updatedItems, required this.originalItems});
}
