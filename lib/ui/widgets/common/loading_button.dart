import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? loadingColor;
  final double? loadingSize;
  final double? strokeWidth;

  const LoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.backgroundColor,
    this.foregroundColor,
    this.loadingColor = Colors.white,
    this.loadingSize = 20,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: padding,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.zero),
      ),
      child: isLoading
          ? SizedBox(
              height: loadingSize,
              width: loadingSize,
              child: CircularProgressIndicator(
                strokeWidth: strokeWidth!,
                valueColor: AlwaysStoppedAnimation<Color>(loadingColor!),
              ),
            )
          : Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
    );
  }
}
