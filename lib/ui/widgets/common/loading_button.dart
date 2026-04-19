import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';

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
    this.loadingColor = AppColors.white,
    this.loadingSize = 20,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    // Bug latente anterior: `strokeWidth!` e `loadingColor!` (null
    // assertions) crashavam com TypeError se o caller passasse
    // `strokeWidth: null` ou `loadingColor: null` explicitamente.
    // Defaults na assinatura so se aplicam para argumentos OMITIDOS,
    // nao para nulls passados de forma deliberada (ex.: spread de
    // configuracao opcional). Agora usamos fallback explicito que
    // tolera null sem crash.
    final effectiveStrokeWidth = strokeWidth ?? 2.0;
    final effectiveLoadingColor = loadingColor ?? AppColors.white;
    final effectiveLoadingSize = loadingSize ?? 20.0;

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
              height: effectiveLoadingSize,
              width: effectiveLoadingSize,
              child: CircularProgressIndicator(
                strokeWidth: effectiveStrokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(effectiveLoadingColor),
              ),
            )
          : Text(text, style: AppFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
    );
  }
}
