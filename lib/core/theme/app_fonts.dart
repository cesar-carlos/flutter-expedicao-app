import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:data7_expedicao/core/constants/ui_constants.dart';

class AppFonts {
  AppFonts._();

  static String get primaryFontFamily => 'Inter';

  static TextTheme getTextTheme({
    required Color baseColor,
    Brightness brightness = Brightness.light,
  }) {
    return GoogleFonts.interTextTheme(
      TextTheme(
        headlineLarge: GoogleFonts.inter(
          fontSize: UIConstants.xxLargeFontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          color: baseColor,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: UIConstants.extraLargeFontSize,
          fontWeight: FontWeight.bold,
          color: baseColor,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: UIConstants.xLargeFontSize,
          fontWeight: FontWeight.w600,
          color: baseColor,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: UIConstants.xLargeFontSize,
          fontWeight: FontWeight.w600,
          color: baseColor,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: UIConstants.mediumFontSize,
          fontWeight: FontWeight.w600,
          color: baseColor,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: UIConstants.defaultFontSize,
          fontWeight: FontWeight.w600,
          color: baseColor,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: UIConstants.mediumFontSize,
          fontWeight: FontWeight.normal,
          color: baseColor,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: UIConstants.defaultFontSize,
          fontWeight: FontWeight.normal,
          color: baseColor,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: UIConstants.smallFontSize,
          fontWeight: FontWeight.normal,
          color: baseColor,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: UIConstants.defaultFontSize,
          fontWeight: FontWeight.w500,
          color: baseColor,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: UIConstants.smallFontSize,
          fontWeight: FontWeight.w500,
          color: baseColor,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: UIConstants.tinyFontSize,
          fontWeight: FontWeight.w500,
          color: baseColor,
        ),
      ),
    );
  }

  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle code(BuildContext context, {Color? color}) {
    final theme = Theme.of(context);
    return GoogleFonts.robotoMono(
      fontSize: UIConstants.defaultFontSize,
      fontWeight: FontWeight.w500,
      color: color ?? theme.colorScheme.onSurface,
    );
  }

  static TextStyle interSmall({Color? color, FontWeight? fontWeight}) {
    return inter(fontSize: UIConstants.smallFontSize, color: color, fontWeight: fontWeight);
  }

  static TextStyle interDefault({Color? color, FontWeight? fontWeight}) {
    return inter(fontSize: UIConstants.defaultFontSize, color: color, fontWeight: fontWeight);
  }

  static TextStyle interMedium({Color? color, FontWeight? fontWeight}) {
    return inter(fontSize: UIConstants.mediumFontSize, color: color, fontWeight: fontWeight);
  }

  static TextStyle interLarge({Color? color, FontWeight? fontWeight}) {
    return inter(fontSize: UIConstants.largeFontSize, color: color, fontWeight: fontWeight);
  }

  static TextStyle interXLarge({Color? color, FontWeight? fontWeight}) {
    return inter(fontSize: UIConstants.xLargeFontSize, color: color, fontWeight: fontWeight);
  }

  static String getFontFamily() => primaryFontFamily;
}
