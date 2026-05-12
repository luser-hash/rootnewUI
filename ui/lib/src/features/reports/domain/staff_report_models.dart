class AssociationSummaryReport {
  const AssociationSummaryReport({
    required this.generatedAt,
    required this.capital,
    required this.members,
    required this.investments,
    required this.distributions,
    required this.submissions,
  });

  final DateTime? generatedAt;
  final AssociationCapitalSummary capital;
  final AssociationMemberSummary members;
  final AssociationInvestmentSummary investments;
  final AssociationDistributionSummary distributions;
  final AssociationSubmissionSummary submissions;

  factory AssociationSummaryReport.fromJson(Map<String, dynamic> json) {
    return AssociationSummaryReport(
      generatedAt: DateTime.tryParse('${json['generated_at'] ?? ''}'),
      capital: AssociationCapitalSummary.fromJson(_map(json['capital'])),
      members: AssociationMemberSummary.fromJson(_map(json['members'])),
      investments: AssociationInvestmentSummary.fromJson(
        _map(json['investments']),
      ),
      distributions: AssociationDistributionSummary.fromJson(
        _map(json['distributions']),
      ),
      submissions: AssociationSubmissionSummary.fromJson(
        _map(json['submissions']),
      ),
    );
  }
}

class AssociationCapitalSummary {
  const AssociationCapitalSummary({
    required this.totalAuthorized,
    required this.totalPending,
    required this.totalInvested,
  });

  final String totalAuthorized;
  final String totalPending;
  final String totalInvested;

  factory AssociationCapitalSummary.fromJson(Map<String, dynamic> json) {
    return AssociationCapitalSummary(
      totalAuthorized: '${json['total_authorized'] ?? '0.00'}',
      totalPending: '${json['total_pending'] ?? '0.00'}',
      totalInvested: '${json['total_invested'] ?? '0.00'}',
    );
  }
}

class AssociationMemberSummary {
  const AssociationMemberSummary({
    required this.total,
    required this.active,
    required this.inactive,
  });

  final int total;
  final int active;
  final int inactive;

  factory AssociationMemberSummary.fromJson(Map<String, dynamic> json) {
    return AssociationMemberSummary(
      total: _int(json['total']),
      active: _int(json['active']),
      inactive: _int(json['inactive']),
    );
  }
}

class AssociationInvestmentSummary {
  const AssociationInvestmentSummary({
    required this.total,
    required this.draft,
    required this.open,
    required this.closed,
    required this.distributed,
    required this.reversed,
  });

  final int total;
  final int draft;
  final int open;
  final int closed;
  final int distributed;
  final int reversed;

  factory AssociationInvestmentSummary.fromJson(Map<String, dynamic> json) {
    return AssociationInvestmentSummary(
      total: _int(json['total']),
      draft: _int(json['draft']),
      open: _int(json['open']),
      closed: _int(json['closed']),
      distributed: _int(json['distributed']),
      reversed: _int(json['reversed']),
    );
  }
}

class AssociationDistributionSummary {
  const AssociationDistributionSummary({required this.totalPnlDistributed});

  final String totalPnlDistributed;

  factory AssociationDistributionSummary.fromJson(Map<String, dynamic> json) {
    return AssociationDistributionSummary(
      totalPnlDistributed: '${json['total_pnl_distributed'] ?? '0.00'}',
    );
  }
}

class AssociationSubmissionSummary {
  const AssociationSubmissionSummary({
    required this.total,
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  final int total;
  final int pending;
  final int approved;
  final int rejected;

  factory AssociationSubmissionSummary.fromJson(Map<String, dynamic> json) {
    return AssociationSubmissionSummary(
      total: _int(json['total']),
      pending: _int(json['pending']),
      approved: _int(json['approved']),
      rejected: _int(json['rejected']),
    );
  }
}

class StaffMemberBalancesReport {
  const StaffMemberBalancesReport({
    required this.totalCapital,
    required this.memberCount,
    required this.members,
  });

  final String totalCapital;
  final int memberCount;
  final List<StaffMemberBalance> members;

  factory StaffMemberBalancesReport.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw = json['members'] is List<dynamic>
        ? json['members'] as List<dynamic>
        : <dynamic>[];
    return StaffMemberBalancesReport(
      totalCapital: '${json['total_capital'] ?? '0.00'}',
      memberCount: _int(json['member_count']),
      members: raw
          .whereType<Map<String, dynamic>>()
          .map(StaffMemberBalance.fromJson)
          .toList(),
    );
  }
}

class StaffMemberBalance {
  const StaffMemberBalance({
    required this.userId,
    required this.fullName,
    required this.contactNo,
    required this.email,
    required this.joinDate,
    required this.role,
    required this.status,
    required this.balance,
  });

