import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:exp/core/routing/app_router.dart';
import 'package:exp/domain/viewmodels/separation_viewmodel.dart';
import 'package:exp/ui/widgets/separation/separation_card.dart';
import 'package:exp/ui/widgets/common/custom_app_bar.dart';
import 'package:exp/ui/widgets/app_drawer/app_drawer.dart';

class SeparationScreen extends StatefulWidget {
  const SeparationScreen({super.key});

  @override
  State<SeparationScreen> createState() => _SeparationScreenState();
}

class _SeparationScreenState extends State<SeparationScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega as separações quando a tela é inicializada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SeparationViewModel>().loadSeparations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Separação',
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        leading: IconButton(
          onPressed: () => context.go(AppRouter.home),
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          tooltip: 'Voltar',
        ),
        actions: [
          IconButton(
            onPressed: () => _refreshData(context),
            icon: Icon(Icons.refresh, color: colorScheme.onSurface),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer<SeparationViewModel>(
        builder: (context, viewModel, child) {
          return _buildBody(context, viewModel);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, SeparationViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando separações...'),
          ],
        ),
      );
    }

    if (viewModel.hasError) {
      return _buildErrorState(context, viewModel);
    }

    if (!viewModel.hasData) {
      return _buildEmptyState(context);
    }

    return _buildSeparationsList(context, viewModel);
  }

  Widget _buildErrorState(BuildContext context, SeparationViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar separações',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage ?? 'Erro desconhecido',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => viewModel.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma separação encontrada',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Não há separações disponíveis no momento.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _refreshData(context),
              icon: const Icon(Icons.refresh),
              label: const Text('Atualizar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeparationsList(
    BuildContext context,
    SeparationViewModel viewModel,
  ) {
    return Column(
      children: [
        // Header com informações
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Últimas ${viewModel.separations.length} separações',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Ordenadas por código (DESC)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Lista de separações
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => viewModel.refresh(),
            child: ListView.builder(
              itemCount: viewModel.separations.length,
              itemBuilder: (context, index) {
                final separation = viewModel.separations[index];
                return SeparationCard(
                  separation: separation,
                  onTap: () => _onSeparationTap(context, separation),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _refreshData(BuildContext context) {
    context.read<SeparationViewModel>().refresh();
  }

  void _onSeparationTap(BuildContext context, separation) {
    // TODO: Implementar navegação para detalhes da separação
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Separação ${separation.codSepararEstoque} selecionada'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
