import 'package:data7_expedicao/domain/models/expedition_cart_route_model.dart';
import 'package:data7_expedicao/domain/models/separate_model.dart';

class StartSeparationSuccess {
  final ExpeditionCartRouteModel createdCartRoute;
  final SeparateModel updatedSeparation;

  const StartSeparationSuccess({required this.createdCartRoute, required this.updatedSeparation});

  factory StartSeparationSuccess.create({
    required ExpeditionCartRouteModel createdCartRoute,
    required SeparateModel updatedSeparation,
  }) {
    return StartSeparationSuccess(createdCartRoute: createdCartRoute, updatedSeparation: updatedSeparation);
  }

  String get message => 'Separação iniciada com sucesso';

  int get codCarrinhoPercurso => createdCartRoute.codCarrinhoPercurso;

  int get codSepararEstoque => updatedSeparation.codSepararEstoque;

  String get situacaoDescription => updatedSeparation.situacaoDescription;

  String get situacaoCode => updatedSeparation.situacaoCode;

  String get origemCode => updatedSeparation.origem.code;

  String get origemDescription => updatedSeparation.origem.description;

  String get nomeEntidade => updatedSeparation.nomeEntidade;

  DateTime get dataInicio => createdCartRoute.dataInicio;

  String get horaInicio => createdCartRoute.horaInicio;

  String get cartRouteInfo {
    return 'Carrinho Percurso ${createdCartRoute.codCarrinhoPercurso} - ${createdCartRoute.situacao.description}';
  }

  String get separationInfo {
    return 'Separação ${updatedSeparation.codSepararEstoque} - $nomeEntidade - ${updatedSeparation.situacaoDescription}';
  }

  String get operationSummary {
    return 'Separação $codSepararEstoque iniciada. '
        'Carrinho Percurso: $codCarrinhoPercurso. '
        'Situação: ${updatedSeparation.situacaoDescription}';
  }

  Map<String, dynamic> get auditInfo {
    return {
      'operation': 'START_SEPARATION',
      'codEmpresa': updatedSeparation.codEmpresa,
      'codSepararEstoque': codSepararEstoque,
      'codCarrinhoPercurso': codCarrinhoPercurso,
      'origem': origemCode,
      'codOrigem': updatedSeparation.codOrigem,
      'situacao_anterior': 'AGUARDANDO',
      'situacao_atual': situacaoCode,
      'data_inicio': dataInicio.toIso8601String(),
      'hora_inicio': horaInicio,
      'tipo_entidade': updatedSeparation.tipoEntidade.code,
      'cod_entidade': updatedSeparation.codEntidade,
      'nome_entidade': nomeEntidade,
    };
  }

  List<String> get notifications {
    final notifications = <String>[];

    notifications.add('Separação iniciada: $nomeEntidade');
    notifications.add('Carrinho Percurso $codCarrinhoPercurso criado');

    if (updatedSeparation.observacao != null && updatedSeparation.observacao!.isNotEmpty) {
      notifications.add('Observação: ${updatedSeparation.observacao}');
    }

    if (updatedSeparation.codPrioridade > 0) {
      notifications.add('Prioridade: ${updatedSeparation.codPrioridade}');
    }

    return notifications;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StartSeparationSuccess &&
        other.createdCartRoute == createdCartRoute &&
        other.updatedSeparation == updatedSeparation;
  }

  @override
  int get hashCode => createdCartRoute.hashCode ^ updatedSeparation.hashCode;

  @override
  String toString() {
    return 'StartSeparationSuccess('
        'codCarrinhoPercurso: $codCarrinhoPercurso, '
        'codSepararEstoque: $codSepararEstoque, '
        'situacao: $situacaoCode'
        ')';
  }
}
