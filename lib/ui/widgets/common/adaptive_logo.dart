import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/constants/app_assets.dart';
import 'package:data7_expedicao/core/theme/theme_extensions.dart';

class AdaptiveLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? fallback;
  final bool useTransparentBackground;

  const AdaptiveLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.fallback,
    this.useTransparentBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.isDark;

    final logoPath = isDark ? AppAssets.logSe7eWhite : AppAssets.logSe7eBlack;

    return Image.asset(
      logoPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return fallback ??
            Icon(Icons.qr_code_scanner, size: width ?? height ?? 60, color: Theme.of(context).colorScheme.primary);
      },
    );
  }
}

class AdaptiveLogoContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final bool showShadow;
  final EdgeInsetsGeometry? padding;

  const AdaptiveLogoContainer({
    super.key,
    this.width = 130,
    this.height = 130,
    this.borderRadius = 10,
    this.showShadow = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        // Bug latente anterior: a `BoxShadow` era criada com
        // `alpha: 0.0` (totalmente invisivel). O parametro
        // `showShadow` existia mas era no-op visual. Agora aplica
        // sombra real (alpha 0.15) quando solicitado, mantendo a
        // API publica intacta.
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
        // Bug similar removido: `Border.all(width: 0.0)` era invisivel.
        // Como nunca foi configuravel, removido completamente do
        // BoxDecoration (sem regressao visual — antes ja era 0px).
      ),
      child: AdaptiveLogo(
        width: width != null ? width! * 0.3 : null,
        height: height != null ? height! * 0.6 : null,
        fit: BoxFit.contain,
      ),
    );
  }
}
