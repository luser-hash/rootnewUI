class InvestmentDistributionRecord {
  const InvestmentDistributionRecord({
    required this.distributionId,
    required this.investmentId,
    required this.snapshotId,
    required this.pnlAmount,
    required this.roundedTotal,
    required this.remainderApplied,
    required this.status,
    required this.postedBy,
    required this.postedAt,
    required this.reversedBy,
    required this.reversedAt,
    required this.lines,
  });

  final String distributionId;
  final String investmentId;
  final String snapshotId;
  final String pnlAmount;
  final String roundedTotal;
  final String remainderApplied;
  final InvestmentDistributionStatus status;
  final InvestmentDistributionUser? postedBy;
  final DateTime? postedAt;
  final InvestmentDistributionUser? reversedBy;
  final DateTime? reversedAt;
  final List<InvestmentDistributionLine> lines;
}

enum InvestmentDistributionStatus { posted, reversed }

extension InvestmentDistributionStatusX on InvestmentDistributionStatus {
  String get label {
    return switch (this) {
      InvestmentDistributionStatus.posted => 'POSTED',
      InvestmentDistributionStatus.reversed => 'REVERSED',
    };
  }

  String get displayName {
    return switch (this) {
      InvestmentDistributionStatus.posted => 'Posted',
      InvestmentDistributionStatus.reversed => 'Reversed',
    };
  }
}

class InvestmentDistributionUser {
  const InvestmentDistributionUser({
    required this.userId,
    required this.fullName,
  });

  final String userId;
  final String fullName;
}

class InvestmentDistributionLine {
  const InvestmentDistributionLine({
    required this.distributionLineId,
    required this.userId,
    required this.fullName,
    required this.ratioUsed,
    required this.shareAmount,
    required this.ledgerEntryId,
  });

  final String distributionLineId;
  final String userId;
  final String fullName;
  final String ratioUsed;
  final String shareAmount;
  final String ledgerEntryId;
}
