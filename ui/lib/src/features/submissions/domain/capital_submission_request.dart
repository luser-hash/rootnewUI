enum CapitalRequestType {
  installment('INSTALLMENT', 'Installment'),
  submission('SUBMISSION', 'Submission');

  const CapitalRequestType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  factory CapitalRequestType.fromApi(String? value) {
    return switch (value?.trim().toUpperCase()) {
      'SUBMISSION' => CapitalRequestType.submission,
      _ => CapitalRequestType.installment,
    };
  }
}

enum PaymentChannel {
  handCash('HAND_CASH', 'Hand Cash'),
  bkash('BKASH', 'bKash'),
  bank('BANK', 'Bank'),
  other('OTHER', 'Other');

  const PaymentChannel(this.apiValue, this.label);

  final String apiValue;
  final String label;

  factory PaymentChannel.fromApi(String? value) {
    return switch (value?.trim().toUpperCase()) {
      'HAND_CASH' => PaymentChannel.handCash,
      'BANK' => PaymentChannel.bank,
      'OTHER' => PaymentChannel.other,
      _ => PaymentChannel.bkash,
    };
  }
}

enum CapitalSubmissionStatus {
  pending('PENDING', 'Pending'),
  approved('APPROVED', 'Approved'),
  rejected('REJECTED', 'Rejected');

  const CapitalSubmissionStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  factory CapitalSubmissionStatus.fromApi(String? value) {
    return switch (value?.trim().toUpperCase()) {
      'APPROVED' => CapitalSubmissionStatus.approved,
      'REJECTED' => CapitalSubmissionStatus.rejected,
      _ => CapitalSubmissionStatus.pending,
    };
  }
}

class CapitalSubmissionRequest {
  const CapitalSubmissionRequest({
    required this.requestType,
    required this.amount,
    required this.txnDate,
    required this.paymentChannel,
    required this.externalReference,
    required this.notes,
  });

  final CapitalRequestType requestType;
  final String amount;
  final DateTime txnDate;
  final PaymentChannel paymentChannel;
  final String externalReference;
  final String notes;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'request_type': requestType.apiValue,
      'amount': amount,
      'txn_date': _formatDate(txnDate),
      'payment_channel': paymentChannel.apiValue,
      'external_reference': externalReference,
      'notes': notes,
    };
  }

  String _formatDate(DateTime value) {
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class CapitalSubmission {
  const CapitalSubmission({
    required this.requestId,
    required this.requestType,
    required this.amount,
    required this.txnDate,
    required this.paymentChannel,
    required this.externalReference,
    required this.notes,
    required this.status,
    required this.requestedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionReason,
    this.resultingLedgerId,
  });

  final String requestId;
  final CapitalRequestType requestType;
  final String amount;
  final String txnDate;
  final PaymentChannel paymentChannel;
  final String externalReference;
  final String notes;
  final CapitalSubmissionStatus status;
  final DateTime? requestedAt;
  final SubmissionReviewer? reviewedBy;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final String? resultingLedgerId;

  factory CapitalSubmission.fromJson(Map<String, dynamic> json) {
    return CapitalSubmission(
      requestId: '${json['request_id'] ?? ''}',
      requestType: _requestTypeFromApi(json['request_type'] as String?),
      amount: '${json['amount'] ?? ''}',
      txnDate: '${json['txn_date'] ?? ''}',
      paymentChannel: _paymentChannelFromApi(
        json['payment_channel'] as String?,
      ),
      externalReference: '${json['external_reference'] ?? ''}',
      notes: '${json['notes'] ?? ''}',
      status: CapitalSubmissionStatus.fromApi(json['status'] as String?),
      requestedAt: DateTime.tryParse('${json['requested_at'] ?? ''}'),
      reviewedBy: json['reviewed_by'] is Map<String, dynamic>
          ? SubmissionReviewer.fromJson(
              json['reviewed_by'] as Map<String, dynamic>,
            )
          : null,
      reviewedAt: DateTime.tryParse('${json['reviewed_at'] ?? ''}'),
      rejectionReason: json['rejection_reason'] as String?,
      resultingLedgerId: json['resulting_ledger_id'] as String?,
    );
  }
}

class SubmissionReviewer {
  const SubmissionReviewer({required this.userId, required this.fullName});

  final String userId;
  final String fullName;

  factory SubmissionReviewer.fromJson(Map<String, dynamic> json) {
    return SubmissionReviewer(
      userId: '${json['user_id'] ?? ''}',
      fullName: '${json['full_name'] ?? ''}',
    );
  }
}

CapitalRequestType _requestTypeFromApi(String? value) {
  return CapitalRequestType.fromApi(value);
}

PaymentChannel _paymentChannelFromApi(String? value) {
  return PaymentChannel.fromApi(value);
}
