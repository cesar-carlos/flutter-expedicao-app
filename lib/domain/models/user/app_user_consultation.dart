/// Modelo para dados detalhados do AppUser na consulta (com permissões)
class AppUserConsultation {
  final int codLoginApp;
  final String ativo;
  final String nome;
  final int? codUsuario;
  final String? permiteSepararForaSequencia;
  final String? permiteConferirForaSequencia;
  final String? visualizaTodasSeparacoes;
  final String? visualizaTodasConferencias;
  final String? visualizaTodasArmazenagem;
  final int? codSetorEstoque;
  final int? codSetorConferencia;
  final int? codSetorArmazenagem;
  final String? salvaCarrinhoOutroUsuario;
  final String? editaCarrinhoOutroUsuario;
  final String? excluiCarrinhoOutroUsuario;
  final String? permiteDevolverItemEntregaBalcao;
  final String? permiteDevolverItemEmbalagem;

  AppUserConsultation({
    required this.codLoginApp,
    required this.ativo,
    required this.nome,
    this.codUsuario,
    this.permiteSepararForaSequencia,
    this.permiteConferirForaSequencia,
    this.visualizaTodasSeparacoes,
    this.visualizaTodasConferencias,
    this.visualizaTodasArmazenagem,
    this.codSetorEstoque,
    this.codSetorConferencia,
    this.codSetorArmazenagem,
    this.salvaCarrinhoOutroUsuario,
    this.editaCarrinhoOutroUsuario,
    this.excluiCarrinhoOutroUsuario,
    this.permiteDevolverItemEntregaBalcao,
    this.permiteDevolverItemEmbalagem,
  });

  factory AppUserConsultation.fromJson(Map<String, dynamic> json) {
    return AppUserConsultation(
      codLoginApp: json['CodLoginApp'],
      ativo: json['Ativo'],
      nome: json['Nome'],
      codUsuario: json['CodUsuario'],
      permiteSepararForaSequencia: json['PermiteSepararForaSequencia'],
      permiteConferirForaSequencia: json['PermiteConferirForaSequencia'],
      visualizaTodasSeparacoes: json['VisualizaTodasSeparacoes'],
      visualizaTodasConferencias: json['VisualizaTodasConferencias'],
      visualizaTodasArmazenagem: json['VisualizaTodasArmazenagem'],
      codSetorEstoque: json['CodSetorEstoque'],
      codSetorConferencia: json['CodSetorConferencia'],
      codSetorArmazenagem: json['CodSetorArmazenagem'],
      salvaCarrinhoOutroUsuario: json['SalvaCarrinhoOutroUsuario'],
      editaCarrinhoOutroUsuario: json['EditaCarrinhoOutroUsuario'],
      excluiCarrinhoOutroUsuario: json['ExcluiCarrinhoOutroUsuario'],
      permiteDevolverItemEntregaBalcao: json['PermiteDevolverItemEntregaBalcao'],
      permiteDevolverItemEmbalagem: json['PermiteDevolverItemEmbalagem'],
    );
  }

  /// Verifica se o usuário está ativo (Ativo == "S")
  bool get isActive => ativo.toUpperCase() == 'S';

  /// Verifica se o usuário tem código de usuário do sistema
  bool get hasSystemUser => codUsuario != null;

  /// Verifica se pode separar fora de sequência
  bool get canSeparateOutOfSequence => permiteSepararForaSequencia?.toUpperCase() == 'S';

  /// Verifica se pode conferir fora de sequência
  bool get canCheckOutOfSequence => permiteConferirForaSequencia?.toUpperCase() == 'S';

  /// Verifica se visualiza todas as separações
  bool get canViewAllSeparations => visualizaTodasSeparacoes?.toUpperCase() == 'S';

  /// Verifica se visualiza todas as conferências
  bool get canViewAllConferences => visualizaTodasConferencias?.toUpperCase() == 'S';

  /// Verifica se visualiza todas as armazenagens
  bool get canViewAllStorage => visualizaTodasArmazenagem?.toUpperCase() == 'S';

  /// Verifica se pode salvar carrinho de outro usuário
  bool get canSaveOtherUserCart => salvaCarrinhoOutroUsuario?.toUpperCase() == 'S';

  /// Verifica se pode editar carrinho de outro usuário
  bool get canEditOtherUserCart => editaCarrinhoOutroUsuario?.toUpperCase() == 'S';

  /// Verifica se pode excluir carrinho de outro usuário
  bool get canDeleteOtherUserCart => excluiCarrinhoOutroUsuario?.toUpperCase() == 'S';

  /// Verifica se pode devolver item entrega balcão
  bool get canReturnCounterDeliveryItem => permiteDevolverItemEntregaBalcao?.toUpperCase() == 'S';

  /// Verifica se pode devolver item embalagem
  bool get canReturnPackagingItem => permiteDevolverItemEmbalagem?.toUpperCase() == 'S';

  Map<String, dynamic> toJson() {
    return {
      'CodLoginApp': codLoginApp,
      'Ativo': ativo,
      'Nome': nome,
      'CodUsuario': codUsuario,
      'PermiteSepararForaSequencia': permiteSepararForaSequencia,
      'PermiteConferirForaSequencia': permiteConferirForaSequencia,
      'VisualizaTodasSeparacoes': visualizaTodasSeparacoes,
      'VisualizaTodasConferencias': visualizaTodasConferencias,
      'VisualizaTodasArmazenagem': visualizaTodasArmazenagem,
      'CodSetorEstoque': codSetorEstoque,
      'CodSetorConferencia': codSetorConferencia,
      'CodSetorArmazenagem': codSetorArmazenagem,
      'SalvaCarrinhoOutroUsuario': salvaCarrinhoOutroUsuario,
      'EditaCarrinhoOutroUsuario': editaCarrinhoOutroUsuario,
      'ExcluiCarrinhoOutroUsuario': excluiCarrinhoOutroUsuario,
      'PermiteDevolverItemEntregaBalcao': permiteDevolverItemEntregaBalcao,
      'PermiteDevolverItemEmbalagem': permiteDevolverItemEmbalagem,
    };
  }

  @override
  String toString() {
    return 'AppUserConsultation(codLoginApp: $codLoginApp, ativo: $ativo, nome: $nome, codUsuario: $codUsuario)';
  }
}
