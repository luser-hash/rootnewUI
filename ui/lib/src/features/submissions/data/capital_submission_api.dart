import '../../../../core/network/api_client.dart';
import '../domain/capital_submission_request.dart';
import '../domain/submission_approval_queue.dart';

class CapitalSubmissionApi {
  const CapitalSubmissionApi(this._apiClient);

  final ApiClient _apiClient;

  Future<List<CapitalSubmission>> list({
    CapitalSubmissionStatus? status,
  }) async {
    final String path = status == null
        ? '/submission/'
        : '/submission/?status=${status.apiValue}';
    final Map<String, dynamic> response = await _apiClient.get(path);
    final Object? data = response['data'];
    final List<dynamic> items = data is List<dynamic>
        ? data
        : response['results'] is List<dynamic>
        ? response['results'] as List<dynamic>
        : response['items'] is List<dynamic>
        ? response['items'] as List<dynamic>
        : <dynamic>[];

    return items
        .whereType<Map<String, dynamic>>()
        .map(CapitalSubmission.fromJson)
        .toList();
  }

  Future<CapitalSubmission> detail(String requestId) async {
    final Map<String, dynamic> response = await _apiClient.get(
      '/submission/$requestId/',
    );
    final Object? data = response['data'];
    return CapitalSubmission.fromJson(
      data is Map<String, dynamic> ? data : response,
    );
  }

  Future<SubmissionApprovalQueue> queue({PaymentChannel? paymentChannel}) async {
    final Uri uri = Uri(
      path: '/submission/queue/',
      queryParameters: paymentChannel == null
          ? null
          : <String, String>{'payment_channel': paymentChannel.apiValue},
    );
    final Map<String, dynamic> response = await _apiClient.get(uri.toString());
    final Object? data = response['data'];
    return SubmissionApprovalQueue.fromJson(
      data is Map<String, dynamic> ? data : response,
    );
  }

  Future<Map<String, dynamic>> create(CapitalSubmissionRequest request) {
    return _apiClient.post('/submission/', body: request.toJson());
  }
}
