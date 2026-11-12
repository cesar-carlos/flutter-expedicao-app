import 'package:data7_expedicao/domain/usecases/base_usecase.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/usecases/add_cart/add_cart_params.dart';
import 'package:data7_expedicao/domain/usecases/add_cart/add_cart_success.dart';
import 'package:data7_expedicao/domain/usecases/add_cart/add_cart_failure.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_query.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:data7_expedicao/domain/repositories/user_system_repository.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_model.dart';
import 'package:data7_expedicao/domain/models/expedition_internship_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/models/user/app_user.dart';
import 'package:data7_expedicao/core/utils/app_helper.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/core/results/index.dart';

class AddCartUseCase extends UseCase<AddCartSuccess, AddCartParams> {
  final BasicRepository<ExpeditionCartModel> _cartRepository;
  final BasicRepository<ExpeditionCartRouteModel> _cartRouteRepository;
  final BasicRepository<ExpeditionCartRouteInternshipModel> _cartRouteInternshipRepository;
  final BasicConsultationRepository<ExpeditionCartConsultationModel> _cartConsultationRepository;
  final BasicRepository<ExpeditionInternshipModel> _expeditionInternshipRepository;
  final UserSystemRepository _userSystemRepository;
  final IUserSessionService _userSessionService;

  AddCartUseCase({
    required BasicRepository<ExpeditionCartModel> cartRepository,
    required BasicRepository<ExpeditionCartRouteModel> cartRouteRepository,
    required BasicRepository<ExpeditionCartRouteInternshipModel> cartRouteInternshipRepository,
    required BasicConsultationRepository<ExpeditionCartConsultationModel> cartConsultationRepository,
    required BasicRepository<ExpeditionInternshipModel> expeditionInternshipRepository,
    required UserSystemRepository userSystemRepository,
    required IUserSessionService userSessionService,
  }) : _cartRepository = cartRepository,
       _cartRouteRepository = cartRouteRepository,
       _cartRouteInternshipRepository = cartRouteInternshipRepository,
       _cartConsultationRepository = cartConsultationRepository,
       _expeditionInternshipRepository = expeditionInternshipRepository,
       _userSystemRepository = userSystemRepository,
       _userSessionService = userSessionService;

  @override
  Future<Result<AddCartSuccess>> call(AddCartParams params) async {
    try {
      if (!params.isValid) {
        final errors = params.validationErrors.join(', ');
        return failure(AddCartFailure.invalidParameters(errors));
      }

      final hasResolvedRoute =
          params.origem == ExpeditionOrigem.separacaoEstoque &&
          params.codCarrinhoPercurso != null &&
          params.codCarrinhoPercurso! > 0;

      final cartLookup = params.scannedCart != null
          ? Future.value(success(params.scannedCart!))
          : _findCartByCode(params.codCarrinho);
      final routeLookup = hasResolvedRoute ? Future.value(success(params.codCarrinhoPercurso!)) : _findRoute(params);

      final (user, cartsResult, internshipResult, routeResult) = await (
        _loadAndEnsureUserSystemModel(),
        cartLookup,
        _findInternship(params.origem),
        routeLookup,
      ).wait;

      if (user?.userSystemModel == null) {
        return failure(AddCartFailure.userNotAuthenticated());
      }

      final cartFailure = _failureFrom(cartsResult);
      if (cartFailure != null) {
        return cartFailure;
      }
      final cart = cartsResult.getOrNull()!;

      final situationResult = _validateCartSituation(cart);
      final situationFailure = _failureFrom(situationResult);
      if (situationFailure != null) {
        return situationFailure;
      }

      final routeFailure = _failureFrom(routeResult);
      if (routeFailure != null) {
        return routeFailure;
      }
      final resolvedCodCarrinhoPercurso = routeResult.getOrNull()!;

      final internshipFailure = _failureFrom(internshipResult);
      if (internshipFailure != null) {
        return internshipFailure;
      }
      final internshipCode = internshipResult.getOrNull()!;

      await _updateCartSituation(cart);
      final cartRouteInternshipModel = _createCartRouteInternship(
        params,
        cart,
        user!.userSystemModel!,
        internshipCode,
        resolvedCodCarrinhoPercurso,
      );

      try {
        await _cartRouteInternshipRepository.insert(cartRouteInternshipModel);
      } catch (e) {
        await _rollbackCartSituation(cart);
        rethrow;
      }

      return success(
        AddCartSuccess(
          addedCart: cart,
          message: 'Carrinho ${cart.codCarrinho} adicionado com sucesso à separação',
          codCarrinhoPercurso: resolvedCodCarrinhoPercurso,
        ),
      );
    } catch (e) {
      return failure(AddCartFailure.repositoryError(e));
    }
  }

  Result<AddCartSuccess>? _failureFrom<T extends Object>(Result<T> result) {
    if (result.isSuccess()) {
      return null;
    }
    final error = result.exceptionOrNull();
    if (error is AppFailure) {
      return Failure(error);
    }
    return failure(AddCartFailure.repositoryError(error));
  }