  final String userId;
  final String fullName;
  final String contactNo;
  final String email;
  final String joinDate;
  final String role;
  final String status;
  final String balance;

  factory StaffMemberBalance.fromJson(Map<String, dynamic> json) {
    return StaffMemberBalance(
      userId: '${json['user_id'] ?? ''}',
      fullName: '${json['full_name'] ?? ''}',
      contactNo: '${json['contact_no'] ?? ''}',
      email: '${json['email'] ?? ''}',
      joinDate: '${json['join_date'] ?? ''}',
      role: '${json['role'] ?? ''}',
      status: '${json['status'] ?? ''}',
      balance: '${json['balance'] ?? '0.00'}',
    );
  }
}

class StaffInvestmentRegisterReport {
  const StaffInvestmentRegisterReport({
    required this.investmentCount,
    required this.investments,
  });

  final int investmentCount;
  final List<StaffInvestmentRegisterItem> investments;

  factory StaffInvestmentRegisterReport.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw = json['investments'] is List<dynamic>
        ? json['investments'] as List<dynamic>
        : <dynamic>[];
    return StaffInvestmentRegisterReport(
      investmentCount: _int(json['investment_count']),
      investments: raw
          .whereType<Map<String, dynamic>>()
          .map(StaffInvestmentRegisterItem.fromJson)
          .toList(),
    );
  }
}

class StaffInvestmentRegisterItem {
  const StaffInvestmentRegisterItem({
    required this.investmentId,
    required this.title,
    required this.investmentType,
    required this.investedTo,
    required this.investedAmount,
    required this.returnAmount,
    required this.pnlAmount,
    required this.createdDate,
    required this.closeDate,
    required this.status,
    required this.memberCount,
    required this.createdBy,
    required this.fundReleasedBy,
    required this.fundReleasedAt,
  });

  final String investmentId;
  final String title;
  final String investmentType;
  final String investedTo;
  final String investedAmount;
  final String returnAmount;
  final String pnlAmount;
  final String createdDate;
  final String closeDate;
  final String status;
  final int memberCount;
  final String createdBy;
  final String fundReleasedBy;
  final DateTime? fundReleasedAt;

  factory StaffInvestmentRegisterItem.fromJson(Map<String, dynamic> json) {
    return StaffInvestmentRegisterItem(
      investmentId: '${json['investment_id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      investmentType: '${json['investment_type'] ?? ''}',
      investedTo: '${json['invested_to'] ?? ''}',
      investedAmount: '${json['invested_amount'] ?? '0.00'}',
      returnAmount: '${json['return_amount'] ?? '0.00'}',
      pnlAmount: '${json['pnl_amount'] ?? '0.00'}',
      createdDate: '${json['created_date'] ?? ''}',
      closeDate: '${json['close_date'] ?? ''}',
      status: '${json['status'] ?? ''}',
      memberCount: _int(json['member_count']),
      createdBy: _person(json['created_by']),
      fundReleasedBy: _person(json['fund_released_by']),
      fundReleasedAt: DateTime.tryParse('${json['fund_released_at'] ?? ''}'),
    );
  }
}

class StaffDistributionLogsReport {
  const StaffDistributionLogsReport({
    required this.distributionCount,
    required this.distributions,
  });

  final int distributionCount;
  final List<StaffDistributionLogItem> distributions;

  factory StaffDistributionLogsReport.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw = json['distributions'] is List<dynamic>
        ? json['distributions'] as List<dynamic>
        : <dynamic>[];
    return StaffDistributionLogsReport(
      distributionCount: _int(json['distribution_count']),
      distributions: raw
          .whereType<Map<String, dynamic>>()
          .map(StaffDistributionLogItem.fromJson)
          .toList(),
    );
  }
}

class StaffDistributionLogItem {
  const StaffDistributionLogItem({
    required this.distributionId,
    required this.investmentTitle,
    required this.pnlAmount,
    required this.roundedTotal,
    required this.remainderApplied,
    required this.status,
    required this.postedBy,
    required this.postedAt,
    required this.reversedBy,
    required this.reversedAt,
    required this.memberCount,
    required this.lines,
  });

  final String distributionId;
  final String investmentTitle;
  final String pnlAmount;
  final String roundedTotal;
  final String remainderApplied;
  final String status;
  final String postedBy;
  final DateTime? postedAt;
  final String reversedBy;
  final DateTime? reversedAt;
  final int memberCount;
  final List<StaffDistributionLine> lines;

