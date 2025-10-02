import 'package:exp/domain/models/situation/situation_model.dart';

void main() {
  // Exemplo de uso do SituationModel

  print('=== Exemplos de Uso do SituationModel ===\n');

  // 1. Uso básico do enum
  print('1. Uso básico do enum:');
  final situacaoAtiva = Situation.ativo;
  print('Código: ${situacaoAtiva.code}'); // S
  print('Descrição: ${situacaoAtiva.description}'); // Sim
  print('Enum: $situacaoAtiva'); // Situation.ativo
  print('');

  // 2. Conversão de string para enum
  print('2. Conversão de string para enum:');
  final situacaoFromString = Situation.fromCode('S');
  print('String "S" -> ${situacaoFromString?.description}'); // Sim

  final situacaoInvalida = Situation.fromCode('X');
  print('String "X" -> $situacaoInvalida'); // null
  print('');

  // 3. Uso da extension
  print('3. Uso da extension:');
  final codigo = 'N';
  print('Código "$codigo" -> ${codigo.situationDescription}'); // Não
  print('É válido? ${codigo.isValidSituation}'); // true
  print('');

  // 4. Uso da classe utilitária
  print('4. Uso da classe utilitária:');
  print('Todos os códigos: ${SituationModel.getAllCodes()}'); // [S, N]
  print('Todas as descrições: ${SituationModel.getAllDescriptions()}'); // [Sim, Não]
  print('Mapa: ${SituationModel.situationMap}'); // {S: Sim, N: Não}
  print('');

  // 5. Conversão com fallback
  print('5. Conversão com fallback:');
  final situacaoComFallback = Situation.fromCodeWithFallback('X', fallback: Situation.inativo);
  print('String "X" com fallback -> ${situacaoComFallback.description}'); // Não
  print('');

  // 6. Validação
  print('6. Validação:');
  print('"S" é válido? ${Situation.isValidSituation('S')}'); // true
  print('"N" é válido? ${Situation.isValidSituation('N')}'); // true
  print('"X" é válido? ${Situation.isValidSituation('X')}'); // false
  print('');

  // 7. Exemplo prático de uso em modelo
  print('7. Exemplo prático de uso em modelo:');
  final exemploModelo = ExemploModelo(nome: 'Produto Teste', ativo: Situation.fromCodeWithFallback('S'));
  print('Modelo: $exemploModelo');
  print('Está ativo? ${exemploModelo.ativo.description}'); // Sim
}

/// Exemplo de modelo usando Situation
class ExemploModelo {
  final String nome;
  final Situation ativo;

  ExemploModelo({required this.nome, required this.ativo});

  factory ExemploModelo.fromJson(Map<String, dynamic> json) {
    return ExemploModelo(nome: json['Nome'] ?? '', ativo: Situation.fromCodeWithFallback(json['Ativo'] ?? 'N'));
  }

  Map<String, dynamic> toJson() {
    return {'Nome': nome, 'Ativo': ativo.code};
  }

  @override
  String toString() {
    return 'ExemploModelo(nome: $nome, ativo: ${ativo.description})';
  }
}
