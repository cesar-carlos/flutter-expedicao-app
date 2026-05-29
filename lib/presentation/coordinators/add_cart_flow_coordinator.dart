import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/domain/usecases/check_separation_user_sector_completion/check_separation_user_sector_completion_params.dart';
import 'package:data7_expedicao/domain/usecases/check_separation_user_sector_completion/check_separation_user_sector_completion_usecase.dart';
import 'package:data7_expedicao/domain/usecases/get_separation_consultation/get_separation_consultation_params.dart';
import 'package:data7_expedicao/domain/usecases/get_separation_consultation/get_separation_consultation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/resolve_separation_user_link/resolve_separation_user_link_params.dart';
import 'package:data7_expedicao/domain/usecases/resolve_separation_user_link/resolve_separation_user_link_usecase.dart';

sealed class AddCartValidationResult {
  const AddCartValidationResult();
}

class AddCartConsultFailed extends AddCartValidationResult {
  final String message;

  const AddCartConsultFailed(this.message);
}

class AddCartSeparationNotFound extends AddCartValidationResult {
  const AddCartSeparationNotFound();
}

class AddCartSituationNotAllowed extends AddCartValidationResult {
  final SeparateConsultationModel freshSeparation;

  const AddCartSituationNotAllowed(this.freshSeparation);
}

class AddCartUserNotIdentified extends AddCartValidationResult {
  const AddCartUserNotIdentified();
}

class AddCartLinkCheckFailed extends AddCartValidationResult {
  const AddCartLinkCheckFailed();
}

class AddCartNotAssigned extends AddCartValidationResult {
  const AddCartNotAssigned();
}

class AddCartCompletionCheckFailed extends AddCartValidationResult {
  const AddCartCompletionCheckFailed();
}

class AddCartSectorAlreadyCompleted extends AddCartValidationResult {
  const AddCartSectorAlreadyCompleted();
}

class AddCartAllowed extends AddCartValidationResult {
  final SeparateConsultationModel freshSeparation;

  const AddCartAllowed(this.freshSeparation);
}

class AddCartFlowCoordinator {
  final GetSeparationConsultationUseCase _getSeparationConsultationUseCase;
  final IUserSessionService _userSessionService;
  final ResolveSeparationUserLinkUseCase _resolveSeparationUserLinkUseCase;
  final CheckSeparationUserSectorCompletionUseCase _checkSeparationUserSectorCompletionUseCase;

  const AddCartFlowCoordinator({
    required GetSeparationConsultationUseCase getSeparationConsultationUseCase,
    required IUserSessionService userSessionService,
    required ResolveSeparationUserLinkUseCase resolveSeparationUserLinkUseCase,
    required CheckSeparationUserSectorCompletionUseCase checkSeparationUserSectorCompletionUseCase,
  }) : _getSeparationConsultationUseCase = getSeparationConsultationUseCase,
       _userSessionService = userSessionService,
       _resolveSeparationUserLinkUseCase = resolveSeparationUserLinkUseCase,
       _checkSeparationUserSectorCompletionUseCase = checkSeparationUserSectorCompletionUseCase;

  Future<AddCartValidationResult> validate(SeparateConsultationModel separation) async {
    final freshResult = await _getSeparationConsultationUseCase.call(
      GetSeparationConsultationParams(
        codEmpresa: separation.codEmpresa,
        codSepararEstoque: separation.codSepararEstoque,
      ),
    );

    if (freshResult.isError()) {
      final failure = freshResult.exceptionOrNull();
      final message = failure is AppFailure
          ? failure.userMessage
          : (failure?.toString() ?? 'Erro ao consultar separação');
      return AddCartConsultFailed(message);
    }

    final freshSeparation = freshResult.getOrNull();
    if (freshSeparation == null) {
      return const AddCartSeparationNotFound();
    }

    if (!_canAddCart(freshSeparation)) {
      return AddCartSituationNotAllowed(freshSeparation);
    }

    final appUser = await _userSessionService.loadUserSession();
    final codUsuario = appUser?.userSystemModel?.codUsuario;
    final codSetorEstoque = appUser?.userSystemModel?.codSetorEstoque;

    if (codUsuario == null || codUsuario <= 0) {
      return const AddCartUserNotIdentified();
    }

    if (codSetorEstoque != null && codSetorEstoque > 0) {
      final resolveResult = await _resolveSeparationUserLinkUseCase.call(
        ResolveSeparationUserLinkParams(
          separation: freshSeparation,
          codUsuario: codUsuario,
          codSetorEstoque: codSetorEstoque,
        ),
      );
      if (resolveResult.isError()) {
        return const AddCartLinkCheckFailed();
      }
      if (resolveResult.getOrNull() != true) {
        return const AddCartNotAssigned();
      }

      final completionResult = await _checkSeparationUserSectorCompletionUseCase.call(
        CheckSeparationUserSectorCompletionParams(
          codEmpresa: freshSeparation.codEmpresa,
          codSepararEstoque: freshSeparation.codSepararEstoque,
          codSetorEstoque: codSetorEstoque,
          codUsuario: codUsuario,
        ),
      );
      if (completionResult.isError()) {
        return const AddCartCompletionCheckFailed();
      }
      if (completionResult.getOrNull() == true) {
        return const AddCartSectorAlreadyCompleted();
      }
    }

    return AddCartAllowed(freshSeparation);
  }

  bool _canAddCart(SeparateConsultationModel? separation) {
    if (separation == null) return false;
    final situacao = separation.situacao;
    return situacao == ExpeditionSituation.aguardando || situacao == ExpeditionSituation.separando;
  }
}
