import 'package:exp/core/utils/app_logger.dart';
import 'package:exp/domain/models/situation/situation_model.dart';

void main() {
  // Exemplo de uso do SituationModel

  AppLogger.debug('=== Exemplos de Uso do SituationModel ===\n');

  // 1. Uso básico do enum
  AppLogger.debug('1. Uso básico do enum:');
  final situacaoAtiva = Situation.ativo;
  AppLogger.debug('Código: ${situacaoAtiva.code}'); // S
  AppLogger.debug('Descrição: ${situacaoAtiva.description}'); // Sim
  AppLogger.debug('Enum: $situacaoAtiva'); // Situation.ativo
  AppLogger.debug('');

  // 2. Conversão de string para enum
  AppLogger.debug('2. Conversão de string para enum:');
  final situacaoFromString = Situation.fromCode('S');
  AppLogger.debug('String "S" -> ${situacaoFromString?.description}'); // Sim

  final situacaoInvalida = Situation.fromCode('X');
  AppLogger.debug('String "X" -> $situacaoInvalida'); // null
  AppLogger.debug('');

  // 3. Uso da extension
  AppLogger.debug('3. Uso da extension:');
  final codigo = 'N';
  AppLogger.debug('Código "$codigo" -> ${codigo.situationDescription}'); // Não
  AppLogger.debug('É válido? ${codigo.isValidSituation}'); // true
  AppLogger.debug('');

  // 4. Uso da classe utilitária
  AppLogger.debug('4. Uso da classe utilitária:');
  AppLogger.debug('Todos os códigos: ${SituationModel.getAllCodes()}'); // [S, N]
  AppLogger.debug('Todas as descrições: ${SituationModel.getAllDescriptions()}'); // [Sim, Não]
  AppLogger.debug('Mapa: ${SituationModel.situationMap}'); // {S: Sim, N: Não}
  AppLogger.debug('');

  // 5. Conversão com fallback
  AppLogger.debug('5. Conversão com fallback:');
  final situacaoComFallback = Situation.fromCodeWithFallback('X', fallback: Situation.inativo);
  AppLogger.debug('String "X" com fallback -> ${situacaoComFallback.description}'); // Não
  AppLogger.debug('');

  // 6. Validação
  AppLogger.debug('6. Validação:');
  AppLogger.debug('"S" é válido? ${Situation.isValidSituation('S')}'); // true
  AppLogger.debug('"N" é válido? ${Situation.isValidSituation('N')}'); // true
  AppLogger.debug('"X" é válido? ${Situation.isValidSituation('X')}'); // false
  AppLogger.debug('');

  // 7. Exemplo prático de uso em modelo
  AppLogger.debug('7. Exemplo prático de uso em modelo:');
  final exemploModelo = ExemploModelo(nome: 'Produto Teste', ativo: Situation.fromCodeWithFallback('S'));
  AppLogger.debug('Modelo: $exemploModelo');
  AppLogger.debug('Está ativo? ${exemploModelo.ativo.description}'); // Sim
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
