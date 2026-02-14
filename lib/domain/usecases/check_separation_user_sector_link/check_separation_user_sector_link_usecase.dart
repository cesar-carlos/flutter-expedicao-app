import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/usecases/check_separation_user_sector_link/check_separation_user_sector_link_params.dart';

class CheckSeparationUserSectorLinkUseCase {
  final BasicConsultationRepository<SeparationUserSectorConsultationModel> _repository;

  CheckSeparationUserSectorLinkUseCase({
    required BasicConsultationRepository<SeparationUserSectorConsultationModel> repository,
  }) : _repository = repository;

  static const String _fieldCodEmpresa = 'CodEmpresa';
  static const String _fieldCodSepararEstoque = 'CodSepararEstoque';
  static const String _fieldCodSetorEstoque = 'CodSetorEstoque';
  static const String _fieldCodUsuario = 'CodUsuario';

  Future<Result<bool>> call(CheckSeparationUserSectorLinkParams params) async {
    if (!params.isValid) {
      return Failure(ValidationFailure.fromErrors(params.validationErrors));
    }

    final query = QueryBuilder()
      ..equals(_fieldCodEmpresa, params.codEmpresa)
      ..equals(_fieldCodSepararEstoque, params.codSepararEstoque)
      ..equals(_fieldCodSetorEstoque, params.codSetorEstoque)
      ..equals(_fieldCodUsuario, params.codUsuario);

    try {
      final results = await _repository.selectConsultation(query);
      return Success(results.isNotEmpty);
    } on DataError catch (e) {
      return Failure(NetworkFailure(message: e.message, code: 'NETWORK_ERROR', exception: e));
    } on Exception catch (e) {
      return Failure(UnknownFailure.fromException(e));
    }
  }
}
