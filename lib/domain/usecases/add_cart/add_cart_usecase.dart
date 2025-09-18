import 'package:exp/domain/usecases/base_usecase.dart';
import 'package:exp/domain/models/expedition_cart_model.dart';
import 'package:exp/domain/usecases/add_cart/add_cart_params.dart';
import 'package:exp/domain/usecases/add_cart/add_cart_result.dart';
import 'package:exp/domain/repositories/basic_consultation_repository.dart';
import 'package:exp/domain/models/expedition_cart_consultation_model.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_model.dart';
import 'package:exp/domain/models/expedition_cart_situation_model.dart';
import 'package:exp/domain/repositories/user_system_repository.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/domain/repositories/basic_repository.dart';
import 'package:exp/data/services/user_session_service.dart';
import 'package:exp/domain/models/user_system_models.dart';
import 'package:exp/domain/models/user/app_user.dart';
import 'package:exp/core/utils/app_helper.dart';

/// UseCase para adicionar um carrinho à separação
class AddCartUseCase extends UseCase<AddCartResult, AddCartParams> {
  final BasicRepository<ExpeditionCartModel> _cartRepository;
  final BasicRepository<ExpeditionCartRouteInternshipModel> _cartRouteRepository;
  final BasicConsultationRepository<ExpeditionCartConsultationModel> _cartConsultationRepository;
  final UserSystemRepository _userSystemRepository;
  final UserSessionService _userSessionService;

  AddCartUseCase({
    required BasicRepository<ExpeditionCartModel> cartRepository,
    required BasicRepository<ExpeditionCartRouteInternshipModel> cartRouteRepository,
    required BasicConsultationRepository<ExpeditionCartConsultationModel> cartConsultationRepository,
    required UserSessionService userSessionService,
    required UserSystemRepository userSystemRepository,
  }) : _cartRepository = cartRepository,
       _cartRouteRepository = cartRouteRepository,
       _cartConsultationRepository = cartConsultationRepository,
       _userSystemRepository = userSystemRepository,
       _userSessionService = userSessionService;

  @override
  Future<AddCartResult> call(AddCartParams params) async {
    try {
      // 1. Validar parâmetros
      final validationResult = _validateParams(params);
      if (validationResult != null) {
        return validationResult;
      }

      // 2. Verificar usuário autenticado e carregar UserSystemModel se necessário
      final user = await _loadAndEnsureUserSystemModel();
      if (user?.userSystemModel == null) {
        return AddCartFailure.userNotAuthenticated();
      }

      // 3. Buscar carrinho pelo código
      final carts = await _cartConsultationRepository.selectConsultation(
        QueryBuilder().equals('codCarrinho', params.codCarrinho),
      );

      if (carts.isEmpty) {
        return AddCartFailure.cartNotFound(params.codCarrinho.toString());
      }

      // 4. Validar situação do carrinho
      final situationValidation = _validateCartSituation(carts.first);
      if (situationValidation != null) {
        return situationValidation;
      }

      final cart = carts.first;

      // 5. Executar operações de banco de dados
      await _updateCartSituation(cart);
      await _createCartRoute(params, cart, user!.userSystemModel!);

      // 6. Retornar sucesso
      return AddCartSuccess(
        addedCart: cart,
        message: 'Carrinho ${cart.codCarrinho} adicionado com sucesso à separação',
      );
    } catch (e) {
      return AddCartFailure.repositoryError(e);
    }
  }

  /// Valida os parâmetros de entrada
  AddCartFailure? _validateParams(AddCartParams params) {
    if (!params.isValid) {
      final errors = params.validationErrors.join(', ');
      return AddCartFailure.invalidParameters(errors);
    }
    return null;
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

  /// Valida se o carrinho pode ser adicionado
  AddCartFailure? _validateCartSituation(ExpeditionCartConsultationModel cart) {
    if (cart.situacao != ExpeditionCartSituation.liberado) {
      return AddCartFailure.invalidSituation(cart.situacaoDescription);
    }
    return null;
  }

  /// Atualiza a situação do carrinho para SEPARADO
  Future<void> _updateCartSituation(ExpeditionCartConsultationModel cart) async {
    final cartModel = ExpeditionCartModel(
      codEmpresa: cart.codEmpresa,
      codCarrinho: cart.codCarrinho,
      descricao: cart.descricaoCarrinho,
      ativo: cart.ativo,
      codigoBarras: cart.codigoBarras,
      situacao: ExpeditionCartSituation.separando,
    );

    await _cartRepository.update(cartModel);
  }

  /// Cria o vínculo do carrinho com a separação
  Future<void> _createCartRoute(
    AddCartParams params,
    ExpeditionCartConsultationModel cart,
    UserSystemModel userSystem,
  ) async {
    final now = DateTime.now();

    final routeModel = ExpeditionCartRouteInternshipModel(
      codEmpresa: params.codEmpresa,
      codCarrinhoPercurso: 0, // Será gerado pelo backend
      item: '00000',
      origem: params.origem,
      codOrigem: params.codOrigem,
      codPercursoEstagio: 1, // Estágio inicial
      codCarrinho: cart.codCarrinho,
      situacao: ExpeditionCartSituation.separando,
      dataInicio: now,
      horaInicio: AppHelper.formatTime(now),
      codUsuarioInicio: userSystem.codUsuario,
      nomeUsuarioInicio: userSystem.nomeUsuario,
    );

    await _cartRouteRepository.insert(routeModel);
  }
}
