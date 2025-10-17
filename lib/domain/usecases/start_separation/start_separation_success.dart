import 'package:data7_expedicao/domain/models/expedition_cart_route_model.dart';
import 'package:data7_expedicao/domain/models/separate_model.dart';

/// Resultado de sucesso ao iniciar uma separação
class StartSeparationSuccess {
  final ExpeditionCartRouteModel createdCartRoute;
  final SeparateModel updatedSeparation;

  const StartSeparationSuccess({required this.createdCartRoute, required this.updatedSeparation});

  /// Cria um resultado de sucesso
  factory StartSeparationSuccess.create({
    required ExpeditionCartRouteModel createdCartRoute,
    required SeparateModel updatedSeparation,
  }) {
    return StartSeparationSuccess(createdCartRoute: createdCartRoute, updatedSeparation: updatedSeparation);
  }

  /// Retorna uma mensagem de sucesso
  String get message => 'Separação iniciada com sucesso';

  /// Retorna o código do carrinho percurso criado
  int get codCarrinhoPercurso => createdCartRoute.codCarrinhoPercurso;

  /// Retorna o código da separação
  int get codSepararEstoque => updatedSeparation.codSepararEstoque;

  /// Retorna a descrição da situação da separação
  String get situacaoDescription => updatedSeparation.situacaoDescription;

  /// Retorna o código da situação da separação
  String get situacaoCode => updatedSeparation.situacaoCode;

  /// Retorna a origem da separação
  String get origemCode => updatedSeparation.origem.code;

  /// Retorna a descrição da origem
  String get origemDescription => updatedSeparation.origem.description;

  /// Retorna o nome da entidade
  String get nomeEntidade => updatedSeparation.nomeEntidade;

  /// Retorna a data de início da separação
  DateTime get dataInicio => createdCartRoute.dataInicio;

  /// Retorna a hora de início da separação
  String get horaInicio => createdCartRoute.horaInicio;

  /// Retorna informações sobre o carrinho criado
  String get cartRouteInfo {
    return 'Carrinho Percurso ${createdCartRoute.codCarrinhoPercurso} - ${createdCartRoute.situacao.description}';
  }

  /// Retorna informações sobre a separação atualizada
  String get separationInfo {
    return 'Separação ${updatedSeparation.codSepararEstoque} - $nomeEntidade - ${updatedSeparation.situacaoDescription}';
  }

  /// Retorna um resumo da operação
  String get operationSummary {
    return 'Separação $codSepararEstoque iniciada. '
        'Carrinho Percurso: $codCarrinhoPercurso. '
        'Situação: ${updatedSeparation.situacaoDescription}';
  }

  /// Retorna informações detalhadas para auditoria
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

  /// Retorna alertas ou informações relevantes
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
