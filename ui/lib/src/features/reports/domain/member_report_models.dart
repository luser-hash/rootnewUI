class MemberStatementFilter {
  const MemberStatementFilter({
    this.fromDate,
    this.toDate,
    this.entryType,
  });

  final DateTime? fromDate;
  final DateTime? toDate;
  final MemberReportEntryType? entryType;

  bool get hasFilters {
    return fromDate != null || toDate != null || entryType != null;
  }

  Map<String, String> toQueryParams() {
    return <String, String>{
      if (fromDate != null) 'from_date': _formatDate(fromDate!),
      if (toDate != null) 'to_date': _formatDate(toDate!),
      if (entryType != null) 'entry_type': entryType!.apiValue,
    };
  }
}

class MemberReportStatement {
  const MemberReportStatement({
    required this.member,
    required this.currentBalance,
    required this.pendingTotal,
    required this.entryCount,
    required this.entries,
    required this.pendingRequests,
  });

  final MemberReportMember? member;
  final String currentBalance;
  final String pendingTotal;
  final int entryCount;
  final List<MemberReportEntry> entries;
  final List<MemberReportPendingRequest> pendingRequests;

  factory MemberReportStatement.fromJson(Map<String, dynamic> json) {
    final Object? member = json['member'];
    final Object? entries = json['entries'];
    final Object? pendingRequests = json['pending_requests'];
    return MemberReportStatement(
      member: member is Map<String, dynamic>
          ? MemberReportMember.fromJson(member)
          : null,
      currentBalance: '${json['current_balance'] ?? '0.00'}',
      pendingTotal: '${json['pending_total'] ?? '0.00'}',
      entryCount: json['entry_count'] is int
          ? json['entry_count'] as int
          : int.tryParse('${json['entry_count'] ?? 0}') ?? 0,
      entries: entries is List<dynamic>
          ? entries
                .whereType<Map<String, dynamic>>()
                .map(MemberReportEntry.fromJson)
                .toList()
          : <MemberReportEntry>[],
      pendingRequests: pendingRequests is List<dynamic>
          ? pendingRequests
                .whereType<Map<String, dynamic>>()
                .map(MemberReportPendingRequest.fromJson)
                .toList()
          : <MemberReportPendingRequest>[],
    );
  }
}

class MemberReportMember {
  const MemberReportMember({
    required this.userId,
    required this.fullName,
    required this.contactNo,
    required this.joinDate,
  });

  final String userId;
  final String fullName;
  final String contactNo;
  final String joinDate;

  factory MemberReportMember.fromJson(Map<String, dynamic> json) {
    return MemberReportMember(
      userId: '${json['user_id'] ?? ''}',
      fullName: '${json['full_name'] ?? ''}',
      contactNo: '${json['contact_no'] ?? ''}',
      joinDate: '${json['join_date'] ?? ''}',
    );
  }
}

class MemberReportEntry {
  const MemberReportEntry({
    required this.ledgerId,
    required this.entryType,
    required this.amount,
    required this.currency,
    required this.txnDate,
    required this.runningBalance,
    required this.referenceType,
    required this.referenceId,
    required this.comment,
    required this.createdAt,
    required this.createdByFullName,
  });

  final String ledgerId;
  final MemberReportEntryType entryType;
  final String amount;
  final String currency;
  final String txnDate;
  final String runningBalance;
  final String referenceType;
  final String referenceId;
  final String comment;
  final DateTime? createdAt;
  final String createdByFullName;

  factory MemberReportEntry.fromJson(Map<String, dynamic> json) {
    return MemberReportEntry(
      ledgerId: '${json['ledger_id'] ?? ''}',
      entryType: MemberReportEntryType.fromApi('${json['entry_type'] ?? ''}'),
      amount: '${json['amount'] ?? '0.00'}',
      currency: '${json['currency'] ?? 'BDT'}',
      txnDate: '${json['txn_date'] ?? ''}',
      runningBalance: '${json['running_balance'] ?? '0.00'}',
      referenceType: '${json['reference_type'] ?? ''}',
      referenceId: '${json['reference_id'] ?? ''}',
      comment: '${json['comment'] ?? ''}',
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}'),
      createdByFullName:
          '${json['created_by__full_name'] ?? json['created_by_name'] ?? ''}',
    );
  }
}

