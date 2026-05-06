import '../domain/capital_submission_request.dart';
import 'capital_submission_api.dart';

abstract class CapitalSubmissionRepository {
  Future<List<CapitalSubmission>> list({CapitalSubmissionStatus? status});
  Future<CapitalSubmission> detail(String requestId);
  Future<void> create(CapitalSubmissionRequest request);
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
  Future<void> create(CapitalSubmissionRequest request) async {
    await _api.create(request);
  }
}
