import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:exp/core/routing/app_router.dart';
import 'package:exp/domain/viewmodels/separate_items_viewmodel.dart';
import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/ui/widgets/common/custom_app_bar.dart';

class SeparateItemsScreen extends StatefulWidget {
  final SeparateConsultationModel separation;

  const SeparateItemsScreen({super.key, required this.separation});

  @override
  State<SeparateItemsScreen> createState() => _SeparateItemsScreenState();
}

class _SeparateItemsScreenState extends State<SeparateItemsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Carrega os itens quando a tela é inicializada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SeparateItemsViewModel>().loadSeparationItems(
        widget.separation,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Separar Itens',
        leading: IconButton(
          onPressed: () => context.go(AppRouter.separation),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
        ),
        actions: [
          // Separar todos os itens (equivalente ao F7 do desktop)
          IconButton(
            onPressed: () => _separateAllItems(context),
            icon: const Icon(Icons.select_all),
            tooltip: 'Separar Todos',
          ),
          IconButton(
            onPressed: () => _showSeparationInfo(context),
            icon: const Icon(Icons.info_outline),
            tooltip: 'Informações',
          ),
          IconButton(
            onPressed: () => _refreshData(context),
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
          // Menu de opções
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_cart',
                child: Row(
                  children: [
                    Icon(Icons.add_shopping_cart),
                    SizedBox(width: 8),
                    Text('Adicionar Carrinho'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'add_observation',
                child: Row(
                  children: [
                    Icon(Icons.note_add),
                    SizedBox(width: 8),
                    Text('Adicionar Observação'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'recover_cart',
                child: Row(
                  children: [
                    Icon(Icons.restore),
                    SizedBox(width: 8),
                    Text('Recuperar Carrinho'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'finalize',
                child: Row(
                  children: [
                    Icon(Icons.check_circle),
                    SizedBox(width: 8),
                    Text('Finalizar Separação'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<SeparateItemsViewModel>(
        builder: (context, viewModel, child) {
          return _buildBody(context, viewModel);
        },
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildBody(BuildContext context, SeparateItemsViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando itens da separação...'),
          ],
        ),
      );
    }

    if (viewModel.hasError) {
      return _buildErrorState(context, viewModel);
    }

    return Column(
      children: [
        // Header com informações da separação
        _buildSeparationHeader(context, viewModel),

        // Conteúdo das abas
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildWaitingItemsView(context, viewModel),
              _buildCartsView(context, viewModel),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeparationHeader(
    BuildContext context,
    SeparateItemsViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.separation.situacao.color.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.separation.situacao.description.toUpperCase(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: widget.separation.situacao.color,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.separation.nomeEntidade,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.separation.nomeTipoOperacaoExpedicao,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.tag,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '#${widget.separation.codSepararEstoque}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (viewModel.hasData) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total de Itens: ${viewModel.totalItems}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Progresso: ${viewModel.percentualConcluido.toStringAsFixed(0)}%',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    SeparateItemsViewModel viewModel,
  ) {
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
              'Erro ao carregar itens',
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

  Widget _buildWaitingItemsView(
    BuildContext context,
    SeparateItemsViewModel viewModel,
  ) {
    if (!viewModel.hasData) {
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
                'Nenhum item encontrado',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Não há itens para separar nesta separação.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.items.length,
      itemBuilder: (context, index) {
        final item = viewModel.items[index];
        return _buildItemCard(context, item, viewModel);
      },
    );
  }

  Widget _buildCartsView(
    BuildContext context,
    SeparateItemsViewModel viewModel,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Carrinhos',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Funcionalidade em desenvolvimento.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    SeparateItemConsultationModel item,
    SeparateItemsViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isCompleted =
        item.quantidadeSeparacao >
        0; // Se tem quantidade separada, está separado

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted
              ? colorScheme.primary.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.2),
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header do item com código e nome
            Row(
              children: [
                // Código do produto
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.codProduto}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Nome do produto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nomeProduto,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.nomeMarca != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${item.nomeMarca}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Status visual
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? colorScheme.primary.withOpacity(0.1)
                        : colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.check_circle
                            : Icons.hourglass_empty,
                        color: isCompleted
                            ? colorScheme.primary
                            : colorScheme.error,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCompleted ? 'OK' : 'Pendente',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isCompleted
                              ? colorScheme.primary
                              : colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Código de barras se disponível
            if (item.codigoBarras != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.qr_code,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Código: ${item.codigoBarras}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Localização e grupo
            Row(
              children: [
                if (item.nomeSetorEstoque != null) ...[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: colorScheme.onTertiaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Setor',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onTertiaryContainer,
                                  ),
                                ),
                                Text(
                                  '${item.nomeSetorEstoque}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onTertiaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (item.endereco != null ||
                    item.enderecoDescricao != null) ...[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.place,
                            size: 16,
                            color: colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Endereço',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSecondaryContainer,
                                  ),
                                ),
                                Text(
                                  item.enderecoDescricao ?? item.endereco ?? '',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // Informações de quantidade e grupo
            Row(
              children: [
                Expanded(
                  child: _buildInfoColumn(
                    context,
                    'UN',
                    item.nomeUnidadeMedida,
                  ),
                ),
                Expanded(
                  child: _buildInfoColumn(
                    context,
                    'Qtd. Total',
                    item.quantidade.toStringAsFixed(2),
                  ),
                ),
                Expanded(
                  child: _buildInfoColumn(
                    context,
                    'Qtd. Separada',
                    item.quantidadeSeparacao.toStringAsFixed(2),
                    color: isCompleted
                        ? colorScheme.primary
                        : colorScheme.error,
                  ),
                ),
                Expanded(
                  child: _buildInfoColumn(
                    context,
                    'Grupo',
                    item.nomeGrupoProduto,
                    maxLines: 1,
                  ),
                ),
              ],
            ),

            // Informações adicionais
            if (item.codigoBarras != null && item.codigoBarras!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.qr_code,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Código: ${item.codigoBarras}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],

            // Informações adicionais de localização
            if ((item.endereco != null && item.endereco!.isNotEmpty) ||
                (item.enderecoDescricao != null &&
                    item.enderecoDescricao!.isNotEmpty)) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Local: ${item.enderecoDescricao ?? item.endereco}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Botão de ação (se não estiver completo)
            if (!isCompleted) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _onSeparateItem(context, item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: Text(
                    'Separar Item',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
    BuildContext context,
    String label,
    String value, {
    Color? color,
    int? maxLines,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: maxLines,
          overflow: maxLines != null ? TextOverflow.ellipsis : null,
        ),
      ],
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: colorScheme.primary,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorWeight: 3,
        tabs: const [
          Tab(icon: Icon(Icons.hourglass_empty), text: 'Aguardando'),
          Tab(icon: Icon(Icons.shopping_cart), text: 'Carrinhos'),
        ],
      ),
    );
  }

  void _showSeparationInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Separação ${widget.separation.codSepararEstoque}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Entidade', widget.separation.nomeEntidade),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Operação',
              widget.separation.nomeTipoOperacaoExpedicao,
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Situação', widget.separation.situacao.description),
            const SizedBox(height: 8),
            _buildInfoRow('Prioridade', widget.separation.nomePrioridade),
            const SizedBox(height: 8),
            _buildInfoRow('Data', _formatDate(widget.separation.dataEmissao)),
            if (widget.separation.observacao != null &&
                widget.separation.observacao!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow('Observação', widget.separation.observacao!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  void _onSeparateItem(
    BuildContext context,
    SeparateItemConsultationModel item,
  ) {
    // TODO: Implementar ação de separar item específico
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Separar item ${item.codProduto} - Em desenvolvimento'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _refreshData(BuildContext context) {
    context.read<SeparateItemsViewModel>().refresh();
  }

  void _separateAllItems(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Separar Todos os Itens'),
        content: const Text(
          'Deseja separar automaticamente todos os itens pendentes desta separação?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SeparateItemsViewModel>().separateAllItems();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Separando todos os itens...'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
            child: const Text('Separar Todos'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'add_cart':
        _showAddCartDialog(context);
        break;
      case 'add_observation':
        _showAddObservationDialog(context);
        break;
      case 'recover_cart':
        _showRecoverCartDialog(context);
        break;
      case 'finalize':
        _showFinalizeSeparationDialog(context);
        break;
    }
  }

  void _showAddCartDialog(BuildContext context) {
    // TODO: Implementar dialog de adicionar carrinho
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Adicionar Carrinho - Em desenvolvimento'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showAddObservationDialog(BuildContext context) {
    final observationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Observação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Separação ${widget.separation.codSepararEstoque}'),
            const SizedBox(height: 16),
            TextField(
              controller: observationController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observação',
                border: OutlineInputBorder(),
                hintText: 'Digite uma observação sobre esta separação...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implementar salvamento da observação
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Observação adicionada - Em desenvolvimento',
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showRecoverCartDialog(BuildContext context) {
    // TODO: Implementar dialog de recuperar carrinho
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Recuperar Carrinho - Em desenvolvimento'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }

  void _showFinalizeSeparationDialog(BuildContext context) {
    final viewModel = context.read<SeparateItemsViewModel>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Separação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Separação ${widget.separation.codSepararEstoque}'),
            const SizedBox(height: 8),
            Text('Total de itens: ${viewModel.totalItems}'),
            Text(
              'Progresso: ${viewModel.percentualConcluido.toStringAsFixed(0)}%',
            ),
            const SizedBox(height: 16),
            if (!viewModel.isSeparationComplete)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Atenção: Nem todos os itens foram separados!',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: viewModel.isSeparationComplete
                ? () {
                    Navigator.of(context).pop();
                    // TODO: Implementar finalização da separação
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Separação finalizada - Em desenvolvimento',
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  }
                : null,
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
