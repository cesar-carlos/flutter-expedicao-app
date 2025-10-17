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

/// UseCase para registrar a atribuição de uma separação a um usuário/setor
///
/// Responsabilidades:
/// - Validar parâmetros de entrada
/// - Criar registro de vinculação usuário/separação/setor
/// - Capturar informações do dispositivo
/// - Registrar data/hora do lançamento
/// - Logar sucesso ou falha da operação
///
/// Este use case é reutilizável em diferentes contextos onde é necessário
/// atribuir uma separação a um usuário específico.
class RegisterSeparationUserSectorUseCase {
  final BasicRepository<SeparationUserSectorModel> _repository;

  RegisterSeparationUserSectorUseCase({required BasicRepository<SeparationUserSectorModel> repository})
    : _repository = repository;

  // === CONSTANTES ===

  /// Item padrão usado para registro de atribuição usuário/setor
  static const String _defaultAssignmentItem = '00000';

  /// Executa o registro da atribuição
  ///
  /// [params] - Parâmetros contendo informações do usuário, separação e setor
  ///
  /// Retorna [Result<RegisterSeparationUserSectorSuccess>] com informações da atribuição
  Future<Result<RegisterSeparationUserSectorSuccess>> call(RegisterSeparationUserSectorParams params) async {
    try {
      // 1. Validar parâmetros
      if (!params.isValid) {
        final errors = params.validationErrors;
        _logError('Parâmetros inválidos: ${errors.join(', ')}');
        return failure(RegisterSeparationUserSectorFailure.invalidParams(errors.join(', ')));
      }

      // 2. Criar modelo de atribuição
      final userSectorModel = _buildUserSectorModel(params);

      // 3. Inserir no repositório
      await _repository.insert(userSectorModel);

      // 4. Logar sucesso
      _logSuccess(params, userSectorModel.estacaoSeparacao);

      // 5. Retornar sucesso
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

  // === CONSTRUÇÃO DO MODELO ===

  /// Constrói o modelo de atribuição usuário/setor
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

  // === LOGGING ===

  /// Registra log de sucesso
  void _logSuccess(RegisterSeparationUserSectorParams params, String deviceIdentifier) {
    AppLogger.info(
      'Atribuição registrada: Usuário ${params.nomeUsuario} '
      '(${params.codUsuario}) assumiu separação ${params.codSepararEstoque} '
      'no dispositivo $deviceIdentifier',
    );
  }

  /// Registra log de erro
  void _logError(String error) {
    AppLogger.error('Erro ao registrar atribuição usuário/setor: $error');
  }
}
