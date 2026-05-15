part of 'member_detail_screen.dart';

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: dark ? 0 : 0);
  }
}

bool _isApprovedHistory(SubmissionHistoryItem submission) {
  return submission.isApproved;
}

String _submissionMeta(SubmissionHistoryItem submission) {
  return '${submission.paymentChannel.label} · ${valueOrDash(submission.txnDate)}';
}

Color _submissionStatusBackground(
  BuildContext context,
  CapitalSubmissionStatus status,
) {
  return switch (status) {
    CapitalSubmissionStatus.pending => AppThemeColors.statusWarningBg(context),
    CapitalSubmissionStatus.approved => AppThemeColors.statusSuccessBg(context),
    CapitalSubmissionStatus.rejected => AppThemeColors.statusErrorBg(context),
  };
}

Color _submissionStatusForeground(
  BuildContext context,
  CapitalSubmissionStatus status,
) {
  return switch (status) {
    CapitalSubmissionStatus.pending => AppThemeColors.statusWarningFg(context),
    CapitalSubmissionStatus.approved => AppThemeColors.statusSuccessFg(context),
    CapitalSubmissionStatus.rejected => AppThemeColors.statusErrorFg(context),
  };
}

IconData _submissionStatusIcon(CapitalSubmissionStatus status) {
  return switch (status) {
    CapitalSubmissionStatus.pending => Icons.schedule_rounded,
    CapitalSubmissionStatus.approved => Icons.check_rounded,
    CapitalSubmissionStatus.rejected => Icons.close_rounded,
  };
}

Color _ledgerEntryBackground(BuildContext context, MemberLedgerEntryType type) {
  return switch (type) {
    MemberLedgerEntryType.submission => AppThemeColors.statusSuccessBg(context),
    MemberLedgerEntryType.withdraw => AppThemeColors.statusErrorBg(context),
    MemberLedgerEntryType.adjustment => AppThemeColors.statusWarningBg(context),
    MemberLedgerEntryType.distribution => AppThemeColors.statusInfoBg(context),
    MemberLedgerEntryType.distributionReversal => AppThemeColors.statusErrorBg(
      context,
    ),
  };
}

Color _ledgerEntryForeground(BuildContext context, MemberLedgerEntryType type) {
  return switch (type) {
    MemberLedgerEntryType.submission => AppThemeColors.statusSuccessFg(context),
    MemberLedgerEntryType.withdraw => AppThemeColors.statusErrorFg(context),
    MemberLedgerEntryType.adjustment => AppThemeColors.statusWarningFg(context),
    MemberLedgerEntryType.distribution => AppThemeColors.statusInfoFg(context),
    MemberLedgerEntryType.distributionReversal => AppThemeColors.statusErrorFg(
      context,
    ),
  };
}

IconData _ledgerEntryIcon(MemberLedgerEntryType type) {
  return switch (type) {
    MemberLedgerEntryType.submission => Icons.south_rounded,
    MemberLedgerEntryType.withdraw => Icons.north_rounded,
    MemberLedgerEntryType.adjustment => Icons.tune_rounded,
    MemberLedgerEntryType.distribution => Icons.call_split_rounded,
    MemberLedgerEntryType.distributionReversal => Icons.undo_rounded,
  };
}

bool _isLedgerInflow(MemberLedgerEntryType type, double amount) {
  if (amount < 0) {
    return false;
  }
  return switch (type) {
    MemberLedgerEntryType.withdraw => false,
    MemberLedgerEntryType.distributionReversal => false,
    _ => true,
  };
}
