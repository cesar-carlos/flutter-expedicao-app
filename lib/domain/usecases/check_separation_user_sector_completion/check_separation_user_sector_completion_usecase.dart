import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/usecases/check_separation_user_sector_completion/check_separation_user_sector_completion_params.dart';

class CheckSeparationUserSectorCompletionUseCase {
  final BasicConsultationRepository<SeparationUserSectorConsultationModel> _repository;

  CheckSeparationUserSectorCompletionUseCase({
    required BasicConsultationRepository<SeparationUserSectorConsultationModel> repository,
  }) : _repository = repository;

  static const String _fieldCodEmpresa = 'CodEmpresa';
  static const String _fieldCodSepararEstoque = 'CodSepararEstoque';
  static const String _fieldCodSetorEstoque = 'CodSetorEstoque';
  static const String _fieldCodUsuario = 'CodUsuario';

  Future<Result<bool>> call(CheckSeparationUserSectorCompletionParams params) async {
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
      if (results.isEmpty) {
        return const Success(false);
      }

      final hasPendingWork = results.any(_hasPendingWork);
      final isSectorCompleted = !hasPendingWork;
      return Success(isSectorCompleted);
    } on DataError catch (e) {
      return Failure(NetworkFailure(message: e.message, code: 'NETWORK_ERROR', exception: e));
    } on Exception catch (e) {
      return Failure(UnknownFailure.fromException(e));
    } catch (e) {
      // Bug H: catch generico para `Error`s nao capturados por `on Exception`.
      return Failure(UnknownFailure(message: 'Erro inesperado: $e'));
    }
  }

  static bool hasPendingItems(SeparationUserSectorConsultationModel item) {
    const cartOpenValue = 'S';
    final hasPendingItems = item.quantidadeItensSetor > item.quantidadeItensSeparacaoSetor;
    final hasOpenCarts = item.carrinhosAbertosUsuario == cartOpenValue;
    return hasPendingItems || hasOpenCarts;
  }

  bool _hasPendingWork(SeparationUserSectorConsultationModel item) {
    return hasPendingItems(item);
  }
}
