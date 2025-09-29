import 'package:exp/core/results/index.dart';
import 'package:exp/core/errors/app_error.dart';
import 'package:exp/domain/models/separate_item_model.dart';
import 'package:exp/domain/models/separation_item_model.dart';
import 'package:exp/domain/models/expedition_item_situation_model.dart';
import 'package:exp/domain/models/expedition_situation_model.dart';
import 'package:exp/domain/models/separate_model.dart';
import 'package:exp/domain/usecases/cancel_item_separation/cancel_item_separation_params.dart';
import 'package:exp/domain/usecases/cancel_item_separation/cancel_item_separation_success.dart';
import 'package:exp/domain/usecases/cancel_item_separation/cancel_item_separation_failure.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/domain/repositories/basic_repository.dart';
import 'package:exp/data/services/user_session_service.dart';

/// Use case para cancelar um item específico da separação
///
/// Este use case é responsável por:
/// - Validar parâmetros de entrada
/// - Verificar usuário autenticado
/// - Buscar item de separação específico
/// - Verificar se o item não foi cancelado anteriormente
/// - Atualizar situação do item para CA (cancelado)
/// - Atualizar quantidade de separação na tabela separate_item (subtraindo)
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

  /// Cancela um item específico da separação
  ///
  /// [params] - Parâmetros para cancelamento do item
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

      // 3. Buscar item de separação específico
      final separationItem = await _findSeparationItem(params);
      if (separationItem == null) {
        return failure(CancelItemSeparationFailure.separationItemNotFound());
      }

      // 4. Verificar se o item já foi cancelado
      if (separationItem.situacao == ExpeditionItemSituation.cancelado) {
        return failure(CancelItemSeparationFailure.itemAlreadyCancelled());
      }

      // 5. Buscar item base correspondente
      final separateItem = await _findSeparateItem(separationItem);
      if (separateItem == null) {
        return failure(CancelItemSeparationFailure.separateItemNotFound(separationItem.codProduto));
      }

      // 6. Verificar se a separação está em situação de separando
      final separate = await _findSeparate(params);
      if (separate == null) {
        return failure(CancelItemSeparationFailure.separateNotFound());
      }

      if (separate.situacao != ExpeditionSituation.separando) {
        return failure(CancelItemSeparationFailure.separateNotInSeparatingState());
      }

      // 7. Executar operação transacional: UPDATE separation_item + UPDATE separate_item
      return await _executeTransactionalOperation(params, separationItem, separateItem);
    } on DataError catch (e) {
      return failure(CancelItemSeparationFailure.networkError(e.message, Exception(e.message)));
    } on Exception catch (e) {
      return failure(CancelItemSeparationFailure.unknown(e.toString(), e));
    }
  }

  /// Executa a operação transacional de UPDATE + UPDATE
  Future<Result<CancelItemSeparationSuccess>> _executeTransactionalOperation(
    CancelItemSeparationParams params,
    SeparationItemModel separationItem,
    SeparateItemModel separateItem,
  ) async {
    try {
      // UPDATE 1: Marcar item de separação como cancelado
      final cancelledSeparationItem = separationItem.copyWith(situacao: ExpeditionItemSituation.cancelado);
      final updatedSeparationItems = await _separationItemRepository.update(cancelledSeparationItem);

      if (updatedSeparationItems.isEmpty) {
        return failure(CancelItemSeparationFailure.updateSeparationItemFailed('Falha ao cancelar item de separação'));
      }

      // UPDATE 2: Reduzir quantidade de separação no separate_item
      final newSeparationQuantity = separateItem.quantidadeSeparacao - separationItem.quantidade;
      final updatedSeparateItem = separateItem.copyWith(
        quantidadeSeparacao: newSeparationQuantity.clamp(0.0, separateItem.quantidade),
      );

      final updatedSeparateItems = await _separateItemRepository.update(updatedSeparateItem);

      if (updatedSeparateItems.isEmpty) {
        // ROLLBACK: Em caso de falha no UPDATE do separate_item, idealmente deveríamos desfazer o UPDATE anterior
        // Por limitação da arquitetura atual, apenas retornamos erro
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

  /// Busca o item de separação específico pelos parâmetros
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

  /// Busca o item base correspondente ao item de separação encontrado
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

  /// Busca a separação correspondente aos parâmetros
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
