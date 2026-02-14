import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/ui/widgets/card_picking/widgets/index.dart';
import 'package:data7_expedicao/presentation/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/widgets/barcode_scanner_card_optimized.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/picking_scan_state.dart';
import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/picking_state.dart';

class PickingScreenLayout extends StatelessWidget {
  final ExpeditionCartRouteInternshipConsultationModel cart;

  final CardPickingViewModel viewModel;

  final TextEditingController quantityController;

  final FocusNode quantityFocusNode;

  final TextEditingController scanController;

  final FocusNode scanFocusNode;

  final VoidCallback onToggleKeyboard;

  final void Function(String) onBarcodeScanned;

  const PickingScreenLayout({
    super.key,
    required this.cart,
    required this.viewModel,
    required this.quantityController,
    required this.quantityFocusNode,
    required this.scanController,
    required this.scanFocusNode,
    required this.onToggleKeyboard,
    required this.onBarcodeScanned,
  });

  static const double _cardSpacing = UIConstants.smallPadding;

  static const double _defaultPadding = UIConstants.smallPadding;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final hasKeyboard = bottomInset > 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _defaultPadding,
        _defaultPadding,
        _defaultPadding,
        _defaultPadding + (hasKeyboard ? UIConstants.keyboardOverlayPadding : 0),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          await viewModel.refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNextItemCard(),
              const SizedBox(height: _cardSpacing),
              _buildQuantitySelector(),
              const SizedBox(height: _cardSpacing),
              _buildBarcodeScanner(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextItemCard() {
    return Selector<CardPickingViewModel, _NextItemViewData>(
      selector: (_, vm) => _NextItemViewData.fromViewModel(vm),
      builder: (context, data, _) {
        return RepaintBoundary(
          child: NextItemCard(
            nextItem: data.nextItem,
            completedCount: data.completedCount,
            totalCount: data.totalCount,
            userSectorCode: data.userSectorCode,
            pickedQuantity: data.pickedQuantity,
            itemState: data.itemState,
            hasItemsForUserSector: data.hasItemsForUserSector,
          ),
        );
      },
    );
  }

  Widget _buildQuantitySelector() {
    return Selector<PickingScanState, bool>(
      selector: (_, s) => s.enabled,
      builder: (context, isEnabled, _) {
        return Selector<CardPickingViewModel, _QuantitySelectorViewData>(
          selector: (_, vm) => _QuantitySelectorViewData.fromViewModel(vm),
          builder: (context, data, child) {
            return RepaintBoundary(
              child: QuantitySelectorCard(
                controller: quantityController,
                focusNode: quantityFocusNode,
                enabled: isEnabled,
                viewModel: viewModel,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBarcodeScanner() {
    return RepaintBoundary(
      child: BarcodeScannerCardOptimized(
        controller: scanController,
        focusNode: scanFocusNode,
        onToggleKeyboard: onToggleKeyboard,
        onSubmitted: onBarcodeScanned,
      ),
    );
  }
}

class _NextItemViewData {
  final SeparateItemConsultationModel? nextItem;
  final int completedCount;
  final int totalCount;
  final int? userSectorCode;
  final int pickedQuantity;
  final PickingItemState? itemState;
  final bool hasItemsForUserSector;

  _NextItemViewData({
    required this.nextItem,
    required this.completedCount,
    required this.totalCount,
    required this.userSectorCode,
    required this.pickedQuantity,
    required this.itemState,
    required this.hasItemsForUserSector,
  });

  factory _NextItemViewData.fromViewModel(CardPickingViewModel vm) {
    final nextItem = vm.nextItem;

    return _NextItemViewData(
      nextItem: nextItem,
      completedCount: vm.completedItems,
      totalCount: vm.totalItems,
      userSectorCode: vm.userModel?.codSetorEstoque,
      pickedQuantity: nextItem != null ? vm.getPickedQuantity(nextItem.item) : 0,
      itemState: nextItem != null ? vm.pickingState.getItemState(nextItem.item) : null,
      hasItemsForUserSector: vm.hasItemsForUserSector,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _NextItemViewData &&
          nextItem?.item == other.nextItem?.item &&
          completedCount == other.completedCount &&
          totalCount == other.totalCount &&
          userSectorCode == other.userSectorCode &&
          pickedQuantity == other.pickedQuantity &&
          hasItemsForUserSector == other.hasItemsForUserSector &&
          _itemStateEquals(itemState, other.itemState);

  static bool _itemStateEquals(PickingItemState? a, PickingItemState? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    return a.itemId == b.itemId &&
        a.pickedQuantity == b.pickedQuantity &&
        a.isCompleted == b.isCompleted &&
        a.totalQuantity == b.totalQuantity &&
        a.pendingOperations.length == b.pendingOperations.length;
  }

  @override
  int get hashCode => Object.hash(
    nextItem?.item,
    completedCount,
    totalCount,
    userSectorCode,
    pickedQuantity,
    hasItemsForUserSector,
    itemState?.itemId,
    itemState?.pickedQuantity,
    itemState?.isCompleted,
    itemState?.totalQuantity,
    itemState?.pendingOperations.length ?? 0,
  );
}

class _QuantitySelectorViewData {
  final String? nextItemId;
  final int maxQuantity;

  _QuantitySelectorViewData({this.nextItemId, required this.maxQuantity});

  factory _QuantitySelectorViewData.fromViewModel(CardPickingViewModel vm) {
    final nextItem = vm.nextItem;
    return _QuantitySelectorViewData(nextItemId: nextItem?.item, maxQuantity: vm.maxQuantityForNextItem);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _QuantitySelectorViewData && nextItemId == other.nextItemId && maxQuantity == other.maxQuantity;

  @override
  int get hashCode => Object.hash(nextItemId, maxQuantity);
}
