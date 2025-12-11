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
import 'package:data7_expedicao/data/services/user_session_service.dart';

class CancelCardItemSeparationUseCase {
  final BasicRepository<SeparateItemModel> _separateItemRepository;
  final BasicRepository<SeparationItemModel> _separationItemRepository;
  final UserSessionService _userSessionService;

  CancelCardItemSeparationUseCase({
    required BasicRepository<SeparateItemModel> separateItemRepository,
    required BasicRepository<SeparationItemModel> separationItemRepository,
    required UserSessionService userSessionService,
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

      final cancelledQuantitiesByProduct = _calculateCancelledQuantitiesByProduct(separationItems);

      final updatedSeparateItems = await _updateSeparateItemQuantities(params, cancelledQuantitiesByProduct);
      if (updatedSeparateItems.isEmpty) {
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
          updatedSeparateItems: updatedSeparateItems,
          cancelledSeparationItems: cancelledSeparationItems,
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

  Future<List<SeparateItemModel>> _updateSeparateItemQuantities(
    CancelCardItemSeparationParams params,
    Map<int, double> cancelledQuantitiesByProduct,
  ) async {
    try {
      final List<SeparateItemModel> updatedItems = [];

      for (final codProduto in cancelledQuantitiesByProduct.keys) {
        final cancelledQuantity = cancelledQuantitiesByProduct[codProduto]!;

        final separateItems = await _separateItemRepository.select(
          QueryBuilder()
              .equals('CodEmpresa', params.codEmpresa)
              .equals('CodSepararEstoque', params.codSepararEstoque)
              .equals('CodProduto', codProduto),
        );

        if (separateItems.isNotEmpty) {
          final separateItem = separateItems.first;

          final newQuantidadeSeparacao = separateItem.quantidadeSeparacao - cancelledQuantity;

          final finalQuantidadeSeparacao = newQuantidadeSeparacao < 0 ? 0.0 : newQuantidadeSeparacao;

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
}
