import 'package:exp/domain/models/user_system_models.dart';
import 'package:exp/domain/models/situation/situation_model.dart';

UserSystemModel createTestUserSystem() {
  return UserSystemModel(
    codEmpresa: 1,
    codUsuario: 1,
    nomeUsuario: 'TESTE_USUARIO_${DateTime.now().millisecondsSinceEpoch}',
    ativo: Situation.ativo,
    codContaFinanceira: 'TESTE_CONTA',
    nomeContaFinanceira: 'Conta Teste',
    nomeCaixaOperador: 'Caixa Teste',
    codLoginApp: 12345,
    permiteSepararForaSequencia: Situation.ativo,
    visualizaTodasSeparacoes: Situation.ativo,
    permiteConferirForaSequencia: Situation.ativo,
    visualizaTodasConferencias: Situation.ativo,
    permiteArmazenarForaSequencia: Situation.ativo,
    visualizaTodasArmazenagem: Situation.ativo,
    salvaCarrinhoOutroUsuario: Situation.inativo,
    editaCarrinhoOutroUsuario: Situation.inativo,
    excluiCarrinhoOutroUsuario: Situation.inativo,
    expedicaoEntregaBalcaoPreVenda: Situation.inativo,
  );
}

UserSystemModel createDefaultTestUserSystem() {
  return createTestUserSystem();
}

UserSystemModel createUpdatedTestUserSystem(UserSystemModel originalUser) {
  return UserSystemModel(
    codEmpresa: originalUser.codEmpresa,
    codUsuario: originalUser.codUsuario,
    nomeUsuario: 'USUARIO_ATUALIZADO_${DateTime.now().millisecondsSinceEpoch}',
    ativo: originalUser.ativo,
    codContaFinanceira: originalUser.codContaFinanceira,
    nomeContaFinanceira: 'Conta Atualizada',
    nomeCaixaOperador: originalUser.nomeCaixaOperador,
    codLoginApp: originalUser.codLoginApp,
    permiteSepararForaSequencia: Situation.inativo,
    visualizaTodasSeparacoes: originalUser.visualizaTodasSeparacoes,
    permiteConferirForaSequencia: originalUser.permiteConferirForaSequencia,
    visualizaTodasConferencias: originalUser.visualizaTodasConferencias,
    permiteArmazenarForaSequencia: originalUser.permiteArmazenarForaSequencia,
    visualizaTodasArmazenagem: originalUser.visualizaTodasArmazenagem,
    salvaCarrinhoOutroUsuario: originalUser.salvaCarrinhoOutroUsuario,
    editaCarrinhoOutroUsuario: originalUser.editaCarrinhoOutroUsuario,
    excluiCarrinhoOutroUsuario: originalUser.excluiCarrinhoOutroUsuario,
    expedicaoEntregaBalcaoPreVenda: originalUser.expedicaoEntregaBalcaoPreVenda,
  );
}

UserSystemModel createInactiveTestUserSystem() {
  return UserSystemModel(
    codEmpresa: 1,
    codUsuario: 888888,
    nomeUsuario: 'USUARIO_INATIVO_${DateTime.now().millisecondsSinceEpoch}',
    ativo: Situation.inativo,
    codContaFinanceira: 'CONTA_INATIVA',
    nomeContaFinanceira: 'Conta Inativa',
    nomeCaixaOperador: 'Caixa Inativo',
    codLoginApp: 54321,
    permiteSepararForaSequencia: Situation.inativo,
    visualizaTodasSeparacoes: Situation.inativo,
    permiteConferirForaSequencia: Situation.inativo,
    visualizaTodasConferencias: Situation.inativo,
    permiteArmazenarForaSequencia: Situation.inativo,
    visualizaTodasArmazenagem: Situation.inativo,
    salvaCarrinhoOutroUsuario: Situation.inativo,
    editaCarrinhoOutroUsuario: Situation.inativo,
    excluiCarrinhoOutroUsuario: Situation.inativo,
    expedicaoEntregaBalcaoPreVenda: Situation.inativo,
  );
}
