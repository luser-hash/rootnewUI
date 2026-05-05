import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: 'Nunito',
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
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