  factory StaffDistributionLogItem.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw = json['lines'] is List<dynamic>
        ? json['lines'] as List<dynamic>
        : <dynamic>[];
    return StaffDistributionLogItem(
      distributionId: '${json['distribution_id'] ?? ''}',
      investmentTitle: '${json['investment_title'] ?? ''}',
      pnlAmount: '${json['pnl_amount'] ?? '0.00'}',
      roundedTotal: '${json['rounded_total'] ?? '0.00'}',
      remainderApplied: '${json['remainder_applied'] ?? '0.00'}',
      status: '${json['status'] ?? ''}',
      postedBy: _person(json['posted_by']),
      postedAt: DateTime.tryParse('${json['posted_at'] ?? ''}'),
      reversedBy: _person(json['reversed_by']),
      reversedAt: DateTime.tryParse('${json['reversed_at'] ?? ''}'),
      memberCount: _int(json['member_count']),
      lines: raw
          .whereType<Map<String, dynamic>>()
          .map(StaffDistributionLine.fromJson)
          .toList(),
    );
  }
}

class StaffDistributionLine {
  const StaffDistributionLine({
    required this.fullName,
    required this.ratioUsed,
    required this.shareAmount,
    required this.ledgerEntryId,
  });

  final String fullName;
  final String ratioUsed;
  final String shareAmount;
  final String ledgerEntryId;

  factory StaffDistributionLine.fromJson(Map<String, dynamic> json) {
    return StaffDistributionLine(
      fullName: '${json['full_name'] ?? json['member_name'] ?? ''}',
      ratioUsed: '${json['ratio_used'] ?? ''}',
      shareAmount: '${json['share_amount'] ?? '0.00'}',
      ledgerEntryId: '${json['ledger_entry_id'] ?? ''}',
    );
  }
}

class StaffApprovalQueueReport {
  const StaffApprovalQueueReport({
    required this.totalPendingAmount,
    required this.totalPendingCount,
    required this.byChannel,
    required this.items,
  });

  final String totalPendingAmount;
  final int totalPendingCount;
  final Map<String, StaffApprovalChannelSummary> byChannel;
  final List<StaffApprovalQueueItem> items;

  factory StaffApprovalQueueReport.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> rawChannels = _map(json['by_channel']);
    final List<dynamic> rawItems = json['items'] is List<dynamic>
        ? json['items'] as List<dynamic>
        : <dynamic>[];
    return StaffApprovalQueueReport(
      totalPendingAmount: '${json['total_pending_amount'] ?? '0.00'}',
      totalPendingCount: _int(json['total_pending_count']),
      byChannel: rawChannels.map(
        (String key, dynamic value) =>
            MapEntry<String, StaffApprovalChannelSummary>(
              key,
              StaffApprovalChannelSummary.fromJson(_map(value)),
            ),
      ),
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(StaffApprovalQueueItem.fromJson)
          .toList(),
    );
  }
}

class StaffApprovalChannelSummary {
  const StaffApprovalChannelSummary({
    required this.count,
    required this.totalAmount,
  });

  final int count;
  final String totalAmount;

  factory StaffApprovalChannelSummary.fromJson(Map<String, dynamic> json) {
    return StaffApprovalChannelSummary(
      count: _int(json['count']),
      totalAmount: '${json['total_amount'] ?? '0.00'}',
    );
  }
}

class StaffApprovalQueueItem {
  const StaffApprovalQueueItem({
    required this.requestId,
    required this.memberName,
    required this.memberContact,
    required this.requestType,
    required this.amount,
    required this.txnDate,
    required this.paymentChannel,
    required this.externalReference,
    required this.notes,
    required this.requestedAt,
    required this.attachmentCount,
  });

  final String requestId;
  final String memberName;
  final String memberContact;
  final String requestType;
  final String amount;
  final String txnDate;
  final String paymentChannel;
  final String externalReference;
  final String notes;
  final DateTime? requestedAt;
  final int attachmentCount;

  factory StaffApprovalQueueItem.fromJson(Map<String, dynamic> json) {
    return StaffApprovalQueueItem(
      requestId: '${json['request_id'] ?? ''}',
      memberName: '${json['member_name'] ?? ''}',
      memberContact: '${json['member_contact'] ?? ''}',
      requestType: '${json['request_type'] ?? ''}',
      amount: '${json['amount'] ?? '0.00'}',
      txnDate: '${json['txn_date'] ?? ''}',
      paymentChannel: '${json['payment_channel'] ?? ''}',
      externalReference: '${json['external_reference'] ?? ''}',
      notes: '${json['notes'] ?? ''}',
      requestedAt: DateTime.tryParse('${json['requested_at'] ?? ''}'),
      attachmentCount: _int(json['attachment_count']),
    );
  }
}

Map<String, dynamic> _map(Object? value) {
  return value is Map<String, dynamic> ? value : <String, dynamic>{};
}

int _int(Object? value) {
  return value is int ? value : int.tryParse('$value') ?? 0;
}

String _person(Object? value) {
  if (value == null) {
    return '';
  }
  if (value is Map<String, dynamic>) {
    return '${value['full_name'] ?? value['name'] ?? ''}';
  }
  return '$value';
}
