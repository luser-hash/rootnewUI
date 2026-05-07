import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../submissions/data/capital_submission_repository.dart';
import '../../submissions/domain/submission_history.dart';

class MemberDetailSubmissionHistoryController extends ChangeNotifier {
  MemberDetailSubmissionHistoryController({
    required CapitalSubmissionRepository repository,
  }) : _repository = repository;

  final CapitalSubmissionRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  SubmissionHistory? _history;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SubmissionHistory? get history => _history;
  List<SubmissionHistoryItem> get results {
    return List<SubmissionHistoryItem>.unmodifiable(
      _history?.results ?? <SubmissionHistoryItem>[],
    );
  }

  Future<void> load(String userId) async {
    if (userId.trim().isEmpty) {
      _errorMessage = 'Missing member ID.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _history = await _repository.history(userId: userId);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load submission history. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
