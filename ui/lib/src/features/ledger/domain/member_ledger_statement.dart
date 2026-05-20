enum MemberLedgerEntryType {
  submission('SUBMISSION', 'Funds Given'),
  withdraw('WITHDRAW', 'Funds Taken'),
  adjustment('ADJUSTMENT', 'Adjustment'),
  distribution('DISTRIBUTION', 'Profit Added'),
  distributionReversal('DISTRIBUTION_REVERSAL', 'Profit Reversed');

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

enum LedgerWalletType {
  capital('CAPITAL', 'Capital Wallet'),
  profit('PROFIT', 'Profit Wallet');

  const LedgerWalletType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  factory LedgerWalletType.fromApi(String? value) {
    return switch (value?.trim().toUpperCase()) {
      'PROFIT' => LedgerWalletType.profit,
      _ => LedgerWalletType.capital,
    };
  }

  static LedgerWalletType infer(MemberLedgerEntryType entryType) {
    if (entryType == MemberLedgerEntryType.distribution ||
        entryType == MemberLedgerEntryType.distributionReversal) {
      return LedgerWalletType.profit;
    }
    return LedgerWalletType.capital;
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
    this.walletType,
  });

  final String contactNo;
  final MemberLedgerEntryType entryType;
  final String amount;
  final DateTime txnDate;
  final String comment;
  final String referenceId;
  final LedgerWalletType? walletType;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'contact_no': contactNo,
      'entry_type': entryType.apiValue,
      'amount': amount,
      'txn_date': _formatDate(txnDate),
      'comment': comment,
      'reference_id': referenceId,
      if (entryType == MemberLedgerEntryType.adjustment && walletType != null)
        'wallet_type': walletType!.apiValue,
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
    this.walletType,
    this.fromDate,
    this.toDate,
    this.userId,
  });

  final MemberLedgerEntryType? entryType;
  final LedgerWalletType? walletType;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? userId;

  bool get hasFilters {
    return entryType != null ||
        walletType != null ||
        fromDate != null ||
        toDate != null ||
        (userId?.trim().isNotEmpty ?? false);
  }

  Map<String, String> toQueryParams() {
    return <String, String>{
      if (entryType != null) 'entry_type': entryType!.apiValue,
      if (walletType != null) 'wallet_type': walletType!.apiValue,
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
    required this.givenAmount,
    required this.takenAmount,
    required this.capitalBalance,
    required this.profitWalletBalance,
    required this.totalAmount,
    required this.entryCount,
    required this.entries,
  });

  final String totalIn;
  final String totalOut;
  final String givenAmount;
  final String takenAmount;
  final String capitalBalance;
  final String profitWalletBalance;
  final String totalAmount;
  final int entryCount;
  final List<MemberLedgerEntry> entries;

  factory AdminLedgerStatement.fromJson(Map<String, dynamic> json) {
    final Object? entries = json['entries'];
    final String totalIn = _stringAmount(json['total_in']);
    final String totalOut = _stringAmount(json['total_out']);
    final String legacyBalance = _subtractAmountStrings(totalIn, totalOut);
    final String capitalBalance = _stringAmount(
      json['capital_balance'] ?? json['current_balance'] ?? legacyBalance,
    );
    final String profitWalletBalance = _stringAmount(
      json['profit_wallet_balance'],
    );
    final String totalAmount = _stringAmount(
      json['total_amount'] ??
          json['current_balance'] ??
          _sumAmountStrings(capitalBalance, profitWalletBalance),
    );
    return AdminLedgerStatement(
      totalIn: totalIn,
      totalOut: totalOut,
      givenAmount: _stringAmount(json['given_amount'] ?? totalIn),
      takenAmount: _stringAmount(json['taken_amount'] ?? totalOut),
      capitalBalance: capitalBalance,
      profitWalletBalance: profitWalletBalance,
      totalAmount: totalAmount,
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
    required this.givenAmount,
    required this.takenAmount,
    required this.capitalBalance,
    required this.profitWalletBalance,
    required this.totalAmount,
    required this.pendingTotal,
    required this.entryCount,
    required this.entries,
  });

  final MemberLedgerUser? user;
  final String currentBalance;
  final String givenAmount;
  final String takenAmount;
  final String capitalBalance;
  final String profitWalletBalance;
  final String totalAmount;
  final String pendingTotal;
  final int entryCount;
  final List<MemberLedgerEntry> entries;

  factory MemberLedgerStatement.fromJson(Map<String, dynamic> json) {
    final Object? entries = json['entries'];
    final Object? user = json['user'];
    final String legacyCurrentBalance = _stringAmount(
      json['current_balance'] ?? json['total_amount'],
    );
    final String capitalBalance = _stringAmount(
      json['capital_balance'] ?? legacyCurrentBalance,
    );
    final String profitWalletBalance = _stringAmount(
      json['profit_wallet_balance'],
    );
    final String totalAmount = _stringAmount(
      json['total_amount'] ??
          (json['current_balance'] == null
              ? _sumAmountStrings(capitalBalance, profitWalletBalance)
              : legacyCurrentBalance),
    );
    final String currentBalance = _stringAmount(
      json['current_balance'] ?? json['total_amount'] ?? totalAmount,
    );
    return MemberLedgerStatement(
      user: user is Map<String, dynamic>
          ? MemberLedgerUser.fromJson(user)
          : null,
      currentBalance: currentBalance,
      givenAmount: _stringAmount(json['given_amount']),
      takenAmount: _stringAmount(json['taken_amount']),
      capitalBalance: capitalBalance,
      profitWalletBalance: profitWalletBalance,
      totalAmount: totalAmount,
      pendingTotal: _stringAmount(json['pending_total']),
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
    required this.walletType,
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
  final LedgerWalletType walletType;
  final String amount;
  final String currency;
  final String txnDate;
  final String referenceType;
  final String referenceId;
  final String comment;
  final String createdByName;
  final DateTime? createdAt;

  factory MemberLedgerEntry.fromJson(Map<String, dynamic> json) {
    final MemberLedgerEntryType entryType = MemberLedgerEntryType.fromApi(
      json['entry_type'] as String?,
    );
    return MemberLedgerEntry(
      ledgerId: '${json['ledger_id'] ?? ''}',
      userId: '${json['user_id'] ?? ''}',
      memberName: '${json['member_name'] ?? ''}',
      memberContact: '${json['member_contact'] ?? ''}',
      entryType: entryType,
      walletType: json['wallet_type'] == null
          ? LedgerWalletType.infer(entryType)
          : LedgerWalletType.fromApi('${json['wallet_type']}'),
      amount: _stringAmount(json['amount']),
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

String _stringAmount(Object? value) {
  if (value == null) {
    return '0.00';
  }
  final String stringValue = '$value';
  return stringValue.trim().isEmpty ? '0.00' : stringValue;
}

String _subtractAmountStrings(String first, String second) {
  final num firstAmount = num.tryParse(first) ?? 0;
  final num secondAmount = num.tryParse(second) ?? 0;
  return (firstAmount - secondAmount).toStringAsFixed(2);
}

String _sumAmountStrings(String first, String second) {
  final num firstAmount = num.tryParse(first) ?? 0;
  final num secondAmount = num.tryParse(second) ?? 0;
  return (firstAmount + secondAmount).toStringAsFixed(2);
}
