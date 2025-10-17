import 'package:data7_expedicao/domain/usecases/base_usecase.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/usecases/add_cart/add_cart_params.dart';
import 'package:data7_expedicao/domain/usecases/add_cart/add_cart_success.dart';
import 'package:data7_expedicao/domain/usecases/add_cart/add_cart_failure.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:data7_expedicao/domain/repositories/user_system_repository.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_model.dart';
import 'package:data7_expedicao/domain/models/expedition_internship_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/data/services/user_session_service.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/models/user/app_user.dart';
import 'package:data7_expedicao/core/utils/app_helper.dart';
import 'package:data7_expedicao/core/results/index.dart';

/// UseCase para adicionar um carrinho à separação
class AddCartUseCase extends UseCase<AddCartSuccess, AddCartParams> {
  late int codCarrinhoPercurso;
  final BasicRepository<ExpeditionCartModel> _cartRepository;
  final BasicRepository<ExpeditionCartRouteModel> _cartRouteRepository;
  final BasicRepository<ExpeditionCartRouteInternshipModel> _cartRouteInternshipRepository;
  final BasicConsultationRepository<ExpeditionCartConsultationModel> _cartConsultationRepository;
  final BasicRepository<ExpeditionInternshipModel> _expeditionInternshipRepository;
  final UserSystemRepository _userSystemRepository;
  final UserSessionService _userSessionService;

  AddCartUseCase({
    required BasicRepository<ExpeditionCartModel> cartRepository,
    required BasicRepository<ExpeditionCartRouteModel> cartRouteRepository,
    required BasicRepository<ExpeditionCartRouteInternshipModel> cartRouteInternshipRepository,
    required BasicConsultationRepository<ExpeditionCartConsultationModel> cartConsultationRepository,
    required BasicRepository<ExpeditionInternshipModel> expeditionInternshipRepository,
    required UserSystemRepository userSystemRepository,
    required UserSessionService userSessionService,
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
      // 1. Validar parâmetros
      if (!params.isValid) {
        final errors = params.validationErrors.join(', ');
        return failure(AddCartFailure.invalidParameters(errors));
      }

      // 2. Verificar usuário autenticado e carregar UserSystemModel se necessário
      final user = await _loadAndEnsureUserSystemModel();
      if (user?.userSystemModel == null) {
        return failure(AddCartFailure.userNotAuthenticated());
      }

      // 3. Buscar carrinho pelo código
      final cartsResult = await _findCartByCode(params.codCarrinho);
      final cart = cartsResult.fold((success) => success, (failure) => null);
      if (cart == null) {
        return cartsResult.fold(
          (success) => failure(AddCartFailure.generic('Erro inesperado')),
          (failure) => Failure(failure),
        );
      }

      // 4. Validar situação do carrinho
      final situationResult = _validateCartSituation(cart);
      final isValidSituation = situationResult.fold((success) => true, (failure) => false);
      if (!isValidSituation) {
        return situationResult.fold(
          (success) => failure(AddCartFailure.generic('Erro inesperado')),
          (failure) => Failure(failure),
        );
      }

      // 5. Buscar percurso baseado na origem
      final routeResult = await _findRoute(params);
      final routeCode = routeResult.fold((success) => success, (failure) => null);
      if (routeCode == null) {
        return routeResult.fold(
          (success) => failure(AddCartFailure.generic('Percurso não encontrado')),
          (failure) => Failure(failure),
        );
      }

      codCarrinhoPercurso = routeCode;
      final internshipResult = await _findInternship(params.origem);
      final internshipCode = internshipResult.fold((success) => success, (failure) => null);
      if (internshipCode == null) {
        return internshipResult.fold(
          (success) => failure(AddCartFailure.generic('Estágio não encontrado')),
          (failure) => Failure(failure),
        );
      }

      // 6. Executar operações de banco de dados
      await _updateCartSituation(cart);
      final cartRouteInternshipModel = await _createCartRoute(params, cart, user!.userSystemModel!, internshipCode);
      await _cartRouteInternshipRepository.insert(cartRouteInternshipModel);

      // 7. Retornar sucesso
      return success(
        AddCartSuccess(
          addedCart: cart,
          message: 'Carrinho ${cart.codCarrinho} adicionado com sucesso à separação',
          codCarrinhoPercurso: codCarrinhoPercurso,
        ),
      );
    } catch (e) {
      return failure(AddCartFailure.repositoryError(e));
    }
  }

