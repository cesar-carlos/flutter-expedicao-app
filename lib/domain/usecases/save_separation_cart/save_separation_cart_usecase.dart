import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/utils/app_helper.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_params.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_query_fields.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_success.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_failure.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_item_situation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_model.dart';
import 'package:data7_expedicao/domain/models/separate_progress_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';

class SaveSeparationCartUseCase {
  final BasicRepository<ExpeditionCartRouteInternshipModel> _cartRouteInternshipRepository;
  final BasicConsultationRepository<SeparationItemConsultationModel> _separationItemRepository;
  final BasicConsultationRepository<SeparateItemConsultationModel> _separateItemRepository;
  final BasicConsultationRepository<SeparateProgressConsultationModel> _separateProgressRepository;
  final BasicRepository<ExpeditionCartModel> _cartRepository;
  final BasicRepository<SeparationItemModel> _separationItemModelRepository;
  final IUserSessionService _userSessionService;

  SaveSeparationCartUseCase({
    required BasicRepository<ExpeditionCartRouteInternshipModel> cartRouteInternshipRepository,
    required BasicConsultationRepository<SeparationItemConsultationModel> separationItemConsultationRepository,
    required BasicConsultationRepository<SeparateItemConsultationModel> separateItemRepository,
    required BasicConsultationRepository<SeparateProgressConsultationModel> separateProgressRepository,
    required BasicRepository<SeparationItemModel> separationItemModelRepository,
    required BasicRepository<ExpeditionCartModel> cartRepository,
    required IUserSessionService userSessionService,
  }) : _cartRouteInternshipRepository = cartRouteInternshipRepository,
       _separationItemRepository = separationItemConsultationRepository,
       _separateItemRepository = separateItemRepository,
       _separationItemModelRepository = separationItemModelRepository,
       _separateProgressRepository = separateProgressRepository,
       _userSessionService = userSessionService,
       _cartRepository = cartRepository;

