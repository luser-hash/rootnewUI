import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../finance.dart';

class AppMetricCard extends StatelessWidget {
  const AppMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.color = AppColors.text,
    this.background = AppColors.white,
    this.borderColor,
    this.borderRadius = 16,
    this.boxShadow,
    this.icon,
    this.iconText,
    this.iconBackground,
    this.padding = const EdgeInsets.all(14),
    this.labelMaxLines = 2,
    this.valueMaxLines = 1,
    this.labelStyle,
    this.valueStyle,
    this.iconSize = 20,
    this.spacing = 8,
    this.horizontal = false,
    this.uppercaseLabel = true,
    this.valueFirst = false,
    this.onTap,
  }) : assert(icon == null || iconText == null);

  final String label;
  final String value;
  final Color color;
  final Color background;
  final Color? borderColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final IconData? icon;
  final String? iconText;
  final Color? iconBackground;
  final EdgeInsetsGeometry padding;
  final int labelMaxLines;
  final int valueMaxLines;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final double iconSize;
  final double spacing;
  final bool horizontal;
  final bool uppercaseLabel;
  final bool valueFirst;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(borderRadius);
    final Widget labelText = Text(
      uppercaseLabel ? label.toUpperCase() : label,
      maxLines: labelMaxLines,
      overflow: TextOverflow.ellipsis,
      style:
          labelStyle ??
          const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.textMute,
            letterSpacing: 0.4,
          ),
    );
    final Widget valueText = Text(
      value,
      maxLines: valueMaxLines,
      overflow: TextOverflow.ellipsis,
      style:
          valueStyle ??
          TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
    );
    final Widget textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: valueFirst
          ? <Widget>[valueText, labelText]
          : <Widget>[labelText, const SizedBox(height: 6), valueText],
    );
    final Widget? leading = icon == null && iconText == null
        ? null
        : _MetricIcon(
            icon: icon,
            iconText: iconText,
            color: color,
            background: iconBackground,
            size: iconSize,
          );
    final Widget content = Padding(
      padding: padding,
      child: horizontal && leading != null
          ? Row(
              children: <Widget>[
                leading,
                SizedBox(width: spacing),
                Expanded(child: textContent),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (leading != null) ...<Widget>[
                  leading,
                  SizedBox(height: spacing),
                ],
                textContent,
              ],
            ),
    );

    if (onTap == null) {
      return Container(decoration: _decoration(radius), child: content);
    }

    return Material(
      color: background,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(decoration: _decoration(radius), child: content),
      ),
    );
  }

  BoxDecoration _decoration(BorderRadius radius) {
    return BoxDecoration(
      color: onTap == null ? background : Colors.transparent,
      borderRadius: radius,
      border: borderColor == null ? null : Border.all(color: borderColor!),
      boxShadow: boxShadow,
    );
  }
}

class AppMoneyMetricCard extends StatelessWidget {
  const AppMoneyMetricCard({
    super.key,
    required this.label,
    this.value,
    this.textValue,
    this.color = AppColors.text,
    this.background = AppColors.white,
    this.borderColor = AppColors.border,
    this.icon,
    this.padding = const EdgeInsets.all(14),
    this.signed = true,
    this.textValueIsFormattedMoney = true,
    this.onTap,
  });

  final String label;
  final num? value;
  final String? textValue;
  final Color color;
  final Color background;
  final Color? borderColor;
  final IconData? icon;
  final EdgeInsetsGeometry padding;
  final bool signed;
  final bool textValueIsFormattedMoney;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String displayValue = textValue == null
        ? (signed
              ? formatMoneySigned(value ?? 0)
              : formatMoneyUnsigned(value ?? 0))
        : textValueIsFormattedMoney
        ? formatMoneyTextSigned(textValue!)
        : textValue!;

    return AppMetricCard(
      label: label,
      value: displayValue,
      color: color,
      background: background,
      borderColor: borderColor,
      boxShadow: borderColor == null
          ? null
          : <BoxShadow>[AppColors.softShadow(opacity: 0.08, blur: 10)],
      icon: icon,
      padding: padding,
      onTap: onTap,
    );
  }
}

class _MetricIcon extends StatelessWidget {
  const _MetricIcon({
    required this.icon,
    required this.iconText,
    required this.color,
    required this.background,
    required this.size,
  });

  final IconData? icon;
  final String? iconText;
  final Color color;
  final Color? background;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (background == null) {
      if (icon != null) {
        return Icon(icon, color: color, size: size);
      }
      return Text(iconText!, style: TextStyle(fontSize: size));
    }

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: icon != null
          ? Icon(icon, color: color, size: size)
          : Text(iconText!, style: TextStyle(fontSize: size)),
    );
  }
}
