import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_item_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/separate_model.dart';
import 'package:data7_expedicao/domain/usecases/cancel_item_separation/cancel_item_separation_params.dart';
import 'package:data7_expedicao/domain/usecases/cancel_item_separation/cancel_item_separation_success.dart';
import 'package:data7_expedicao/domain/usecases/cancel_item_separation/cancel_item_separation_failure.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/data/services/user_session_service.dart';

class CancelItemSeparationUseCase {
  final BasicRepository<SeparateItemModel> _separateItemRepository;
  final BasicRepository<SeparationItemModel> _separationItemRepository;
  final BasicRepository<SeparateModel> _separateRepository;
  final UserSessionService _userSessionService;

  CancelItemSeparationUseCase({
    required BasicRepository<SeparateItemModel> separateItemRepository,
    required BasicRepository<SeparationItemModel> separationItemRepository,
    required BasicRepository<SeparateModel> separateRepository,
    required UserSessionService userSessionService,
  }) : _separateItemRepository = separateItemRepository,
       _separationItemRepository = separationItemRepository,
       _separateRepository = separateRepository,
       _userSessionService = userSessionService;

  Future<Result<CancelItemSeparationSuccess>> call(CancelItemSeparationParams params) async {
    try {
      if (!params.isValid) {
        final errors = params.validationErrors;
        return failure(CancelItemSeparationFailure.invalidParams('Parâmetros inválidos: ${errors.join(', ')}'));
      }

      final appUser = await _userSessionService.loadUserSession();
      if (appUser?.userSystemModel == null) {
        return failure(CancelItemSeparationFailure.userNotFound());
      }

      final separationItem = await _findSeparationItem(params);
      if (separationItem == null) {
        return failure(CancelItemSeparationFailure.separationItemNotFound());
      }

      if (separationItem.situacao == ExpeditionItemSituation.cancelado) {
        return failure(CancelItemSeparationFailure.itemAlreadyCancelled());
      }

      final separateItem = await _findSeparateItem(separationItem);
      if (separateItem == null) {
        return failure(CancelItemSeparationFailure.separateItemNotFound(separationItem.codProduto));
      }

      final separate = await _findSeparate(params);
      if (separate == null) {
        return failure(CancelItemSeparationFailure.separateNotFound());
      }

      if (separate.situacao != ExpeditionSituation.separando) {
        return failure(CancelItemSeparationFailure.separateNotInSeparatingState());
      }

      return await _executeTransactionalOperation(params, separationItem, separateItem);
    } on DataError catch (e) {
      return failure(CancelItemSeparationFailure.networkError(e.message, Exception(e.message)));
    } on Exception catch (e) {
      return failure(CancelItemSeparationFailure.unknown(e.toString(), e));
    }
  }

  Future<Result<CancelItemSeparationSuccess>> _executeTransactionalOperation(
    CancelItemSeparationParams params,
    SeparationItemModel separationItem,
    SeparateItemModel separateItem,
  ) async {
    try {
      final cancelledSeparationItem = separationItem.copyWith(situacao: ExpeditionItemSituation.cancelado);
      final updatedSeparationItems = await _separationItemRepository.update(cancelledSeparationItem);

      if (updatedSeparationItems.isEmpty) {
        return failure(CancelItemSeparationFailure.updateSeparationItemFailed('Falha ao cancelar item de separação'));
      }

      final newSeparationQuantity = separateItem.quantidadeSeparacao - separationItem.quantidade;
      final updatedSeparateItem = separateItem.copyWith(
        quantidadeSeparacao: newSeparationQuantity.clamp(0.0, separateItem.quantidade),
      );

      final updatedSeparateItems = await _separateItemRepository.update(updatedSeparateItem);

      if (updatedSeparateItems.isEmpty) {
        return failure(
          CancelItemSeparationFailure.updateSeparateItemFailed('Falha ao atualizar quantidade de separação'),
        );
      }

      return success(
        CancelItemSeparationSuccess.create(
          cancelledSeparationItem: updatedSeparationItems.first,
          updatedSeparateItem: updatedSeparateItems.first,
          cancelledQuantity: separationItem.quantidade,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<SeparationItemModel?> _findSeparationItem(CancelItemSeparationParams params) async {
    try {
      final separationItems = await _separationItemRepository.select(
        QueryBuilder()
            .equals('CodEmpresa', params.codEmpresa)
            .equals('CodSepararEstoque', params.codSepararEstoque)
            .equals('Item', params.item),
      );

      return separationItems.isNotEmpty ? separationItems.first : null;
    } catch (e) {
      rethrow;
    }
  }

  Future<SeparateItemModel?> _findSeparateItem(SeparationItemModel separationItem) async {
    try {
      final separateItems = await _separateItemRepository.select(
        QueryBuilder()
            .equals('CodEmpresa', separationItem.codEmpresa)
            .equals('CodSepararEstoque', separationItem.codSepararEstoque)
            .equals('CodProduto', separationItem.codProduto),
      );

      return separateItems.isNotEmpty ? separateItems.first : null;
    } catch (e) {
      rethrow;
    }
  }

  Future<SeparateModel?> _findSeparate(CancelItemSeparationParams params) async {
    try {
      final separates = await _separateRepository.select(
        QueryBuilder().equals('CodEmpresa', params.codEmpresa).equals('CodSepararEstoque', params.codSepararEstoque),
      );

      return separates.isNotEmpty ? separates.first : null;
    } catch (e) {
      rethrow;
    }
  }
}
