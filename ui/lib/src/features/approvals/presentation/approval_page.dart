import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../shared/finance.dart';
import '../../shared/widgets/app_action_button.dart';
import '../../shared/widgets/app_detail_block.dart';
import '../../shared/widgets/app_pill.dart';
import '../../shared/widgets/app_screen_header.dart';
import '../../shared/widgets/status_pills.dart';
import '../../submissions/data/capital_submission_repository.dart';
import '../../submissions/domain/capital_submission_request.dart';
import '../../submissions/domain/submission_approval_queue.dart';
import '../../submissions/domain/submission_history.dart';
import 'approval_queue_controller.dart';

part 'widgets/approval_header.dart';
part 'widgets/payment_channel_filter.dart';
part 'widgets/pending_submission_list.dart';
part 'widgets/submission_review_card.dart';
part 'widgets/reviewed_submission_list.dart';
part 'widgets/rejection_reason_dialog.dart';
part 'widgets/approval_success_overlay.dart';

class ApprovalPage extends StatefulWidget {
  const ApprovalPage({super.key, required this.repository});

  final CapitalSubmissionRepository repository;

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  late final ApprovalQueueController _queueController;
  bool _successVisible = false;
  Timer? _successTimer;

  @override
  void initState() {
    super.initState();
    _queueController = ApprovalQueueController(repository: widget.repository);
    _queueController.load();
    _queueController.loadHistory();
  }

  @override
  void dispose() {
    _successTimer?.cancel();
    _queueController.dispose();
    super.dispose();
  }

  Future<void> _approve(String id) async {
    final bool approved = await _queueController.approve(id);
    if (!mounted || !approved) {
      return;
    }

    setState(() {
      _successVisible = true;
    });
    _successTimer?.cancel();
    _successTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _successVisible = false);
      }
    });
  }

  Future<void> _reject(String id) async {
    if (_queueController.hasActionInFlight) {
      return;
    }

    final String? rejectionReason = await _requestRejectionReason();
    if (!mounted || rejectionReason == null || rejectionReason.isEmpty) {
      return;
    }

    final bool rejected = await _queueController.reject(
      id,
      rejectionReason: rejectionReason,
    );
    if (!mounted || !rejected) {
      return;
    }
  }

  Future<String?> _requestRejectionReason() async {
    return showDialog<String>(
      context: context,
      builder: (_) => const _RejectionReasonDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _queueController,
      builder: (BuildContext context, _) => _buildWithSubmissions(),
    );
  }

  Widget _buildWithSubmissions() {
    final List<SubmissionQueueItem> pending = _queueController.results;
    final List<SubmissionHistoryItem> reviewed =
        _queueController.historyResults;

    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _ApprovalHeaderContent(
              reviewed: reviewed,
              pendingCount: _queueController.count,
            ),
            _PaymentChannelFilter(
              selected: _queueController.paymentChannel,
              onSelected: (PaymentChannel? channel) {
                _queueController.load(paymentChannel: channel);
              },
            ),
            _PendingSubmissionList(
              pending: pending,
              isLoading: _queueController.isLoading,
              approvingRequestId: _queueController.approvingRequestId,
              rejectingRequestId: _queueController.rejectingRequestId,
              errorMessage: _queueController.errorMessage,
              onApprove: _approve,
              onReject: _reject,
            ),
            if (_queueController.isHistoryLoading ||
                _queueController.historyErrorMessage != null ||
                reviewed.isNotEmpty)
              _ReviewedSubmissionList(
                reviewed: reviewed,
                isLoading: _queueController.isHistoryLoading,
                errorMessage: _queueController.historyErrorMessage,
              ),
          ],
        ),
        if (_successVisible)
          _SuccessOverlay(
            onClose: () => setState(() => _successVisible = false),
          ),
      ],
    );
  }
}
