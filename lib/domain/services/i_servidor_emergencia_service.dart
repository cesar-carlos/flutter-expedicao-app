import 'package:data7_expedicao/domain/models/servidor_emergencia_aviso_model.dart';

abstract interface class IServidorEmergenciaService {
  Stream<ServidorEmergenciaAvisoModel> get avisos;

  ServidorEmergenciaAvisoModel? get lastAviso;

  void start();

  void stop();
}
