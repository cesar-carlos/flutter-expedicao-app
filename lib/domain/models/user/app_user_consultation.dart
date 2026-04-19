import 'package:data7_expedicao/domain/models/situation/situation_model.dart';

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
    // Bug AAAAAAAAAAAA: campos NAO-NULLABLE (codLoginApp, nome) eram
    // lidos sem cast nem fallback. Mesmo padrao do bug XXXXXXXXXXX
    // corrigido em AppUser. Crashava com TypeError se servidor
    // retornasse null para algum campo obrigatorio.
    return AppUserConsultation(
      codLoginApp: _parseInt(json['CodLoginApp']) ?? 0,
      ativo: Situation.fromCodeWithFallback(json['Ativo']?.toString() ?? 'N'),
      nome: json['Nome']?.toString() ?? '',
      codUsuario: _parseInt(json['CodUsuario']),
      permiteSepararForaSequencia: Situation.fromCodeWithFallback(
        json['PermiteSepararForaSequencia']?.toString() ?? 'N',
      ),
      permiteConferirForaSequencia: Situation.fromCodeWithFallback(
        json['PermiteConferirForaSequencia']?.toString() ?? 'N',
      ),
      visualizaTodasSeparacoes: Situation.fromCodeWithFallback(json['VisualizaTodasSeparacoes']?.toString() ?? 'N'),
      visualizaTodasConferencias: Situation.fromCodeWithFallback(json['VisualizaTodasConferencias']?.toString() ?? 'N'),
      visualizaTodasArmazenagem: Situation.fromCodeWithFallback(json['VisualizaTodasArmazenagem']?.toString() ?? 'N'),
      codSetorEstoque: _parseInt(json['CodSetorEstoque']),
      codSetorConferencia: _parseInt(json['CodSetorConferencia']),
      codSetorArmazenagem: _parseInt(json['CodSetorArmazenagem']),
      salvaCarrinhoOutroUsuario: Situation.fromCodeWithFallback(json['SalvaCarrinhoOutroUsuario']?.toString() ?? 'N'),
      editaCarrinhoOutroUsuario: Situation.fromCodeWithFallback(json['EditaCarrinhoOutroUsuario']?.toString() ?? 'N'),
      excluiCarrinhoOutroUsuario: Situation.fromCodeWithFallback(json['ExcluiCarrinhoOutroUsuario']?.toString() ?? 'N'),
      permiteDevolverItemEntregaBalcao: Situation.fromCodeWithFallback(
        json['PermiteDevolverItemEntregaBalcao']?.toString() ?? 'N',
      ),
      permiteDevolverItemEmbalagem: Situation.fromCodeWithFallback(
        json['PermiteDevolverItemEmbalagem']?.toString() ?? 'N',
      ),
    );
  }

  /// Parse defensivo de int (mesmo helper do AppUser).
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  bool get isActive => ativo == Situation.ativo;

  bool get hasSystemUser => codUsuario != null;

  bool get canSeparateOutOfSequence => permiteSepararForaSequencia == Situation.ativo;

  bool get canCheckOutOfSequence => permiteConferirForaSequencia == Situation.ativo;

  bool get canViewAllSeparations => visualizaTodasSeparacoes == Situation.ativo;

  bool get canViewAllConferences => visualizaTodasConferencias == Situation.ativo;

  bool get canViewAllStorage => visualizaTodasArmazenagem == Situation.ativo;

  bool get canSaveOtherUserCart => salvaCarrinhoOutroUsuario == Situation.ativo;

  bool get canEditOtherUserCart => editaCarrinhoOutroUsuario == Situation.ativo;

  bool get canDeleteOtherUserCart => excluiCarrinhoOutroUsuario == Situation.ativo;

  bool get canReturnCounterDeliveryItem => permiteDevolverItemEntregaBalcao == Situation.ativo;

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
