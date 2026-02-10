import 'package:flutter/widgets.dart';
import 'package:data7_expedicao/data/repositories/separation_item_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separate_item_repository_impl.dart';
import 'package:data7_expedicao/data/repositories/separate_repository_impl.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';

/// Helper para limpeza de dados de teste
class TestDataCleanupHelper {
  /// Limpa os dados de teste da base de dados
  static Future<void> cleanupTestData() async {
    try {
      debugPrint('🧹 Iniciando limpeza dos dados de teste...');

      // Inicializar repositórios para limpeza
      final separateItemRepo = SeparateItemRepositoryImpl();
      final separationItemRepo = SeparationItemRepositoryImpl();
      final separateRepo = SeparateRepositoryImpl();

      // Códigos de separação de teste que precisam ser limpos
      final testSeparationCodes = [999999, 999997];

      // 1. Limpar ItemSeparacaoEstoque (separation_item) - registros de teste
      debugPrint('🗑️ Limpando registros de ItemSeparacaoEstoque...');
      for (final codSepararEstoque in testSeparationCodes) {
        final separationItems = await separationItemRepo.select(
          QueryBuilder().equals('CodEmpresa', 1).equals('CodSepararEstoque', codSepararEstoque).equals('CodProduto', 1),
        );

        for (final item in separationItems) {
          try {
            await separationItemRepo.delete(item);
            debugPrint('   ✅ Removido: ItemSeparacaoEstoque - CodSepararEstoque $codSepararEstoque, Item ${item.item}');
          } catch (e) {
            debugPrint('   ⚠️ Erro ao remover ItemSeparacaoEstoque: $e');
          }
        }
      }

      // 2. Limpar ItemSepararEstoque (separate_item) - registros de teste
      debugPrint('🗑️ Limpando registros de ItemSepararEstoque...');
      for (final codSepararEstoque in testSeparationCodes) {
        final separateItems = await separateItemRepo.select(
          QueryBuilder().equals('CodEmpresa', 1).equals('CodSepararEstoque', codSepararEstoque).equals('CodProduto', 1),
        );

        for (final item in separateItems) {
          try {
            await separateItemRepo.delete(item);
            debugPrint('   ✅ Removido: ItemSepararEstoque - CodSepararEstoque $codSepararEstoque, Item ${item.item}');
          } catch (e) {
            debugPrint('   ⚠️ Erro ao remover ItemSepararEstoque: $e');
          }
        }
      }

      // 3. Limpar SepararEstoque (separate) - registros de teste
      debugPrint('🗑️ Limpando registros de SepararEstoque...');
      for (final codSepararEstoque in testSeparationCodes) {
        final separates = await separateRepo.select(
          QueryBuilder().equals('CodEmpresa', 1).equals('CodSepararEstoque', codSepararEstoque),
        );

        for (final separate in separates) {
          try {
            await separateRepo.delete(separate);
            debugPrint('   ✅ Removido: SepararEstoque - CodSepararEstoque $codSepararEstoque');
          } catch (e) {
            debugPrint('   ⚠️ Erro ao remover SepararEstoque: $e');
          }
        }
      }

      debugPrint('✅ Limpeza dos dados de teste concluída!');
    } catch (e) {
      debugPrint('❌ Erro durante limpeza dos dados de teste: $e');
      // Não falhar o teste por causa da limpeza
    }
  }
}
