import 'package:exp/domain/repositories/event_generic_repository.dart';
import 'package:exp/domain/models/separate_consultation_model.dart';

/// Repositório de eventos específico para separação de expedição
///
/// Esta interface define contratos específicos para eventos de separação,
/// estendendo o repositório genérico de eventos.
abstract class SeparateEventRepository extends EventGenericRepository<SeparateConsultationModel> {
  // Métodos específicos para eventos de separação podem ser adicionados aqui
  // se necessário no futuro
}
