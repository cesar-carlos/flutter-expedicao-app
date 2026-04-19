import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/usecases/get_separation_consultation/get_separation_consultation_params.dart';

class GetSeparationConsultationUseCase {
  final BasicConsultationRepository<SeparateConsultationModel> _repository;

  GetSeparationConsultationUseCase({
    required BasicConsultationRepository<SeparateConsultationModel> repository,
  }) : _repository = repository;

  static const String _fieldCodEmpresa = 'CodEmpresa';
  static const String _fieldCodSepararEstoque = 'CodSepararEstoque';

  Future<Result<SeparateConsultationModel>> call(GetSeparationConsultationParams params) async {
    if (!params.isValid) {
      return Failure(ValidationFailure.fromErrors(params.validationErrors));
    }

    final query = QueryBuilder()
      ..equals(_fieldCodEmpresa, params.codEmpresa)
      ..equals(_fieldCodSepararEstoque, params.codSepararEstoque);

    try {
      final results = await _repository.selectConsultation(query);
      if (results.isEmpty) {
        return Failure(DataFailure.notFound('Separação'));
      }
      return Success(results.first);
    } on DataError catch (e) {
      return Failure(NetworkFailure(message: e.message, code: 'NETWORK_ERROR', exception: e));
    } on Exception catch (e) {
      return Failure(UnknownFailure.fromException(e));
    } catch (e) {
      // Bug H: catch generico para `Error`s nao capturados por `on Exception`.
      return Failure(UnknownFailure(message: 'Erro inesperado: $e'));
    }
  }
}
