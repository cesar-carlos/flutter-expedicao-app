import 'package:flutter/material.dart';

/// Classe com as cores definidas para o tema da aplicação
class AppColors {
  // Cores principais do tema teal
  static const Color primary = Color(0xFF1A7A8A);
  static const Color secondary = Color(0xFF4FB3C1);
  static const Color accent = Color(0xFF0A5A6B);
  static const Color light = Color(0xFFB8E6EA);
  static const Color dark = Color(0xFF052F36);

  // Aliases para compatibilidade com o tema
  static const Color primaryTeal = primary;
  static const Color secondaryTeal = secondary;
  static const Color accentTeal = accent;
  static const Color lightTeal = light;
  static const Color darkTeal = dark;

  // Cores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Cores neutras
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF424242);

  // Cores básicas
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  // Cores de superfície e fundo
  static const Color surface = Color(0xFFFAFAFA);
  static const Color background = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onBackground = Color(0xFF1C1B1F);

  //create font colors
  static const Color fontPrimary = Color(0xFF1A7A8A);
  static const Color fontSecondary = Color(0xFF4FB3C1);
  static const Color fontAccent = Color(0xFF0A5A6B);
  static const Color fontLight = Color(0xFFB8E6EA);
  static const Color fontDark = Color(0xFF052F36);

  // Transparências e variações
  static Color primaryWithOpacity(double opacity) =>
      primary.withValues(alpha: opacity);
  static Color secondaryWithOpacity(double opacity) =>
      secondary.withValues(alpha: opacity);
  static Color successWithOpacity(double opacity) =>
      success.withValues(alpha: opacity);
  static Color lightWithOpacity(double opacity) =>
      light.withValues(alpha: opacity);
  static Color accentWithOpacity(double opacity) =>
      accent.withValues(alpha: opacity);

  // Métodos utilitários para cores com opacidade
  static Color withOpacity(Color color, double opacity) =>
      color.withValues(alpha: opacity);
}
