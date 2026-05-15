import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppThemeTokens.light.background,
      fontFamily: 'Nunito',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppThemeTokens.light.surface,
      ),
      extensions: const <ThemeExtension<dynamic>>[AppThemeTokens.light],
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: AppThemeTokens.light.text,
        displayColor: AppThemeTokens.light.text,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppThemeTokens.dark.background,
      fontFamily: 'Nunito',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryLt,
        brightness: Brightness.dark,
        primary: AppColors.primaryLt,
        secondary: AppColors.accentLt,
        surface: AppThemeTokens.dark.surface,
      ),
      extensions: const <ThemeExtension<dynamic>>[AppThemeTokens.dark],
      cardTheme: const CardThemeData(color: AppThemeTokens.darkCard),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppThemeTokens.darkSurface,
      ),
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: AppThemeTokens.darkText,
        displayColor: AppThemeTokens.darkText,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppThemeTokens.darkSurface,
        labelStyle: const TextStyle(color: AppThemeTokens.darkTextMid),
        hintStyle: const TextStyle(color: AppThemeTokens.darkTextMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppThemeTokens.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryLt, width: 1.4),
        ),
      ),
    );
  }
}

class AppThemeColors {
  static AppThemeTokens of(BuildContext context) {
    return Theme.of(context).extension<AppThemeTokens>() ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppThemeTokens.dark
            : AppThemeTokens.light);
  }

  static Color background(BuildContext context) => of(context).background;
  static Color surface(BuildContext context) => of(context).surface;
  static Color card(BuildContext context) => of(context).card;
  static Color elevatedSurface(BuildContext context) =>
      of(context).elevatedSurface;
  static Color text(BuildContext context) => of(context).text;
  static Color textMid(BuildContext context) => of(context).textMid;
  static Color textMuted(BuildContext context) => of(context).textMuted;
  static Color border(BuildContext context) => of(context).border;
  static Color divider(BuildContext context) => of(context).divider;
  static Color shadow(BuildContext context) => of(context).shadow;

  static Color statusSuccessBg(BuildContext context) =>
      of(context).statusSuccessBg;
  static Color statusSuccessFg(BuildContext context) =>
      of(context).statusSuccessFg;
  static Color statusErrorBg(BuildContext context) => of(context).statusErrorBg;
  static Color statusErrorFg(BuildContext context) => of(context).statusErrorFg;
  static Color statusWarningBg(BuildContext context) =>
      of(context).statusWarningBg;
  static Color statusWarningFg(BuildContext context) =>
      of(context).statusWarningFg;
  static Color statusInfoBg(BuildContext context) => of(context).statusInfoBg;
  static Color statusInfoFg(BuildContext context) => of(context).statusInfoFg;
  static Color statusPurpleBg(BuildContext context) =>
      of(context).statusPurpleBg;
  static Color statusPurpleFg(BuildContext context) =>
      of(context).statusPurpleFg;
  static Color statusNeutralBg(BuildContext context) =>
      of(context).statusNeutralBg;
  static Color statusNeutralFg(BuildContext context) =>
      of(context).statusNeutralFg;

  static ({Color background, Color foreground}) statusSuccess(
    BuildContext context,
  ) {
    final AppThemeTokens tokens = of(context);
    return (
      background: tokens.statusSuccessBg,
      foreground: tokens.statusSuccessFg,
    );
  }

  static ({Color background, Color foreground}) statusError(
    BuildContext context,
  ) {
    final AppThemeTokens tokens = of(context);
    return (background: tokens.statusErrorBg, foreground: tokens.statusErrorFg);
  }

  static ({Color background, Color foreground}) statusWarning(
    BuildContext context,
  ) {
    final AppThemeTokens tokens = of(context);
    return (
      background: tokens.statusWarningBg,
      foreground: tokens.statusWarningFg,
    );
  }

  static ({Color background, Color foreground}) statusInfo(
    BuildContext context,
  ) {
    final AppThemeTokens tokens = of(context);
    return (background: tokens.statusInfoBg, foreground: tokens.statusInfoFg);
  }

  static ({Color background, Color foreground}) statusPurple(
    BuildContext context,
  ) {
    final AppThemeTokens tokens = of(context);
    return (
      background: tokens.statusPurpleBg,
      foreground: tokens.statusPurpleFg,
    );
  }

  static ({Color background, Color foreground}) statusNeutral(
    BuildContext context,
  ) {
    final AppThemeTokens tokens = of(context);
    return (
      background: tokens.statusNeutralBg,
      foreground: tokens.statusNeutralFg,
    );
  }
}

