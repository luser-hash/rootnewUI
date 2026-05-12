import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/finance_models.dart';

class AppStatusPill extends StatelessWidget {
  const AppStatusPill({
    super.key,
    required this.label,
    this.background,
    this.foreground,
    this.color,
    this.strike = false,
    this.showBorder = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.fontSize = 11,
    this.fontWeight = FontWeight.w700,
    this.textHeight = 1,
  });

  final String label;
  final Color? background;
  final Color? foreground;
  final Color? color;
  final bool strike;
  final bool showBorder;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final FontWeight fontWeight;
  final double? textHeight;

  @override
  Widget build(BuildContext context) {
    final ({Color background, Color foreground}) statusColors =
        appStatusPillColors(label);
    final Color resolvedForeground =
        foreground ?? color ?? statusColors.foreground;
    final Color resolvedBackground =
        background ??
        (color == null
            ? statusColors.background
            : resolvedForeground.withValues(alpha: .12));

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: resolvedBackground,
        borderRadius: BorderRadius.circular(999),
        border: showBorder
            ? Border.all(color: resolvedForeground.withValues(alpha: .2))
            : null,
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: resolvedForeground,
          height: textHeight,
          decoration: strike ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }
}

class SubmissionStatusPill extends StatelessWidget {
  const SubmissionStatusPill({super.key, required this.status, this.strike});

  final SubmissionStatus status;
  final bool? strike;

  @override
  Widget build(BuildContext context) {
    final ({Color background, Color foreground}) colors = appStatusPillColors(
      status.label,
    );
    return AppStatusPill(
      label: status.label,
      background: colors.background,
      foreground: colors.foreground,
      strike: strike ?? false,
    );
  }
}

class InvestmentStatusPill extends StatelessWidget {
  const InvestmentStatusPill({super.key, required this.status, this.strike});

  final InvestmentStatus status;
  final bool? strike;

  @override
  Widget build(BuildContext context) {
    final ({Color background, Color foreground}) colors = appStatusPillColors(
      status.label,
    );
    return AppStatusPill(
      label: status.label,
      background: colors.background,
      foreground: colors.foreground,
      strike: strike ?? status == InvestmentStatus.reversed,
    );
  }
}

class MemberStatusPill extends StatelessWidget {
  const MemberStatusPill({super.key, required this.status});

  final MemberStatus status;

  @override
  Widget build(BuildContext context) {
    final ({Color background, Color foreground}) colors = appStatusPillColors(
      status.label,
    );
    return AppStatusPill(
      label: status.label,
      background: colors.background,
      foreground: colors.foreground,
    );
  }
}

({Color background, Color foreground}) appStatusPillColors(String status) {
  return switch (status.trim().toUpperCase()) {
    'PENDING' || 'DRAFT' => (
      background: AppColors.amberLt,
      foreground: AppColors.amber,
    ),
    'APPROVED' || 'ACTIVE' || 'OPEN' || 'POSTED' => (
      background: AppColors.greenLt,
      foreground: AppColors.green,
    ),
    'REJECTED' || 'REVERSED' => (
      background: AppColors.redLt,
      foreground: AppColors.red,
    ),
    'DISTRIBUTED' => (
      background: AppColors.blueLt,
      foreground: AppColors.blue,
    ),
    'CLOSED' || 'INACTIVE' => (
      background: AppColors.surface,
      foreground: AppColors.textMute,
    ),
    _ => (background: AppColors.surface, foreground: AppColors.textMute),
  };
}
