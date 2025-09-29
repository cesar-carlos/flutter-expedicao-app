import 'package:flutter/material.dart';

/// Widget customizado para botões simples com ícone e texto
///
/// Este widget padroniza a aparência e comportamento dos botões
/// simples utilizados na aplicação, garantindo consistência visual.
class CustomSimpleButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool isLoading;
  final bool isOutlined;
  final double? iconSize;
  final TextStyle? textStyle;
  final double? elevation;

  const CustomSimpleButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding,
    this.borderRadius,
    this.isLoading = false,
    this.isOutlined = false,
    this.iconSize,
    this.textStyle,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveBackgroundColor = backgroundColor ?? colorScheme.primary;
    final effectiveForegroundColor = foregroundColor ?? (isOutlined ? effectiveBackgroundColor : colorScheme.onPrimary);
    final effectiveBorderColor = borderColor ?? (isOutlined ? effectiveBackgroundColor : Colors.transparent);
    final effectivePadding = padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24);
    final effectiveBorderRadius = borderRadius ?? 12.0;
    final effectiveIconSize = iconSize ?? 20.0;
    final effectiveElevation = elevation ?? (isOutlined ? 0 : 2);

    return SizedBox(
      width: double.infinity,
      child: isOutlined
          ? _buildOutlinedButton(
              theme,
              effectiveBackgroundColor,
              effectiveForegroundColor,
              effectiveBorderColor,
              effectivePadding,
              effectiveBorderRadius,
              effectiveIconSize,
            )
          : _buildElevatedButton(
              theme,
              effectiveBackgroundColor,
              effectiveForegroundColor,
              effectivePadding,
              effectiveBorderRadius,
              effectiveIconSize,
              effectiveElevation,
            ),
    );
  }

  Widget _buildElevatedButton(
    ThemeData theme,
    Color backgroundColor,
    Color foregroundColor,
    EdgeInsetsGeometry padding,
    double borderRadius,
    double iconSize,
    double elevation,
  ) {
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          elevation: elevation,
        ),
        icon: _buildIcon(foregroundColor, iconSize),
        label: _buildLabel(theme, foregroundColor),
      );
    } else {
      return ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          elevation: elevation,
        ),
        child: _buildLabel(theme, foregroundColor),
      );
    }
  }

  Widget _buildOutlinedButton(
    ThemeData theme,
    Color backgroundColor,
    Color foregroundColor,
    Color borderColor,
    EdgeInsetsGeometry padding,
    double borderRadius,
    double iconSize,
  ) {
    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : backgroundColor,
          foregroundColor: foregroundColor,
          side: BorderSide(color: borderColor),
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        ),
        icon: _buildIcon(foregroundColor, iconSize),
        label: _buildLabel(theme, foregroundColor),
      );
    } else {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : backgroundColor,
          foregroundColor: foregroundColor,
          side: BorderSide(color: borderColor),
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        ),
        child: _buildLabel(theme, foregroundColor),
      );
    }
  }

  Widget _buildIcon(Color color, double size) {
    if (isLoading) {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(color)),
      );
    }

    if (icon != null) {
      return Icon(icon, size: size, color: color);
    }

    return SizedBox(width: size, height: size);
  }

  Widget _buildLabel(ThemeData theme, Color color) {
    final effectiveTextStyle =
        textStyle ?? theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: color);

    return Text(isLoading ? 'Carregando...' : text, style: effectiveTextStyle);
  }
}

/// Extensão com variações pré-definidas do CustomSimpleButton
extension CustomSimpleButtonVariations on CustomSimpleButton {
  /// Cria um botão primário simples
  static CustomSimpleButton primary({
    required String text,
    IconData? icon,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return CustomSimpleButton(text: text, icon: icon, onPressed: onPressed, isLoading: isLoading);
  }

  /// Cria um botão outlined (contorno)
  static CustomSimpleButton outlined({
    required String text,
    IconData? icon,
    VoidCallback? onPressed,
    Color? color,
    bool isLoading = false,
  }) {
    return CustomSimpleButton(
      text: text,
      icon: icon,
      onPressed: onPressed,
      foregroundColor: color,
      borderColor: color,
      isOutlined: true,
      isLoading: isLoading,
    );
  }

  /// Cria um botão secundário (será aplicado durante o build)
  static CustomSimpleButton secondary({
    required String text,
    IconData? icon,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return CustomSimpleButton(
      text: text,
      icon: icon,
      onPressed: onPressed,
      backgroundColor: null, // Será definido no build usando secondary
      foregroundColor: null, // Será definido no build usando onSecondary
      isLoading: isLoading,
    );
  }

  /// Cria um botão de erro/danger
  static CustomSimpleButton danger({
    required String text,
    IconData? icon,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return CustomSimpleButton(
      text: text,
      icon: icon,
      onPressed: onPressed,
      backgroundColor: Colors.red, // Cor de erro padrão
      foregroundColor: Colors.white,
      isLoading: isLoading,
    );
  }
}
