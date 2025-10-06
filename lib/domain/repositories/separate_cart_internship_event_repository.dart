import 'package:exp/domain/repositories/event_generic_repository.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';

/// Repositório de eventos específico para carrinhos de separação de expedição
///
/// Esta interface define contratos específicos para eventos de carrinhos de separação,
/// estendendo o repositório genérico de eventos.
abstract class SeparateCartInternshipEventRepository
    extends EventGenericRepository<ExpeditionCartRouteInternshipConsultationModel> {
  // Métodos específicos para eventos de carrinhos de separação podem ser adicionados aqui
  // se necessário no futuro
}
