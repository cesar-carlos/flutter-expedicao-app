import 'package:exp/domain/usecases/base_usecase.dart';
import 'package:exp/domain/models/expedition_cart_model.dart';
import 'package:exp/domain/usecases/add_cart/add_cart_params.dart';
import 'package:exp/domain/usecases/add_cart/add_cart_result.dart';
import 'package:exp/domain/models/expedition_cart_consultation_model.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_model.dart';
import 'package:exp/domain/repositories/expedition_cart_consultation_repository.dart';
import 'package:exp/domain/models/expedition_cart_situation_model.dart';
import 'package:exp/domain/repositories/basic_repository.dart';
import 'package:exp/data/services/user_session_service.dart';
import 'package:exp/domain/models/user/app_user.dart';

/// UseCase para adicionar um carrinho à separação
class AddCartUseCase extends UseCase<AddCartResult, AddCartParams> {
  final ExpeditionCartConsultationRepository _cartConsultationRepository;
  final BasicRepository<ExpeditionCartModel> _cartRepository;
  final BasicRepository<ExpeditionCartRouteInternshipModel> _cartRouteRepository;
  final UserSessionService _userSessionService;

  AddCartUseCase({
    required ExpeditionCartConsultationRepository cartConsultationRepository,
    required BasicRepository<ExpeditionCartModel> cartRepository,
    required BasicRepository<ExpeditionCartRouteInternshipModel> cartRouteRepository,
    required UserSessionService userSessionService,
  }) : _cartConsultationRepository = cartConsultationRepository,
       _cartRepository = cartRepository,
       _cartRouteRepository = cartRouteRepository,
       _userSessionService = userSessionService;

  @override
  Future<AddCartResult> call(AddCartParams params) async {
    try {
      // 1. Validar parâmetros
      final validationResult = _validateParams(params);
      if (validationResult != null) {
        return validationResult;
      }

      // 2. Verificar usuário autenticado
      final user = await _loadCurrentUser();
      if (user?.userSystemModel == null) {
        return AddCartFailure.userNotAuthenticated();
      }

      // 3. Buscar carrinho pelo código
      final cart = await _findCartByCode(params);
      if (cart == null) {
        return AddCartFailure.cartNotFound(params.codCarrinho.toString());
      }

      // 4. Validar situação do carrinho
      final situationValidation = _validateCartSituation(cart);
      if (situationValidation != null) {
        return situationValidation;
      }

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

  /// Carrega o usuário atual da sessão
  Future<AppUser?> _loadCurrentUser() async {
    try {
      return await _userSessionService.loadUserSession();
    } catch (e) {
      return null;
    }
  }

  /// Busca o carrinho pelo código
  Future<ExpeditionCartConsultationModel?> _findCartByCode(AddCartParams params) async {
    return await _cartConsultationRepository.getCartByCode(
      codEmpresa: params.codEmpresa,
      codCarrinho: params.codCarrinho,
    );
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
      situacao: ExpeditionCartSituation.separado,
    );

    await _cartRepository.update(cartModel);
  }

  /// Cria o vínculo do carrinho com a separação
  Future<void> _createCartRoute(AddCartParams params, ExpeditionCartConsultationModel cart, dynamic userSystem) async {
    final now = DateTime.now();

    final routeModel = ExpeditionCartRouteInternshipModel(
      codEmpresa: params.codEmpresa,
      codCarrinhoPercurso: 0, // Será gerado pelo backend
      item: 'Separação de Estoque',
      origem: params.origem,
      codOrigem: params.codOrigem,
      codPercursoEstagio: 1, // Estágio inicial
      codCarrinho: cart.codCarrinho,
      situacao: ExpeditionCartSituation.separado,
      dataInicio: now,
      horaInicio: _formatTime(now),
      codUsuarioInicio: userSystem.codUsuario,
      nomeUsuarioInicio: userSystem.nomeUsuario,
    );

    await _cartRouteRepository.insert(routeModel);
  }

  /// Formata a hora no formato HH:mm
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
