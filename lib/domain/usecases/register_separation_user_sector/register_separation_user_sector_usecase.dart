import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/utils/app_helper.dart';
import 'package:data7_expedicao/core/utils/device_helper.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/usecases/register_separation_user_sector/register_separation_user_sector_params.dart';
import 'package:data7_expedicao/domain/usecases/register_separation_user_sector/register_separation_user_sector_success.dart';
import 'package:data7_expedicao/domain/usecases/register_separation_user_sector/register_separation_user_sector_failure.dart';
import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';

class RegisterSeparationUserSectorUseCase {
  final BasicRepository<SeparationUserSectorModel> _repository;

  RegisterSeparationUserSectorUseCase({required BasicRepository<SeparationUserSectorModel> repository})
    : _repository = repository;

  static const String _defaultAssignmentItem = '00000';

  Future<Result<RegisterSeparationUserSectorSuccess>> call(RegisterSeparationUserSectorParams params) async {
    try {
      if (!params.isValid) {
        final errors = params.validationErrors;
        _logError('Parâmetros inválidos: ${errors.join(', ')}');
        return failure(RegisterSeparationUserSectorFailure.invalidParams(errors.join(', ')));
      }

      final userSectorModel = _buildUserSectorModel(params);

      await _repository.insert(userSectorModel);

      _logSuccess(params, userSectorModel.estacaoSeparacao);

      return success(
        RegisterSeparationUserSectorSuccess.registered(
          codUsuario: params.codUsuario,
          nomeUsuario: params.nomeUsuario,
          codSepararEstoque: params.codSepararEstoque,
          deviceIdentifier: userSectorModel.estacaoSeparacao,
        ),
      );
    } on DataError catch (e) {
      _logError(e.message);
      return failure(RegisterSeparationUserSectorFailure.networkError(e.message, Exception(e.message)));
    } on Exception catch (e) {
      _logError(e.toString());
      return failure(RegisterSeparationUserSectorFailure.insertError(e.toString(), e));
    }
  }

  SeparationUserSectorModel _buildUserSectorModel(RegisterSeparationUserSectorParams params) {
    final now = DateTime.now();
    final deviceIdentifier = DeviceHelper.getDeviceIdentifier();

    return SeparationUserSectorModel(
      codEmpresa: params.codEmpresa,
      codSepararEstoque: params.codSepararEstoque,
      item: _defaultAssignmentItem,
      codSetorEstoque: params.codSetorEstoque,
      dataLancamento: now,
      horaLancamento: AppHelper.formatTime(now),
      codUsuario: params.codUsuario,
      nomeUsuario: params.nomeUsuario,
      estacaoSeparacao: deviceIdentifier,
    );
  }

  void _logSuccess(RegisterSeparationUserSectorParams params, String deviceIdentifier) {
    AppLogger.info(
      'Atribuição registrada: Usuário ${params.nomeUsuario} '
      '(${params.codUsuario}) assumiu separação ${params.codSepararEstoque} '
      'no dispositivo $deviceIdentifier',
    );
  }

  void _logError(String error) {
    AppLogger.error('Erro ao registrar atribuição usuário/setor: $error');
  }
}
