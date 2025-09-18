import 'package:exp/domain/models/situation_model.dart';

/// Modelo para dados detalhados do AppUser na consulta (com permissões)
class AppUserConsultation {
  final int codLoginApp;
  final Situation ativo;
  final String nome;
  final int? codUsuario;
  final Situation permiteSepararForaSequencia;
  final Situation permiteConferirForaSequencia;
  final Situation visualizaTodasSeparacoes;
  final Situation visualizaTodasConferencias;
  final Situation visualizaTodasArmazenagem;
  final int? codSetorEstoque;
  final int? codSetorConferencia;
  final int? codSetorArmazenagem;
  final Situation salvaCarrinhoOutroUsuario;
  final Situation editaCarrinhoOutroUsuario;
  final Situation excluiCarrinhoOutroUsuario;
  final Situation permiteDevolverItemEntregaBalcao;
  final Situation permiteDevolverItemEmbalagem;

  AppUserConsultation({
    required this.codLoginApp,
    required this.ativo,
    required this.nome,
    this.codUsuario,
    required this.permiteSepararForaSequencia,
    required this.permiteConferirForaSequencia,
    required this.visualizaTodasSeparacoes,
    required this.visualizaTodasConferencias,
    required this.visualizaTodasArmazenagem,
    this.codSetorEstoque,
    this.codSetorConferencia,
    this.codSetorArmazenagem,
    required this.salvaCarrinhoOutroUsuario,
    required this.editaCarrinhoOutroUsuario,
    required this.excluiCarrinhoOutroUsuario,
    required this.permiteDevolverItemEntregaBalcao,
    required this.permiteDevolverItemEmbalagem,
  });

  factory AppUserConsultation.fromJson(Map<String, dynamic> json) {
    return AppUserConsultation(
      codLoginApp: json['CodLoginApp'],
      ativo: Situation.fromCodeWithFallback(json['Ativo'] as String? ?? 'N'),
      nome: json['Nome'],
      codUsuario: json['CodUsuario'],
      permiteSepararForaSequencia: Situation.fromCodeWithFallback(
        json['PermiteSepararForaSequencia'] as String? ?? 'N',
      ),
      permiteConferirForaSequencia: Situation.fromCodeWithFallback(
        json['PermiteConferirForaSequencia'] as String? ?? 'N',
      ),
      visualizaTodasSeparacoes: Situation.fromCodeWithFallback(json['VisualizaTodasSeparacoes'] as String? ?? 'N'),
      visualizaTodasConferencias: Situation.fromCodeWithFallback(json['VisualizaTodasConferencias'] as String? ?? 'N'),
      visualizaTodasArmazenagem: Situation.fromCodeWithFallback(json['VisualizaTodasArmazenagem'] as String? ?? 'N'),
      codSetorEstoque: json['CodSetorEstoque'],
      codSetorConferencia: json['CodSetorConferencia'],
      codSetorArmazenagem: json['CodSetorArmazenagem'],
      salvaCarrinhoOutroUsuario: Situation.fromCodeWithFallback(json['SalvaCarrinhoOutroUsuario'] as String? ?? 'N'),
      editaCarrinhoOutroUsuario: Situation.fromCodeWithFallback(json['EditaCarrinhoOutroUsuario'] as String? ?? 'N'),
      excluiCarrinhoOutroUsuario: Situation.fromCodeWithFallback(json['ExcluiCarrinhoOutroUsuario'] as String? ?? 'N'),
      permiteDevolverItemEntregaBalcao: Situation.fromCodeWithFallback(
        json['PermiteDevolverItemEntregaBalcao'] as String? ?? 'N',
      ),
      permiteDevolverItemEmbalagem: Situation.fromCodeWithFallback(
        json['PermiteDevolverItemEmbalagem'] as String? ?? 'N',
      ),
    );
  }

  /// Verifica se o usuário está ativo
  bool get isActive => ativo == Situation.ativo;

  /// Verifica se o usuário tem código de usuário do sistema
  bool get hasSystemUser => codUsuario != null;

  /// Verifica se pode separar fora de sequência
  bool get canSeparateOutOfSequence => permiteSepararForaSequencia == Situation.ativo;

  /// Verifica se pode conferir fora de sequência
  bool get canCheckOutOfSequence => permiteConferirForaSequencia == Situation.ativo;

  /// Verifica se visualiza todas as separações
  bool get canViewAllSeparations => visualizaTodasSeparacoes == Situation.ativo;

  /// Verifica se visualiza todas as conferências
  bool get canViewAllConferences => visualizaTodasConferencias == Situation.ativo;

  /// Verifica se visualiza todas as armazenagens
  bool get canViewAllStorage => visualizaTodasArmazenagem == Situation.ativo;

  /// Verifica se pode salvar carrinho de outro usuário
  bool get canSaveOtherUserCart => salvaCarrinhoOutroUsuario == Situation.ativo;

  /// Verifica se pode editar carrinho de outro usuário
  bool get canEditOtherUserCart => editaCarrinhoOutroUsuario == Situation.ativo;

  /// Verifica se pode excluir carrinho de outro usuário
  bool get canDeleteOtherUserCart => excluiCarrinhoOutroUsuario == Situation.ativo;

  /// Verifica se pode devolver item entrega balcão
  bool get canReturnCounterDeliveryItem => permiteDevolverItemEntregaBalcao == Situation.ativo;

  /// Verifica se pode devolver item embalagem
  bool get canReturnPackagingItem => permiteDevolverItemEmbalagem == Situation.ativo;

  Map<String, dynamic> toJson() {
    return {
      'CodLoginApp': codLoginApp,
      'Ativo': ativo.code,
      'Nome': nome,
      'CodUsuario': codUsuario,
      'PermiteSepararForaSequencia': permiteSepararForaSequencia.code,
      'PermiteConferirForaSequencia': permiteConferirForaSequencia.code,
      'VisualizaTodasSeparacoes': visualizaTodasSeparacoes.code,
      'VisualizaTodasConferencias': visualizaTodasConferencias.code,
      'VisualizaTodasArmazenagem': visualizaTodasArmazenagem.code,
      'CodSetorEstoque': codSetorEstoque,
      'CodSetorConferencia': codSetorConferencia,
      'CodSetorArmazenagem': codSetorArmazenagem,
      'SalvaCarrinhoOutroUsuario': salvaCarrinhoOutroUsuario.code,
      'EditaCarrinhoOutroUsuario': editaCarrinhoOutroUsuario.code,
      'ExcluiCarrinhoOutroUsuario': excluiCarrinhoOutroUsuario.code,
      'PermiteDevolverItemEntregaBalcao': permiteDevolverItemEntregaBalcao.code,
      'PermiteDevolverItemEmbalagem': permiteDevolverItemEmbalagem.code,
    };
  }

  @override
  String toString() {
    return 'AppUserConsultation(codLoginApp: $codLoginApp, ativo: $ativo, nome: $nome, codUsuario: $codUsuario)';
  }
}