enum MemberReportEntryType {
  submission('SUBMISSION', 'Submission'),
  withdraw('WITHDRAW', 'Withdraw'),
  adjustment('ADJUSTMENT', 'Adjustment'),
  distribution('DISTRIBUTION', 'Distribution'),
  distributionReversal('DISTRIBUTION_REVERSAL', 'Distribution Reversal');

  const MemberReportEntryType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  factory MemberReportEntryType.fromApi(String value) {
    return switch (value.trim().toUpperCase()) {
      'WITHDRAW' => MemberReportEntryType.withdraw,
      'ADJUSTMENT' => MemberReportEntryType.adjustment,
      'DISTRIBUTION' => MemberReportEntryType.distribution,
      'DISTRIBUTION_REVERSAL' => MemberReportEntryType.distributionReversal,
      _ => MemberReportEntryType.submission,
    };
  }
}

class MemberReportPendingRequest {
  const MemberReportPendingRequest({
    required this.requestId,
    required this.requestType,
    required this.amount,
    required this.paymentChannel,
    required this.requestedAt,
  });

  final String requestId;
  final String requestType;
  final String amount;
  final String paymentChannel;
  final DateTime? requestedAt;

  factory MemberReportPendingRequest.fromJson(Map<String, dynamic> json) {
    return MemberReportPendingRequest(
      requestId: '${json['request_id'] ?? ''}',
      requestType: '${json['request_type'] ?? ''}',
      amount: '${json['amount'] ?? '0.00'}',
      paymentChannel: '${json['payment_channel'] ?? ''}',
      requestedAt: DateTime.tryParse('${json['requested_at'] ?? ''}'),
    );
  }
}

class MemberDistributionsReport {
  const MemberDistributionsReport({
    required this.totalReceived,
    required this.distributionCount,
    required this.distributions,
  });

  final String totalReceived;
  final int distributionCount;
  final List<MemberDistributionReportItem> distributions;

  factory MemberDistributionsReport.fromJson(Map<String, dynamic> json) {
    final Object? distributions = json['distributions'];
    return MemberDistributionsReport(
      totalReceived: '${json['total_received'] ?? '0.00'}',
      distributionCount: json['distribution_count'] is int
          ? json['distribution_count'] as int
          : int.tryParse('${json['distribution_count'] ?? 0}') ?? 0,
      distributions: distributions is List<dynamic>
          ? distributions
                .whereType<Map<String, dynamic>>()
                .map(MemberDistributionReportItem.fromJson)
                .toList()
          : <MemberDistributionReportItem>[],
    );
  }
}

class MemberDistributionReportItem {
  const MemberDistributionReportItem({
    required this.distributionId,
    required this.investmentId,
    required this.investmentTitle,
    required this.investmentType,
    required this.pnlAmount,
    required this.distributionStatus,
    required this.ratioUsed,
    required this.shareAmount,
    required this.postedAt,
    required this.postedBy,
    required this.ledgerEntryId,
  });

  final String distributionId;
  final String investmentId;
  final String investmentTitle;
  final String investmentType;
  final String pnlAmount;
  final String distributionStatus;
  final String ratioUsed;
  final String shareAmount;
  final DateTime? postedAt;
  final String postedBy;
  final String ledgerEntryId;

  factory MemberDistributionReportItem.fromJson(Map<String, dynamic> json) {
    return MemberDistributionReportItem(
      distributionId: '${json['distribution_id'] ?? ''}',
      investmentId: '${json['investment_id'] ?? ''}',
      investmentTitle: '${json['investment_title'] ?? ''}',
      investmentType: '${json['investment_type'] ?? ''}',
      pnlAmount: '${json['pnl_amount'] ?? '0.00'}',
      distributionStatus: '${json['distribution_status'] ?? ''}',
      ratioUsed: '${json['ratio_used'] ?? ''}',
      shareAmount: '${json['share_amount'] ?? '0.00'}',
      postedAt: DateTime.tryParse('${json['posted_at'] ?? ''}'),
      postedBy: '${json['posted_by'] ?? ''}',
      ledgerEntryId: '${json['ledger_entry_id'] ?? ''}',
    );
  }
}

String _formatDate(DateTime value) {
  final String month = value.month.toString().padLeft(2, '0');
  final String day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