  Future<Result<SaveSeparationCartSuccess>> call(SaveSeparationCartParams params) async {
    try {
      if (!params.isValid) {
        final errors = params.validationErrors.join(', ');
        AppLogger.warning('Parâmetros inválidos ao salvar carrinho: $errors', tag: 'SaveSeparationCartUseCase');
        return Failure(SaveSeparationCartFailure.unexpected('Parâmetros inválidos: $errors'));
      }

      AppLogger.debug(
        'Iniciando salvamento de carrinho: codCarrinhoPercurso=${params.codCarrinhoPercurso}, item=${params.itemCarrinhoPercurso}',
        tag: 'SaveSeparationCartUseCase',
      );

      final appUser = await _userSessionService.loadUserSession();
      if (appUser?.userSystemModel == null) {
        AppLogger.warning('Usuário não autenticado ao salvar carrinho', tag: 'SaveSeparationCartUseCase');
        return Failure(SaveSeparationCartFailure.userNotAuthenticated());
      }

      final (separateProgress, itemsSeparation, cartRouteInternship) = await _wait3(
        _findSeparateProgress(params),
        _findItemsSeparation(params.codEmpresa, params.codCarrinhoPercurso, params.itemCarrinhoPercurso),
        _findCartRouteInternship(params.codEmpresa, params.codCarrinhoPercurso, params.itemCarrinhoPercurso),
      );

      if (separateProgress == null) {
        AppLogger.warning(
          'Separação não encontrada: codEmpresa=${params.codEmpresa}, codSepararEstoque=${params.codSepararEstoque}',
          tag: 'SaveSeparationCartUseCase',
        );
        return Failure(SaveSeparationCartFailure.separationNotFound());
      }

      if (separateProgress.situacao != ExpeditionSituation.separando) {
        AppLogger.warning(
          'Separação não está em situação SEPARANDO: ${separateProgress.situacao.description}',
          tag: 'SaveSeparationCartUseCase',
        );
        return Failure(SaveSeparationCartFailure.invalidSeparationStatus(separateProgress.situacao.description));
      }

      if (itemsSeparation.isEmpty) {
        AppLogger.warning(
          'Nenhum item encontrado para o carrinho: codCarrinhoPercurso=${params.codCarrinhoPercurso}',
          tag: 'SaveSeparationCartUseCase',
        );
        return Failure(SaveSeparationCartFailure.noItems());
      }

      final hasSeparatedItems = itemsSeparation.any((item) => item.situacao == ExpeditionItemSituation.separado);

      if (!hasSeparatedItems) {
        AppLogger.warning(
          'Nenhum item foi separado no carrinho: codCarrinhoPercurso=${params.codCarrinhoPercurso}',
          tag: 'SaveSeparationCartUseCase',
        );
        return Failure(SaveSeparationCartFailure.noSeparatedItems());
      }

      if (cartRouteInternship == null) {
        AppLogger.warning(
          'Carrinho percurso não encontrado: codCarrinhoPercurso=${params.codCarrinhoPercurso}, item=${params.itemCarrinhoPercurso}',
          tag: 'SaveSeparationCartUseCase',
        );
        return Failure(SaveSeparationCartFailure.cartRouteInternshiptNotFound());
      }

      if (cartRouteInternship.situacao != ExpeditionSituation.separando) {
        AppLogger.warning(
          'Carrinho percurso não está em situação SEPARANDO: ${cartRouteInternship.situacao.description}',
          tag: 'SaveSeparationCartUseCase',
        );
        return Failure(SaveSeparationCartFailure.invalidStatus(cartRouteInternship));
      }

      AppLogger.debug('Validando quantidades separadas antes de salvar carrinho', tag: 'SaveSeparationCartUseCase');

      final (validationResult, cartModel) = await _wait2(
        _validateSeparatedQuantities(params, itemsSeparation),
        _findCart(params.codEmpresa, cartRouteInternship.codCarrinho),
      );

      if (validationResult != null) {
        AppLogger.warning(
          'Validação de quantidades falhou: ${validationResult.message}',
          tag: 'SaveSeparationCartUseCase',
        );
        return Failure(validationResult);
      }
      if (cartModel == null) {
        AppLogger.warning(
          'Carrinho não encontrado: codCarrinho=${cartRouteInternship.codCarrinho}',
          tag: 'SaveSeparationCartUseCase',
        );
        return Failure(SaveSeparationCartFailure.cartNotFound());
      }

      final now = DateTime.now();
      final userModel = appUser!.userSystemModel!;
      final currentTime = AppHelper.formatTime(now);

      final copyWithCart = cartModel.copyWith(situacao: ExpeditionCartSituation.separado);

      final copyWithCartRouteInternship = cartRouteInternship.copyWith(
        situacao: ExpeditionSituation.separado,
        dataFinalizacao: now,
        horaFinalizacao: currentTime,
        codUsuarioFinalizacao: userModel.codUsuario,
        nomeUsuarioFinalizacao: userModel.nomeUsuario,
      );

      AppLogger.debug('Atualizando carrinho e itens para situação SEPARADO', tag: 'SaveSeparationCartUseCase');

      final finalizationResult = await _updateSeparationItemsToFinalized(
        params.codEmpresa,
        params.codCarrinhoPercurso,
        params.itemCarrinhoPercurso,
      );

      bool routeUpdated = false;
      bool cartUpdated = false;
      try {
        await _cartRouteInternshipRepository.update(copyWithCartRouteInternship);
        routeUpdated = true;
        await _cartRepository.update(copyWithCart);
        cartUpdated = true;
      } catch (e, stackTrace) {
        AppLogger.error(
          'Falha ao atualizar entidades de carrinho durante salvamento',
          tag: 'SaveSeparationCartUseCase',
          error: e,
          stackTrace: stackTrace,
        );
        final rollbackItemsResult = await _rollbackSeparationItemsToOriginal(finalizationResult.originalItems);
        bool rollbackRouteResult = true;
        bool rollbackCartResult = true;
        if (routeUpdated) {
          rollbackRouteResult = await _rollbackCartRouteToOriginal(cartRouteInternship);
        }
        if (cartUpdated) {
          rollbackCartResult = await _rollbackCartToOriginal(cartModel);
        }
        final rollbackStatus =
            'rollbackItens=${rollbackItemsResult ? 'ok' : 'falhou'}, '
            'rollbackPercurso=${rollbackRouteResult ? 'ok' : 'falhou'}, '
            'rollbackCarrinho=${rollbackCartResult ? 'ok' : 'falhou'}';
        return Failure(
          SaveSeparationCartFailure(
            message: 'Falha ao finalizar carrinho',
            details: 'Operação revertida parcialmente ($rollbackStatus).',
          ),
        );
      }

      AppLogger.success(
        'Carrinho salvo com sucesso: codCarrinhoPercurso=${params.codCarrinhoPercurso}',
        tag: 'SaveSeparationCartUseCase',
      );

      return Success(
        SaveSeparationCartSuccess(
          cart: copyWithCartRouteInternship,
          dataFinalizacao: now,
          horaFinalizacao: currentTime,
          codUsuarioFinalizacao: userModel.codUsuario,
          nomeUsuarioFinalizacao: userModel.nomeUsuario,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro inesperado ao salvar carrinho',
        tag: 'SaveSeparationCartUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      return Failure(SaveSeparationCartFailure.unexpected(e));
    }
  }

  Future<ExpeditionCartModel?> _findCart(int codEmpresa, int codCarrinho) async {
    final query = QueryBuilder()
      ..equals(SaveCartQueryFields.codEmpresa, codEmpresa.toString())
      ..equals(SaveCartQueryFields.codCarrinho, codCarrinho.toString());

    final carts = await _cartRepository.select(query);
    if (carts.isEmpty) return null;
    return carts.first;
  }

  Future<ExpeditionCartRouteInternshipModel?> _findCartRouteInternship(
    int codEmpresa,
    int codCarrinhoPercurso,
    String item,
  ) async {
    final query = QueryBuilder()
      ..equals(SaveCartQueryFields.codEmpresa, codEmpresa.toString())
      ..equals(SaveCartQueryFields.codCarrinhoPercurso, codCarrinhoPercurso.toString())
      ..equals(SaveCartQueryFields.item, item);

    final cartRoutes = await _cartRouteInternshipRepository.select(query);
    if (cartRoutes.isEmpty) return null;
    return cartRoutes.first;
  }

  Future<List<SeparationItemConsultationModel>> _findItemsSeparation(
    int codEmpresa,
    int codCarrinhoPercurso,
    String itemCarrinhoPercurso,
  ) async {
    final query = QueryBuilder()
      ..equals(SaveCartQueryFields.codEmpresa, codEmpresa.toString())
      ..equals(SaveCartQueryFields.codCarrinhoPercurso, codCarrinhoPercurso.toString())
      ..equals(SaveCartQueryFields.itemCarrinhoPercurso, itemCarrinhoPercurso);

    final items = await _separationItemRepository.selectConsultation(query);
    return items;
  }

  Future<SeparateProgressConsultationModel?> _findSeparateProgress(SaveSeparationCartParams params) async {
    final query = QueryBuilder()
      ..equals(SaveCartQueryFields.codEmpresa, params.codEmpresa.toString())
      ..equals(SaveCartQueryFields.codSepararEstoque, params.codSepararEstoque.toString());

    final separateProgresses = await _separateProgressRepository.selectConsultation(query);
    if (separateProgresses.isEmpty) return null;
    return separateProgresses.first;
  }

  Future<_SeparationItemsFinalizationResult> _updateSeparationItemsToFinalized(
    int codEmpresa,
    int codCarrinhoPercurso,
    String itemCarrinhoPercurso,
  ) async {
    final query = QueryBuilder()
      ..equals(SaveCartQueryFields.codEmpresa, codEmpresa.toString())
      ..equals(SaveCartQueryFields.codCarrinhoPercurso, codCarrinhoPercurso.toString())
      ..equals(SaveCartQueryFields.itemCarrinhoPercurso, itemCarrinhoPercurso)
      ..notEquals(SaveCartQueryFields.situacao, ExpeditionItemSituation.cancelado.code);

    final separationItems = await _separationItemModelRepository.select(query);
    final originalItems = List<SeparationItemModel>.from(separationItems);
    final finalizedItems = separationItems
        .map((item) => item.copyWith(situacao: ExpeditionItemSituation.finalizado))
        .toList();

    const batchSize = 5;
    const itemTimeout = Duration(seconds: 10);
    for (int i = 0; i < finalizedItems.length; i += batchSize) {
      final batch = finalizedItems.skip(i).take(batchSize).toList();
      await Future.wait(batch.map((item) => _separationItemModelRepository.update(item).timeout(itemTimeout)));
    }
    return _SeparationItemsFinalizationResult(originalItems: originalItems, finalizedItems: finalizedItems);
  }

  Future<bool> _rollbackSeparationItemsToOriginal(List<SeparationItemModel> originalItems) async {
    try {
      if (originalItems.isEmpty) return true;
      const batchSize = 5;
      const itemTimeout = Duration(seconds: 10);
      for (int i = 0; i < originalItems.length; i += batchSize) {
        final batch = originalItems.skip(i).take(batchSize).toList();
        await Future.wait(batch.map((item) => _separationItemModelRepository.update(item).timeout(itemTimeout)));
      }
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Falha no rollback dos itens de separação',
        tag: 'SaveSeparationCartUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> _rollbackCartRouteToOriginal(ExpeditionCartRouteInternshipModel originalRoute) async {
    try {
      await _cartRouteInternshipRepository.update(originalRoute);
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Falha no rollback do carrinho percurso',
        tag: 'SaveSeparationCartUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> _rollbackCartToOriginal(ExpeditionCartModel originalCart) async {
    try {
      await _cartRepository.update(originalCart);
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Falha no rollback do carrinho',
        tag: 'SaveSeparationCartUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<SaveSeparationCartFailure?> _validateSeparatedQuantities(
    SaveSeparationCartParams params,
    List<SeparationItemConsultationModel> itemsSeparation,
  ) async {
    try {
      AppLogger.debug('Iniciando validação de quantidades separadas', tag: 'SaveSeparationCartUseCase');

      final separateItemsQuery = QueryBuilder()
        ..equals(SaveCartQueryFields.codEmpresa, params.codEmpresa.toString())
        ..equals(SaveCartQueryFields.codSepararEstoque, params.codSepararEstoque.toString());

      final separateItems = await _separateItemRepository
          .selectConsultation(separateItemsQuery)
          .timeout(const Duration(seconds: 10));

      if (separateItems.isEmpty) {
        AppLogger.debug('Nenhum item de separação encontrado para validação', tag: 'SaveSeparationCartUseCase');
        return null;
      }

      final validSeparationItems = itemsSeparation
          .where((item) => item.situacao != ExpeditionItemSituation.cancelado)
          .toList();

      if (validSeparationItems.isEmpty) {
        AppLogger.debug('Nenhum item válido de separação encontrado para validação', tag: 'SaveSeparationCartUseCase');
        return null;
      }

      final Map<int, double> quantidadesSeparadasPorProduto = {};

      for (final item in validSeparationItems) {
        final codProduto = item.codProduto;
        final quantidade = item.quantidade;

        quantidadesSeparadasPorProduto[codProduto] = (quantidadesSeparadasPorProduto[codProduto] ?? 0.0) + quantidade;
      }

      AppLogger.debug('Validando ${separateItems.length} produto(s)', tag: 'SaveSeparationCartUseCase');

      for (final separateItem in separateItems) {
        final codProduto = separateItem.codProduto;
        final quantidadeSolicitada = separateItem.quantidade;
        final quantidadeSeparada = quantidadesSeparadasPorProduto[codProduto] ?? 0.0;

        if (quantidadeSeparada > quantidadeSolicitada) {
          AppLogger.warning(
            'Quantidade separada excede solicitada para produto ${separateItem.nomeProduto} (Cod: $codProduto) - Solicitado: $quantidadeSolicitada, Separado: $quantidadeSeparada',
            tag: 'SaveSeparationCartUseCase',
          );

          return SaveSeparationCartFailure.excessSeparatedQuantity(
            produtoNome: separateItem.nomeProduto,
            codProduto: codProduto,
            quantidadeSolicitada: quantidadeSolicitada,
            quantidadeSeparada: quantidadeSeparada,
          );
        }
      }

      AppLogger.debug('Validação de quantidades concluída com sucesso', tag: 'SaveSeparationCartUseCase');
      return null;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao validar quantidades separadas',
        tag: 'SaveSeparationCartUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      return SaveSeparationCartFailure.unexpected(e);
    }
  }

  static Future<(A, B, C)> _wait3<A, B, C>(Future<A> a, Future<B> b, Future<C> c) async {
    final r = await Future.wait([a, b, c]);
    return (r[0] as A, r[1] as B, r[2] as C);
  }

  static Future<(A, B)> _wait2<A, B>(Future<A> a, Future<B> b) async {
    final r = await Future.wait([a, b]);
    return (r[0] as A, r[1] as B);
  }
}

class _SeparationItemsFinalizationResult {
  final List<SeparationItemModel> originalItems;
  final List<SeparationItemModel> finalizedItems;

  const _SeparationItemsFinalizationResult({required this.originalItems, required this.finalizedItems});
}
