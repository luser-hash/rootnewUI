import 'capital_submission_request.dart';

class SubmissionHistory {
  const SubmissionHistory({required this.count, required this.results});

  final int count;
  final List<SubmissionHistoryItem> results;

  factory SubmissionHistory.fromJson(Map<String, dynamic> json) {
    final Object? results = json['results'];
    return SubmissionHistory(
      count: json['count'] is int
          ? json['count'] as int
          : int.tryParse('${json['count'] ?? 0}') ?? 0,
      results: results is List<dynamic>
          ? results
                .whereType<Map<String, dynamic>>()
                .map(SubmissionHistoryItem.fromJson)
                .toList()
          : <SubmissionHistoryItem>[],
    );
  }
}

class SubmissionHistoryItem {
  const SubmissionHistoryItem({
    required this.requestId,
    required this.memberName,
    required this.memberContact,
    required this.requestType,
    required this.amount,
    required this.txnDate,
    required this.paymentChannel,
    required this.externalReference,
    required this.status,
    required this.reviewedAt,
    required this.reviewedBy,
    required this.rejectionReason,
  });

  final String requestId;
  final String memberName;
  final String memberContact;
  final CapitalRequestType requestType;
  final String amount;
  final String txnDate;
  final PaymentChannel paymentChannel;
  final String externalReference;
  final CapitalSubmissionStatus status;
  final DateTime? reviewedAt;
  final SubmissionReviewer? reviewedBy;
  final String rejectionReason;

  bool get isApproved => status == CapitalSubmissionStatus.approved;

  factory SubmissionHistoryItem.fromJson(Map<String, dynamic> json) {
    return SubmissionHistoryItem(
      requestId: '${json['request_id'] ?? ''}',
      memberName: '${json['member_name'] ?? ''}',
      memberContact: '${json['member_contact'] ?? ''}',
      requestType: CapitalRequestType.fromApi(json['request_type'] as String?),
      amount: '${json['amount'] ?? '0.00'}',
      txnDate: '${json['txn_date'] ?? ''}',
      paymentChannel: PaymentChannel.fromApi(
        json['payment_channel'] as String?,
      ),
      externalReference: '${json['external_reference'] ?? ''}',
      status: CapitalSubmissionStatus.fromApi(json['status'] as String?),
      reviewedAt: DateTime.tryParse('${json['reviewed_at'] ?? ''}'),
      reviewedBy: json['reviewed_by'] is Map<String, dynamic>
          ? SubmissionReviewer.fromJson(
              json['reviewed_by'] as Map<String, dynamic>,
            )
          : null,
      rejectionReason: '${json['rejection_reason'] ?? ''}',
    );
  }
}
