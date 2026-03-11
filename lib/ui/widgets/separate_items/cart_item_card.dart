import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/validation/common/socket_validation_helper.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/domain/services/picking_state_manager.dart';
import 'package:data7_expedicao/ui/widgets/common/custom_flat_button.dart';
import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/usecases/get_separation_consultation/get_separation_consultation_params.dart';
import 'package:data7_expedicao/domain/usecases/get_separation_consultation/get_separation_consultation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_usecase.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_params.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_success.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_failure.dart';
import 'package:data7_expedicao/domain/viewmodels/separation_items_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/domain/services/cart_validation_service.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';
import 'package:data7_expedicao/core/theme/app_text_styles.dart';
import 'package:data7_expedicao/core/theme/theme_extensions.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';

class CartItemCard extends StatefulWidget {
  final ExpeditionCartRouteInternshipConsultationModel cartRouteInternshipConsultation;
  final VoidCallback? onCancel;
  final SeparationItemsViewModel? viewModel;

  const CartItemCard({super.key, required this.cartRouteInternshipConsultation, this.onCancel, this.viewModel});

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  DateTime? _lastSyncTime;
  String? _lastSyncKey;
  static const _minSyncInterval = Duration(seconds: 2);
  bool _isSaving = false;
  BuildContext? _loadingDialogContext;

