import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_consultation_model.dart';

/// Cria uma separação mockada para testes
SeparationUserSectorConsultationModel createMockSeparation({
  required int codSepararEstoque,
  required ExpeditionSituation situacao,
  int codEmpresa = 1,
  int codSetorEstoque = 100,
  String descricaoSetorEstoque = 'Setor Mock',
  int codPrioridade = 1,
  String descricaoPrioridade = 'Normal',
  int prioridade = 1,
  double quantidadeItens = 10.0,
  double quantidadeItensSeparacao = 5.0,
  double quantidadeItensSetor = 10.0,
  double quantidadeItensSeparacaoSetor = 5.0,
  String carrinhosAbertosUsuario = 'N',
  int? codUsuario,
  String? nomeUsuario,
  String? estacaoSeparacao,
}) {
  return SeparationUserSectorConsultationModel(
    codEmpresa: codEmpresa,
    codSepararEstoque: codSepararEstoque,
    separarEstoqueSituacao: situacao,
    codSetorEstoque: codSetorEstoque,
    descricaoSetorEstoque: descricaoSetorEstoque,
    codPrioridade: codPrioridade,
    descricaoPrioridade: descricaoPrioridade,
    prioridade: prioridade,
    quantidadeItens: quantidadeItens,
    quantidadeItensSeparacao: quantidadeItensSeparacao,
    quantidadeItensSetor: quantidadeItensSetor,
    quantidadeItensSeparacaoSetor: quantidadeItensSeparacaoSetor,
    carrinhosAbertosUsuario: carrinhosAbertosUsuario,
    codUsuario: codUsuario,
    nomeUsuario: nomeUsuario,
    estacaoSeparacao: estacaoSeparacao,
  );
}

/// Cria uma separação 100% completada pelo usuário
/// Critérios: setor 100% separado, sem carrinhos abertos
SeparationUserSectorConsultationModel createMockCompletedSeparation({
  required int codUsuario,
  required String nomeUsuario,
  int codSepararEstoque = 100,
}) {
  return createMockSeparation(
    codSepararEstoque: codSepararEstoque,
    situacao: ExpeditionSituation.separando,
    codUsuario: codUsuario,
    nomeUsuario: nomeUsuario,
    quantidadeItensSetor: 10.0, // 100% separado
    quantidadeItensSeparacaoSetor: 10.0, // 100% separado
    carrinhosAbertosUsuario: 'N', // Sem carrinhos abertos
  );
}

/// Cria uma separação com itens pendentes no setor
/// Critérios: setor com itens ainda a separar
SeparationUserSectorConsultationModel createMockSeparationWithPendingItems({
  required int codUsuario,
  required String nomeUsuario,
  int codSepararEstoque = 200,
}) {
  return createMockSeparation(
    codSepararEstoque: codSepararEstoque,
    situacao: ExpeditionSituation.separando,
    codUsuario: codUsuario,
    nomeUsuario: nomeUsuario,
    quantidadeItensSetor: 10.0, // Total no setor
    quantidadeItensSeparacaoSetor: 5.0, // 50% separado
    carrinhosAbertosUsuario: 'N', // Sem carrinhos abertos
  );
}

/// Cria uma separação nova disponível (CodUsuario IS NULL)
SeparationUserSectorConsultationModel createMockNewSeparation({
  int codSepararEstoque = 300,
}) {
  return createMockSeparation(
    codSepararEstoque: codSepararEstoque,
    situacao: ExpeditionSituation.aguardando,
    quantidadeItensSetor: 10.0, // Tem itens no setor
    quantidadeItensSeparacaoSetor: 0.0, // Nenhum separado
    carrinhosAbertosUsuario: 'N', // Sem carrinhos abertos
    codUsuario: null, // Disponível
  );
}
