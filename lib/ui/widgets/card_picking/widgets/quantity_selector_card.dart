import 'dart:async' show Timer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:data7_expedicao/domain/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/core/utils/picking_utils.dart';

class QuantitySelectorCard extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final CardPickingViewModel? viewModel;

  const QuantitySelectorCard({
    super.key,
    required this.controller,
    required this.focusNode,
    this.enabled = true,
    this.viewModel,
  });

  @override
  State<QuantitySelectorCard> createState() => _QuantitySelectorCardState();
}

class _QuantitySelectorCardState extends State<QuantitySelectorCard> {
  Timer? _incrementTimer;
  Timer? _decrementTimer;
  bool _isIncrementing = false;
  bool _isDecrementing = false;

  /// Delay inicial antes de começar o incremento contínuo
  static const Duration _initialDelay = Duration(milliseconds: 500);

  /// Intervalo entre incrementos durante o hold
  static const Duration _repeatInterval = Duration(milliseconds: 100);

  /// Quantidade mínima permitida
  static const int _minQuantity = 1;

  @override
  void dispose() {
    _incrementTimer?.cancel();
    _decrementTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.enabled ? Colors.orange.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          const SizedBox(height: 6),
          _buildQuantityRow(theme, colorScheme),
          const SizedBox(height: 6),
          _buildHelpText(theme, colorScheme),
        ],
      ),
    );
  }

  /// Obtém a quantidade máxima permitida baseada no item atual
  int get _maxQuantity {
    if (widget.viewModel == null) return 999;

    // Encontrar o próximo item usando o mesmo utilitário do NextItemCard
    final nextItem = PickingUtils.findNextItemToPick(
      widget.viewModel!.items,
      widget.viewModel!.isItemCompleted,
      userSectorCode: widget.viewModel!.userModel?.codSetorEstoque,
    );

    if (nextItem == null) return 999;

    final totalQuantity = nextItem.quantidade.toInt();
    final pickedQuantity = widget.viewModel!.getPickedQuantity(nextItem.item);
    final remainingQuantity = totalQuantity - pickedQuantity;

    return remainingQuantity > 0 ? remainingQuantity : _minQuantity;
  }

  /// Obtém a quantidade atual do campo
  int get _currentQuantity => int.tryParse(widget.controller.text) ?? _minQuantity;

  /// Incrementa a quantidade uma vez
  void _incrementOnce() {
    final current = _currentQuantity;
    final max = _maxQuantity;

    if (current < max) {
      widget.controller.text = (current + 1).toString();
    }
  }

  /// Decrementa a quantidade uma vez
  void _decrementOnce() {
    final current = _currentQuantity;

    if (current > _minQuantity) {
      widget.controller.text = (current - 1).toString();
    }
  }

  /// Inicia o incremento contínuo
  void _startIncrementing() {
    if (!widget.enabled || _isIncrementing) return;

    _isIncrementing = true;
    _incrementTimer = Timer(_initialDelay, () {
      if (_isIncrementing) {
        _incrementTimer = Timer.periodic(_repeatInterval, (_) {
          if (_isIncrementing && _currentQuantity < _maxQuantity) {
            _incrementOnce();
          } else {
            _stopIncrementing();
          }
        });
      }
    });
  }

  /// Para o incremento contínuo
  void _stopIncrementing() {
    _isIncrementing = false;
    _incrementTimer?.cancel();
    _incrementTimer = null;
  }

  /// Inicia o decremento contínuo
  void _startDecrementing() {
    if (!widget.enabled || _isDecrementing) return;

    _isDecrementing = true;
    _decrementTimer = Timer(_initialDelay, () {
      if (_isDecrementing) {
        _decrementTimer = Timer.periodic(_repeatInterval, (_) {
          if (_isDecrementing && _currentQuantity > _minQuantity) {
            _decrementOnce();
          } else {
            _stopDecrementing();
          }
        });
      }
    });
  }

  /// Para o decremento contínuo
  void _stopDecrementing() {
    _isDecrementing = false;
    _decrementTimer?.cancel();
    _decrementTimer = null;
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.inventory_2, color: widget.enabled ? Colors.orange : Colors.grey, size: 20),
        const SizedBox(width: 6),
        Text(
          'Quantidade a Separar',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: widget.enabled ? Colors.orange : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityRow(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        _buildDecrementButton(),
        const SizedBox(width: 8),
        _buildQuantityField(colorScheme),
        const SizedBox(width: 8),
        _buildIncrementButton(),
      ],
    );
  }

  Widget _buildDecrementButton() {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => _decrementOnce() : null,
      onLongPressStart: widget.enabled ? (_) => _startDecrementing() : null,
      onLongPressEnd: widget.enabled ? (_) => _stopDecrementing() : null,
      child: Container(
        decoration: BoxDecoration(
          color: widget.enabled ? Colors.orange.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: widget.enabled ? _decrementOnce : null,
          icon: Icon(Icons.remove, color: widget.enabled ? Colors.orange : Colors.grey),
          style: IconButton.styleFrom(backgroundColor: Colors.transparent, shape: const CircleBorder()),
        ),
      ),
    );
  }

  Widget _buildIncrementButton() {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => _incrementOnce() : null,
      onLongPressStart: widget.enabled ? (_) => _startIncrementing() : null,
      onLongPressEnd: widget.enabled ? (_) => _stopIncrementing() : null,
      child: Container(
        decoration: BoxDecoration(
          color: widget.enabled ? Colors.orange.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: widget.enabled ? _incrementOnce : null,
          icon: Icon(Icons.add, color: widget.enabled ? Colors.orange : Colors.grey),
          style: IconButton.styleFrom(backgroundColor: Colors.transparent, shape: const CircleBorder()),
        ),
      ),
    );
  }

  Widget _buildQuantityField(ColorScheme colorScheme) {
    return Expanded(
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        enabled: widget.enabled,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
        onChanged: (value) {
          // Garantir que o valor não exceda o máximo
          final intValue = int.tryParse(value);
          if (intValue != null && intValue > _maxQuantity) {
            widget.controller.text = _maxQuantity.toString();
            widget.controller.selection = TextSelection.fromPosition(
              TextPosition(offset: widget.controller.text.length),
            );
          }
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: widget.enabled ? Colors.orange : Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: widget.enabled ? Colors.orange : Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: widget.enabled ? Colors.orange : Colors.grey, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          fillColor: widget.enabled ? null : Colors.grey.withValues(alpha: 0.1),
          filled: !widget.enabled,
        ),
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.enabled ? null : Colors.grey),
      ),
    );
  }

  Widget _buildHelpText(ThemeData theme, ColorScheme colorScheme) {
    final maxQuantity = _maxQuantity;

    // Verificar se há próximo item disponível
    final hasNextItem =
        widget.viewModel != null &&
        PickingUtils.findNextItemToPick(
              widget.viewModel!.items,
              widget.viewModel!.isItemCompleted,
              userSectorCode: widget.viewModel!.userModel?.codSetorEstoque,
            ) !=
            null;

    final helpText = hasNextItem
        ? 'Quantidade restante a separar: $maxQuantity'
        : 'Defina a quantidade que será separada (máximo: $maxQuantity)';

    return Text(
      helpText,
      style: theme.textTheme.bodySmall?.copyWith(color: widget.enabled ? colorScheme.onSurfaceVariant : Colors.grey),
    );
  }
}
