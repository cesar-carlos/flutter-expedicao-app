import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exp/domain/models/separation_filters_model.dart';

class FiltersStorageService {
  static const String _separationFiltersKey = 'separation_filters';

  /// Salva os filtros da tela de separação
  Future<void> saveSeparationFilters(SeparationFiltersModel filters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = jsonEncode(filters.toJson());
      await prefs.setString(_separationFiltersKey, filtersJson);
    } catch (e) {
      // Log do erro, mas não quebra a aplicação
      print('Erro ao salvar filtros de separação: $e');
    }
  }

  /// Carrega os filtros salvos da tela de separação
  Future<SeparationFiltersModel> loadSeparationFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = prefs.getString(_separationFiltersKey);

      if (filtersJson != null) {
        final filtersMap = jsonDecode(filtersJson) as Map<String, dynamic>;
        return SeparationFiltersModel.fromJson(filtersMap);
      }
    } catch (e) {
      // Log do erro, mas retorna filtros vazios
      print('Erro ao carregar filtros de separação: $e');
    }

    return const SeparationFiltersModel();
  }

  /// Remove os filtros salvos da tela de separação
  Future<void> clearSeparationFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_separationFiltersKey);
    } catch (e) {
      print('Erro ao limpar filtros de separação: $e');
    }
  }

  /// Verifica se existem filtros salvos
  Future<bool> hasSavedSeparationFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_separationFiltersKey);
    } catch (e) {
      print('Erro ao verificar filtros salvos: $e');
      return false;
    }
  }
}
