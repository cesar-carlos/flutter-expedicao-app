import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/theme/app_colors.dart';

extension ThemeDataExtensions on ThemeData {
  bool get isDark => brightness == Brightness.dark;

  Color adaptivePrimary(ColorScheme colorScheme) {
    return isDark ? AppColors.light : colorScheme.primary;
  }

  Color adaptiveSecondary(ColorScheme colorScheme) {
    return isDark ? AppColors.secondary : colorScheme.primary;
  }

  Color adaptiveOnSurfaceVariant(ColorScheme colorScheme) {
    return isDark ? AppColors.light : colorScheme.onSurfaceVariant;
  }

  Color adaptiveSecondaryColor(ColorScheme colorScheme) {
    return isDark ? AppColors.light : colorScheme.secondary;
  }
}