class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    required this.background,
    required this.surface,
    required this.card,
    required this.elevatedSurface,
    required this.text,
    required this.textMid,
    required this.textMuted,
    required this.border,
    required this.divider,
    required this.shadow,
    required this.statusSuccessBg,
    required this.statusSuccessFg,
    required this.statusErrorBg,
    required this.statusErrorFg,
    required this.statusWarningBg,
    required this.statusWarningFg,
    required this.statusInfoBg,
    required this.statusInfoFg,
    required this.statusPurpleBg,
    required this.statusPurpleFg,
    required this.statusNeutralBg,
    required this.statusNeutralFg,
  });

  static const Color darkBackground = Color(0xFF071311);
  static const Color darkSurface = Color(0xFF10201D);
  static const Color darkCard = Color(0xFF132622);
  static const Color darkElevatedSurface = Color(0xFF19312C);
  static const Color darkText = Color(0xFFE5F0EE);
  static const Color darkTextMid = Color(0xFFAFC4C0);
  static const Color darkTextMuted = Color(0xFF718984);
  static const Color darkBorder = Color(0xFF29413D);
  static const Color darkDivider = Color(0xFF203530);

  static const AppThemeTokens light = AppThemeTokens(
    background: AppColors.bg,
    surface: AppColors.surface,
    card: AppColors.card,
    elevatedSurface: AppColors.white,
    text: AppColors.text,
    textMid: AppColors.textMid,
    textMuted: AppColors.textMute,
    border: AppColors.border,
    divider: AppColors.border,
    shadow: Color(0x26006B5E),
    statusSuccessBg: AppColors.greenLt,
    statusSuccessFg: AppColors.green,
    statusErrorBg: AppColors.redLt,
    statusErrorFg: AppColors.red,
    statusWarningBg: AppColors.amberLt,
    statusWarningFg: AppColors.amber,
    statusInfoBg: AppColors.blueLt,
    statusInfoFg: AppColors.blue,
    statusPurpleBg: AppColors.purpleLt,
    statusPurpleFg: Color(0xFF6E5FA8),
    statusNeutralBg: AppColors.surface,
    statusNeutralFg: AppColors.textMute,
  );

  static const AppThemeTokens dark = AppThemeTokens(
    background: darkBackground,
    surface: darkSurface,
    card: darkCard,
    elevatedSurface: darkElevatedSurface,
    text: darkText,
    textMid: darkTextMid,
    textMuted: darkTextMuted,
    border: darkBorder,
    divider: darkDivider,
    shadow: Color(0x8A000000),
    statusSuccessBg: Color(0xFF123A2B),
    statusSuccessFg: Color(0xFF68DCA2),
    statusErrorBg: Color(0xFF421C1C),
    statusErrorFg: Color(0xFFFF8585),
    statusWarningBg: Color(0xFF3D3016),
    statusWarningFg: Color(0xFFF0C76B),
    statusInfoBg: Color(0xFF182C4A),
    statusInfoFg: Color(0xFF8AB0FF),
    statusPurpleBg: Color(0xFF2F2845),
    statusPurpleFg: Color(0xFFC5B8FF),
    statusNeutralBg: Color(0xFF1A2B27),
    statusNeutralFg: darkTextMuted,
  );

  final Color background;
  final Color surface;
  final Color card;
  final Color elevatedSurface;
  final Color text;
  final Color textMid;
  final Color textMuted;
  final Color border;
  final Color divider;
  final Color shadow;
  final Color statusSuccessBg;
  final Color statusSuccessFg;
  final Color statusErrorBg;
  final Color statusErrorFg;
  final Color statusWarningBg;
  final Color statusWarningFg;
  final Color statusInfoBg;
  final Color statusInfoFg;
  final Color statusPurpleBg;
  final Color statusPurpleFg;
  final Color statusNeutralBg;
  final Color statusNeutralFg;

  @override
  AppThemeTokens copyWith({
    Color? background,
    Color? surface,
    Color? card,
    Color? elevatedSurface,
    Color? text,
    Color? textMid,
    Color? textMuted,
    Color? border,
    Color? divider,
    Color? shadow,
    Color? statusSuccessBg,
    Color? statusSuccessFg,
    Color? statusErrorBg,
    Color? statusErrorFg,
    Color? statusWarningBg,
    Color? statusWarningFg,
    Color? statusInfoBg,
    Color? statusInfoFg,
    Color? statusPurpleBg,
    Color? statusPurpleFg,
    Color? statusNeutralBg,
    Color? statusNeutralFg,
  }) {
    return AppThemeTokens(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      text: text ?? this.text,
      textMid: textMid ?? this.textMid,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      shadow: shadow ?? this.shadow,
      statusSuccessBg: statusSuccessBg ?? this.statusSuccessBg,
      statusSuccessFg: statusSuccessFg ?? this.statusSuccessFg,
      statusErrorBg: statusErrorBg ?? this.statusErrorBg,
      statusErrorFg: statusErrorFg ?? this.statusErrorFg,
      statusWarningBg: statusWarningBg ?? this.statusWarningBg,
      statusWarningFg: statusWarningFg ?? this.statusWarningFg,
      statusInfoBg: statusInfoBg ?? this.statusInfoBg,
      statusInfoFg: statusInfoFg ?? this.statusInfoFg,
      statusPurpleBg: statusPurpleBg ?? this.statusPurpleBg,
      statusPurpleFg: statusPurpleFg ?? this.statusPurpleFg,
      statusNeutralBg: statusNeutralBg ?? this.statusNeutralBg,
      statusNeutralFg: statusNeutralFg ?? this.statusNeutralFg,
    );
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) {
      return this;
    }

    return AppThemeTokens(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMid: Color.lerp(textMid, other.textMid, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      statusSuccessBg: Color.lerp(statusSuccessBg, other.statusSuccessBg, t)!,
      statusSuccessFg: Color.lerp(statusSuccessFg, other.statusSuccessFg, t)!,
      statusErrorBg: Color.lerp(statusErrorBg, other.statusErrorBg, t)!,
      statusErrorFg: Color.lerp(statusErrorFg, other.statusErrorFg, t)!,
      statusWarningBg: Color.lerp(statusWarningBg, other.statusWarningBg, t)!,
      statusWarningFg: Color.lerp(statusWarningFg, other.statusWarningFg, t)!,
      statusInfoBg: Color.lerp(statusInfoBg, other.statusInfoBg, t)!,
      statusInfoFg: Color.lerp(statusInfoFg, other.statusInfoFg, t)!,
      statusPurpleBg: Color.lerp(statusPurpleBg, other.statusPurpleBg, t)!,
      statusPurpleFg: Color.lerp(statusPurpleFg, other.statusPurpleFg, t)!,
      statusNeutralBg: Color.lerp(statusNeutralBg, other.statusNeutralBg, t)!,
      statusNeutralFg: Color.lerp(statusNeutralFg, other.statusNeutralFg, t)!,
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
