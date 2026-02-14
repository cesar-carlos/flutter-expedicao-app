import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/usecases/check_separation_user_sector_link/check_separation_user_sector_link_params.dart';
import 'package:data7_expedicao/domain/usecases/check_separation_user_sector_link/check_separation_user_sector_link_usecase.dart';
import 'package:data7_expedicao/domain/usecases/resolve_separation_user_link/resolve_separation_user_link_params.dart';

class ResolveSeparationUserLinkUseCase {
  final CheckSeparationUserSectorLinkUseCase _checkLinkUseCase;

  ResolveSeparationUserLinkUseCase({
    required CheckSeparationUserSectorLinkUseCase checkLinkUseCase,
  }) : _checkLinkUseCase = checkLinkUseCase;

  Future<Result<bool>> call(ResolveSeparationUserLinkParams params) async {
    if (!params.isValid) {
      return Failure(ValidationFailure.fromErrors(params.validationErrors));
    }

    final separation = params.separation;
    if (separation.codUsuariosSeparacao.isNotEmpty) {
      return Success(separation.codUsuariosSeparacao.contains(params.codUsuario));
    }

    return _checkLinkUseCase.call(
      CheckSeparationUserSectorLinkParams(
        codEmpresa: separation.codEmpresa,
        codSepararEstoque: separation.codSepararEstoque,
        codSetorEstoque: params.codSetorEstoque,
        codUsuario: params.codUsuario,
      ),
    );
  }
}
