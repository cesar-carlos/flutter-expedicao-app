import 'package:exp/domain/models/separate_model.dart';

SeparateModel createTestSeparate() {
  return SeparateModel(
    codEmpresa: 1,
    codSepararEstoque: 0,
    origem: 'OB',
    codOrigem: 1,
    codTipoOperacaoExpedicao: 1,
    tipoEntidade: 'C',
    codEntidade: 999999,
    nomeEntidade: 'TESTE ${DateTime.now().millisecondsSinceEpoch}',
    situacao: 'PENDENTE',
    data: DateTime.now(),
    hora: '10:00:00',
    codPrioridade: 1,
    historico: 'Criado via teste de integração',
    observacao: 'Teste de integração - INSERT',
    codMotivoCancelamento: null,
    dataCancelamento: null,
    horaCancelamento: null,
    codUsuarioCancelamento: null,
    nomeUsuarioCancelamento: null,
    observacaoCancelamento: null,
  );
}

SeparateModel createDefaultTestSeparate() {
  return createTestSeparate();
}

SeparateModel createUpdatedTestSeparate(SeparateModel originalSeparate) {
  return originalSeparate.copyWith(
    situacao: 'SEPARANDO',
    observacao: 'Atualizado via teste de integração - UPDATE',
    historico: 'Atualizado em ${DateTime.now().toIso8601String()}',
  );
}