  ExpeditionCartRouteInternshipConsultationModel _resolveCurrentCart() {
    final viewModel = widget.viewModel;
    if (viewModel == null) {
      return widget.cartRouteInternshipConsultation;
    }

    return viewModel.getCartSnapshot(
          codEmpresa: widget.cartRouteInternshipConsultation.codEmpresa,
          codCarrinhoPercurso: widget.cartRouteInternshipConsultation.codCarrinhoPercurso,
          item: widget.cartRouteInternshipConsultation.item,
        ) ??
        widget.cartRouteInternshipConsultation;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isActive = widget.cartRouteInternshipConsultation.ativo.code == 'S';
    final isFinalized = widget.cartRouteInternshipConsultation.dataFinalizacao != null;
    final situationColor = _getSituationColor(widget.cartRouteInternshipConsultation.situacao, colorScheme);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shadowColor: situationColor.withValues(alpha: 0.2),
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.largeBorderRadius),
        side: BorderSide(color: situationColor.withValues(alpha: 0.4), width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UIConstants.largeBorderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [situationColor.withValues(alpha: 0.05), situationColor.withValues(alpha: 0.02)],
          ),
        ),
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainHeader(context, theme, colorScheme, isActive, isFinalized, situationColor),

            const SizedBox(height: UIConstants.defaultPadding),

            _buildCodeAndSituation(context, theme, colorScheme, situationColor),

            const SizedBox(height: UIConstants.defaultPadding),

            _buildTimelineInfo(context, theme, colorScheme, isFinalized),

            if (widget.cartRouteInternshipConsultation.nomeSetorEstoque != null) ...[
              const SizedBox(height: UIConstants.smallPadding),
              _buildSectorInfo(context, theme, colorScheme),
            ],

            if (widget.cartRouteInternshipConsultation.carrinhoAgrupadorCode.isNotEmpty) ...[
              const SizedBox(height: UIConstants.smallPadding),
              _buildGroupInfo(context, theme, colorScheme),
            ],

            const SizedBox(height: UIConstants.defaultPadding),
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
        Container(
          padding: const EdgeInsets.all(UIConstants.smallPadding),
          decoration: BoxDecoration(
            color: situationColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(UIConstants.defaultBorderRadius),
          ),
          child: Icon(Icons.shopping_cart, color: situationColor, size: UIConstants.mediumIconSize),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: situationColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                    ),
                    child: Text(
                      '#${widget.cartRouteInternshipConsultation.codCarrinho}',
                      style: theme.textTheme.labelMedium?.copyWith(color: situationColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),

                  _buildStatusChip(context, theme, isFinalized, isActive, situationColor),
                ],
              ),
              const SizedBox(height: 6),

              Text(
                widget.cartRouteInternshipConsultation.nomeCarrinho,
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
        borderRadius: BorderRadius.circular(UIConstants.extraLargeBorderRadius),
        boxShadow: [BoxShadow(color: situationColor.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))],
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
            color: AppColors.white,
            size: UIConstants.smallIconSize,
          ),
          const SizedBox(width: 4),
          Text(
            widget.cartRouteInternshipConsultation.situacao.description,
            style: theme.textTheme.labelSmall?.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeAndSituation(BuildContext context, ThemeData theme, ColorScheme colorScheme, Color situationColor) {
    final barcodeLabelColor = theme.adaptivePrimary(colorScheme);
    final barcodeValueColor = theme.adaptiveSecondary(colorScheme);

    final originLabelColor = theme.isDark
        ? (situationColor == AppColors.warning ? AppColors.orange700 : AppColors.light)
        : situationColor;
    final originValueColor = theme.isDark
        ? (situationColor == AppColors.warning ? AppColors.orange700 : AppColors.secondary)
        : situationColor;

    return Container(
      padding: const EdgeInsets.all(UIConstants.smallPadding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: situationColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          if (widget.cartRouteInternshipConsultation.codigoBarrasCarrinho.isNotEmpty) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.qr_code_2, size: UIConstants.defaultIconSize, color: barcodeLabelColor),
                      const SizedBox(width: 6),
                      Text(
                        'Código de Barras',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: barcodeLabelColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                    ),
                    child: Text(
                      widget.cartRouteInternshipConsultation.codigoBarrasCarrinho,
                      style: AppTextStyles.code(
                        context,
                        color: barcodeValueColor,
                      ).copyWith(fontWeight: FontWeight.w600, fontSize: theme.textTheme.bodySmall?.fontSize),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.source, size: UIConstants.defaultIconSize, color: originLabelColor),
                    const SizedBox(width: 6),
                    Text(
                      'Origem',
                      style: theme.textTheme.labelSmall?.copyWith(color: originLabelColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: situationColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                  ),
                  child: Text(
                    '${widget.cartRouteInternshipConsultation.origem.description} #${widget.cartRouteInternshipConsultation.codOrigem}',
                    style: theme.textTheme.bodySmall?.copyWith(color: originValueColor, fontWeight: FontWeight.w600),
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
      padding: const EdgeInsets.all(UIConstants.smallPadding),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: colorScheme.secondary, shape: BoxShape.circle),
                child: Icon(Icons.play_arrow, color: AppColors.white, size: UIConstants.smallIconSize),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Iniciado por ${widget.cartRouteInternshipConsultation.nomeUsuarioInicio}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    Text(
                      '${_formatDate(widget.cartRouteInternshipConsultation.dataInicio)} às ${widget.cartRouteInternshipConsultation.horaInicio}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (isFinalized && widget.cartRouteInternshipConsultation.nomeUsuarioFinalizacao != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                  child: Icon(Icons.check, color: AppColors.white, size: UIConstants.smallIconSize),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Finalizado por ${widget.cartRouteInternshipConsultation.nomeUsuarioFinalizacao!}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.green800,
                        ),
                      ),
                      Text(
                        '${_formatDate(widget.cartRouteInternshipConsultation.dataFinalizacao!)} às ${widget.cartRouteInternshipConsultation.horaFinalizacao!}',
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.green700),
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
      padding: const EdgeInsets.all(UIConstants.smallPadding),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.tertiary.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.tertiary,
              borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
            ),
            child: Icon(Icons.warehouse, color: AppColors.white, size: UIConstants.defaultIconSize),
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
                  widget.cartRouteInternshipConsultation.nomeSetorEstoque!,
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
      padding: const EdgeInsets.all(UIConstants.smallPadding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.outline,
              borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
            ),
            child: Icon(Icons.group_work, color: AppColors.white, size: UIConstants.defaultIconSize),
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
                      widget.cartRouteInternshipConsultation.carrinhoAgrupadorDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (widget.cartRouteInternshipConsultation.codCarrinhoAgrupador != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#${widget.cartRouteInternshipConsultation.codCarrinhoAgrupador}',
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
      padding: const EdgeInsets.all(UIConstants.smallPadding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: situationColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          if (_shouldShowSeparateButton()) ...[
            Row(
              children: [
                Expanded(
                  child: CustomFlatButtonVariations.outlined(
                    text: 'Separar',
                    icon: Icons.play_arrow,
                    textColor: theme.adaptivePrimary(colorScheme),
                    borderColor: colorScheme.primary.withValues(alpha: 0.3),
                    onPressed: () => _onSeparateCart(context),
                  ),
                ),
                const SizedBox(width: 8),

                _buildViewIconButton(context, theme, colorScheme),

                if (widget.cartRouteInternshipConsultation.situacao == ExpeditionSituation.separando) ...[
                  const SizedBox(width: 8),
                  widget.viewModel != null
                      ? _buildCancelIconButton(
                          context,
                          theme,
                          colorScheme,
                          widget.viewModel!,
                          isSaveInProgress: _isSaving,
                        )
                      : Consumer<SeparationItemsViewModel>(
                          builder: (context, vm, child) {
                            return _buildCancelIconButton(
                              context,
                              theme,
                              colorScheme,
                              vm,
                              isSaveInProgress: _isSaving,
                            );
                          },
                        ),
                ],
              ],
            ),
            const SizedBox(height: 8),
          ],

          if (widget.cartRouteInternshipConsultation.situacao == ExpeditionSituation.separando) ...[
            SizedBox(
              width: double.infinity,
              child: CustomFlatButtonVariations.outlined(
                text: 'Salvar',
                icon: Icons.check_circle,
                textColor: AppColors.success,
                borderColor: AppColors.success.withValues(alpha: 0.3),
                onPressed: _isSaving ? null : () => _onFinalizeCart(context),
              ),
            ),
          ],

          if (_shouldShowViewButton()) ...[
            SizedBox(
              width: double.infinity,
              child: CustomFlatButtonVariations.outlined(
                text: 'Visualizar',
                icon: Icons.visibility,
                textColor: colorScheme.tertiary,
                borderColor: colorScheme.tertiary.withValues(alpha: 0.3),
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
    {required bool isSaveInProgress}
  ) {
    final isCancelling = viewModel.isCartBeingCancelled(widget.cartRouteInternshipConsultation.codCarrinho);
    final isBusy = isCancelling || isSaveInProgress;

    return Container(
      width: UIConstants.defaultButtonHeight,
      height: UIConstants.defaultButtonHeight,
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
        color: AppColors.transparent,
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
          onTap: isBusy ? null : () => _showCancelDialog(context),
          child: Center(
            child: isBusy
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isCancelling ? colorScheme.error : colorScheme.primary,
                    ),
                  )
                : Icon(Icons.delete_outline, color: colorScheme.error, size: UIConstants.defaultIconSize),
          ),
        ),
      ),
    );
  }

  Widget _buildViewIconButton(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: UIConstants.defaultButtonHeight,
      height: UIConstants.defaultButtonHeight,
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.tertiary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
        color: AppColors.transparent,
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
          onTap: () => _onViewCartReadOnly(context),
          child: Center(
            child: Icon(Icons.visibility, color: colorScheme.tertiary, size: UIConstants.defaultIconSize),
          ),
        ),
      ),
    );
  }

  Future<void> _onSeparateCart(BuildContext context) async {
    final currentCart = _resolveCurrentCart();
    final userModel = await _getUserModel();
    final currentUserCode = userModel?.codUsuario;
    final userSectorCode = userModel?.codSetorEstoque;
    final cartValidation = locator<CartValidationService>();

    final accessValidation = cartValidation.validateCartAccess(
      currentUserCode: currentUserCode,
      cart: currentCart,
      userModel: userModel,
      accessType: CartAccessType.edit,
    );

    if (!accessValidation.canAccess) {
      if (context.mounted && accessValidation.cartOwnerName != null) {
        _showDifferentUserDialog(context, accessValidation.cartOwnerName!, actionLabel: 'separar');
      }
      return;
    }

    if (userSectorCode != null) {
      final hasItems = await cartValidation.hasItemsForUserSector(
        codEmpresa: widget.cartRouteInternshipConsultation.codEmpresa,
        codOrigem: widget.cartRouteInternshipConsultation.codOrigem,
        userSectorCode: userSectorCode,
      );

      if (!hasItems && context.mounted) {
        _showNoItemsForSectorDialog(context, userSectorCode);
        return;
      }
    }

    if (context.mounted) {
      final result = await context.push(AppRouter.cardPicking, extra: {'cart': currentCart, 'userModel': userModel});

      if (context.mounted && widget.viewModel != null && result != 'save_cart') {
        unawaited(_syncSeparationFromServer(context));
      }

      if (result == 'save_cart' && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Carrinho salvo com sucesso!'),
            backgroundColor: AppColors.success,
            duration: UIConstants.snackBarShortDuration,
          ),
        );
        context.go(AppRouter.separation);
      }
    }
  }

  Future<void> _syncSeparationFromServer(BuildContext context) async {
    if (widget.viewModel == null) return;

    final syncKey =
        '${widget.cartRouteInternshipConsultation.codEmpresa}_${widget.cartRouteInternshipConsultation.codOrigem}';
    final now = DateTime.now();
    if (_lastSyncKey == syncKey && _lastSyncTime != null && now.difference(_lastSyncTime!) < _minSyncInterval) {
      return;
    }
    _lastSyncKey = syncKey;
    _lastSyncTime = now;

    final useCase = locator<GetSeparationConsultationUseCase>();
    final syncResult = await useCase.call(
      GetSeparationConsultationParams(
        codEmpresa: widget.cartRouteInternshipConsultation.codEmpresa,
        codSepararEstoque: widget.cartRouteInternshipConsultation.codOrigem,
      ),
    );
    if (!context.mounted) return;

    SeparateConsultationModel? fresh;
    syncResult.fold((value) => fresh = value, (_) => {});
    if (context.mounted) unawaited(widget.viewModel!.refreshWithSeparation(fresh));
  }

  Future<UserSystemModel?> _getUserModel() async {
    final userSessionService = locator<IUserSessionService>();
    final appUser = await userSessionService.loadUserSession();
    return appUser?.userSystemModel;
  }

  void _showDifferentUserDialog(BuildContext context, String cartOwnerName, {required String actionLabel}) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.block, color: AppColors.error),
            const SizedBox(width: 8),
            const Expanded(child: Text('Acesso Negado', overflow: TextOverflow.ellipsis)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(UIConstants.smallPadding),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '❌ Você não pode $actionLabel neste carrinho',
                    style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.red700),
                  ),
                  const SizedBox(height: 8),
                  Text('Carrinho incluído por: $cartOwnerName', style: AppFonts.inter(color: AppColors.red600)),
                ],
              ),
            ),
            const SizedBox(height: UIConstants.defaultPadding),
            const Text('Este carrinho foi incluído por outro usuário.'),
            const SizedBox(height: 8),
            Text(
              'Apenas o usuário que incluiu o carrinho pode realizar esta ação.',
              style: AppFonts.inter(fontSize: UIConstants.smallFontSize),
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
            Icon(Icons.info_outline, color: AppColors.info),
            const SizedBox(width: 8),
            const Expanded(child: Text('Sem Itens para Separar', overflow: TextOverflow.ellipsis)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(UIConstants.smallPadding),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Todos os itens do seu setor já foram separados!',
                    style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.blue700),
                  ),
                  const SizedBox(height: 8),
                  Text('Seu setor: Setor $userSectorCode', style: AppFonts.inter(color: AppColors.blue600)),
                ],
              ),
            ),
            const SizedBox(height: UIConstants.defaultPadding),
            const Text('Não há mais produtos do seu setor neste carrinho para separar.'),
            const SizedBox(height: 8),
            Text(
              'Os itens restantes pertencem a outros setores e serão separados por outros usuários.',
              style: AppFonts.inter(fontSize: UIConstants.smallFontSize),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fechar'))],
      ),
    );
  }

  void _ensureLoadingDialogClosed() {
    if (_loadingDialogContext == null) return;
    if (!mounted || !_loadingDialogContext!.mounted) {
      _loadingDialogContext = null;
      return;
    }
    try {
      Navigator.of(_loadingDialogContext!).pop();
    } catch (e) {
      AppLogger.warning('Erro ao fechar loading: $e', tag: 'CartItemCard');
    } finally {
      _loadingDialogContext = null;
    }
  }

  Future<bool> _onFinalizeCart(BuildContext context, {bool skipConfirmation = false}) async {
    if (_isSaving) return false;
    setState(() => _isSaving = true);

    final socketValidation = SocketValidationHelper.validateSocketState();
    if (!socketValidation.isValid) {
      if (mounted) setState(() => _isSaving = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(socketValidation.errorMessage ?? 'Conexão não está pronta. Tente novamente.'),
            backgroundColor: AppColors.error,
            duration: UIConstants.snackBarMediumDuration,
          ),
        );
      }
      return false;
    }

    final currentCart = _resolveCurrentCart();
    final userModel = await _getUserModel();

    if (!context.mounted) {
      if (mounted) setState(() => _isSaving = false);
      return false;
    }

    final cartValidation = locator<CartValidationService>();
    final accessValidation = cartValidation.validateCartAccess(
      currentUserCode: userModel?.codUsuario,
      cart: currentCart,
      userModel: userModel,
      accessType: CartAccessType.save,
    );

    if (!accessValidation.canAccess) {
      if (mounted) setState(() => _isSaving = false);
      if (context.mounted && accessValidation.cartOwnerName != null) {
        _showDifferentUserDialog(context, accessValidation.cartOwnerName!, actionLabel: 'salvar');
      }
      return false;
    }

    if (!skipConfirmation) {
      final confirmed = await _showFinalizeConfirmationDialog(context);
      if (!confirmed || !context.mounted) {
        if (mounted) setState(() => _isSaving = false);
        return false;
      }
    }

    if (!context.mounted) {
      if (mounted) setState(() => _isSaving = false);
      return false;
    }

    _showLoadingDialog(context);

    try {
      final saveSeparationCartUseCase = locator<SaveSeparationCartUseCase>();

      final params = SaveSeparationCartParams(
        codEmpresa: currentCart.codEmpresa,
        codCarrinhoPercurso: currentCart.codCarrinhoPercurso,
        itemCarrinhoPercurso: currentCart.item,
        codSepararEstoque: currentCart.codOrigem,
      );

      final result = await saveSeparationCartUseCase
          .call(params)
          .timeout(
            UIConstants.networkTimeout,
            onTimeout: () {
              throw TimeoutException(
                'Operação excedeu o tempo limite de ${UIConstants.networkTimeout.inSeconds} segundos',
              );
            },
          );

      if (context.mounted) {
        _ensureLoadingDialogClosed();
      }

      final success = result.getOrNull();
      if (success == null) {
        final failure = result.exceptionOrNull();
        if (context.mounted && failure is AppFailure) {
          _showErrorDialog(context, failure);
        } else if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Erro ao salvar carrinho.'), backgroundColor: AppColors.error));
        }
        return false;
      }

      if (!context.mounted) return true;
      if (!skipConfirmation) _showSuccessDialog(context, success);
      if (widget.viewModel != null) unawaited(widget.viewModel!.refresh());

      return true;
    } on TimeoutException catch (e) {
      AppLogger.error('Timeout ao salvar carrinho', tag: 'CartItemCard', error: e);
      if (context.mounted) _ensureLoadingDialogClosed();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tempo esgotado. Verifique sua conexão e tente novamente.'),
            backgroundColor: AppColors.error,
            duration: UIConstants.snackBarMediumDuration,
          ),
        );
      }
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Erro inesperado ao salvar carrinho', tag: 'CartItemCard', error: e, stackTrace: stackTrace);
      if (context.mounted) _ensureLoadingDialogClosed();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro inesperado ao salvar carrinho. Tente novamente.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _onViewCart(BuildContext context) {
    if (!context.mounted) return;

    final tempViewModel = CardPickingViewModel();

    context.push(
      AppRouter.pickingProductsList,
      extra: {'filterType': 'completed', 'viewModel': tempViewModel, 'cart': widget.cartRouteInternshipConsultation},
    );
  }

  void _onViewCartReadOnly(BuildContext context) {
    if (!context.mounted) return;

    final tempViewModel = CardPickingViewModel();

    context.push(
      AppRouter.pickingProductsList,
      extra: {
        'filterType': 'completed',
        'viewModel': tempViewModel,
        'cart': widget.cartRouteInternshipConsultation,
        'isReadOnly': true,
      },
    );
  }

  bool _shouldShowSeparateButton() {
    if (widget.cartRouteInternshipConsultation.situacao == ExpeditionSituation.cancelada ||
        widget.cartRouteInternshipConsultation.situacao == ExpeditionSituation.separado ||
        widget.cartRouteInternshipConsultation.situacao == ExpeditionSituation.conferido ||
        widget.cartRouteInternshipConsultation.situacao == ExpeditionSituation.entregue ||
        widget.cartRouteInternshipConsultation.situacao == ExpeditionSituation.embalado) {
      return false;
    }

    return true;
  }

  bool _shouldShowViewButton() {
    return widget.cartRouteInternshipConsultation.situacao == ExpeditionSituation.separado ||
        widget.cartRouteInternshipConsultation.situacao == ExpeditionSituation.conferido ||
        widget.cartRouteInternshipConsultation.situacao == ExpeditionSituation.entregue ||
        widget.cartRouteInternshipConsultation.situacao == ExpeditionSituation.embalado ||
        widget.cartRouteInternshipConsultation.situacao == ExpeditionSituation.cancelada;
  }

  Future<bool> _showFinalizeConfirmationDialog(BuildContext context) async {
    if (!context.mounted) return false;

    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return ListenableBuilder(
              listenable: locator<PickingStateManager>(),
              builder: (context, _) {
                final pickingState = locator<PickingStateManager>().pickingState;
                final hasPending = pickingState.hasAnyPendingOperations();
                final pendingCount = pickingState.getTotalPendingOperations();
                return _FinalizeConfirmationDialogContent(
                  codCarrinho: widget.cartRouteInternshipConsultation.codCarrinho,
                  hasPending: hasPending,
                  pendingCount: pendingCount,
                  onCancel: () => Navigator.of(dialogContext).pop(false),
                  onConfirm: () => Navigator.of(dialogContext).pop(true),
                );
              },
            );
          },
        ) ??
        false;
  }

  void _showLoadingDialog(BuildContext context) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        _loadingDialogContext = dialogContext;
        return const AlertDialog(
          content: Row(children: [CircularProgressIndicator(), SizedBox(width: 16), Text('Finalizando carrinho...')]),
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, SaveSeparationCartSuccess success) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 8),
            const Text('Sucesso'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Carrinho #${widget.cartRouteInternshipConsultation.codCarrinho} finalizado com sucesso!'),
            if (success.details != null) ...[
              const SizedBox(height: 8),
              Text(
                success.details!,
                style: AppFonts.inter(fontSize: UIConstants.smallFontSize, color: AppColors.grey),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: Text('OK', style: AppFonts.inter(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, AppFailure failure) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: AppColors.error),
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
              Text(
                failure.details!,
                style: AppFonts.inter(fontSize: UIConstants.smallFontSize, color: AppColors.grey),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('OK', style: AppFonts.inter(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    final currentCart = _resolveCurrentCart();
    final userModel = await _getUserModel();
    final cartValidation = locator<CartValidationService>();

    final accessValidation = cartValidation.validateCartAccess(
      currentUserCode: userModel?.codUsuario,
      cart: currentCart,
      userModel: userModel,
      accessType: CartAccessType.delete,
    );

    if (!accessValidation.canAccess) {
      if (context.mounted && accessValidation.cartOwnerName != null) {
        _showDifferentUserDialog(context, accessValidation.cartOwnerName!, actionLabel: 'cancelar');
      }
      return;
    }

    if (!context.mounted) return;

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
              padding: const EdgeInsets.all(UIConstants.smallPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Carrinho #${widget.cartRouteInternshipConsultation.codCarrinho}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.cartRouteInternshipConsultation.nomeCarrinho,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${widget.cartRouteInternshipConsultation.situacao.description}',
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
              foregroundColor: AppColors.white,
            ),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelCart(BuildContext context) async {
    try {
      final vm = widget.viewModel ?? context.read<SeparationItemsViewModel>();

      final success = await vm.cancelCart(widget.cartRouteInternshipConsultation.codCarrinho);

      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Carrinho #${widget.cartRouteInternshipConsultation.codCarrinho} cancelado com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );

          widget.onCancel?.call();
        }
      } else {
        if (context.mounted) {
          final errorMessage = vm.lastCancelError ?? 'Erro ao cancelar carrinho';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Theme.of(context).colorScheme.error));
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error('Erro inesperado ao cancelar carrinho', tag: 'CartItemCard', error: e, stackTrace: stackTrace);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro inesperado. Tente novamente.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Color _getSituationColor(ExpeditionSituation situacao, ColorScheme colorScheme) {
    final cardSituation = ExpeditionSituation.fromCode(situacao.code);
    return cardSituation?.color ?? AppColors.grey;
  }
}

class _FinalizeConfirmationDialogContent extends StatelessWidget {
  final int codCarrinho;
  final bool hasPending;
  final int pendingCount;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _FinalizeConfirmationDialogContent({
    required this.codCarrinho,
    required this.hasPending,
    required this.pendingCount,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Salvar Carrinho'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Deseja realmente salvar o carrinho #$codCarrinho?'),
          if (hasPending) ...[
            const SizedBox(height: UIConstants.defaultPadding),
            Container(
              padding: const EdgeInsets.all(UIConstants.smallPadding),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.sync, color: AppColors.warning, size: UIConstants.defaultIconSize),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Há $pendingCount operação(ões) sincronizando. Aguarde concluir antes de salvar.',
                      style: AppFonts.inter(fontSize: UIConstants.smallFontSize, color: AppColors.orange800),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: hasPending ? null : onConfirm,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
          child: Text('Salvar', style: AppFonts.inter(color: AppColors.white)),
        ),
      ],
    );
  }
}
