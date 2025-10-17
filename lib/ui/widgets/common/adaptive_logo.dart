import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/constants/app_assets.dart';

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
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    final logoPath = isDarkTheme ? AppAssets.logSe7eWhite : AppAssets.logSe7eBlack;

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
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: isDarkTheme
            ? theme.colorScheme.surface.withValues(alpha: 1.0)
            : theme.colorScheme.surface.withValues(alpha: 1.0),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.0), offset: const Offset(0, 8))]
            : null,

        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.0), width: 0.0),
      ),
      child: AdaptiveLogo(
        width: width != null ? width! * 0.3 : null,
        height: height != null ? height! * 0.6 : null,
        fit: BoxFit.contain,
      ),
    );
  }
}
