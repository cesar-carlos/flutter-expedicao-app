import 'package:exp/domain/viewmodels/separate_consultation_viewmodel.dart';
import 'package:exp/domain/models/pagination/query_builder_extension.dart';

/// Exemplo de uso do ShipmentSeparateConsultationViewModel com paginação
class SeparateConsultationPaginationExample {
  final ShipmentSeparateConsultationViewModel viewModel =
      ShipmentSeparateConsultationViewModel();

  /// Exemplo 1: Carregar dados iniciais com paginação padrão
  Future<void> loadInitialData() async {
    print('Carregando dados iniciais...');
    await viewModel.loadConsultations();

    print('Estado: ${viewModel.state}');
    print('Dados carregados: ${viewModel.consultations.length}');
    print('Página atual: ${viewModel.currentPage}');
    print('Tamanho da página: ${viewModel.pageSize}');
    print('Tem mais dados: ${viewModel.hasMoreData}');
  }

  /// Exemplo 2: Carregar próxima página
  Future<void> loadNextPage() async {
    if (viewModel.hasMoreData && !viewModel.isLoading) {
      print('Carregando próxima página...');
      await viewModel.loadNextPage();

      print('Total de dados: ${viewModel.consultations.length}');
      print('Página atual: ${viewModel.currentPage}');
      print('Tem mais dados: ${viewModel.hasMoreData}');
    } else {
      print('Não há mais dados para carregar ou está carregando');
    }
  }

  /// Exemplo 3: Carregar página específica
  Future<void> loadSpecificPage(int page) async {
    print('Carregando página $page...');
    await viewModel.loadPage(page);

    print('Página atual: ${viewModel.currentPage}');
    print('Dados na página: ${viewModel.consultations.length}');
  }

  /// Exemplo 4: Alterar tamanho da página
  Future<void> changePageSize(int newSize) async {
    print('Alterando tamanho da página para $newSize...');
    viewModel.setPageSize(newSize);

    // Recarrega os dados com o novo tamanho
    await viewModel.loadConsultations();

    print('Novo tamanho da página: ${viewModel.pageSize}');
    print('Dados carregados: ${viewModel.consultations.length}');
  }

  /// Exemplo 5: Consulta com filtros personalizados
  Future<void> searchWithCustomFilters() async {
    print('Realizando consulta com filtros personalizados...');

    // Cria um QueryBuilder com filtros específicos
    final queryBuilder = QueryBuilderExtension.withDefaultPagination(
      limit: 15,
      offset: 0,
    ).status('ATIVO').search('codigo', 'SEP').equals('usuario', 'admin');

    await viewModel.performConsultation(queryBuilder);

    print('Consulta realizada com filtros');
    print('Dados encontrados: ${viewModel.consultations.length}');
  }

  /// Exemplo 6: Usar filtros do ViewModel
  Future<void> useViewModelFilters() async {
    print('Usando filtros do ViewModel...');

    // Define filtros
    viewModel.setSearchQuery('SEP001');
    viewModel.setSituacaoFilter('ATIVO');

    // Carrega dados (os filtros são aplicados localmente)
    await viewModel.loadConsultations();

    print('Filtros aplicados:');
    print('- Pesquisa: ${viewModel.searchQuery}');
    print('- Situação: ${viewModel.selectedSituacaoFilter}');
    print('- Dados filtrados: ${viewModel.filteredConsultations.length}');
  }

  /// Exemplo 7: Gerenciar estado de carregamento
  Future<void> handleLoadingState() async {
    print('Iniciando carregamento...');

    // Verifica se está carregando
    if (viewModel.isLoading) {
      print('Já está carregando...');
      return;
    }

    // Inicia carregamento
    await viewModel.loadConsultations();

    // Verifica estado após carregamento
    if (viewModel.hasError) {
      print('Erro: ${viewModel.errorMessage}');
    } else if (viewModel.hasData) {
      print('Dados carregados com sucesso: ${viewModel.consultations.length}');
    } else {
      print('Nenhum dado encontrado');
    }
  }

  /// Exemplo 8: Reset completo do estado
  void resetViewModel() {
    print('Resetando ViewModel...');
    viewModel.resetState();

    print('Estado resetado:');
    print('- Estado: ${viewModel.state}');
    print('- Dados: ${viewModel.consultations.length}');
    print('- Página: ${viewModel.currentPage}');
    print(
      '- Filtros: pesquisa="${viewModel.searchQuery}", situação="${viewModel.selectedSituacaoFilter}"',
    );
  }

  /// Exemplo 9: Simulação de carregamento de múltiplas páginas
  Future<void> loadMultiplePages() async {
    print('Carregando múltiplas páginas...');

    // Carrega primeira página
    await viewModel.loadConsultations();
    print('Página 0: ${viewModel.consultations.length} dados');

    // Carrega próximas páginas se houver mais dados
    while (viewModel.hasMoreData) {
      await viewModel.loadNextPage();
      print(
        'Página ${viewModel.currentPage}: ${viewModel.consultations.length} dados total',
      );

      // Para evitar loop infinito em exemplo
      if (viewModel.currentPage >= 3) break;
    }

    print(
      'Carregamento concluído. Total: ${viewModel.consultations.length} dados',
    );
  }

  /// Exemplo 10: Tratamento de erros
  Future<void> handleErrors() async {
    print('Demonstrando tratamento de erros...');

    try {
      // Simula uma operação que pode falhar
      await viewModel.loadConsultations();

      if (viewModel.hasError) {
        print('Erro capturado: ${viewModel.errorMessage}');
        // Aqui você pode implementar lógica de retry ou notificação
      }
    } catch (e) {
      print('Exceção capturada: $e');
    }
  }
}

/// Função principal para executar os exemplos
void main() async {
  final example = SeparateConsultationPaginationExample();

  print('=== Exemplos de Paginação com SeparateConsultationViewModel ===\n');

  // Exemplo 1: Dados iniciais
  await example.loadInitialData();
  print('');

  // Exemplo 2: Próxima página
  await example.loadNextPage();
  print('');

  // Exemplo 3: Página específica
  await example.loadSpecificPage(2);
  print('');

  // Exemplo 4: Alterar tamanho da página
  await example.changePageSize(10);
  print('');

  // Exemplo 5: Filtros personalizados
  await example.searchWithCustomFilters();
  print('');

  // Exemplo 6: Filtros do ViewModel
  await example.useViewModelFilters();
  print('');

  // Exemplo 7: Estado de carregamento
  await example.handleLoadingState();
  print('');

  // Exemplo 8: Reset
  example.resetViewModel();
  print('');

  // Exemplo 9: Múltiplas páginas
  await example.loadMultiplePages();
  print('');

  // Exemplo 10: Tratamento de erros
  await example.handleErrors();
  print('');

  print('=== Exemplos concluídos ===');
}
