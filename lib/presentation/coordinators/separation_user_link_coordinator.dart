import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/usecases/resolve_separation_user_link/resolve_separation_user_link_params.dart';
import 'package:data7_expedicao/domain/usecases/resolve_separation_user_link/resolve_separation_user_link_usecase.dart';

enum SeparationLinkResult {
  allowed,
  checkFailed,
  notAssigned,
}

class SeparationUserLinkCoordinator {
  final ResolveSeparationUserLinkUseCase _resolveSeparationUserLinkUseCase;

  const SeparationUserLinkCoordinator({
    required ResolveSeparationUserLinkUseCase resolveSeparationUserLinkUseCase,
  }) : _resolveSeparationUserLinkUseCase = resolveSeparationUserLinkUseCase;

  Future<SeparationLinkResult> resolveLink({
    required SeparateConsultationModel separation,
    required int codUsuario,
    required int? codSetorEstoque,
  }) async {
    if (codSetorEstoque != null && codSetorEstoque > 0) {
      final result = await _resolveSeparationUserLinkUseCase.call(
        ResolveSeparationUserLinkParams(
          separation: separation,
          codUsuario: codUsuario,
          codSetorEstoque: codSetorEstoque,
        ),
      );
      if (result.isError()) {
        return SeparationLinkResult.checkFailed;
      }
      if (result.getOrNull() != true) {
        return SeparationLinkResult.notAssigned;
      }
    }
    return SeparationLinkResult.allowed;
  }
}
