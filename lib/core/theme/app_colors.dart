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

  // Cores adicionais para situações
  static const Color yellow = Color(0xFFFFEB3B);
  static const Color lightGreen = Color(0xFF8BC34A);
  static const Color purple = Color(0xFF9C27B0);
  static const Color teal = Color(0xFF009688);
  static const Color brown = Color(0xFF795548);
  static const Color indigo = Color(0xFF3F51B5);

  // Variações de cores de estado (shades)
  static const Color red800 = Color(0xFFC62828);
  static const Color red700 = Color(0xFFD32F2F);
  static const Color red600 = Color(0xFFE53935);
  static const Color red300 = Color(0xFFE57373);
  static const Color red50 = Color(0xFFFFEBEE);
  static const Color green800 = Color(0xFF2E7D32);
  static const Color green700 = Color(0xFF388E3C);
  static const Color green600 = Color(0xFF43A047);
  static const Color green300 = Color(0xFF81C784);
  static const Color green100 = Color(0xFFC8E6C9);
  static const Color green50 = Color(0xFFE8F5E9);
  static const Color orange800 = Color(0xFFE65100);
  static const Color orange700 = Color(0xFFF57C00);
  static const Color blue800 = Color(0xFF1565C0);
  static const Color blue700 = Color(0xFF1976D2);
  static const Color blue600 = Color(0xFF1E88E5);
  static const Color blue500 = Color(0xFF2196F3);
  static const Color blue100 = Color(0xFFBBDEFB);

  // Cores neutras
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF424242);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color black54 = Color(0x8A000000);
  static const Color black87 = Color(0xDD000000);

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
  static Color primaryWithOpacity(double opacity) => primary.withValues(alpha: opacity);
  static Color secondaryWithOpacity(double opacity) => secondary.withValues(alpha: opacity);
  static Color successWithOpacity(double opacity) => success.withValues(alpha: opacity);
  static Color lightWithOpacity(double opacity) => light.withValues(alpha: opacity);
  static Color accentWithOpacity(double opacity) => accent.withValues(alpha: opacity);

  // Métodos utilitários para cores com opacidade
  static Color withOpacity(Color color, double opacity) => color.withValues(alpha: opacity);
}
