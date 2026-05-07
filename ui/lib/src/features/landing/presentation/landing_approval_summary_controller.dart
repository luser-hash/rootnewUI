import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../submissions/data/capital_submission_repository.dart';
import '../../submissions/domain/submission_approval_queue.dart';

class LandingApprovalSummaryController extends ChangeNotifier {
  LandingApprovalSummaryController({
    required CapitalSubmissionRepository repository,
  }) : _repository = repository;

  final CapitalSubmissionRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  SubmissionApprovalQueue? _queue;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get pendingCount => _queue?.count ?? _queue?.results.length ?? 0;
  List<SubmissionQueueItem> get pendingSubmissions {
    return List<SubmissionQueueItem>.unmodifiable(
      _queue?.results ?? <SubmissionQueueItem>[],
    );
  }

  num get pendingTotal {
    return pendingSubmissions.fold<num>(
      0,
      (num sum, SubmissionQueueItem item) =>
          sum + (num.tryParse(item.amount) ?? 0),
    );
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _queue = await _repository.queue();
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load pending approvals.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
