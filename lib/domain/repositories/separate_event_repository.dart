import 'package:exp/domain/repositories/event_contract.dart';

/// Abstração específica para eventos de separação de expedição
abstract class SeparateEventRepository extends EventContract {
  /// Limpa todos os recursos do repositório de eventos
  void dispose();
}
