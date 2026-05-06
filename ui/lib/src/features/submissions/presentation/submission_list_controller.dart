import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../data/capital_submission_repository.dart';
import '../domain/capital_submission_request.dart';

class SubmissionListController extends ChangeNotifier {
  SubmissionListController({required CapitalSubmissionRepository repository})
    : _repository = repository;

  final CapitalSubmissionRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  CapitalSubmissionStatus? _status;
  List<CapitalSubmission> _submissions = <CapitalSubmission>[];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CapitalSubmissionStatus? get status => _status;
  List<CapitalSubmission> get submissions => _submissions;

  Future<void> load({CapitalSubmissionStatus? status}) async {
    _isLoading = true;
    _errorMessage = null;
    _status = status;
    notifyListeners();

    try {
      _submissions = await _repository.list(status: status);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load submissions. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
