import 'package:exp/domain/models/expedition_cart_consultation_model.dart';
import 'package:exp/domain/models/expedition_cart_situation_model.dart';
import 'package:exp/domain/models/situation_model.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';

void main() {
  // Exemplo de uso do ExpeditionCartConsultationModel refatorado

  print(
    '=== Exemplos de Uso do ExpeditionCartConsultationModel Refatorado ===\n',
  );

  // 1. Criação de um modelo com Situation
  print('1. Criação de um modelo com Situation:');
  final consultationModel = ExpeditionCartConsultationModel(
    codEmpresa: 1,
    codCarrinho: 100,
    descricaoCarrinho: 'Carrinho de Consulta Teste',
    ativo: Situation.ativo,
    situacao: ExpeditionCartSituation.emSeparacao,
    codigoBarras: '123456789',
    codCarrinhoPercurso: 200,
    codPercursoEstagio: 300,
    descricaoPercursoEstagio: 'Estágio de Teste',
    origem: ExpeditionOrigem.separacaoEstoque,
    codOrigem: 400,
    dataInicio: DateTime.now(),
    horaInicio: '10:30',
    codUsuarioInicio: 500,
    nomeUsuarioInicio: 'Usuário Teste',
    codSetorEstoque: 600,
    nomeSetorEstoque: 'Setor Teste',
  );
  print('Modelo: $consultationModel');
  print('');

  // 2. Uso dos getters
  print('2. Uso dos getters:');
  print('Código ativo: ${consultationModel.ativoCode}'); // S
  print('Descrição ativo: ${consultationModel.ativoDescription}'); // Sim
  print('Código situação: ${consultationModel.situacaoCode}'); // EM SEPARACAO
  print(
    'Descrição situação: ${consultationModel.situacaoDescription}',
  ); // Em Separação
  print('Código origem: ${consultationModel.origemCode}'); // SE
  print(
    'Descrição origem: ${consultationModel.origemDescription}',
  ); // Separação Estoque
  print('');

  // 3. Serialização JSON
  print('3. Serialização JSON:');
  final json = consultationModel.toJson();
  print('JSON: $json');
  print('');

  // 4. Deserialização JSON
  print('4. Deserialização JSON:');
  final jsonData = {
    'CodEmpresa': 2,
    'CodCarrinho': 200,
    'Descricao': 'Carrinho JSON Consulta',
    'Ativo': 'N', // String que será convertida para Situation.inativo
    'Situacao': 'LIBERADO',
    'CodigoBarras': '987654321',
    'CodCarrinhoPercurso': 250,
    'CodPercursoEstagio': 350,
    'DescricaoPercursoEstagio': 'Estágio JSON',
    'Origem': 'Origem JSON',
    'CodOrigem': 450,
    'DataInicio': '2024-01-15T10:30:00.000Z',
    'HoraInicio': '14:45',
    'CodUsuarioInicio': 550,
    'NomeUsuarioInicio': 'Usuário JSON',
    'CodSetorEstoque': 650,
    'NomeSetorEstoque': 'Setor JSON',
  };

  final consultationFromJson = ExpeditionCartConsultationModel.fromJson(
    jsonData,
  );
  print('Modelo do JSON: $consultationFromJson');
  print('Ativo: ${consultationFromJson.ativoDescription}'); // Não
  print('Situação: ${consultationFromJson.situacaoDescription}'); // Liberado
  print('');

  // 5. Exemplo prático de uso
  print('5. Exemplo prático de uso:');
  final consultations = [
    ExpeditionCartConsultationModel(
      codEmpresa: 1,
      codCarrinho: 101,
      descricaoCarrinho: 'Carrinho Ativo',
      ativo: Situation.ativo,
      situacao: ExpeditionCartSituation.emSeparacao,
      codigoBarras: '111111111',
      origem: ExpeditionOrigem.separacaoEstoque,
    ),
    ExpeditionCartConsultationModel(
      codEmpresa: 1,
      codCarrinho: 102,
      descricaoCarrinho: 'Carrinho Inativo',
      ativo: Situation.inativo,
      situacao: ExpeditionCartSituation.cancelado,
      codigoBarras: '222222222',
      origem: ExpeditionOrigem.devolucaoVenda,
    ),
    ExpeditionCartConsultationModel(
      codEmpresa: 1,
      codCarrinho: 103,
      descricaoCarrinho: 'Carrinho Liberado',
      ativo: Situation.ativo,
      situacao: ExpeditionCartSituation.liberado,
      codigoBarras: '333333333',
      origem: ExpeditionOrigem.orcamentoBalcao,
    ),
  ];

  print('Carrinhos ativos:');
  for (final consultation in consultations) {
    if (consultation.ativo == Situation.ativo) {
      print(
        '  - ${consultation.descricaoCarrinho} (${consultation.situacaoDescription}) - Origem: ${consultation.origemDescription}',
      );
    }
  }

  print('\nCarrinhos inativos:');
  for (final consultation in consultations) {
    if (consultation.ativo == Situation.inativo) {
      print(
        '  - ${consultation.descricaoCarrinho} (${consultation.situacaoDescription}) - Origem: ${consultation.origemDescription}',
      );
    }
  }

  print('\nCarrinhos por situação:');
  final situacoes = consultations.map((c) => c.situacao).toSet();
  for (final situacao in situacoes) {
    final count = consultations.where((c) => c.situacao == situacao).length;
    print('  - ${situacao.description}: $count carrinho(s)');
  }
}

/// Exemplo de função que trabalha com ExpeditionCartConsultationModel
void processConsultation(ExpeditionCartConsultationModel consultation) {
  print('Processando consulta: ${consultation.descricaoCarrinho}');
  print('Status: ${consultation.ativoDescription}');
  print('Situação: ${consultation.situacaoDescription}');

  if (consultation.ativo == Situation.ativo) {
    print('Carrinho está ativo, pode ser consultado');

    switch (consultation.situacao) {
      case ExpeditionCartSituation.emSeparacao:
        print('Carrinho em separação - aguardando processamento');
        break;
      case ExpeditionCartSituation.liberado:
        print('Carrinho liberado - pronto para uso');
        break;
      case ExpeditionCartSituation.separado:
        print('Carrinho separado - processo concluído');
        break;
      default:
        print('Situação: ${consultation.situacaoDescription}');
    }
  } else {
    print('Carrinho está inativo, não pode ser consultado');
  }
}
