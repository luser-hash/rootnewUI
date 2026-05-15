enum MemberLedgerEntryType {
  submission('SUBMISSION', 'Submission'),
  withdraw('WITHDRAW', 'Withdraw'),
  adjustment('ADJUSTMENT', 'Adjustment'),
  distribution('DISTRIBUTION', 'Distribution'),
  distributionReversal('DISTRIBUTION_REVERSAL', 'Distribution Reversal');

  const MemberLedgerEntryType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  factory MemberLedgerEntryType.fromApi(String? value) {
    return switch (value?.trim().toUpperCase()) {
      'WITHDRAW' => MemberLedgerEntryType.withdraw,
      'ADJUSTMENT' => MemberLedgerEntryType.adjustment,
      'DISTRIBUTION' => MemberLedgerEntryType.distribution,
      'DISTRIBUTION_REVERSAL' => MemberLedgerEntryType.distributionReversal,
      _ => MemberLedgerEntryType.submission,
    };
  }
}

class AdminLedgerPostRequest {
  const AdminLedgerPostRequest({
    required this.contactNo,
    required this.entryType,
    required this.amount,
    required this.txnDate,
    required this.comment,
    required this.referenceId,
  });

  final String contactNo;
  final MemberLedgerEntryType entryType;
  final String amount;
  final DateTime txnDate;
  final String comment;
  final String referenceId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'contact_no': contactNo,
      'entry_type': entryType.apiValue,
      'amount': amount,
      'txn_date': _formatDate(txnDate),
      'comment': comment,
      'reference_id': referenceId,
    };
  }

  String _formatDate(DateTime value) {
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class AdminLedgerPostResult {
  const AdminLedgerPostResult({required this.entry, required this.newBalance});

  final MemberLedgerEntry? entry;
  final String newBalance;

  factory AdminLedgerPostResult.fromJson(Map<String, dynamic> json) {
    final Object? entry = json['entry'];
    return AdminLedgerPostResult(
      entry: entry is Map<String, dynamic>
          ? MemberLedgerEntry.fromJson(entry)
          : null,
      newBalance: '${json['new_balance'] ?? '0.00'}',
    );
  }
}

class MemberLedgerFilter {
  const MemberLedgerFilter({
    this.entryType,
    this.fromDate,
    this.toDate,
    this.userId,
  });

  final MemberLedgerEntryType? entryType;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? userId;

  bool get hasFilters {
    return entryType != null ||
        fromDate != null ||
        toDate != null ||
        (userId?.trim().isNotEmpty ?? false);
  }

  Map<String, String> toQueryParams() {
    return <String, String>{
      if (entryType != null) 'entry_type': entryType!.apiValue,
      if (fromDate != null) 'from_date': _formatDate(fromDate!),
      if (toDate != null) 'to_date': _formatDate(toDate!),
      if (userId?.trim().isNotEmpty ?? false) 'user_id': userId!.trim(),
    };
  }

  String _formatDate(DateTime value) {
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class AdminLedgerStatement {
  const AdminLedgerStatement({
    required this.totalIn,
    required this.totalOut,
    required this.entryCount,
    required this.entries,
  });

  final String totalIn;
  final String totalOut;
  final int entryCount;
  final List<MemberLedgerEntry> entries;

  factory AdminLedgerStatement.fromJson(Map<String, dynamic> json) {
    final Object? entries = json['entries'];
    return AdminLedgerStatement(
      totalIn: '${json['total_in'] ?? '0.00'}',
      totalOut: '${json['total_out'] ?? '0.00'}',
      entryCount: json['entry_count'] is int
          ? json['entry_count'] as int
          : int.tryParse('${json['entry_count'] ?? 0}') ?? 0,
      entries: entries is List<dynamic>
          ? entries
                .whereType<Map<String, dynamic>>()
                .map(MemberLedgerEntry.fromJson)
                .toList()
          : <MemberLedgerEntry>[],
    );
  }
}

class MemberLedgerStatement {
  const MemberLedgerStatement({
    required this.user,
    required this.currentBalance,
    required this.pendingTotal,
    required this.entryCount,
    required this.entries,
  });

  final MemberLedgerUser? user;
  final String currentBalance;
  final String pendingTotal;
  final int entryCount;
  final List<MemberLedgerEntry> entries;

  factory MemberLedgerStatement.fromJson(Map<String, dynamic> json) {
    final Object? entries = json['entries'];
    final Object? user = json['user'];
    return MemberLedgerStatement(
      user: user is Map<String, dynamic>
          ? MemberLedgerUser.fromJson(user)
          : null,
      currentBalance: '${json['current_balance'] ?? '0.00'}',
      pendingTotal: '${json['pending_total'] ?? '0.00'}',
      entryCount: json['entry_count'] is int
          ? json['entry_count'] as int
          : int.tryParse('${json['entry_count'] ?? 0}') ?? 0,
      entries: entries is List<dynamic>
          ? entries
                .whereType<Map<String, dynamic>>()
                .map(MemberLedgerEntry.fromJson)
                .toList()
          : <MemberLedgerEntry>[],
    );
  }
}

class MemberLedgerUser {
  const MemberLedgerUser({
    required this.userId,
    required this.fullName,
    required this.contactNo,
  });

  final String userId;
  final String fullName;
  final String contactNo;

  factory MemberLedgerUser.fromJson(Map<String, dynamic> json) {
    return MemberLedgerUser(
      userId: '${json['user_id'] ?? ''}',
      fullName: '${json['full_name'] ?? ''}',
      contactNo: '${json['contact_no'] ?? ''}',
    );
  }
}

class MemberLedgerEntry {
  const MemberLedgerEntry({
    required this.ledgerId,
    required this.userId,
    required this.memberName,
    required this.memberContact,
    required this.entryType,
    required this.amount,
    required this.currency,
    required this.txnDate,
    required this.referenceType,
    required this.referenceId,
    required this.comment,
    required this.createdByName,
    required this.createdAt,
  });

  final String ledgerId;
  final String userId;
  final String memberName;
  final String memberContact;
  final MemberLedgerEntryType entryType;
  final String amount;
  final String currency;
  final String txnDate;
  final String referenceType;
  final String referenceId;
  final String comment;
  final String createdByName;
  final DateTime? createdAt;

  factory MemberLedgerEntry.fromJson(Map<String, dynamic> json) {
    return MemberLedgerEntry(
      ledgerId: '${json['ledger_id'] ?? ''}',
      userId: '${json['user_id'] ?? ''}',
      memberName: '${json['member_name'] ?? ''}',
      memberContact: '${json['member_contact'] ?? ''}',
      entryType: MemberLedgerEntryType.fromApi(json['entry_type'] as String?),
      amount: '${json['amount'] ?? '0.00'}',
      currency: '${json['currency'] ?? 'BDT'}',
      txnDate: '${json['txn_date'] ?? ''}',
      referenceType: '${json['reference_type'] ?? ''}',
      referenceId: '${json['reference_id'] ?? ''}',
      comment: '${json['comment'] ?? ''}',
      createdByName: '${json['created_by_name'] ?? ''}',
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}'),
    );
  }
}
