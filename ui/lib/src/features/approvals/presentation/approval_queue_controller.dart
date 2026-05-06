import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../submissions/data/capital_submission_repository.dart';
import '../../submissions/domain/capital_submission_request.dart';
import '../../submissions/domain/submission_approval_queue.dart';
import '../../submissions/domain/submission_history.dart';

class ApprovalQueueController extends ChangeNotifier {
  ApprovalQueueController({required CapitalSubmissionRepository repository})
    : _repository = repository;

  final CapitalSubmissionRepository _repository;

  bool _isLoading = false;
  bool _isHistoryLoading = false;
  String? _approvingRequestId;
  String? _rejectingRequestId;
  String? _errorMessage;
  String? _historyErrorMessage;
  PaymentChannel? _paymentChannel;
  SubmissionApprovalQueue? _queue;
  SubmissionHistory? _history;

  bool get isLoading => _isLoading;
  bool get isHistoryLoading => _isHistoryLoading;
  String? get approvingRequestId => _approvingRequestId;
  String? get rejectingRequestId => _rejectingRequestId;
  bool get isApproving => _approvingRequestId != null;
  bool get isRejecting => _rejectingRequestId != null;
  bool get hasActionInFlight => isApproving || isRejecting;
  String? get errorMessage => _errorMessage;
  String? get historyErrorMessage => _historyErrorMessage;
  PaymentChannel? get paymentChannel => _paymentChannel;
  SubmissionApprovalQueue? get queue => _queue;
  SubmissionHistory? get history => _history;
  int get count => _queue?.count ?? _queue?.results.length ?? 0;
  int get historyCount => _history?.count ?? _history?.results.length ?? 0;
  List<SubmissionQueueItem> get results {
    return List<SubmissionQueueItem>.unmodifiable(
      _queue?.results ?? <SubmissionQueueItem>[],
    );
  }
  List<SubmissionHistoryItem> get historyResults {
    return List<SubmissionHistoryItem>.unmodifiable(
      _history?.results ?? <SubmissionHistoryItem>[],
    );
  }

  Future<void> load({PaymentChannel? paymentChannel}) async {
    _isLoading = true;
    _errorMessage = null;
    _paymentChannel = paymentChannel;
    notifyListeners();

    try {
      _queue = await _repository.queue(paymentChannel: paymentChannel);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load approval queue. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory({
    CapitalSubmissionStatus? status,
    CapitalRequestType? requestType,
  }) async {
    _isHistoryLoading = true;
    _historyErrorMessage = null;
    notifyListeners();

    try {
      _history = await _repository.history(
        status: status,
        requestType: requestType,
      );
    } on ApiException catch (error) {
      _historyErrorMessage = error.message;
    } catch (_) {
      _historyErrorMessage =
          'Unable to load reviewed submissions. Please try again.';
    } finally {
      _isHistoryLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approve(String requestId) async {
    if (hasActionInFlight) {
      return false;
    }

    _approvingRequestId = requestId;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.approve(requestId);
      remove(requestId);
      await loadHistory();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to approve submission. Please try again.';
      return false;
    } finally {
      _approvingRequestId = null;
      notifyListeners();
    }
  }

  Future<bool> reject(
    String requestId, {
    required String rejectionReason,
  }) async {
    if (hasActionInFlight) {
      return false;
    }

    _rejectingRequestId = requestId;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.reject(
        requestId,
        rejectionReason: rejectionReason,
      );
      remove(requestId);
      await loadHistory();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to reject submission. Please try again.';
      return false;
    } finally {
      _rejectingRequestId = null;
      notifyListeners();
    }
  }

  void remove(String requestId) {
    final SubmissionApprovalQueue? current = _queue;
    if (current == null) {
      return;
    }

    final List<SubmissionQueueItem> remaining = current.results
        .where((SubmissionQueueItem item) => item.requestId != requestId)
        .toList();
    _queue = SubmissionApprovalQueue(
      count: remaining.length,
      results: remaining,
    );
    notifyListeners();
  }
}
