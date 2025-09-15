import 'package:flutter/material.dart';

class CustomFlatButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final IconData? icon;
  final double? borderRadius;
  final bool isOutlined;

  const CustomFlatButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.textColor,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.textStyle,
    this.icon,
    this.borderRadius,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveTextColor =
        textColor ?? (isOutlined ? colorScheme.primary : colorScheme.onPrimary);
    final effectiveBackgroundColor =
        backgroundColor ??
        (isOutlined ? Colors.transparent : colorScheme.primary);
    final effectiveBorderColor =
        borderColor ??
        (isOutlined ? colorScheme.primary : effectiveBackgroundColor);

    return SizedBox(
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: _buildIcon(effectiveTextColor),
              label: _buildLabel(theme, effectiveTextColor),
              style: OutlinedButton.styleFrom(
                foregroundColor: effectiveTextColor,
                backgroundColor: effectiveBackgroundColor,
                side: BorderSide(color: effectiveBorderColor),
                padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius ?? 8),
                ),
                elevation: 0,
              ),
            )
          : ElevatedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: _buildIcon(effectiveTextColor),
              label: _buildLabel(theme, effectiveTextColor),
              style: ElevatedButton.styleFrom(
                foregroundColor: effectiveTextColor,
                backgroundColor: effectiveBackgroundColor,
                padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius ?? 8),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
            ),
    );
  }

  Widget _buildIcon(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Icon(icon, size: 18);
    }

    return const SizedBox(width: 18, height: 18);
  }

  Widget _buildLabel(ThemeData theme, Color color) {
    final effectiveTextStyle =
        textStyle ??
        theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        );

    return Text(isLoading ? 'Carregando...' : text, style: effectiveTextStyle);
  }
}

extension CustomFlatButtonVariations on CustomFlatButton {
  static CustomFlatButton textStyle({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    Color? textColor,
    IconData? icon,
    TextStyle? textStyle,
  }) {
    return CustomFlatButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      textColor: textColor,
      backgroundColor: Colors.transparent,
      borderColor: Colors.transparent,
      icon: icon,
      textStyle: textStyle,
      padding: const EdgeInsets.symmetric(vertical: 12),
      borderRadius: 6,
    );
  }

  static CustomFlatButton outlined({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    Color? textColor,
    Color? borderColor,
    IconData? icon,
  }) {
    return CustomFlatButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      textColor: textColor,
      borderColor: borderColor,
      icon: icon,
      isOutlined: true,
      borderRadius: 8,
    );
  }
}
