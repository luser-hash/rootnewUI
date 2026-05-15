import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: 'Nunito',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.white,
      ),
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
    );
  }

  static ThemeData get darkTheme {
    const Color darkBg = Color(0xFF071311);
    const Color darkSurface = Color(0xFF10201D);
    const Color darkText = Color(0xFFE5F0EE);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      fontFamily: 'Nunito',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryLt,
        brightness: Brightness.dark,
        primary: AppColors.primaryLt,
        secondary: AppColors.accentLt,
        surface: darkSurface,
      ),
      cardTheme: const CardThemeData(color: darkSurface),
      dialogTheme: const DialogThemeData(backgroundColor: darkSurface),
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: darkText,
        displayColor: darkText,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        labelStyle: const TextStyle(color: Color(0xFFAFC4C0)),
        hintStyle: const TextStyle(color: Color(0xFF718984)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF29413D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryLt, width: 1.4),
        ),
      ),
    );
  }
}

class AppColors {
  static const Color primary = Color(0xFF006B5E);
  static const Color primaryDk = Color(0xFF004D44);
  static const Color primaryLt = Color(0xFF00856F);
  static const Color accent = Color(0xFFC8973A);
  static const Color accentLt = Color(0xFFF0B84A);
  static const Color bg = Color(0xFFF2F4F3);
  static const Color white = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFEEF1F0);
  static const Color text = Color(0xFF0D1F1C);
  static const Color textMid = Color(0xFF3D5550);
  static const Color textMute = Color(0xFF7A9490);
  static const Color border = Color(0xFFD8E2E0);
  static const Color green = Color(0xFF1BAA6B);
  static const Color greenLt = Color(0xFFE6F8F0);
  static const Color red = Color(0xFFD94040);
  static const Color redLt = Color(0xFFFDEAEA);
  static const Color amber = Color(0xFFC8973A);
  static const Color amberLt = Color(0xFFFDF3E3);
  static const Color blue = Color(0xFF4F7FFF);
  static const Color blueLt = Color(0xFFEFF3FF);
  static const Color purpleLt = Color(0xFFF0EEF8);
  static const Color appBackgroundStart = Color(0xFF0D1F1C);
  static const Color appBackgroundEnd = Color(0xFF1A1A2E);

  static BoxShadow softShadow({double opacity = 0.15, double blur = 12}) {
    return BoxShadow(
      color: primary.withValues(alpha: opacity),
      blurRadius: blur,
      offset: const Offset(0, 2),
    );
  }
}
