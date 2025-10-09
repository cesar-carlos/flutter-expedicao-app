import 'package:exp/domain/repositories/event_generic_repository.dart';
import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/domain/models/event_model/event_listener_model.dart';

/// Repositório de eventos específico para separação de expedição
///
/// Esta interface define contratos específicos para eventos de separação,
/// estendendo o repositório genérico de eventos.
abstract class SeparateEventRepository extends EventGenericRepository<SeparateConsultationModel> {
  /// Adiciona listener para eventos de consulta (separar.consulta.listen)
  void addConsultationListener(EventListenerModel listener);

  /// Remove listener de eventos de consulta
  void removeConsultationListener(String listenerId);

  /// Adiciona listener para eventos de atualização (separar.update.listen)
  void addUpdateListener(EventListenerModel listener);

  /// Remove listener de eventos de atualização
  void removeUpdateListener(String listenerId);
}