  /// Carrega o usuário atual e garante que tenha UserSystemModel
  Future<AppUser?> _loadAndEnsureUserSystemModel() async {
    try {
      var user = await _userSessionService.loadUserSession();

      if (user == null) {
        return null;
      }

      // Se já tem UserSystemModel, retorna o usuário
      if (user.userSystemModel != null) {
        return user;
      }

      // Se não tem codUsuario, não pode carregar UserSystemModel
      if (user.codUsuario == null) {
        return user;
      }

      // Tentar carregar UserSystemModel do servidor
      try {
        final userSystemModel = await _userSystemRepository.getUserById(user.codUsuario!);

        if (userSystemModel != null) {
          // Atualizar o usuário com o UserSystemModel
          user = user.copyWith(userSystemModel: userSystemModel);

          // Salvar a sessão atualizada
          await _userSessionService.saveUserSession(user);
        }
      } catch (e) {
        // Se falhar ao carregar UserSystemModel, continua com o usuário sem ele
        // Isso não deve impedir o funcionamento do app
      }

      return user;
    } catch (e) {
      return null;
    }
  }

  /// Busca carrinho pelo código
  Future<Result<ExpeditionCartConsultationModel>> _findCartByCode(int codCarrinho) async {
    try {
      final carts = await _cartConsultationRepository.selectConsultation(
        QueryBuilder().equals('codCarrinho', codCarrinho),
      );

      if (carts.isEmpty) {
        return failure(AddCartFailure.cartNotFound(codCarrinho.toString()));
      }

      return success(carts.first);
    } catch (e) {
      return failure(AddCartFailure.repositoryError(e));
    }
  }

  /// Valida se o carrinho pode ser adicionado
  Result<bool> _validateCartSituation(ExpeditionCartConsultationModel cart) {
    if (cart.situacao != ExpeditionCartSituation.liberado) {
      return failure(AddCartFailure.invalidSituation(cart.situacaoDescription));
    }
    return success(true);
  }

  /// Busca o percurso baseado na origem
  Future<Result<int>> _findRoute(AddCartParams params) async {
    try {
      if (params.origem.code == ExpeditionOrigem.separacaoEstoque.code) {
        final cartRouteModels = await _cartRouteRepository.select(
          QueryBuilder()
              .equals('CodEmpresa', params.codEmpresa)
              .equals('CodOrigem', params.codOrigem)
              .equals('Origem', params.origem.code),
        );

        if (cartRouteModels.isEmpty) {
          return failure(AddCartFailure.routeNotFound('separacaoEstoque'));
        }

        return success(cartRouteModels.first.codCarrinhoPercurso);
      }

      if (params.origem.code == ExpeditionOrigem.compraMercadoria.code) {
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
    final cartModel = ExpeditionCartModel(
      codEmpresa: cart.codEmpresa,
      codCarrinho: cart.codCarrinho,
      descricao: cart.descricaoCarrinho,
      ativo: cart.ativo,
      codigoBarras: cart.codigoBarras,
      situacao: ExpeditionCartSituation.emSeparacao,
    );

    await _cartRepository.update(cartModel);
  }

  /// Busca o percurso baseado na origem
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

  /// Cria o vínculo do carrinho com a separação
  Future<ExpeditionCartRouteInternshipModel> _createCartRoute(
    AddCartParams params,
    ExpeditionCartConsultationModel cart,
    UserSystemModel userSystem,
    int internshipCode,
  ) async {
    final now = DateTime.now();

    return ExpeditionCartRouteInternshipModel(
      codEmpresa: params.codEmpresa,
      codCarrinhoPercurso: codCarrinhoPercurso, // Será gerado pelo backend
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
