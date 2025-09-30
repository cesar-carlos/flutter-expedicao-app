import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:exp/ui/screens/card_picking_screen.dart';
import 'package:exp/ui/widgets/common/custom_flat_button.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/domain/models/expedition_cart_situation_model.dart';
import 'package:exp/domain/viewmodels/separate_items_viewmodel.dart';
import 'package:exp/domain/viewmodels/card_picking_viewmodel.dart';

class CartItemCard extends StatelessWidget {
  final ExpeditionCartRouteInternshipConsultationModel cart;
  final VoidCallback? onCancel;
  final SeparateItemsViewModel? viewModel;

  const CartItemCard({super.key, required this.cart, this.onCancel, this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isActive = cart.ativo.code == 'S';
    final isFinalized = cart.dataFinalizacao != null;
    final situationColor = _getSituationColor(cart.situacao, colorScheme);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shadowColor: situationColor.withOpacity(0.2),
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: situationColor.withOpacity(0.4), width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [situationColor.withOpacity(0.05), situationColor.withOpacity(0.02)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header principal
            _buildMainHeader(context, theme, colorScheme, isActive, isFinalized, situationColor),

            const SizedBox(height: 16),

            // Código de barras e situação
            _buildCodeAndSituation(context, theme, colorScheme, situationColor),

            const SizedBox(height: 16),

            // Informações de tempo e usuário
            _buildTimelineInfo(context, theme, colorScheme, isFinalized),

            if (cart.nomeSetorEstoque != null) ...[
              const SizedBox(height: 12),
              _buildSectorInfo(context, theme, colorScheme),
            ],

            // Informações adicionais
            if (cart.carrinhoAgrupadorCode.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildGroupInfo(context, theme, colorScheme),
            ],

            // Seção de ações
            const SizedBox(height: 16),
            _buildActionsSection(context, theme, colorScheme, situationColor),
          ],
        ),
      ),
    );
  }

  Widget _buildMainHeader(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isActive,
    bool isFinalized,
    Color situationColor,
  ) {
    return Row(
      children: [
        // Ícone do carrinho
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: situationColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.shopping_cart, color: situationColor, size: 24),
        ),
        const SizedBox(width: 12),

        // Informações principais
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Código do carrinho
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: situationColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${cart.codCarrinho}',
                      style: theme.textTheme.labelMedium?.copyWith(color: situationColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  // Status visual
                  _buildStatusChip(context, theme, isFinalized, isActive, situationColor),
                ],
              ),
              const SizedBox(height: 6),
              // Nome do carrinho
              Text(
                cart.nomeCarrinho,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.onSurface),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    ThemeData theme,
    bool isFinalized,
    bool isActive,
    Color situationColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: situationColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: situationColor.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFinalized
                ? Icons.check_circle_outline
                : isActive
                ? Icons.play_circle_outline
                : Icons.pause_circle_outline,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            cart.situacao.description,
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeAndSituation(BuildContext context, ThemeData theme, ColorScheme colorScheme, Color situationColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: situationColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          // Código de barras
          if (cart.codigoBarrasCarrinho.isNotEmpty) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.qr_code_2, size: 18, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Código de Barras',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      cart.codigoBarrasCarrinho,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],

          // Origem
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.source, size: 18, color: situationColor),
                    const SizedBox(width: 6),
                    Text(
                      'Origem',
                      style: theme.textTheme.labelSmall?.copyWith(color: situationColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: situationColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${cart.origem.description} #${cart.codOrigem}',
                    style: theme.textTheme.bodySmall?.copyWith(color: situationColor, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineInfo(BuildContext context, ThemeData theme, ColorScheme colorScheme, bool isFinalized) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Início
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: colorScheme.secondary, shape: BoxShape.circle),
                child: Icon(Icons.play_arrow, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Iniciado por ${cart.nomeUsuarioInicio}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    Text(
                      '${_formatDate(cart.dataInicio)} às ${cart.horaInicio}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSecondaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Finalização (se existir)
          if (isFinalized && cart.nomeUsuarioFinalizacao != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  child: Icon(Icons.check, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Finalizado por ${cart.nomeUsuarioFinalizacao!}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        ),
                      ),
                      Text(
                        '${_formatDate(cart.dataFinalizacao!)} às ${cart.horaFinalizacao!}',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.green.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectorInfo(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.tertiary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: colorScheme.tertiary, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.warehouse, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Setor de Estoque',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cart.nomeSetorEstoque!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupInfo(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: colorScheme.outline, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.group_work, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Carrinho Agrupador',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      cart.carrinhoAgrupadorDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (cart.codCarrinhoAgrupador != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.outline.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#${cart.codCarrinhoAgrupador}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.outline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
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

  Widget _buildActionsSection(BuildContext context, ThemeData theme, ColorScheme colorScheme, Color situationColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: situationColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          // Primeira linha: Botão Separar (largura completa)
          if (_shouldShowSeparateButton()) ...[
            SizedBox(
              width: double.infinity,
              child: CustomFlatButtonVariations.outlined(
                text: 'Separar',
                icon: Icons.play_arrow,
                textColor: colorScheme.primary,
                borderColor: colorScheme.primary.withOpacity(0.3),
                onPressed: () => _onSeparateCart(context),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Segunda linha: Botão Cancelar (ícone) e Finalizar lado a lado
          if (cart.situacao == ExpeditionCartSituation.separando) ...[
            Row(
              children: [
                // Botão Cancelar (apenas ícone)
                viewModel != null
                    ? _buildCancelIconButton(context, theme, colorScheme, viewModel!)
                    : Consumer<SeparateItemsViewModel>(
                        builder: (context, vm, child) {
                          return _buildCancelIconButton(context, theme, colorScheme, vm);
                        },
                      ),
                const SizedBox(width: 8),
                // Botão Finalizar (ocupa o resto do espaço)
                Expanded(
                  child: CustomFlatButtonVariations.outlined(
                    text: 'Finalizar',
                    icon: Icons.check_circle,
                    textColor: Colors.green,
                    borderColor: Colors.green.withOpacity(0.3),
                    onPressed: () => _onFinalizeCart(context),
                  ),
                ),
              ],
            ),
          ],

          // Botão de Visualizar (para carrinhos finalizados ou cancelados)
          if (_shouldShowViewButton()) ...[
            SizedBox(
              width: double.infinity,
              child: CustomFlatButtonVariations.outlined(
                text: 'Visualizar',
                icon: Icons.visibility,
                textColor: colorScheme.tertiary,
                borderColor: colorScheme.tertiary.withOpacity(0.3),
                onPressed: () => _onViewCart(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCancelIconButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    SeparateItemsViewModel viewModel,
  ) {
    final isCancelling = viewModel.isCartBeingCancelled(cart.codCarrinho);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.error.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isCancelling ? null : () => _showCancelDialog(context),
          child: Center(
            child: isCancelling
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.error),
                  )
                : Icon(Icons.delete_outline, color: colorScheme.error, size: 20),
          ),
        ),
      ),
    );
  }

  void _onSeparateCart(BuildContext context) {
    // Navegar para a tela de CardPicking
    // TODO: Obter UserSystemModel do contexto/provider quando disponível
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => CardPickingViewModel(),
          child: CardPickingScreen(
            cart: cart,
            userModel: null, // TODO: Passar modelo do usuário quando disponível
          ),
        ),
      ),
    );
  }

  void _onFinalizeCart(BuildContext context) {
    // TODO: Implementar ação de finalizar carrinho
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Finalizar carrinho #${cart.codCarrinho} - Em desenvolvimento'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onViewCart(BuildContext context) {
    // TODO: Implementar ação de visualizar carrinho
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Visualizar carrinho #${cart.codCarrinho} - Em desenvolvimento'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }

  bool _shouldShowSeparateButton() {
    // Mostra botão de separar para carrinhos que podem iniciar a separação
    // Adiciona mais situações onde faz sentido mostrar o botão Separar
    return cart.situacao == ExpeditionCartSituation.emSeparacao ||
        cart.situacao == ExpeditionCartSituation.liberado ||
        cart.situacao == ExpeditionCartSituation.separado ||
        cart.situacao == ExpeditionCartSituation.conferido ||
        cart.situacao == ExpeditionCartSituation.separando;
  }

  bool _shouldShowViewButton() {
    // Mostra botão de visualizar para carrinhos finalizados ou cancelados
    return cart.situacao == ExpeditionCartSituation.separado ||
        cart.situacao == ExpeditionCartSituation.conferido ||
        cart.situacao == ExpeditionCartSituation.liberado ||
        cart.situacao == ExpeditionCartSituation.agrupado ||
        cart.situacao == ExpeditionCartSituation.cancelado ||
        cart.situacao == ExpeditionCartSituation.cancelada;
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 8),
            const Text('Cancelar Carrinho'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deseja realmente cancelar o carrinho?'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.error.withOpacity(0.3), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Carrinho #${cart.codCarrinho}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(cart.nomeCarrinho, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${cart.situacao.description}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Esta ação não pode ser desfeita. O carrinho será marcado como CANCELADO.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Não, manter')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelCart(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelCart(BuildContext context) async {
    try {
      // Obter o ViewModel - usar o passado como parâmetro ou tentar do contexto
      final vm = viewModel ?? context.read<SeparateItemsViewModel>();

      // Executar cancelamento através do ViewModel
      final success = await vm.cancelCart(cart.codCarrinho);

      if (success) {
        // Sucesso
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Carrinho #${cart.codCarrinho} cancelado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          // Chamar callback de cancelamento
          onCancel?.call();
        }
      } else {
        // Falha
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Erro ao cancelar carrinho'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      // Mostrar erro
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro inesperado: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  Color _getSituationColor(ExpeditionCartSituation situacao, ColorScheme colorScheme) {
    switch (situacao.code) {
      case 'SEPARADO':
      case 'CONFERIDO':
        return Colors.green;
      case 'EM SEPARACAO':
      case 'SEPARANDO':
        return colorScheme.primary;
      case 'EM CONFERENCIA':
      case 'CONFERINDO':
        return colorScheme.secondary;
      case 'LIBERADO':
      case 'AGRUPADO':
        return colorScheme.tertiary;
      case 'CANCELADO':
      case 'CANCELADA':
        return Colors.red; // Vermelho para carrinhos cancelados
      default:
        return colorScheme.onSurfaceVariant;
    }
  }
}
