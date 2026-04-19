import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/network/socket_config.dart';
import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';

/// Repositorio de consulta de SeparationUserSectorConsultationModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
/// Preserva comportamento especial: aguarda 1.5s + retry se socket
/// estiver desconectado no inicio (alguns cenarios de inicializacao
/// chegam antes da conexao estar pronta).
class SeparationUserSectorConsultationRepositoryImpl
    implements BasicConsultationRepository<SeparationUserSectorConsultationModel> {
  static const String _selectEvent = 'separar.usuario.setor.consulta';
  static const Duration _waitBeforeSocketCheck = Duration(milliseconds: 1500);

  @override
  Future<List<SeparationUserSectorConsultationModel>> selectConsultation(QueryBuilder queryBuilder) async {
    // Espera socket conectar (pode estar reconectando). Comportamento
    // original deste repo especifico — outros repos falham imediatamente.
    if (!SocketConfig.isConnected) {
      await Future.delayed(_waitBeforeSocketCheck);
      if (!SocketConfig.isConnected) {
        throw DataError(message: 'Socket nao esta conectado');
      }
    }

    return SocketRequestHelper.select<SeparationUserSectorConsultationModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: SeparationUserSectorConsultationModel.fromJson,
      timeout: UIConstants.shortNetworkTimeout,
      includeOrderBy: true,
    );
  }
}
