import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/domain/usecases/get_separation_consultation/get_separation_consultation_params.dart';
import 'package:data7_expedicao/domain/usecases/get_separation_consultation/get_separation_consultation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/next_separation_user/next_separation_user_failure.dart';
import 'package:data7_expedicao/domain/usecases/next_separation_user/next_separation_user_params.dart';
import 'package:data7_expedicao/domain/usecases/next_separation_user/next_separation_user_usecase.dart';

sealed class NextSeparationResult {
  const NextSeparationResult();
}

class NextSeparationSessionError extends NextSeparationResult {
  const NextSeparationSessionError();
}

class NextSeparationInvalidSector extends NextSeparationResult {
  const NextSeparationInvalidSector();
}

class NextSeparationEmpty extends NextSeparationResult {
  final String message;

  const NextSeparationEmpty(this.message);
}

class NextSeparationSearchError extends NextSeparationResult {
  final String message;

  const NextSeparationSearchError(this.message);
}

class NextSeparationAssignmentError extends NextSeparationResult {
  final int codSepararEstoque;

  const NextSeparationAssignmentError(this.codSepararEstoque);
}

class NextSeparationConsultError extends NextSeparationResult {
  final String message;

  const NextSeparationConsultError(this.message);
}

class NextSeparationNotFound extends NextSeparationResult {
  final int codSepararEstoque;

  const NextSeparationNotFound(this.codSepararEstoque);
}

class NextSeparationReady extends NextSeparationResult {
  final SeparateConsultationModel separation;

  const NextSeparationReady(this.separation);
}

class NextSeparationCoordinator {
  final IUserSessionService _userSessionService;
  final NextSeparationUserUseCase _nextSeparationUserUseCase;
  final GetSeparationConsultationUseCase _getSeparationConsultationUseCase;

  const NextSeparationCoordinator({
    required IUserSessionService userSessionService,
    required NextSeparationUserUseCase nextSeparationUserUseCase,
    required GetSeparationConsultationUseCase getSeparationConsultationUseCase,
  }) : _userSessionService = userSessionService,
       _nextSeparationUserUseCase = nextSeparationUserUseCase,
       _getSeparationConsultationUseCase = getSeparationConsultationUseCase;

  Future<NextSeparationResult> findNextSeparation() async {
    final appUser = await _userSessionService.loadUserSession();

    if (appUser?.userSystemModel == null) {
      return const NextSeparationSessionError();
    }

    final userSystemModel = appUser!.userSystemModel!;
    final params = NextSeparationUserParams(
      codEmpresa: userSystemModel.codEmpresa ?? 0,
      codUsuario: userSystemModel.codUsuario,
      codSetorEstoque: userSystemModel.codSetorEstoque,
      userSystemModel: userSystemModel,
    );

    if (!params.hasValidSector) {
      return const NextSeparationInvalidSector();
    }

    final result = await _nextSeparationUserUseCase(params);

    final success = result.getOrNull();
    if (success != null) {
      if (!success.hasSeparation) {
        return NextSeparationEmpty(success.message);
      }

      final separation = success.separation!;
      if (separation.codUsuario != params.codUsuario) {
        return NextSeparationAssignmentError(separation.codSepararEstoque);
      }

      final consultResult = await _getSeparationConsultationUseCase.call(
        GetSeparationConsultationParams(
          codEmpresa: separation.codEmpresa,
          codSepararEstoque: separation.codSepararEstoque,
        ),
      );

      if (consultResult.isError()) {
        final failure = consultResult.exceptionOrNull();
        final message = failure is AppFailure ? failure.userMessage : 'Erro ao consultar separação';
        return NextSeparationConsultError(message);
      }

      final separateConsultation = consultResult.getOrNull();
      if (separateConsultation == null) {
        return NextSeparationNotFound(separation.codSepararEstoque);
      }

      return NextSeparationReady(separateConsultation);
    }

    final failure = result.exceptionOrNull();
    final errorMessage = failure is NextSeparationUserFailure ? failure.userMessage : failure.toString();
    return NextSeparationSearchError(errorMessage);
  }
}
