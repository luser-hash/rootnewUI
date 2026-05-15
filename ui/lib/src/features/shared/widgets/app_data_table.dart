import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../finance.dart';

class AppTableHeader extends StatelessWidget {
  const AppTableHeader({
    super.key,
    required this.cells,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.background,
    this.borderColor,
    this.expandCells = true,
  });

  final List<Widget> cells;
  final EdgeInsetsGeometry padding;
  final Color? background;
  final Color? borderColor;
  final bool expandCells;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? AppThemeColors.surface(context),
        border: Border(
          top: BorderSide(color: borderColor ?? AppThemeColors.border(context)),
        ),
      ),
      child: Row(
        children: expandCells
            ? cells.map((Widget cell) => Expanded(child: cell)).toList()
            : cells,
      ),
    );
  }
}

class AppTableRow extends StatelessWidget {
  const AppTableRow({
    super.key,
    required this.cells,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.background,
    this.borderColor,
    this.showTopBorder = true,
    this.showBottomBorder = false,
    this.expandCells = true,
  });

  final List<Widget> cells;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? background;
  final Color? borderColor;
  final bool showTopBorder;
  final bool showBottomBorder;
  final bool expandCells;

  @override
  Widget build(BuildContext context) {
    final Color resolvedBorder = borderColor ?? AppThemeColors.border(context);

    return Material(
      color: background ?? AppThemeColors.card(context),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            border: Border(
              top: showTopBorder
                  ? BorderSide(color: resolvedBorder)
                  : BorderSide.none,
              bottom: showBottomBorder
                  ? BorderSide(color: resolvedBorder)
                  : BorderSide.none,
            ),
          ),
          child: Row(
            children: expandCells
                ? cells.map((Widget cell) => Expanded(child: cell)).toList()
                : cells,
          ),
        ),
      ),
    );
  }
}

class AppHeaderCell extends StatelessWidget {
  const AppHeaderCell(this.text, {super.key, this.textAlign});

  final String text;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: AppThemeColors.textMuted(context),
      ),
    );
  }
}

class AppTextCell extends StatelessWidget {
  const AppTextCell(
    this.value, {
    super.key,
    this.color,
    this.maxLines = 2,
    this.mono = false,
    this.textAlign,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w800,
  });

  final String value;
  final Color? color;
  final int maxLines;
  final bool mono;
  final TextAlign? textAlign;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      valueOrDash(value),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize,
        height: 1.25,
        fontWeight: fontWeight,
        color: color ?? AppThemeColors.text(context),
        fontFeatures: mono
            ? const <FontFeature>[FontFeature.tabularFigures()]
            : null,
      ),
    );
  }
}

class AppMoneyCell extends StatelessWidget {
  const AppMoneyCell(
    this.value, {
    super.key,
    this.color,
    this.textAlign = TextAlign.end,
    this.signed = true,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w900,
  });

  final String value;
  final Color? color;
  final TextAlign textAlign;
  final bool signed;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      signed
          ? formatMoneyTextSigned(value)
          : formatMoneyUnsigned(num.tryParse(value) ?? 0),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? AppThemeColors.text(context),
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      ),
    );
  }
}

class AppSortableHeaderCell<T> extends StatelessWidget {
  const AppSortableHeaderCell({
    super.key,
    required this.text,
    required this.field,
    required this.active,
    required this.ascending,
    required this.onTap,
    this.alignEnd = false,
  });

  final String text;
  final T field;
  final T active;
  final bool ascending;
  final ValueChanged<T> onTap;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final bool selected = field == active;
    final Color activeColor = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: () => onTap(field),
      child: Row(
        mainAxisAlignment: alignEnd
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: <Widget>[
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: selected ? activeColor : AppThemeColors.textMuted(context),
            ),
          ),
          if (selected)
            Icon(
              ascending
                  ? Icons.arrow_drop_up_rounded
                  : Icons.arrow_drop_down_rounded,
              size: 18,
              color: activeColor,
            ),
        ],
      ),
    );
  }
}
