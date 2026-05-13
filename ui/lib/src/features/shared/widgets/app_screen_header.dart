import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class AppScreenHeader extends StatelessWidget {
  const AppScreenHeader({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.trailing,
    this.bottom,
    this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 24),
    this.gradientColors = const <Color>[AppColors.primary, AppColors.primaryDk],
    this.titleFontSize = 18,
    this.subtitleFontSize = 12,
    this.titleFontWeight = FontWeight.w800,
    this.subtitleFontWeight = FontWeight.w600,
    this.subtitleColor = const Color(0xCCFFFFFF),
    this.iconColor = Colors.white,
    this.iconBackground,
    this.titleBottomGap = 6,
    this.bottomGap = 18,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final Widget? bottom;
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final List<Color> gradientColors;
  final double titleFontSize;
  final double subtitleFontSize;
  final FontWeight titleFontWeight;
  final FontWeight subtitleFontWeight;
  final Color subtitleColor;
  final Color iconColor;
  final Color? iconBackground;
  final double titleBottomGap;
  final double bottomGap;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: child ?? _buildStructuredContent(),
    );
  }

  Widget _buildStructuredContent() {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: <Widget>[
        if (title != null ||
            subtitle != null ||
            icon != null ||
            leading != null ||
            trailing != null)
          _buildTitleRow(),
        if (bottom != null) ...<Widget>[SizedBox(height: bottomGap), bottom!],
      ],
    );
  }

  Widget _buildTitleRow() {
    final Widget titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (title != null)
          Text(
            title!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: titleFontWeight,
              color: Colors.white,
              height: 1.15,
            ),
          ),
        if (subtitle != null) ...<Widget>[
          SizedBox(height: titleBottomGap),
          Text(
            subtitle!,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: subtitleFontSize,
              height: 1.45,
              fontWeight: subtitleFontWeight,
              color: subtitleColor,
            ),
          ),
        ],
      ],
    );

    final Widget? resolvedLeading = leading ?? _buildIcon();

    if (resolvedLeading == null && trailing == null) {
      return titleBlock;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (resolvedLeading != null) ...<Widget>[
          resolvedLeading,
          const SizedBox(width: 10),
        ],
        Expanded(child: titleBlock),
        if (trailing != null) ...<Widget>[const SizedBox(width: 10), trailing!],
      ],
    );
  }

  Widget? _buildIcon() {
    final IconData? value = icon;
    if (value == null) {
      return null;
    }
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: iconBackground ?? Colors.white.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(value, color: iconColor, size: 22),
    );
  }
}

class AppHeaderBackButton extends StatelessWidget {
  const AppHeaderBackButton({
    super.key,
    required this.onPressed,
    this.size = 42,
    this.radius = 10,
    this.icon = Icons.arrow_back_rounded,
  });

  final VoidCallback onPressed;
  final double size;
  final double radius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      tooltip: 'Back',
      style: IconButton.styleFrom(
        backgroundColor: Colors.white24,
        minimumSize: Size(size, size),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class AppHeaderStatsRow extends StatelessWidget {
  const AppHeaderStatsRow({
    super.key,
    required this.stats,
    this.valueFontSize = 16,
    this.horizontalPadding = 12,
    this.verticalPadding = 14,
    this.tileRadius = 14,
    this.tileOpacity = .12,
  });

  final List<AppHeaderStat> stats;
  final double valueFontSize;
  final double horizontalPadding;
  final double verticalPadding;
  final double tileRadius;
  final double tileOpacity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats.map((AppHeaderStat stat) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: stat == stats.last ? 0 : 8,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: tileOpacity),
              borderRadius: BorderRadius.circular(tileRadius),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  stat.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: .55),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class AppHeaderStat {
  const AppHeaderStat({required this.label, required this.value});

  final String label;
  final String value;
}
