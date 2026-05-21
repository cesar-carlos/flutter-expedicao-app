import 'dart:developer' as developer;

import 'package:uuid/uuid.dart';

import 'package:data7_expedicao/core/metrics/metrics_collector.dart';
import 'package:data7_expedicao/core/network/socket_operation_retry.dart';
import 'package:data7_expedicao/core/utils/app_helper.dart';
import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_item_situation_model.dart';
import 'package:data7_expedicao/domain/usecases/add_item_separation/add_item_separation_params.dart';
import 'package:data7_expedicao/domain/usecases/add_item_separation/add_item_separation_success.dart';
import 'package:data7_expedicao/domain/usecases/add_item_separation/add_item_separation_failure.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/results/index.dart';

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
  final IUserSessionService _userSessionService;
  final MetricsCollector? _metricsCollector;
  final SocketOperationRetry? _socketOperationRetry;
  static const _uuid = Uuid();

  AddItemSeparationUseCase({
    required BasicRepository<SeparateItemModel> separateItemRepository,
    required BasicRepository<SeparationItemModel> separationItemRepository,
    required IUserSessionService userSessionService,
    MetricsCollector? metricsCollector,
    SocketOperationRetry? socketOperationRetry,
  }) : _separateItemRepository = separateItemRepository,
       _separationItemRepository = separationItemRepository,
       _userSessionService = userSessionService,
       _metricsCollector = metricsCollector,
       _socketOperationRetry = socketOperationRetry;

  /// Adiciona um item à separação
  ///
  /// [params] - Parâmetros para adição do item
  /// [userSystem] - Sistema do usuário (opcional, se não fornecido será carregado)
  ///
  /// Retorna [Result<AddItemSeparationSuccess>] com sucesso ou falha
  Future<Result<AddItemSeparationSuccess>> call(AddItemSeparationParams params, {UserSystemModel? userSystem}) async {
    final operationId = 'add_item_${_uuid.v4()}';
    final started = DateTime.now();
    _metricsCollector?.recordOperationStart(operationId);

    try {
      // 1. Validar parâmetros
      if (!params.isValid) {
        final errors = params.validationErrors;
        _recordOperationEnd(operationId, started, false);
        return failure(AddItemSeparationFailure.invalidParams('Parâmetros inválidos: ${errors.join(', ')}'));
      }

      // 2. Verificar usuário autenticado (usar fornecido ou carregar)
      UserSystemModel user = userSystem ?? await _loadUserSystem();

      // 3. Buscar item de separação disponível
      final separateItem = await _findSeparateItem(params);
      if (separateItem == null) {
        _recordOperationEnd(operationId, started, false);
        return failure(AddItemSeparationFailure.separateItemNotFound(params.codProduto));
      }

      // 4. Validar quantidade disponível
      final availableQuantity = (separateItem.quantidade - separateItem.quantidadeSeparacao).toDouble();
      if (availableQuantity < params.quantidade) {
        _recordOperationEnd(operationId, started, false);
        return failure(
          AddItemSeparationFailure.insufficientQuantity(
            requested: params.quantidade,
            available: availableQuantity,
            codProduto: params.codProduto,
          ),
        );
      }

      // 5. Executar operação transacional: INSERT + UPDATE (com retry)
      final result = _socketOperationRetry != null
          ? await _socketOperationRetry.execute(
              () => _executeTransactionalOperation(params, separateItem, user),
              operationId: operationId,
            )
          : await _executeTransactionalOperation(params, separateItem, user);
      final success = result.isSuccess();
      _recordOperationEnd(operationId, started, success);
      return result;
    } on DataError catch (e) {
      _recordOperationEnd(operationId, started, false);
      return failure(AddItemSeparationFailure.networkError(e.message, Exception(e.message)));
    } on Exception catch (e) {
      _recordOperationEnd(operationId, started, false);
      return failure(AddItemSeparationFailure.unknown(e.toString(), e));
    } catch (e) {
      // Bug H: catch generico para `Error`s (NullCheckOperator, StateError)
      // que `on Exception` nao captura, evitando crash do app.
      _recordOperationEnd(operationId, started, false);
      return failure(AddItemSeparationFailure.unknown('Erro inesperado: $e', Exception(e.toString())));
    }
  }

  void _recordOperationEnd(String operationId, DateTime started, bool success) {
    final duration = DateTime.now().difference(started);
    _metricsCollector?.recordOperationEnd(operationId, success, duration);
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
    SeparationItemModel? createdItem;

    try {
      // INSERT: Criar e inserir novo item de separação
      final newSeparationItem = _createSeparationItem(params, userSystem.codEmpresa ?? params.codEmpresa);
      final createdSeparationItems = await _separationItemRepository.insert(newSeparationItem);

      if (createdSeparationItems.isEmpty) {
        return failure(AddItemSeparationFailure.insertSeparationItemFailed('Falha ao inserir item de separação'));
      }

      // Armazena referência para rollback se necessário
      createdItem = createdSeparationItems.first;

      // UPDATE: Atualizar quantidade de separação no separate_item
      final updatedSeparateItem = separateItem.copyWith(
        quantidadeSeparacao: (separateItem.quantidadeSeparacao + params.quantidade).toDouble(),
      );

      final updatedSeparateItems = await _separateItemRepository.update(updatedSeparateItem);

      if (updatedSeparateItems.isEmpty) {
        await _attemptRollback(createdItem);
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
      if (createdItem != null) {
        await _attemptRollback(createdItem);
      }
      rethrow; // Permitir que o catch externo trate a exceção
    }
  }

  /// Tenta desfazer (rollback) o INSERT do item de separação em caso de falha
  Future<void> _attemptRollback(SeparationItemModel itemToDelete) async {
    try {
      await _separationItemRepository.delete(itemToDelete);
    } catch (e) {
      // Log da falha no rollback - não pode fazer nada além de logar
      // Em um sistema ideal, teríamos um mecanismo de retry ou compensação
      developer.log('WARNING: Failed to rollback separation item after operation failure', error: e);
    }
  }

  /// Busca o item de separação correspondente aos parâmetros
  Future<SeparateItemModel?> _findSeparateItem(AddItemSeparationParams params) async {
    try {
      final separateItems = await _separateItemRepository.select(
        QueryBuilder()
            .equals('CodEmpresa', params.codEmpresa)
            .equals('CodSepararEstoque', params.codSepararEstoque)
            .equals('CodProduto', params.codProduto)
            .equals('Item', params.itemSepararEstoque),
      );

      for (final item in separateItems) {
        if (item.codEmpresa == params.codEmpresa &&
            item.codSepararEstoque == params.codSepararEstoque &&
            item.codProduto == params.codProduto &&
            item.item == params.itemSepararEstoque) {
          return item;
        }
      }

      return null;
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
