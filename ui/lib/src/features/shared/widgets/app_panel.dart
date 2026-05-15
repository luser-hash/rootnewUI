import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class AppPanel extends StatelessWidget {
  const AppPanel({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.background,
    this.borderColor,
    this.borderRadius = 18,
    this.shadowOpacity = 0.08,
    this.shadowBlur = 10,
    this.clipBehavior = Clip.none,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? background;
  final Color? borderColor;
  final double borderRadius;
  final double shadowOpacity;
  final double shadowBlur;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final Color shadow = AppThemeColors.shadow(
      context,
    ).withValues(alpha: shadowOpacity);

    return Container(
      margin: margin,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: background ?? AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppThemeColors.border(context),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: shadow,
            blurRadius: shadowBlur,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
  }
}

class AppSection extends StatelessWidget {
  const AppSection({
    super.key,
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 20, 16, 0),
    this.titleStyle,
    this.spacing = 12,
  });

  final String title;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final TextStyle? titleStyle;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style:
                titleStyle ??
                TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppThemeColors.text(context),
                ),
          ),
          SizedBox(height: spacing),
          child,
        ],
      ),
    );
  }
}
