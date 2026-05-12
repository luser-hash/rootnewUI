import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../finance.dart';

class AppDetailRow extends StatelessWidget {
  const AppDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.isLast = false,
    this.valueColor = AppColors.text,
    this.labelWidth,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.iconBackground = AppColors.greenLt,
    this.iconColor = AppColors.primary,
    this.showDivider = true,
    this.valueTextAlign = TextAlign.start,
    this.valueMaxLines = 1,
    this.labelExpanded = false,
    this.valueWeight = FontWeight.w800,
  });

  final String label;
  final String value;
  final IconData? icon;
  final bool isLast;
  final Color valueColor;
  final double? labelWidth;
  final EdgeInsetsGeometry padding;
  final Color iconBackground;
  final Color iconColor;
  final bool showDivider;
  final TextAlign valueTextAlign;
  final int? valueMaxLines;
  final bool labelExpanded;
  final FontWeight valueWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        border: Border(
          bottom: showDivider && !isLast
              ? const BorderSide(color: AppColors.border)
              : BorderSide.none,
        ),
      ),
      child: icon == null ? _buildPlainRow() : _buildIconRow(),
    );
  }

  Widget _buildPlainRow() {
    final Widget labelWidget = Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textMute,
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (labelExpanded)
          Expanded(child: labelWidget)
        else
          SizedBox(width: labelWidth ?? 116, child: labelWidget),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            valueOrDash(value),
            maxLines: valueMaxLines,
            overflow: TextOverflow.ellipsis,
            textAlign: valueTextAlign,
            style: TextStyle(
              fontSize: labelExpanded ? 13 : 12,
              height: 1.35,
              fontWeight: valueWeight,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconRow() {
    return Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMute,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                valueOrDash(value),
                maxLines: valueMaxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: valueWeight,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
