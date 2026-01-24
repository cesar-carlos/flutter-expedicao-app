import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/theme/app_fonts.dart';
import 'package:data7_expedicao/core/constants/ui_constants.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle code(BuildContext context, {Color? color}) {
    return AppFonts.code(context, color: color);
  }

  static TextStyle button(BuildContext context) {
    final theme = Theme.of(context);
    return AppFonts.inter(
      fontSize: UIConstants.mediumFontSize,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onPrimary,
    );
  }

  static TextStyle custom({required double fontSize, FontWeight? fontWeight, Color? color}) {
    return AppFonts.inter(fontSize: fontSize, fontWeight: fontWeight, color: color);
  }
}
