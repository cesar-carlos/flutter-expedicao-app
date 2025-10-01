import 'package:exp/core/results/index.dart';
import 'package:exp/core/errors/app_error.dart';
import 'package:exp/core/utils/app_helper.dart';
import 'package:exp/domain/models/separate_item_model.dart';
import 'package:exp/domain/models/separation_item_model.dart';
import 'package:exp/domain/models/expedition_item_situation_model.dart';
import 'package:exp/domain/models/user_system_models.dart';
import 'package:exp/domain/usecases/add_item_separation/add_item_separation_params.dart';
import 'package:exp/domain/usecases/add_item_separation/add_item_separation_success.dart';
import 'package:exp/domain/usecases/add_item_separation/add_item_separation_failure.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/domain/repositories/basic_repository.dart';
import 'package:exp/data/services/user_session_service.dart';

/// Use case para adicionar itens na separação de estoque
///
/// Este use case é responsável por:
/// - Validar parâmetros de entrada
/// - Verificar usuário autenticado
/// - Buscar item de separação disponível
/// - Validar quantidade disponível
/// - Inserir item na tabela separation_item
/// - Atualizar quantidade de separação na tabela separate_item
class AddItemSeparationUseCase {
  final BasicRepository<SeparateItemModel> _separateItemRepository;
  final BasicRepository<SeparationItemModel> _separationItemRepository;
  final UserSessionService _userSessionService;

  AddItemSeparationUseCase({
    required BasicRepository<SeparateItemModel> separateItemRepository,
    required BasicRepository<SeparationItemModel> separationItemRepository,
    required UserSessionService userSessionService,
  }) : _separateItemRepository = separateItemRepository,
       _separationItemRepository = separationItemRepository,
       _userSessionService = userSessionService;

  /// Adiciona um item à separação
  ///
  /// [params] - Parâmetros para adição do item
  /// [userSystem] - Sistema do usuário (opcional, se não fornecido será carregado)
  ///
  /// Retorna [Result<AddItemSeparationSuccess>] com sucesso ou falha
  Future<Result<AddItemSeparationSuccess>> call(AddItemSeparationParams params, {UserSystemModel? userSystem}) async {
    try {
      // 1. Validar parâmetros
      if (!params.isValid) {
        final errors = params.validationErrors;
        return failure(AddItemSeparationFailure.invalidParams('Parâmetros inválidos: ${errors.join(', ')}'));
      }

      // 2. Verificar usuário autenticado (usar fornecido ou carregar)
      UserSystemModel user = userSystem ?? await _loadUserSystem();

      // 3. Buscar item de separação disponível
      final separateItem = await _findSeparateItem(params);
      if (separateItem == null) {
        return failure(AddItemSeparationFailure.separateItemNotFound(params.codProduto));
      }

      // 4. Validar quantidade disponível
      final availableQuantity = separateItem.quantidade - separateItem.quantidadeSeparacao;
      if (availableQuantity < params.quantidade) {
        return failure(
          AddItemSeparationFailure.insufficientQuantity(
            requested: params.quantidade,
            available: availableQuantity,
            codProduto: params.codProduto,
          ),
        );
      }

      // 5. Executar operação transacional: INSERT + UPDATE
      return await _executeTransactionalOperation(params, separateItem, user);
    } on DataError catch (e) {
      return failure(AddItemSeparationFailure.networkError(e.message, Exception(e.message)));
    } on Exception catch (e) {
      return failure(AddItemSeparationFailure.unknown(e.toString(), e));
    }
  }

  /// Carrega o sistema do usuário
  Future<UserSystemModel> _loadUserSystem() async {
    final appUser = await _userSessionService.loadUserSession();
    if (appUser?.userSystemModel == null) {
      throw Exception('Usuário não autenticado');
    }
    return appUser!.userSystemModel!;
  }

  /// Executa a operação transacional de INSERT + UPDATE
  Future<Result<AddItemSeparationSuccess>> _executeTransactionalOperation(
    AddItemSeparationParams params,
    SeparateItemModel separateItem,
    UserSystemModel userSystem,
  ) async {
    try {
      // INSERT: Criar e inserir novo item de separação
      final newSeparationItem = _createSeparationItem(params, userSystem.codEmpresa ?? params.codEmpresa);
      final createdSeparationItems = await _separationItemRepository.insert(newSeparationItem);

      if (createdSeparationItems.isEmpty) {
        return failure(AddItemSeparationFailure.insertSeparationItemFailed('Falha ao inserir item de separação'));
      }

      // UPDATE: Atualizar quantidade de separação no separate_item
      final updatedSeparateItem = separateItem.copyWith(
        quantidadeSeparacao: separateItem.quantidadeSeparacao + params.quantidade,
      );

      final updatedSeparateItems = await _separateItemRepository.update(updatedSeparateItem);

      if (updatedSeparateItems.isEmpty) {
        // ROLLBACK: Em caso de falha no UPDATE, idealmente deveríamos desfazer o INSERT
        // Por limitação da arquitetura atual, apenas retornamos erro
        return failure(AddItemSeparationFailure.updateSeparateItemFailed('Falha ao atualizar quantidade de separação'));
      }

      return success(
        AddItemSeparationSuccess.create(
          createdSeparationItem: createdSeparationItems.first,
          updatedSeparateItem: updatedSeparateItems.first,
          addedQuantity: params.quantidade,
        ),
      );
    } catch (e) {
      rethrow; // Permitir que o catch externo trate a exceção
    }
  }

  /// Busca o item de separação correspondente aos parâmetros
  Future<SeparateItemModel?> _findSeparateItem(AddItemSeparationParams params) async {
    try {
      final separateItems = await _separateItemRepository.select(
        QueryBuilder()
            .equals('CodEmpresa', params.codEmpresa)
            .equals('CodSepararEstoque', params.codSepararEstoque)
            .equals('CodProduto', params.codProduto),
      );

      return separateItems.isNotEmpty ? separateItems.first : null;
    } catch (e) {
      rethrow;
    }
  }

  /// Cria um novo item de separação
  SeparationItemModel _createSeparationItem(AddItemSeparationParams params, int codEmpresa) {
    final now = DateTime.now();

    return SeparationItemModel(
      codEmpresa: codEmpresa,
      codSepararEstoque: params.codSepararEstoque,
      item: '00000',
      sessionId: params.sessionId, //sessionId é o ID/sessionId do socket atual
      situacao: ExpeditionItemSituation.separado,
      codCarrinhoPercurso: params.codCarrinhoPercurso,
      itemCarrinhoPercurso: params.itemCarrinhoPercurso,
      codSeparador: params.codSeparador,
      nomeSeparador: params.nomeSeparador,
      dataSeparacao: now,
      horaSeparacao: AppHelper.formatTime(now),
      codProduto: params.codProduto,
      codUnidadeMedida: params.codUnidadeMedida,
      quantidade: params.quantidade,
    );
  }
}
