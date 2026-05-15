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

Color _submissionStatusBackground(CapitalSubmissionStatus status) {
  return switch (status) {
    CapitalSubmissionStatus.pending => AppColors.amberLt,
    CapitalSubmissionStatus.approved => AppColors.greenLt,
    CapitalSubmissionStatus.rejected => AppColors.redLt,
  };
}

Color _submissionStatusForeground(CapitalSubmissionStatus status) {
  return switch (status) {
    CapitalSubmissionStatus.pending => AppColors.amber,
    CapitalSubmissionStatus.approved => AppColors.green,
    CapitalSubmissionStatus.rejected => AppColors.red,
  };
}

IconData _submissionStatusIcon(CapitalSubmissionStatus status) {
  return switch (status) {
    CapitalSubmissionStatus.pending => Icons.schedule_rounded,
    CapitalSubmissionStatus.approved => Icons.check_rounded,
    CapitalSubmissionStatus.rejected => Icons.close_rounded,
  };
}

Color _ledgerEntryBackground(MemberLedgerEntryType type) {
  return switch (type) {
    MemberLedgerEntryType.submission => AppColors.greenLt,
    MemberLedgerEntryType.withdraw => AppColors.redLt,
    MemberLedgerEntryType.adjustment => AppColors.amberLt,
    MemberLedgerEntryType.distribution => AppColors.blueLt,
    MemberLedgerEntryType.distributionReversal => AppColors.redLt,
  };
}

Color _ledgerEntryForeground(MemberLedgerEntryType type) {
  return switch (type) {
    MemberLedgerEntryType.submission => AppColors.green,
    MemberLedgerEntryType.withdraw => AppColors.red,
    MemberLedgerEntryType.adjustment => AppColors.amber,
    MemberLedgerEntryType.distribution => AppColors.blue,
    MemberLedgerEntryType.distributionReversal => AppColors.red,
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

String _formatMoney(String? value) {
  final double amount = double.tryParse(value ?? '0') ?? 0;
  return '৳${amount.abs().toStringAsFixed(2)}';
}
