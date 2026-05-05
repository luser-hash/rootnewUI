import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/finance_models.dart';
import 'app_pill.dart';

class SubmissionStatusPill extends StatelessWidget {
  const SubmissionStatusPill({super.key, required this.status});

  final SubmissionStatus status;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (status) {
      SubmissionStatus.pending => (AppColors.amberLt, AppColors.amber),
      SubmissionStatus.approved => (AppColors.greenLt, AppColors.green),
      SubmissionStatus.rejected => (AppColors.redLt, AppColors.red),
    };
    return AppPill(label: status.label, background: bg, foreground: fg);
  }
}

class InvestmentStatusPill extends StatelessWidget {
  const InvestmentStatusPill({super.key, required this.status});

  final InvestmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (status) {
      InvestmentStatus.open => (AppColors.greenLt, AppColors.green),
      InvestmentStatus.draft => (AppColors.amberLt, AppColors.amber),
      InvestmentStatus.closed => (AppColors.surface, AppColors.textMute),
      InvestmentStatus.distributed => (AppColors.blueLt, AppColors.blue),
    };
    return AppPill(label: status.label, background: bg, foreground: fg);
  }
}

class MemberStatusPill extends StatelessWidget {
  const MemberStatusPill({super.key, required this.status});

  final MemberStatus status;

  @override
  Widget build(BuildContext context) {
    return AppPill(
      label: status.label,
      background: status == MemberStatus.active
          ? AppColors.greenLt
          : AppColors.surface,
      foreground: status == MemberStatus.active
          ? AppColors.green
          : AppColors.textMute,
    );
  }
}
