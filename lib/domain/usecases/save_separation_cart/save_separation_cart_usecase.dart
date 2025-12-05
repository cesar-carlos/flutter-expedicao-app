import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/utils/app_helper.dart';
import 'package:data7_expedicao/data/services/user_session_service.dart';
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
  final UserSessionService _userSessionService;

  SaveSeparationCartUseCase({
    required BasicRepository<ExpeditionCartRouteInternshipModel> cartRouteInternshipRepository,
    required BasicConsultationRepository<SeparationItemConsultationModel> separationItemConsultationRepository,
    required BasicConsultationRepository<SeparateItemConsultationModel> separateItemRepository,
    required BasicConsultationRepository<SeparateProgressConsultationModel> separateProgressRepository,
    required BasicRepository<SeparationItemModel> separationItemModelRepository,
    required BasicRepository<ExpeditionCartModel> cartRepository,
    required UserSessionService userSessionService,
  }) : _cartRouteInternshipRepository = cartRouteInternshipRepository,
       _separationItemRepository = separationItemConsultationRepository,
       _separateItemRepository = separateItemRepository,
       _separationItemModelRepository = separationItemModelRepository,
       _separateProgressRepository = separateProgressRepository,
       _userSessionService = userSessionService,
       _cartRepository = cartRepository;

  Future<Result<SaveSeparationCartSuccess>> call(SaveSeparationCartParams params) async {
    try {
      final appUser = await _userSessionService.loadUserSession();
      if (appUser?.userSystemModel == null) {
        return Failure(SaveSeparationCartFailure.userNotAuthenticated());
      }

      // Validar situação da separação
      final separateProgress = await _findSeparateProgress(params);
      if (separateProgress == null) {
        return Failure(SaveSeparationCartFailure.separationNotFound());
      }

      if (separateProgress.situacao != ExpeditionSituation.separando) {
        return Failure(SaveSeparationCartFailure.invalidSeparationStatus(separateProgress.situacao.description));
      }

      final itemsSeparation = await _findItemsSeparation(
        params.codEmpresa,
        params.codCarrinhoPercurso,
        params.itemCarrinhoPercurso,
      );

      if (itemsSeparation.isEmpty) {
        return Failure(SaveSeparationCartFailure.noItems());
      }

      final hasSeparatedItems = itemsSeparation.any((item) => item.situacao == ExpeditionItemSituation.separado);

      if (!hasSeparatedItems) {
        return Failure(SaveSeparationCartFailure.noSeparatedItems());
      }

      // Validar se há excesso de quantidade separada
      final validationResult = await _validateSeparatedQuantities(params);
      if (validationResult != null) {
        return Failure(validationResult);
      }

      final cartRouteInternship = await _findCartRouteInternship(
        params.codEmpresa,
        params.codCarrinhoPercurso,
        params.itemCarrinhoPercurso,
      );

      if (cartRouteInternship == null) {
        return Failure(SaveSeparationCartFailure.cartRouteInternshiptNotFound());
      }

      if (cartRouteInternship.situacao != ExpeditionSituation.separando) {
        return Failure(SaveSeparationCartFailure.invalidStatus(cartRouteInternship));
      }

      final cartModel = await _findCart(params.codEmpresa, cartRouteInternship.codCarrinho);
      if (cartModel == null) {
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

      // Atualizar situação dos itens de separação para finalizado
      await _updateSeparationItemsToFinalized(
        params.codEmpresa,
        params.codCarrinhoPercurso,
        params.itemCarrinhoPercurso,
      );

      await _cartRouteInternshipRepository.update(copyWithCartRouteInternship);
      await _cartRepository.update(copyWithCart);
      return Success(
        SaveSeparationCartSuccess(
          cart: copyWithCartRouteInternship,
          dataFinalizacao: now,
          horaFinalizacao: currentTime,
          codUsuarioFinalizacao: userModel.codUsuario,
          nomeUsuarioFinalizacao: userModel.nomeUsuario,
        ),
      );
    } catch (e) {
      return Failure(SaveSeparationCartFailure.unexpected(e));
    }
  }

  //internal methods
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

  /// Valida se a quantidade separada não excede a solicitada para cada produto
  Future<SaveSeparationCartFailure?> _validateSeparatedQuantities(SaveSeparationCartParams params) async {
    try {
      // 1. Buscar os itens do pedido de separação (quantidade solicitada)
      final separateItemsQuery = QueryBuilder()
        ..equals('CodEmpresa', params.codEmpresa.toString())
        ..equals('CodSepararEstoque', params.codSepararEstoque.toString());

      final separateItems = await _separateItemRepository.selectConsultation(separateItemsQuery);

      if (separateItems.isEmpty) {
        return null; // Se não houver itens do pedido, não há como validar
      }

      // 2. Buscar os itens já separados (quantidade separada)
      final separationItems = await _findItemsSeparation(
        params.codEmpresa,
        params.codCarrinhoPercurso,
        params.itemCarrinhoPercurso,
      );

      // Filtrar apenas itens separados (não cancelados)
      final validSeparationItems = separationItems
          .where((item) => item.situacao != ExpeditionItemSituation.cancelado)
          .toList();

      if (validSeparationItems.isEmpty) {
        return null; // Se não houver itens separados válidos, não há excesso
      }

      // 3. Agrupar itens separados por produto e somar as quantidades
      final Map<int, double> quantidadesSeparadasPorProduto = {};

      for (final item in validSeparationItems) {
        final codProduto = item.codProduto;
        final quantidade = item.quantidade;

        quantidadesSeparadasPorProduto[codProduto] = (quantidadesSeparadasPorProduto[codProduto] ?? 0.0) + quantidade;
      }

      // 4. Comparar com as quantidades solicitadas
      for (final separateItem in separateItems) {
        final codProduto = separateItem.codProduto;
        final quantidadeSolicitada = separateItem.quantidade;
        final quantidadeSeparada = quantidadesSeparadasPorProduto[codProduto] ?? 0.0;

        // Se a quantidade separada excede a solicitada
        if (quantidadeSeparada > quantidadeSolicitada) {
          return SaveSeparationCartFailure.excessSeparatedQuantity(
            produtoNome: separateItem.nomeProduto,
            codProduto: codProduto,
            quantidadeSolicitada: quantidadeSolicitada,
            quantidadeSeparada: quantidadeSeparada,
          );
        }
      }

      return null; // Validação passou
    } catch (e) {
      // Em caso de erro na validação, não deve bloquear o salvamento
      // A validação é preventiva, não crítica
      return null;
    }
  }
}
