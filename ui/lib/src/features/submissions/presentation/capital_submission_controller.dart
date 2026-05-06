import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../data/capital_submission_repository.dart';
import '../domain/capital_submission_request.dart';

class CapitalSubmissionController extends ChangeNotifier {
  CapitalSubmissionController({required CapitalSubmissionRepository repository})
    : _repository = repository;

  final CapitalSubmissionRepository _repository;

  bool _isSubmitting = false;
  String? _errorMessage;
  bool _submitted = false;

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get submitted => _submitted;

  Future<bool> submit(CapitalSubmissionRequest request) async {
    _isSubmitting = true;
    _errorMessage = null;
    _submitted = false;
    notifyListeners();

    try {
      await _repository.create(request);
      _submitted = true;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to submit funds. Please try again.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
