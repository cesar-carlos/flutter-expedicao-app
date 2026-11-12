import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
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

      final updateSeparateItemsResult = await _updateSeparateItemQuantities(params, separationItems);
      if (updateSeparateItemsResult.updatedItems.isEmpty ||
          updateSeparateItemsResult.updatedItems.length != updateSeparateItemsResult.originalItems.length) {
        return failure(
          CancelCardItemSeparationFailure.updateSeparateItemFailed('Falha ao atualizar quantidades de separação'),
        );
      }

      final List<SeparationItemModel> cancelledSeparationItems;
      try {
        cancelledSeparationItems = await _updateSeparationItemsToCancel(separationItems);
      } catch (e) {
        // Exceção no passo 2: reverte o passo 1 (quantidades) e os itens de
        // separação já cancelados antes de propagar a falha.
        await _revertSeparateItemQuantities(updateSeparateItemsResult.originalItems);
        await _revertSeparationItems(originalSeparationItems);
        rethrow;
      }

      // Falha total ou PARCIAL no passo 2: tratamos como operação não-atômica
      // e revertemos tudo (quantidades reduzidas + itens já cancelados) para
      // evitar estado inconsistente (parte cancelada, parte não).
      if (cancelledSeparationItems.length != separationItems.length) {
        await _revertSeparateItemQuantities(updateSeparateItemsResult.originalItems);
        await _revertSeparationItems(originalSeparationItems);
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
      return failure(AppFailure.fromCaught(e));
    } on Exception catch (e) {
      return failure(CancelCardItemSeparationFailure.unknown(e.toString(), e));
    } catch (e) {
      // Bug M: catch generico para `Error`s (NullCheckOperator, etc.).
      return failure(CancelCardItemSeparationFailure.unknown('Erro inesperado: $e', Exception(e.toString())));
    }
  }

  Future<List<SeparationItemModel>> _findSeparationItems(CancelCardItemSeparationParams params) async {
    return _separationItemRepository.select(
      QueryBuilder()
        ..equals('CodEmpresa', params.codEmpresa)
        ..equals('CodSepararEstoque', params.codSepararEstoque)
        ..equals('CodCarrinhoPercurso', params.codCarrinhoPercurso)
        ..equals('ItemCarrinhoPercurso', params.itemCarrinhoPercurso)
        ..notEquals('Situacao', ExpeditionItemSituation.cancelado.code)
        ..allRows(thenBy: ['CodProduto']),
    );
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
    List<SeparationItemModel> separationItems,
  ) async {
    final originalItems = <SeparateItemModel>[];
    final updatedItems = <SeparateItemModel>[];
    try {
      final productCodes = {for (final item in separationItems) item.codProduto}.toList();
      final separateItemsQuery = QueryBuilder()
        ..equals('CodEmpresa', params.codEmpresa)
        ..equals('CodSepararEstoque', params.codSepararEstoque)
        ..allRows(thenBy: ['CodProduto']);
      if (productCodes.isNotEmpty) {
        separateItemsQuery.inList('CodProduto', productCodes);
      }
      final separateItems = await _separateItemRepository.select(separateItemsQuery);
      final deductions = _deductionsBySeparateItem(separationItems: separationItems, separateItems: separateItems);

      for (var i = 0; i < deductions.length; i += _mutationBatchSize) {
        final batch = deductions.skip(i).take(_mutationBatchSize).toList();
        final planned = [
          for (final deduction in batch)
            (
              original: deduction.item,
              updated: deduction.item.copyWith(
                quantidadeSeparacao: _reducedQuantity(deduction.item.quantidadeSeparacao, deduction.quantity),
              ),
            ),
        ];
        final results = await Future.wait(
          planned.map((row) async {
            try {
              final updated = await _separateItemRepository.update(row.updated);
              return (original: row.original, updated: updated, failed: updated.isEmpty);
            } catch (_) {
              return (original: row.original, updated: const <SeparateItemModel>[], failed: true);
            }
          }),
        );
        var batchFailed = false;
        for (final result in results) {
          if (result.failed) {
            batchFailed = true;
            continue;
          }
          originalItems.add(result.original);
          updatedItems.addAll(result.updated);
        }
        if (batchFailed) {
          await _revertSeparateItemQuantities(originalItems);
          return const _SeparateItemsUpdateResult(updatedItems: [], originalItems: []);
        }
      }

      return _SeparateItemsUpdateResult(updatedItems: updatedItems, originalItems: originalItems);
    } catch (e) {
      await _revertSeparateItemQuantities(originalItems);
      rethrow;
    }
  }

  Future<List<SeparationItemModel>> _updateSeparationItemsToCancel(List<SeparationItemModel> separationItems) async {
    final updatedItems = <SeparationItemModel>[];
    for (var i = 0; i < separationItems.length; i += _mutationBatchSize) {
      final batch = separationItems.skip(i).take(_mutationBatchSize).toList();
      final results = await Future.wait(
        batch.map(
          (item) => _separationItemRepository.update(item.copyWith(situacao: ExpeditionItemSituation.cancelado)),
        ),
      );
      for (final updateResult in results) {
        if (updateResult.isNotEmpty) {
          updatedItems.addAll(updateResult);
        }
      }
    }
    return updatedItems;
  }

  Future<void> _revertSeparateItemQuantities(List<SeparateItemModel> originalItems) async {
    try {
      await _updateInBatches(originalItems, _separateItemRepository.update);
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Falha no rollback das quantidades de separate_item — estado pode estar inconsistente',
        tag: 'CancelCardItemSeparationUseCase',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _revertSeparationItems(List<SeparationItemModel> originalItems) async {
    try {
      await _updateInBatches(originalItems, _separationItemRepository.update);
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Falha no rollback das situações de separation_item — estado pode estar inconsistente',
        tag: 'CancelCardItemSeparationUseCase',
        error: e,
        stackTrace: stackTrace,
      );
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
      await _updateInBatches(success.originalSeparateItems, _separateItemRepository.update);
      await _updateInBatches(success.originalSeparationItems, _separationItemRepository.update);
      return true;
    } catch (e) {
      return false;
    }
  }

  static const int _mutationBatchSize = 10;

  Future<void> _updateInBatches<T>(List<T> items, Future<List<T>> Function(T item) update) async {
    if (items.isEmpty) return;
    for (var i = 0; i < items.length; i += _mutationBatchSize) {
      final batch = items.skip(i).take(_mutationBatchSize);
      await Future.wait(batch.map(update));
    }
  }

  List<_SeparateItemDeduction> _deductionsBySeparateItem({
    required List<SeparationItemModel> separationItems,
    required List<SeparateItemModel> separateItems,
  }) {
    final byItemAndProduct = <String, SeparateItemModel>{
      for (final item in separateItems) _separateItemKey(item.codProduto, item.item): item,
    };
    final byProduct = <int, SeparateItemModel>{for (final item in separateItems) item.codProduto: item};
    final deductions = <String, _SeparateItemDeduction>{};

    for (final separationItem in separationItems) {
      final matched =
          byItemAndProduct[_separateItemKey(separationItem.codProduto, separationItem.item)] ??
          byProduct[separationItem.codProduto];
      if (matched == null) {
        continue;
      }
      final key = _separateItemKey(matched.codProduto, matched.item);
      final current = deductions[key];
      deductions[key] = _SeparateItemDeduction(
        item: matched,
        quantity: (current?.quantity ?? 0) + separationItem.quantidade,
      );
    }

    return deductions.values.toList();
  }

  String _separateItemKey(int codProduto, String item) => '$codProduto|$item';

  double _reducedQuantity(double current, double cancelled) {
    final next = current - cancelled;
    return next < 0 ? 0.0 : next;
  }
}

class _SeparateItemDeduction {
  final SeparateItemModel item;
  final double quantity;

  const _SeparateItemDeduction({required this.item, required this.quantity});
}

class _SeparateItemsUpdateResult {
  final List<SeparateItemModel> updatedItems;
  final List<SeparateItemModel> originalItems;

  const _SeparateItemsUpdateResult({required this.updatedItems, required this.originalItems});
}
