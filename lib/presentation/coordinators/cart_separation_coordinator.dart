import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/services/cart_validation_service.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/domain/usecases/get_separation_consultation/get_separation_consultation_params.dart';
import 'package:data7_expedicao/domain/usecases/get_separation_consultation/get_separation_consultation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_params.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_success.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_usecase.dart';

sealed class FinalizeCartOutcome {
  const FinalizeCartOutcome();
}

class FinalizeCartSuccess extends FinalizeCartOutcome {
  final SaveSeparationCartSuccess success;

  const FinalizeCartSuccess(this.success);
}

class FinalizeCartFailure extends FinalizeCartOutcome {
  final AppFailure? failure;

  const FinalizeCartFailure(this.failure);
}

class CartSeparationCoordinator {
  final IUserSessionService _userSessionService;
  final CartValidationService _cartValidationService;
  final GetSeparationConsultationUseCase _getSeparationConsultationUseCase;
  final SaveSeparationCartUseCase _saveSeparationCartUseCase;

  const CartSeparationCoordinator({
    required IUserSessionService userSessionService,
    required CartValidationService cartValidationService,
    required GetSeparationConsultationUseCase getSeparationConsultationUseCase,
    required SaveSeparationCartUseCase saveSeparationCartUseCase,
  }) : _userSessionService = userSessionService,
       _cartValidationService = cartValidationService,
       _getSeparationConsultationUseCase = getSeparationConsultationUseCase,
       _saveSeparationCartUseCase = saveSeparationCartUseCase;

  Future<UserSystemModel?> getUserModel() async {
    final appUser = await _userSessionService.loadUserSession();
    return appUser?.userSystemModel;
  }

  CartAccessValidationResult validateAccess({
    required int? currentUserCode,
    required ExpeditionCartRouteInternshipConsultationModel cart,
    required UserSystemModel? userModel,
    required CartAccessType accessType,
  }) {
    return _cartValidationService.validateCartAccess(
      currentUserCode: currentUserCode,
      cart: cart,
      userModel: userModel,
      accessType: accessType,
    );
  }

  Future<bool> hasItemsForUserSector({
    required int codEmpresa,
    required int codOrigem,
    required int userSectorCode,
  }) {
    return _cartValidationService.hasItemsForUserSector(
      codEmpresa: codEmpresa,
      codOrigem: codOrigem,
      userSectorCode: userSectorCode,
    );
  }

  Future<SeparateConsultationModel?> fetchSeparation({
    required int codEmpresa,
    required int codSepararEstoque,
  }) async {
    final result = await _getSeparationConsultationUseCase.call(
      GetSeparationConsultationParams(codEmpresa: codEmpresa, codSepararEstoque: codSepararEstoque),
    );

    SeparateConsultationModel? fresh;
    result.fold((value) => fresh = value, (_) => {});
    return fresh;
  }

  Future<FinalizeCartOutcome> finalizeCart(SaveSeparationCartParams params) async {
    final result = await _saveSeparationCartUseCase.call(params);

    final success = result.getOrNull();
    if (success == null) {
      final failure = result.exceptionOrNull();
      return FinalizeCartFailure(failure is AppFailure ? failure : null);
    }

    return FinalizeCartSuccess(success);
  }
}
