import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../finance.dart';

class AppDetailBlock extends StatelessWidget {
  const AppDetailBlock({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.background,
    this.borderColor,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 12,
    this.selectable = false,
    this.valueColor,
    this.valueMaxLines,
    this.valueOverflow = TextOverflow.ellipsis,
    this.fullWidth = false,
    this.center = false,
    this.labelWeight = FontWeight.w600,
    this.valueWeight = FontWeight.w700,
    this.valueFontSize = 12,
    this.labelFontSize = 10,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? background;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool selectable;
  final Color? valueColor;
  final int? valueMaxLines;
  final TextOverflow valueOverflow;
  final bool fullWidth;
  final bool center;
  final FontWeight labelWeight;
  final FontWeight valueWeight;
  final double valueFontSize;
  final double labelFontSize;

  @override
  Widget build(BuildContext context) {
    final String displayValue = valueOrDash(value);
    final Color resolvedValueColor = valueColor ?? AppThemeColors.text(context);
    final Color mutedText = AppThemeColors.textMuted(context);

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: center
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 14, color: mutedText),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: labelFontSize,
                    fontWeight: labelWeight,
                    color: mutedText,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          selectable
              ? SelectableText(
                  displayValue,
                  style: TextStyle(
                    fontSize: valueFontSize,
                    height: 1.35,
                    fontWeight: valueWeight,
                    color: resolvedValueColor,
                  ),
                )
              : Text(
                  displayValue,
                  maxLines: valueMaxLines,
                  overflow: valueOverflow,
                  style: TextStyle(
                    fontSize: valueFontSize,
                    height: 1.35,
                    fontWeight: valueWeight,
                    color: resolvedValueColor,
                  ),
                ),
        ],
      ),
    );
  }
}
