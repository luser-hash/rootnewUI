import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

enum AppMessageTone { info, success, warning, error, neutral }

class AppMessageCard extends StatelessWidget {
  const AppMessageCard({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.tone = AppMessageTone.info,
    this.background,
    this.foreground,
    this.textColor,
    this.margin,
    this.padding,
    this.borderRadius = 16,
    this.iconSize,
    this.showBorder = true,
    this.showIcon = true,
    this.compact = false,
    this.fullWidth = false,
    this.textAlign,
  });

  final String message;
  final String? title;
  final IconData? icon;
  final AppMessageTone tone;
  final Color? background;
  final Color? foreground;
  final Color? textColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double? iconSize;
  final bool showBorder;
  final bool showIcon;
  final bool compact;
  final bool fullWidth;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final Color resolvedForeground = foreground ?? _foregroundFor(tone);
    final Color resolvedBackground = background ?? _backgroundFor(tone);
    final double resolvedIconSize = iconSize ?? (compact ? 18 : 22);

    return Container(
      width: fullWidth ? double.infinity : null,
      margin: margin,
      padding: padding ?? EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: resolvedBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(color: resolvedForeground.withValues(alpha: .18))
            : null,
      ),
      child: Row(
        children: <Widget>[
          if (showIcon) ...<Widget>[
            Icon(
              icon ?? _iconFor(tone),
              size: resolvedIconSize,
              color: resolvedForeground,
            ),
            SizedBox(width: compact ? 10 : 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (title != null) ...<Widget>[
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: compact ? 12 : 13,
                      fontWeight: FontWeight.w900,
                      color: resolvedForeground,
                    ),
                  ),
                  const SizedBox(height: 3),
                ],
                Text(
                  message,
                  textAlign: textAlign,
                  style: TextStyle(
                    fontSize: compact ? 11 : 13,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: textColor ?? AppColors.textMid,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _backgroundFor(AppMessageTone tone) {
    return switch (tone) {
      AppMessageTone.info => AppColors.blueLt,
      AppMessageTone.success => AppColors.greenLt,
      AppMessageTone.warning => AppColors.amberLt,
      AppMessageTone.error => AppColors.redLt,
      AppMessageTone.neutral => AppColors.surface,
    };
  }

  Color _foregroundFor(AppMessageTone tone) {
    return switch (tone) {
      AppMessageTone.info => AppColors.blue,
      AppMessageTone.success => AppColors.green,
      AppMessageTone.warning => AppColors.amber,
      AppMessageTone.error => AppColors.red,
      AppMessageTone.neutral => AppColors.textMute,
    };
  }

  IconData _iconFor(AppMessageTone tone) {
    return switch (tone) {
      AppMessageTone.info => Icons.info_outline_rounded,
      AppMessageTone.success => Icons.check_circle_outline_rounded,
      AppMessageTone.warning => Icons.warning_amber_rounded,
      AppMessageTone.error => Icons.error_outline,
      AppMessageTone.neutral => Icons.info_outline_rounded,
    };
  }
}
