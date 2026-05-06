import 'capital_submission_request.dart';

class SubmissionApprovalQueue {
  const SubmissionApprovalQueue({required this.count, required this.results});

  final int count;
  final List<SubmissionQueueItem> results;

  factory SubmissionApprovalQueue.fromJson(Map<String, dynamic> json) {
    final Object? results = json['results'];
    return SubmissionApprovalQueue(
      count: json['count'] is int
          ? json['count'] as int
          : int.tryParse('${json['count'] ?? 0}') ?? 0,
      results: results is List<dynamic>
          ? results
                .whereType<Map<String, dynamic>>()
                .map(SubmissionQueueItem.fromJson)
                .toList()
          : <SubmissionQueueItem>[],
    );
  }
}

class SubmissionQueueItem {
  const SubmissionQueueItem({
    required this.requestId,
    required this.memberName,
    required this.memberContact,
    required this.requestType,
    required this.amount,
    required this.paymentChannel,
    required this.externalReference,
    required this.notes,
    required this.requestedAt,
    required this.attachmentCount,
    required this.attachments,
  });

  final String requestId;
  final String memberName;
  final String memberContact;
  final CapitalRequestType requestType;
  final String amount;
  final PaymentChannel paymentChannel;
  final String externalReference;
  final String notes;
  final DateTime? requestedAt;
  final int attachmentCount;
  final List<dynamic> attachments;

  factory SubmissionQueueItem.fromJson(Map<String, dynamic> json) {
    final Object? attachments = json['attachments'];
    return SubmissionQueueItem(
      requestId: '${json['request_id'] ?? ''}',
      memberName: '${json['member_name'] ?? ''}',
      memberContact: '${json['member_contact'] ?? ''}',
      requestType: CapitalRequestType.fromApi(json['request_type'] as String?),
      amount: '${json['amount'] ?? '0.00'}',
      paymentChannel: PaymentChannel.fromApi(
        json['payment_channel'] as String?,
      ),
      externalReference: '${json['external_reference'] ?? ''}',
      notes: '${json['notes'] ?? ''}',
      requestedAt: DateTime.tryParse('${json['requested_at'] ?? ''}'),
      attachmentCount: json['attachment_count'] is int
          ? json['attachment_count'] as int
          : int.tryParse('${json['attachment_count'] ?? 0}') ?? 0,
      attachments: attachments is List<dynamic> ? attachments : <dynamic>[],
    );
  }
}
