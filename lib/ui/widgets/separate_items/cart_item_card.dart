import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:exp/di/locator.dart';
import 'package:exp/core/results/app_failure.dart';
import 'package:exp/data/services/user_session_service.dart';
import 'package:exp/ui/widgets/common/custom_flat_button.dart';
import 'package:exp/ui/screens/picking_products_list_screen.dart';
import 'package:exp/domain/models/situation/expedition_situation_model.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/domain/usecases/save_separation_cart/save_separation_cart_usecase.dart';
import 'package:exp/domain/usecases/save_separation_cart/save_separation_cart_params.dart';
import 'package:exp/domain/usecases/save_separation_cart/save_separation_cart_success.dart';
import 'package:exp/domain/usecases/save_separation_cart/save_separation_cart_failure.dart';
import 'package:exp/domain/viewmodels/separation_items_viewmodel.dart';
import 'package:exp/domain/viewmodels/card_picking_viewmodel.dart';
import 'package:exp/domain/services/cart_validation_service.dart';
import 'package:exp/domain/models/user_system_models.dart';
import 'package:exp/ui/screens/card_picking_screen.dart';

class CartItemCard extends StatelessWidget {
  final ExpeditionCartRouteInternshipConsultationModel cartRouteInternshipConsultation;
  final VoidCallback? onCancel;
  final SeparationItemsViewModel? viewModel;

