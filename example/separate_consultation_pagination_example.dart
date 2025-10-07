import 'package:exp/core/utils/app_logger.dart';
import 'package:exp/domain/viewmodels/separate_consultation_viewmodel.dart';
import 'package:exp/domain/models/pagination/query_builder_extension.dart';

/// Exemplo de uso do ShipmentSeparateConsultationViewModel com paginação
class SeparateConsultationPaginationExample {
  final ShipmentSeparateConsultationViewModel viewModel = ShipmentSeparateConsultationViewModel();

  /// Exemplo 1: Carregar dados iniciais com paginação padrão
  Future<void> loadInitialData() async {
    AppLogger.debug('Carregando dados iniciais...');
    await viewModel.loadConsultations();

    AppLogger.debug('Estado: ${viewModel.state}');
    AppLogger.debug('Dados carregados: ${viewModel.consultations.length}');
    AppLogger.debug('Página atual: ${viewModel.currentPage}');
    AppLogger.debug('Tamanho da página: ${viewModel.pageSize}');
    AppLogger.debug('Tem mais dados: ${viewModel.hasMoreData}');
  }

  /// Exemplo 2: Carregar próxima página
  Future<void> loadNextPage() async {
    if (viewModel.hasMoreData && !viewModel.isLoading) {
      AppLogger.debug('Carregando próxima página...');
      await viewModel.loadNextPage();

      AppLogger.debug('Total de dados: ${viewModel.consultations.length}');
      AppLogger.debug('Página atual: ${viewModel.currentPage}');
      AppLogger.debug('Tem mais dados: ${viewModel.hasMoreData}');
    } else {
      AppLogger.debug('Não há mais dados para carregar ou está carregando');
    }
  }

  /// Exemplo 3: Carregar página específica
  Future<void> loadSpecificPage(int page) async {
    AppLogger.debug('Carregando página $page...');
    await viewModel.loadPage(page);

    AppLogger.debug('Página atual: ${viewModel.currentPage}');
    AppLogger.debug('Dados na página: ${viewModel.consultations.length}');
  }

  /// Exemplo 4: Alterar tamanho da página
  Future<void> changePageSize(int newSize) async {
    AppLogger.debug('Alterando tamanho da página para $newSize...');
    viewModel.setPageSize(newSize);

    // Recarrega os dados com o novo tamanho
    await viewModel.loadConsultations();

    AppLogger.debug('Novo tamanho da página: ${viewModel.pageSize}');
    AppLogger.debug('Dados carregados: ${viewModel.consultations.length}');
  }

  /// Exemplo 5: Consulta com filtros personalizados
  Future<void> searchWithCustomFilters() async {
    AppLogger.debug('Realizando consulta com filtros personalizados...');

    // Cria um QueryBuilder com filtros específicos
    final queryBuilder = QueryBuilderExtension.withDefaultPagination(
      limit: 15,
      offset: 0,
    ).status('ATIVO').search('codigo', 'SEP').equals('usuario', 'admin');

    await viewModel.performConsultation(queryBuilder);

    AppLogger.debug('Consulta realizada com filtros');
    AppLogger.debug('Dados encontrados: ${viewModel.consultations.length}');
  }

  /// Exemplo 6: Usar filtros do ViewModel
  Future<void> useViewModelFilters() async {
    AppLogger.debug('Usando filtros do ViewModel...');

    // Define filtros
    viewModel.setSearchQuery('SEP001');
    viewModel.setSituacaoFilter('ATIVO');

    // Carrega dados (os filtros são aplicados localmente)
    await viewModel.loadConsultations();

    AppLogger.debug('Filtros aplicados:');
    AppLogger.debug('- Pesquisa: ${viewModel.searchQuery}');
    AppLogger.debug('- Situação: ${viewModel.selectedSituacaoFilter}');
    AppLogger.debug('- Dados filtrados: ${viewModel.filteredConsultations.length}');
  }

