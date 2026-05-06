import '../domain/capital_submission_request.dart';
import '../domain/submission_approval_queue.dart';
import 'capital_submission_api.dart';

abstract class CapitalSubmissionRepository {
  Future<List<CapitalSubmission>> list({CapitalSubmissionStatus? status});
  Future<CapitalSubmission> detail(String requestId);
  Future<SubmissionApprovalQueue> queue({PaymentChannel? paymentChannel});
  Future<void> create(CapitalSubmissionRequest request);
  Future<CapitalSubmission> approve(String requestId);
  Future<CapitalSubmission> reject(
    String requestId, {
    required String rejectionReason,
  });
}

class ApiCapitalSubmissionRepository implements CapitalSubmissionRepository {
  const ApiCapitalSubmissionRepository({required CapitalSubmissionApi api})
    : _api = api;

  final CapitalSubmissionApi _api;

  @override
  Future<List<CapitalSubmission>> list({CapitalSubmissionStatus? status}) {
    return _api.list(status: status);
  }

  @override
  Future<CapitalSubmission> detail(String requestId) {
    return _api.detail(requestId);
  }

  @override
  Future<SubmissionApprovalQueue> queue({PaymentChannel? paymentChannel}) {
    return _api.queue(paymentChannel: paymentChannel);
  }

  @override
  Future<void> create(CapitalSubmissionRequest request) async {
    await _api.create(request);
  }

  @override
  Future<CapitalSubmission> approve(String requestId) {
    return _api.approve(requestId);
  }

  @override
  Future<CapitalSubmission> reject(
    String requestId, {
    required String rejectionReason,
  }) {
    return _api.reject(requestId, rejectionReason: rejectionReason);
  }
}
