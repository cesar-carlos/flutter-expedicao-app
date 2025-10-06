import 'package:exp/core/results/index.dart';
import 'package:exp/core/errors/app_error.dart';
import 'package:exp/domain/models/separate_item_model.dart';
import 'package:exp/domain/models/separation_item_model.dart';
import 'package:exp/domain/models/situation/expedition_situation_model.dart';
import 'package:exp/domain/models/separate_model.dart';
import 'package:exp/domain/usecases/delete_item_separation/delete_item_separation_params.dart';
import 'package:exp/domain/usecases/delete_item_separation/delete_item_separation_success.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/domain/repositories/basic_repository.dart';
import 'package:exp/data/services/user_session_service.dart';

/// Use case para excluir um item específico da separação
///
/// Este use case é responsável por:
/// - Validar parâmetros de entrada
/// - Verificar usuário autenticado
/// - Buscar item de separação específico
/// - Verificar se a separação está em situação de separando
/// - DELETAR o item de separação do banco de dados
/// - Atualizar quantidade de separação na tabela separate_item (subtraindo)
class DeleteItemSeparationUseCase {
  // === CONSTANTES ===
  static const String _deleteFailedCode = 'DELETE_FAILED';
  static const String _updateFailedCode = 'UPDATE_FAILED';

  // === DEPENDÊNCIAS ===
  final BasicRepository<SeparateItemModel> _separateItemRepository;
  final BasicRepository<SeparationItemModel> _separationItemRepository;
  final BasicRepository<SeparateModel> _separateRepository;
  final UserSessionService _userSessionService;

  DeleteItemSeparationUseCase({
    required BasicRepository<SeparateItemModel> separateItemRepository,
    required BasicRepository<SeparationItemModel> separationItemRepository,
    required BasicRepository<SeparateModel> separateRepository,
    required UserSessionService userSessionService,
  }) : _separateItemRepository = separateItemRepository,
       _separationItemRepository = separationItemRepository,
       _separateRepository = separateRepository,
       _userSessionService = userSessionService;

  /// Exclui um item específico da separação
  ///
  /// [params] - Parâmetros para exclusão do item
  ///
  /// Retorna [Result<DeleteItemSeparationSuccess>] com sucesso ou falha
  Future<Result<DeleteItemSeparationSuccess>> call(DeleteItemSeparationParams params) async {
    try {
      // === VALIDAÇÕES INICIAIS ===
      final validationResult = await _validateRequest(params);
      if (validationResult != null) return validationResult;

      // === BUSCAR DADOS NECESSÁRIOS ===
      final separationItem = await _findSeparationItem(params);
      if (separationItem == null) {
        return failure(DataFailure.notFound('Item de separação'));
      }

      final separateItem = await _findSeparateItem(separationItem);
      if (separateItem == null) {
        return failure(DataFailure.notFound('Item base para o produto ${separationItem.codProduto}'));
      }

      final separate = await _findSeparate(params);
      if (separate == null) {
        return failure(DataFailure.notFound('Separação'));
      }

      // === VALIDAR ESTADO DA SEPARAÇÃO ===
      if (separate.situacao != ExpeditionSituation.separando) {
        return failure(BusinessFailure.invalidState('Separação não está em situação de separando'));
      }

      // === EXECUTAR OPERAÇÃO TRANSACIONAL ===
      return await _executeTransactionalOperation(params, separationItem, separateItem);
    } on DataError catch (e) {
      return failure(NetworkFailure(message: e.message, exception: Exception(e.message)));
    } on Exception catch (e) {
      return failure(UnknownFailure.fromException(e));
    }
  }

  /// Valida parâmetros e usuário autenticado
  Future<Result<DeleteItemSeparationSuccess>?> _validateRequest(DeleteItemSeparationParams params) async {
    // Validar parâmetros
    if (!params.isValid) {
      final errors = params.validationErrors;
      return failure(ValidationFailure.fromErrors(errors));
    }

    // Verificar usuário autenticado
    final appUser = await _userSessionService.loadUserSession();
    if (appUser?.userSystemModel == null) {
      return failure(AuthFailure.unauthenticated());
    }

    return null; // Validação passou
  }

  /// Executa a operação transacional de DELETE + UPDATE
  Future<Result<DeleteItemSeparationSuccess>> _executeTransactionalOperation(
    DeleteItemSeparationParams params,
    SeparationItemModel separationItem,
    SeparateItemModel separateItem,
  ) async {
    try {
      // === PASSO 1: EXCLUIR ITEM DE SEPARAÇÃO ===
      final deletedItems = await _separationItemRepository.delete(separationItem);
      if (deletedItems.isEmpty) {
        return failure(DataFailure(message: 'Falha ao excluir item de separação', code: _deleteFailedCode));
      }

      // === PASSO 2: ATUALIZAR QUANTIDADE DE SEPARAÇÃO ===
      final newQuantity = separateItem.quantidadeSeparacao - separationItem.quantidade;
      final clampedQuantity = newQuantity.clamp(0.0, separateItem.quantidade);
      final updatedItem = separateItem.copyWith(quantidadeSeparacao: clampedQuantity);

      final updatedItems = await _separateItemRepository.update(updatedItem);
      if (updatedItems.isEmpty) {
        return failure(DataFailure(message: 'Falha ao atualizar quantidade de separação', code: _updateFailedCode));
      }

      // === RETORNAR SUCESSO ===
      return success(
        DeleteItemSeparationSuccess.create(
          deletedSeparationItem: deletedItems.first,
          updatedSeparateItem: updatedItems.first,
          deletedQuantity: separationItem.quantidade,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Busca o item de separação específico pelos parâmetros
  Future<SeparationItemModel?> _findSeparationItem(DeleteItemSeparationParams params) async {
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
  Future<SeparateModel?> _findSeparate(DeleteItemSeparationParams params) async {
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