  /// Exemplo 7: Gerenciar estado de carregamento
  Future<void> handleLoadingState() async {
    AppLogger.debug('Iniciando carregamento...');

    // Verifica se está carregando
    if (viewModel.isLoading) {
      AppLogger.debug('Já está carregando...');
      return;
    }

    // Inicia carregamento
    await viewModel.loadConsultations();

    // Verifica estado após carregamento
    if (viewModel.hasError) {
      AppLogger.debug('Erro: ${viewModel.errorMessage}');
    } else if (viewModel.hasData) {
      AppLogger.debug('Dados carregados com sucesso: ${viewModel.consultations.length}');
    } else {
      AppLogger.debug('Nenhum dado encontrado');
    }
  }

  /// Exemplo 8: Reset completo do estado
  void resetViewModel() {
    AppLogger.debug('Resetando ViewModel...');
    viewModel.resetState();

    AppLogger.debug('Estado resetado:');
    AppLogger.debug('- Estado: ${viewModel.state}');
    AppLogger.debug('- Dados: ${viewModel.consultations.length}');
    AppLogger.debug('- Página: ${viewModel.currentPage}');
    AppLogger.debug('- Filtros: pesquisa="${viewModel.searchQuery}", situação="${viewModel.selectedSituacaoFilter}"');
  }

  /// Exemplo 9: Simulação de carregamento de múltiplas páginas
  Future<void> loadMultiplePages() async {
    AppLogger.debug('Carregando múltiplas páginas...');

    // Carrega primeira página
    await viewModel.loadConsultations();
    AppLogger.debug('Página 0: ${viewModel.consultations.length} dados');

    // Carrega próximas páginas se houver mais dados
    while (viewModel.hasMoreData) {
      await viewModel.loadNextPage();
      AppLogger.debug('Página ${viewModel.currentPage}: ${viewModel.consultations.length} dados total');

      // Para evitar loop infinito em exemplo
      if (viewModel.currentPage >= 3) break;
    }

    AppLogger.debug('Carregamento concluído. Total: ${viewModel.consultations.length} dados');
  }

  /// Exemplo 10: Tratamento de erros
  Future<void> handleErrors() async {
    AppLogger.debug('Demonstrando tratamento de erros...');

    try {
      // Simula uma operação que pode falhar
      await viewModel.loadConsultations();

      if (viewModel.hasError) {
        AppLogger.debug('Erro capturado: ${viewModel.errorMessage}');
        // Aqui você pode implementar lógica de retry ou notificação
      }
    } catch (e) {
      AppLogger.debug('Exceção capturada: $e');
    }
  }
}

/// Função principal para executar os exemplos
void main() async {
  final example = SeparateConsultationPaginationExample();

  AppLogger.debug('=== Exemplos de Paginação com SeparateConsultationViewModel ===\n');

  // Exemplo 1: Dados iniciais
  await example.loadInitialData();
  AppLogger.debug('');

  // Exemplo 2: Próxima página
  await example.loadNextPage();
  AppLogger.debug('');

  // Exemplo 3: Página específica
  await example.loadSpecificPage(2);
  AppLogger.debug('');

  // Exemplo 4: Alterar tamanho da página
  await example.changePageSize(10);
  AppLogger.debug('');

  // Exemplo 5: Filtros personalizados
  await example.searchWithCustomFilters();
  AppLogger.debug('');

  // Exemplo 6: Filtros do ViewModel
  await example.useViewModelFilters();
  AppLogger.debug('');

  // Exemplo 7: Estado de carregamento
  await example.handleLoadingState();
  AppLogger.debug('');

  // Exemplo 8: Reset
  example.resetViewModel();
  AppLogger.debug('');

  // Exemplo 9: Múltiplas páginas
  await example.loadMultiplePages();
  AppLogger.debug('');

  // Exemplo 10: Tratamento de erros
  await example.handleErrors();
  AppLogger.debug('');

  AppLogger.debug('=== Exemplos concluídos ===');
}
