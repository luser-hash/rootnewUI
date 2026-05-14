import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class AppPanel extends StatelessWidget {
  const AppPanel({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.background = AppColors.white,
    this.borderColor = AppColors.border,
    this.borderRadius = 18,
    this.shadowOpacity = 0.08,
    this.shadowBlur = 10,
    this.clipBehavior = Clip.none,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color background;
  final Color borderColor;
  final double borderRadius;
  final double shadowOpacity;
  final double shadowBlur;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
        boxShadow: <BoxShadow>[
          AppColors.softShadow(opacity: shadowOpacity, blur: shadowBlur),
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
                const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
          ),
          SizedBox(height: spacing),
          child,
        ],
      ),
    );
  }
}
