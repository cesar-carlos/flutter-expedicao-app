import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/utils/app_helper.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_params.dart';
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

      final results = await Future.wait([
        _findSeparateProgress(params),
        _findItemsSeparation(params.codEmpresa, params.codCarrinhoPercurso, params.itemCarrinhoPercurso),
      ]);

      final separateProgress = results[0] as SeparateProgressConsultationModel?;
      final itemsSeparation = results[1] as List<SeparationItemConsultationModel>;

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

      AppLogger.debug('Validando quantidades separadas antes de salvar carrinho', tag: 'SaveSeparationCartUseCase');

      final validationResult = await _validateSeparatedQuantities(params);
      if (validationResult != null) {
        AppLogger.warning(
          'Validação de quantidades falhou: ${validationResult.message}',
          tag: 'SaveSeparationCartUseCase',
        );
        return Failure(validationResult);
      }

      final cartRouteInternship = await _findCartRouteInternship(
        params.codEmpresa,
        params.codCarrinhoPercurso,
        params.itemCarrinhoPercurso,
      );

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

      final cartModel = await _findCart(params.codEmpresa, cartRouteInternship.codCarrinho);
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

      await _updateSeparationItemsToFinalized(
        params.codEmpresa,
        params.codCarrinhoPercurso,
        params.itemCarrinhoPercurso,
      );

      await _cartRouteInternshipRepository.update(copyWithCartRouteInternship);
      await _cartRepository.update(copyWithCart);

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
      ..equals('CodEmpresa', codEmpresa.toString())
      ..equals('CodCarrinho', codCarrinho.toString());

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
      ..equals('CodEmpresa', codEmpresa.toString())
      ..equals('CodCarrinhoPercurso', codCarrinhoPercurso.toString())
      ..equals('Item', item);

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
      ..equals('CodEmpresa', codEmpresa.toString())
      ..equals('CodCarrinhoPercurso', codCarrinhoPercurso.toString())
      ..equals('ItemCarrinhoPercurso', itemCarrinhoPercurso);

    final items = await _separationItemRepository.selectConsultation(query);
    return items;
  }

  Future<SeparateProgressConsultationModel?> _findSeparateProgress(SaveSeparationCartParams params) async {
    final query = QueryBuilder()
      ..equals('CodEmpresa', params.codEmpresa.toString())
      ..equals('CodSepararEstoque', params.codSepararEstoque.toString());

    final separateProgresses = await _separateProgressRepository.selectConsultation(query);
    if (separateProgresses.isEmpty) return null;
    return separateProgresses.first;
  }

  Future<void> _updateSeparationItemsToFinalized(
    int codEmpresa,
    int codCarrinhoPercurso,
    String itemCarrinhoPercurso,
  ) async {
    final query = QueryBuilder()
      ..equals('CodEmpresa', codEmpresa.toString())
      ..equals('CodCarrinhoPercurso', codCarrinhoPercurso.toString())
      ..equals('ItemCarrinhoPercurso', itemCarrinhoPercurso)
      ..notEquals('Situacao', ExpeditionItemSituation.cancelado.code);

    final separationItems = await _separationItemModelRepository.select(query);

    for (final item in separationItems) {
      final updatedItem = item.copyWith(situacao: ExpeditionItemSituation.finalizado);
      await _separationItemModelRepository.update(updatedItem);
    }
  }

  Future<SaveSeparationCartFailure?> _validateSeparatedQuantities(SaveSeparationCartParams params) async {
    try {
      AppLogger.debug('Iniciando validação de quantidades separadas', tag: 'SaveSeparationCartUseCase');

      final separateItemsQuery = QueryBuilder()
        ..equals('CodEmpresa', params.codEmpresa.toString())
        ..equals('CodSepararEstoque', params.codSepararEstoque.toString());

      final separationItemsQuery = QueryBuilder()
        ..equals('CodEmpresa', params.codEmpresa.toString())
        ..equals('CodCarrinhoPercurso', params.codCarrinhoPercurso.toString())
        ..equals('ItemCarrinhoPercurso', params.itemCarrinhoPercurso);

      AppLogger.debug('Sincronizando dados do servidor antes da validação', tag: 'SaveSeparationCartUseCase');

      final syncResults = await Future.wait([
        _separateItemRepository.selectConsultation(separateItemsQuery),
        _separationItemRepository.selectConsultation(separationItemsQuery),
      ]);

      final separateItems = syncResults[0] as List<SeparateItemConsultationModel>;
      final separationItems = syncResults[1] as List<SeparationItemConsultationModel>;

      if (separateItems.isEmpty) {
        AppLogger.debug('Nenhum item de separação encontrado para validação', tag: 'SaveSeparationCartUseCase');
        return null;
      }

      final validSeparationItems = separationItems
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

      for (final separateItem in separateItems) {
        final codProduto = separateItem.codProduto;
        final quantidadeSolicitada = separateItem.quantidade;
        final quantidadeSeparada = quantidadesSeparadasPorProduto[codProduto] ?? 0.0;

        AppLogger.debug(
          'Validando produto: ${separateItem.nomeProduto} (Cod: $codProduto) - Solicitado: $quantidadeSolicitada, Separado: $quantidadeSeparada',
          tag: 'SaveSeparationCartUseCase',
        );

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
}
