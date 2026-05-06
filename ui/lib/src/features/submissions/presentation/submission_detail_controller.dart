import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../data/capital_submission_repository.dart';
import '../domain/capital_submission_request.dart';

class SubmissionDetailController extends ChangeNotifier {
  SubmissionDetailController({
    required CapitalSubmissionRepository repository,
    required String requestId,
  }) : _repository = repository,
       _requestId = requestId;

  final CapitalSubmissionRepository _repository;
  final String _requestId;

  bool _isLoading = false;
  String? _errorMessage;
  CapitalSubmission? _submission;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CapitalSubmission? get submission => _submission;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _submission = await _repository.detail(_requestId);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load submission details. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