  Future<void> _rollbackCartSituation(ExpeditionCartConsultationModel cart) async {
    try {
      await _cartRepository.update(cart.toCartModel(situacao: ExpeditionCartSituation.liberado));
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Falha no rollback do cart apos erro na criacao da rota — estado pode estar inconsistente',
        tag: 'AddCartUseCase',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<AppUser?> _loadAndEnsureUserSystemModel() async {
    try {
      var user = await _userSessionService.loadUserSession();

      if (user == null) {
        return null;
      }

      if (user.userSystemModel != null) {
        return user;
      }

      if (user.codUsuario == null) {
        return user;
      }

      try {
        final userSystemModel = await _userSystemRepository.getUserById(user.codUsuario!);

        if (userSystemModel != null) {
          user = user.copyWith(userSystemModel: userSystemModel);

          await _userSessionService.saveUserSession(user);
        }
      } catch (e, stackTrace) {
        AppLogger.warning(
          'Erro ao carregar userSystemModel ou salvar sessão',
          tag: 'AddCartUseCase',
          error: e,
          stackTrace: stackTrace,
        );
      }

      return user;
    } catch (e, stackTrace) {
      AppLogger.warning('Erro ao carregar sessão do usuário', tag: 'AddCartUseCase', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<Result<ExpeditionCartConsultationModel>> _findCartByCode(int codCarrinho) async {
    try {
      final carts = await _cartConsultationRepository.selectConsultation(
        QueryBuilder().equals('CodCarrinho', codCarrinho),
      );

      if (carts.isEmpty) {
        return failure(AddCartFailure.cartNotFound(codCarrinho.toString()));
      }

      return success(carts.first);
    } catch (e) {
      return failure(AddCartFailure.repositoryError(e));
    }
  }

  Result<bool> _validateCartSituation(ExpeditionCartConsultationModel cart) {
    if (cart.situacao != ExpeditionCartSituation.liberado) {
      return failure(AddCartFailure.invalidSituation(cart.situacaoDescription));
    }
    return success(true);
  }

  Future<Result<int>> _findRoute(AddCartParams params) async {
    try {
      if (params.origem == ExpeditionOrigem.separacaoEstoque) {
        final cartRouteModels = await _cartRouteRepository.select(
          ExpeditionCartRouteQuery.activeByOrigin(
            codEmpresa: params.codEmpresa,
            origem: params.origem,
            codOrigem: params.codOrigem,
          ),
        );

        if (cartRouteModels.isEmpty) {
          return failure(AddCartFailure.routeNotFound('separacaoEstoque'));
        }

        return success(cartRouteModels.first.codCarrinhoPercurso);
      }

      if (params.origem == ExpeditionOrigem.compraMercadoria) {
        final cartRouteInternshipModels = await _cartRouteInternshipRepository.select(
          QueryBuilder()
              .equals('CodEmpresa', params.codEmpresa)
              .equals('CodOrigem', params.codOrigem)
              .equals('Origem', params.origem.code),
        );

        if (cartRouteInternshipModels.isEmpty) {
          return failure(AddCartFailure.routeNotFound('compraMercadoria'));
        }

        return success(cartRouteInternshipModels.first.codCarrinhoPercurso);
      }

      return failure(AddCartFailure.routeNotFound(params.origem.code));
    } catch (e) {
      return failure(AddCartFailure.repositoryError(e));
    }
  }

  Future<void> _updateCartSituation(ExpeditionCartConsultationModel cart) async {
    await _cartRepository.update(cart.toCartModel(situacao: ExpeditionCartSituation.emSeparacao));
  }

  Future<Result<int>> _findInternship(ExpeditionOrigem origem) async {
    try {
      final internshipModels = await _expeditionInternshipRepository.select(
        QueryBuilder().equals('Origem', origem.code),
      );

      if (internshipModels.isEmpty) {
        return failure(AddCartFailure.generic('Estágio não encontrado'));
      }

      return success(internshipModels.first.codPercursoEstagio);
    } catch (e) {
      return failure(AddCartFailure.repositoryError(e));
    }
  }

  ExpeditionCartRouteInternshipModel _createCartRouteInternship(
    AddCartParams params,
    ExpeditionCartConsultationModel cart,
    UserSystemModel userSystem,
    int internshipCode,
    int codCarrinhoPercurso,
  ) {
    final now = DateTime.now();

    return ExpeditionCartRouteInternshipModel(
      codEmpresa: params.codEmpresa,
      codCarrinhoPercurso: codCarrinhoPercurso,
      item: '00000',
      origem: params.origem,
      codOrigem: params.codOrigem,
      codPercursoEstagio: internshipCode,
      codCarrinho: cart.codCarrinho,
      situacao: ExpeditionSituation.separando,
      dataInicio: now,
      horaInicio: AppHelper.formatTime(now),
      codUsuarioInicio: userSystem.codUsuario,
      nomeUsuarioInicio: userSystem.nomeUsuario,
    );
  }
}