  const CartItemCard({super.key, required this.cartRouteInternshipConsultation, this.onCancel, this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isActive = cartRouteInternshipConsultation.ativo.code == 'S';
    final isFinalized = cartRouteInternshipConsultation.dataFinalizacao != null;
    final situationColor = _getSituationColor(cartRouteInternshipConsultation.situacao, colorScheme);

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

            if (cartRouteInternshipConsultation.nomeSetorEstoque != null) ...[
              const SizedBox(height: 12),
              _buildSectorInfo(context, theme, colorScheme),
            ],

            // Informações adicionais
            if (cartRouteInternshipConsultation.carrinhoAgrupadorCode.isNotEmpty) ...[
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
                      '#${cartRouteInternshipConsultation.codCarrinho}',
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
                cartRouteInternshipConsultation.nomeCarrinho,
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
            cartRouteInternshipConsultation.situacao.description,
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
          if (cartRouteInternshipConsultation.codigoBarrasCarrinho.isNotEmpty) ...[
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
                      cartRouteInternshipConsultation.codigoBarrasCarrinho,
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
                    '${cartRouteInternshipConsultation.origem.description} #${cartRouteInternshipConsultation.codOrigem}',
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
                      'Iniciado por ${cartRouteInternshipConsultation.nomeUsuarioInicio}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    Text(
                      '${_formatDate(cartRouteInternshipConsultation.dataInicio)} às ${cartRouteInternshipConsultation.horaInicio}',
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
          if (isFinalized && cartRouteInternshipConsultation.nomeUsuarioFinalizacao != null) ...[
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
                        'Finalizado por ${cartRouteInternshipConsultation.nomeUsuarioFinalizacao!}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        ),
                      ),
                      Text(
                        '${_formatDate(cartRouteInternshipConsultation.dataFinalizacao!)} às ${cartRouteInternshipConsultation.horaFinalizacao!}',
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
                  cartRouteInternshipConsultation.nomeSetorEstoque!,
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
                      cartRouteInternshipConsultation.carrinhoAgrupadorDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (cartRouteInternshipConsultation.codCarrinhoAgrupador != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.outline.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#${cartRouteInternshipConsultation.codCarrinhoAgrupador}',
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
          if (_shouldShowSeparateButton()) ...[
            Row(
              children: [
                // Botão Separar (ocupa a maior parte do espaço)
                Expanded(
                  child: CustomFlatButtonVariations.outlined(
                    text: 'Separar',
                    icon: Icons.play_arrow,
                    textColor: colorScheme.primary,
                    borderColor: colorScheme.primary.withOpacity(0.3),
                    onPressed: () => _onSeparateCart(context),
                  ),
                ),
                const SizedBox(width: 8),
                // Botão Visualizar (apenas ícone)
                _buildViewIconButton(context, theme, colorScheme),
                // Botão Cancelar (apenas ícone) - mostrar se carrinho está separando
                if (cartRouteInternshipConsultation.situacao == ExpeditionSituation.separando) ...[
                  const SizedBox(width: 8),
                  viewModel != null
                      ? _buildCancelIconButton(context, theme, colorScheme, viewModel!)
                      : Consumer<SeparationItemsViewModel>(
                          builder: (context, vm, child) {
                            return _buildCancelIconButton(context, theme, colorScheme, vm);
                          },
                        ),
                ],
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Segunda linha: Botão Salvar (largura completa)
          if (cartRouteInternshipConsultation.situacao == ExpeditionSituation.separando) ...[
            SizedBox(
              width: double.infinity,
              child: CustomFlatButtonVariations.outlined(
                text: 'Salvar',
                icon: Icons.check_circle,
                textColor: Colors.green,
                borderColor: Colors.green.withOpacity(0.3),
                onPressed: () => _onFinalizeCart(context),
              ),
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
    SeparationItemsViewModel viewModel,
  ) {
    final isCancelling = viewModel.isCartBeingCancelled(cartRouteInternshipConsultation.codCarrinho);

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

  Widget _buildViewIconButton(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.tertiary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _onViewCartReadOnly(context),
          child: Center(child: Icon(Icons.visibility, color: colorScheme.tertiary, size: 20)),
        ),
      ),
    );
  }

  Future<void> _onSeparateCart(BuildContext context) async {
    // Obter usuário da sessão
    final userModel = await _getUserModel();
    final currentUserCode = userModel?.codUsuario;
    final userSectorCode = userModel?.codSetorEstoque;

    // Validação 1: Verificar permissão de acesso ao carrinho
    final accessValidation = CartValidationService.validateCartAccess(
      currentUserCode: currentUserCode,
      cart: cartRouteInternshipConsultation,
      userModel: userModel,
      accessType: CartAccessType.edit,
    );

    if (!accessValidation.canAccess) {
      if (context.mounted && accessValidation.cartOwnerName != null) {
        _showDifferentUserDialog(context, accessValidation.cartOwnerName!);
      }
      return;
    }

    // Validação 2: Verificar se há itens disponíveis para o setor do usuário
    if (userSectorCode != null) {
      final hasItems = await CartValidationService.hasItemsForUserSector(
        codEmpresa: cartRouteInternshipConsultation.codEmpresa,
        codOrigem: cartRouteInternshipConsultation.codOrigem,
        userSectorCode: userSectorCode,
      );

      if (!hasItems && context.mounted) {
        _showNoItemsForSectorDialog(context, userSectorCode);
        return;
      }
    }

    // Navegar para a tela de CardPicking
    if (context.mounted) {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (_) => CardPickingViewModel(),
            child: CardPickingScreen(cart: cartRouteInternshipConsultation, userModel: userModel),
          ),
        ),
      );

      // Se o resultado for 'save_cart', executar salvamento automático
      if (result == 'save_cart' && context.mounted) {
        final saved = await _onFinalizeCart(context, skipConfirmation: true);

        // Se salvou com sucesso, mostrar snackbar e atualizar lista
        if (saved && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Carrinho salvo com sucesso!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  /// Obtém o modelo do usuário da sessão
  Future<UserSystemModel?> _getUserModel() async {
    final userSessionService = locator<UserSessionService>();
    final appUser = await userSessionService.loadUserSession();
    return appUser?.userSystemModel;
  }

  void _showDifferentUserDialog(BuildContext context, String cartOwnerName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.block, color: Colors.red),
            const SizedBox(width: 8),
            const Expanded(child: Text('Acesso Negado', overflow: TextOverflow.ellipsis)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '❌ Você não pode separar neste carrinho',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700),
                  ),
                  const SizedBox(height: 8),
                  Text('Carrinho incluído por: $cartOwnerName', style: TextStyle(color: Colors.red.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Este carrinho foi incluído por outro usuário.'),
            const SizedBox(height: 8),
            const Text(
              'Apenas o usuário que incluiu o carrinho pode realizar a separação.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fechar'))],
      ),
    );
  }

  void _showNoItemsForSectorDialog(BuildContext context, int userSectorCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 8),
            const Expanded(child: Text('Sem Itens para Separar', overflow: TextOverflow.ellipsis)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Todos os itens do seu setor já foram separados!',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                  ),
                  const SizedBox(height: 8),
                  Text('Seu setor: Setor $userSectorCode', style: TextStyle(color: Colors.blue.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Não há mais produtos do seu setor neste carrinho para separar.'),
            const SizedBox(height: 8),
            const Text(
              'Os itens restantes pertencem a outros setores e serão separados por outros usuários.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fechar'))],
      ),
    );
  }

  Future<bool> _onFinalizeCart(BuildContext context, {bool skipConfirmation = false}) async {
    // Obter usuário da sessão e validar acesso
    final userModel = await _getUserModel();

    final accessValidation = CartValidationService.validateCartAccess(
      currentUserCode: userModel?.codUsuario,
      cart: cartRouteInternshipConsultation,
      userModel: userModel,
      accessType: CartAccessType.save,
    );

    if (!accessValidation.canAccess) {
      if (context.mounted && accessValidation.cartOwnerName != null) {
        _showDifferentUserDialog(context, accessValidation.cartOwnerName!);
      }
      return false;
    }

    // Mostrar diálogo de confirmação (pular se já confirmado)
    if (!skipConfirmation) {
      final confirmed = await _showFinalizeConfirmationDialog(context);
      if (!confirmed) return false;
    }

    // Mostrar indicador de carregamento
    if (context.mounted) _showLoadingDialog(context);

    try {
      // Obter o use case do locator
      final saveSeparationCartUseCase = locator<SaveSeparationCartUseCase>();

      // Criar parâmetros
      final params = SaveSeparationCartParams(
        codEmpresa: cartRouteInternshipConsultation.codEmpresa,
        codCarrinhoPercurso: cartRouteInternshipConsultation.codCarrinhoPercurso,
        itemCarrinhoPercurso: cartRouteInternshipConsultation.item,
        codSepararEstoque: cartRouteInternshipConsultation.codOrigem,
      );

      // Executar o use case
      final result = await saveSeparationCartUseCase.call(params);

      // Fechar diálogo de carregamento
      if (context.mounted) Navigator.of(context).pop();

      // Processar resultado
      return result.fold(
        (success) {
          // Se skipConfirmation, não mostrar diálogo (salvamento automático)
          if (!skipConfirmation) {
            _showSuccessDialog(context, success);
          }

          // Atualizar a lista de carrinhos
          if (viewModel != null) {
            viewModel!.refresh();
          }

          return true;
        },
        (failure) {
          _showErrorDialog(context, failure as AppFailure);
          return false;
        },
      );
    } catch (e) {
      // Fechar diálogo de carregamento se ainda estiver aberto
      if (context.mounted) Navigator.of(context).pop();

      // Mostrar erro genérico
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro inesperado: ${e.toString()}'), backgroundColor: Colors.red));
      }
      return false;
    }
  }

  void _onViewCart(BuildContext context) {
    // Criar ViewModel temporário para navegação
    final tempViewModel = CardPickingViewModel();

    // Navegar para a tela de produtos separados
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: tempViewModel,
          child: PickingProductsListScreen(
            filterType: 'completed',
            viewModel: tempViewModel,
            cart: cartRouteInternshipConsultation,
          ),
        ),
      ),
    );
  }

  void _onViewCartReadOnly(BuildContext context) {
    // Criar ViewModel temporário para navegação (modo somente leitura)
    final tempViewModel = CardPickingViewModel();

    // Navegar para a tela de produtos separados em modo somente leitura
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: tempViewModel,
          child: PickingProductsListScreen(
            filterType: 'completed',
            viewModel: tempViewModel,
            cart: cartRouteInternshipConsultation,
            isReadOnly: true, // Novo parâmetro para modo somente leitura
          ),
        ),
      ),
    );
  }

  bool _shouldShowSeparateButton() {
    if (cartRouteInternshipConsultation.situacao == ExpeditionSituation.cancelada ||
        cartRouteInternshipConsultation.situacao == ExpeditionSituation.separado ||
        cartRouteInternshipConsultation.situacao == ExpeditionSituation.conferido ||
        cartRouteInternshipConsultation.situacao == ExpeditionSituation.entregue ||
        cartRouteInternshipConsultation.situacao == ExpeditionSituation.embalado) {
      return false;
    }

    return true;
  }

  bool _shouldShowViewButton() {
    return cartRouteInternshipConsultation.situacao == ExpeditionSituation.separado ||
        cartRouteInternshipConsultation.situacao == ExpeditionSituation.conferido ||
        cartRouteInternshipConsultation.situacao == ExpeditionSituation.entregue ||
        cartRouteInternshipConsultation.situacao == ExpeditionSituation.embalado ||
        cartRouteInternshipConsultation.situacao == ExpeditionSituation.cancelada;
  }

  Future<bool> _showFinalizeConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Salvar Carrinho'),
            content: Text('Deseja realmente salvar o carrinho #${cartRouteInternshipConsultation.codCarrinho}?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Salvar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(children: [CircularProgressIndicator(), SizedBox(width: 16), Text('Finalizando carrinho...')]),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, SaveSeparationCartSuccess success) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Sucesso'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Carrinho #${cartRouteInternshipConsultation.codCarrinho} finalizado com sucesso!'),
            if (success.details != null) ...[
              const SizedBox(height: 8),
              Text(success.details!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, AppFailure failure) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Erro'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(failure.userMessage),
            if (failure is SaveSeparationCartFailure && failure.details != null) ...[
              const SizedBox(height: 8),
              Text(failure.details!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    // Obter usuário da sessão e validar acesso
    final userModel = await _getUserModel();

    final accessValidation = CartValidationService.validateCartAccess(
      currentUserCode: userModel?.codUsuario,
      cart: cartRouteInternshipConsultation,
      userModel: userModel,
      accessType: CartAccessType.delete,
    );

    if (!accessValidation.canAccess) {
      if (context.mounted && accessValidation.cartOwnerName != null) {
        _showDifferentUserDialog(context, accessValidation.cartOwnerName!);
      }
      return;
    }

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
                    'Carrinho #${cartRouteInternshipConsultation.codCarrinho}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(cartRouteInternshipConsultation.nomeCarrinho, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${cartRouteInternshipConsultation.situacao.description}',
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
      final vm = viewModel ?? context.read<SeparationItemsViewModel>();

      // Executar cancelamento através do ViewModel
      final success = await vm.cancelCart(cartRouteInternshipConsultation.codCarrinho);

      if (success) {
        // Sucesso
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Carrinho #${cartRouteInternshipConsultation.codCarrinho} cancelado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          // Chamar callback de cancelamento
          onCancel?.call();
        }
      } else {
        // Falha - mostrar mensagem específica se disponível
        if (context.mounted) {
          final errorMessage = vm.lastCancelError ?? 'Erro ao cancelar carrinho';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Theme.of(context).colorScheme.error));
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

  Color _getSituationColor(ExpeditionSituation situacao, ColorScheme colorScheme) {
    final cardSituation = ExpeditionSituation.fromCode(situacao.code);
    return cardSituation?.color ?? Colors.grey;
  }
}
