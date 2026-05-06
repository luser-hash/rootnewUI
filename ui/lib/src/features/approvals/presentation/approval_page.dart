import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/state/app_state.dart';
import '../../shared/finance.dart';
import '../../shared/widgets/app_action_button.dart';
import '../../shared/widgets/app_pill.dart';
import '../../shared/widgets/status_pills.dart';
import '../../submissions/data/capital_submission_repository.dart';
import '../../submissions/domain/capital_submission_request.dart';
import '../../submissions/domain/submission_approval_queue.dart';
import '../../submissions/domain/submission_history.dart';
import 'approval_queue_controller.dart';

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
    AppState.updateSubmissionStatus(id, SubmissionStatus.approved);
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

    AppState.updateSubmissionStatus(id, SubmissionStatus.rejected);
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
      builder: (BuildContext context, _) {
        return SubmissionsBuilder(builder: _buildWithSubmissions);
      },
    );
  }

  Widget _buildWithSubmissions(List<Submission> _) {
    final List<SubmissionQueueItem> pending = _queueController.results;
    final List<SubmissionHistoryItem> reviewed =
        _queueController.historyResults;

    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _ApprovalHeader(
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

class _RejectionReasonDialog extends StatefulWidget {
  const _RejectionReasonDialog();

  @override
  State<_RejectionReasonDialog> createState() => _RejectionReasonDialogState();
}

class _RejectionReasonDialogState extends State<_RejectionReasonDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final FocusNode _reasonFocusNode = FocusNode();

  @override
  void dispose() {
    _reasonFocusNode.unfocus();
    _reasonFocusNode.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _close([String? reason]) {
    _reasonFocusNode.unfocus();
    Navigator.of(context).pop(reason);
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _close(_reasonController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reject Submission'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _reasonController,
          focusNode: _reasonFocusNode,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Rejection reason',
            hintText: 'Payment reference could not be verified.',
          ),
          validator: (String? value) {
            final String raw = value?.trim() ?? '';
            return raw.isEmpty ? 'Rejection reason is required' : null;
          },
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => _close(), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: const Text('Reject')),
      ],
    );
  }
}

class _PaymentChannelFilter extends StatelessWidget {
  const _PaymentChannelFilter({
    required this.selected,
    required this.onSelected,
  });

  final PaymentChannel? selected;
  final ValueChanged<PaymentChannel?> onSelected;

  @override
  Widget build(BuildContext context) {
    final List<({String label, PaymentChannel? channel})> filters =
        <({String label, PaymentChannel? channel})>[
          (label: 'All', channel: null),
          for (final PaymentChannel channel in PaymentChannel.values)
            (label: channel.label, channel: channel),
        ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final ({String label, PaymentChannel? channel}) filter =
              filters[index];
          final bool active = selected == filter.channel;
          return ChoiceChip(
            selected: active,
            label: Text(filter.label),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.white,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : AppColors.textMid,
            ),
            side: const BorderSide(color: AppColors.border),
            onSelected: (_) => onSelected(filter.channel),
          );
        },
      ),
    );
  }
}

class _ApprovalHeader extends StatelessWidget {
  const _ApprovalHeader({required this.reviewed, required this.pendingCount});

  final List<SubmissionHistoryItem> reviewed;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final List<({String label, String value})>
    stats = <({String label, String value})>[
      (label: 'Pending', value: '$pendingCount'),
      (
        label: 'Approved',
        value:
            '${reviewed.where((SubmissionHistoryItem s) => s.status == CapitalSubmissionStatus.approved).length}',
      ),
      (
        label: 'Rejected',
        value:
            '${reviewed.where((SubmissionHistoryItem s) => s.status == CapitalSubmissionStatus.rejected).length}',
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.primary, AppColors.primaryDk],
        ),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(0, 12, 0, 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Approval Queue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                AppPill(
                  label: '$pendingCount pending',
                  background: AppColors.amberLt,
                  foreground: AppColors.amber,
                ),
              ],
            ),
          ),
          Row(
            children: stats.map((({String label, String value}) s) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: s.label == stats.last.label ? 0 : 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        s.value,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        s.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: .65),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PendingSubmissionList extends StatelessWidget {
  const _PendingSubmissionList({
    required this.pending,
    required this.isLoading,
    required this.approvingRequestId,
    required this.rejectingRequestId,
    required this.errorMessage,
    required this.onApprove,
    required this.onReject,
  });

  final List<SubmissionQueueItem> pending;
  final bool isLoading;
  final String? approvingRequestId;
  final String? rejectingRequestId;
  final String? errorMessage;
  final ValueChanged<String> onApprove;
  final ValueChanged<String> onReject;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Text(
              'Awaiting Review',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textMute,
                letterSpacing: 0.72,
              ),
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else ...<Widget>[
            if (errorMessage != null)
              _QueueMessageCard(
                icon: Icons.error_outline,
                message: errorMessage!,
                background: AppColors.redLt,
                foreground: AppColors.red,
              ),
            if (pending.isEmpty && errorMessage == null)
              const _QueueMessageCard(
                icon: Icons.inbox_outlined,
                message: 'No submissions are awaiting review.',
                background: AppColors.surface,
                foreground: AppColors.textMute,
              )
            else
              ...pending.map(
                (SubmissionQueueItem s) => _SubmissionCard(
                  submission: s,
                  isApproving: approvingRequestId == s.requestId,
                  isRejecting: rejectingRequestId == s.requestId,
                  isActionLocked:
                      approvingRequestId != null || rejectingRequestId != null,
                  onApprove: onApprove,
                  onReject: onReject,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({
    required this.submission,
    required this.isApproving,
    required this.isRejecting,
    required this.isActionLocked,
    required this.onApprove,
    required this.onReject,
  });

  final SubmissionQueueItem submission;
  final bool isApproving;
  final bool isRejecting;
  final bool isActionLocked;
  final ValueChanged<String> onApprove;
  final ValueChanged<String> onReject;

  @override
  Widget build(BuildContext context) {
    final int colorIdx = submission.memberName.hashCode.abs();
    final String initials = _initials(submission.memberName);
    final double amount = double.tryParse(submission.amount) ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[AppColors.softShadow()],
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _ApprovalAvatar(
                      initials: initials,
                      color: avatarColor(colorIdx),
                      size: 40,
                      radius: 13,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            submission.memberName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            submission.memberContact.isEmpty
                                ? submission.requestType.label
                                : submission.memberContact,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMute,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SubmissionStatusPill(
                      status: SubmissionStatus.pending,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  fmt(amount),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.6,
                  children: <Widget>[
                    _DetailBox(
                      label: 'Type',
                      value: submission.requestType.label,
                    ),
                    _DetailBox(
                      label: 'Channel',
                      value: submission.paymentChannel.label,
                    ),
                    _DetailBox(
                      label: 'Requested',
                      value: _formatRequestedAt(submission.requestedAt),
                    ),
                    _DetailBox(
                      label: 'Reference',
                      value: submission.externalReference.isEmpty
                          ? '-'
                          : submission.externalReference,
                    ),
                    _DetailBox(
                      label: 'Attachments',
                      value: '${submission.attachmentCount}',
                    ),
                    _DetailBox(label: 'ID', value: submission.requestId),
                  ],
                ),
                if (submission.notes.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10),
                  _DetailBox(label: 'Notes', value: submission.notes),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: AppActionButton(
                    label: isRejecting ? 'Rejecting...' : '✕ Reject',
                    background: isActionLocked && !isRejecting
                        ? AppColors.textMute
                        : AppColors.redLt,
                    foreground: isActionLocked && !isRejecting
                        ? Colors.white
                        : AppColors.red,
                    onTap: isActionLocked
                        ? null
                        : () => onReject(submission.requestId),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppActionButton(
                    label: isApproving ? 'Approving...' : '✓ Approve',
                    background: isActionLocked && !isApproving
                        ? AppColors.textMute
                        : AppColors.primary,
                    foreground: Colors.white,
                    onTap: isActionLocked
                        ? null
                        : () => onApprove(submission.requestId),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueMessageCard extends StatelessWidget {
  const _QueueMessageCard({
    required this.icon,
    required this.message,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String message;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: foreground),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailBox extends StatelessWidget {
  const _DetailBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMute,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTextBlock extends StatelessWidget {
  const _DetailTextBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMute,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

String _initials(String name) {
  final List<String> parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((String part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return '?';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

String _formatRequestedAt(DateTime? value) {
  if (value == null) {
    return '-';
  }

  final DateTime local = value.toLocal();
  final String month = local.month.toString().padLeft(2, '0');
  final String day = local.day.toString().padLeft(2, '0');
  final String hour = local.hour.toString().padLeft(2, '0');
  final String minute = local.minute.toString().padLeft(2, '0');
  return '${local.year}-$month-$day $hour:$minute';
}

class _ReviewedSubmissionList extends StatelessWidget {
  const _ReviewedSubmissionList({
    required this.reviewed,
    required this.isLoading,
    required this.errorMessage,
  });

  final List<SubmissionHistoryItem> reviewed;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Text(
              'Reviewed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textMute,
                letterSpacing: 0.72,
              ),
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (errorMessage != null)
            _QueueMessageCard(
              icon: Icons.error_outline,
              message: errorMessage!,
              background: AppColors.redLt,
              foreground: AppColors.red,
            )
          else
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: <BoxShadow>[AppColors.softShadow()],
              ),
              child: Column(
                children: reviewed.asMap().entries.map((
                  MapEntry<int, SubmissionHistoryItem> entry,
                ) {
                  final SubmissionHistoryItem s = entry.value;
                  final double amount = double.tryParse(s.amount) ?? 0;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showReviewedDetails(context, s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: entry.key == reviewed.length - 1
                                ? BorderSide.none
                                : const BorderSide(color: AppColors.border),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: s.isApproved
                                    ? AppColors.greenLt
                                    : AppColors.redLt,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                s.isApproved ? '✓' : '✕',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    s.memberName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  Text(
                                    '${s.requestType.label} · ${s.txnDate}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMute,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  fmt(amount),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SubmissionStatusPill(
                                  status: _sharedStatus(s.status),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _showReviewedDetails(
    BuildContext context,
    SubmissionHistoryItem submission,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (BuildContext context) {
        final double amount = double.tryParse(submission.amount) ?? 0;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: submission.isApproved
                            ? AppColors.greenLt
                            : AppColors.redLt,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        submission.isApproved ? '✓' : '✕',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            submission.memberName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            submission.memberContact.isEmpty
                                ? submission.requestId
                                : submission.memberContact,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMute,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SubmissionStatusPill(
                      status: _sharedStatus(submission.status),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  fmt(amount),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.45,
                  children: <Widget>[
                    _DetailBox(
                      label: 'Type',
                      value: submission.requestType.label,
                    ),
                    _DetailBox(
                      label: 'Channel',
                      value: submission.paymentChannel.label,
                    ),
                    _DetailBox(label: 'Txn Date', value: submission.txnDate),
                    _DetailBox(
                      label: 'Reviewed',
                      value: _formatRequestedAt(submission.reviewedAt),
                    ),
                    _DetailBox(
                      label: 'Reference',
                      value: submission.externalReference.isEmpty
                          ? '-'
                          : submission.externalReference,
                    ),
                    _DetailBox(
                      label: 'Reviewed By',
                      value: submission.reviewedBy?.fullName ?? '-',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _DetailTextBlock(
                  label: 'Request ID',
                  value: submission.requestId,
                ),
                if ((submission.reviewedBy?.userId ?? '').isNotEmpty)
                  ...<Widget>[
                    const SizedBox(height: 8),
                    _DetailTextBlock(
                      label: 'Reviewer ID',
                      value: submission.reviewedBy!.userId,
                    ),
                  ],
                if (submission.rejectionReason.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  _DetailTextBlock(
                    label: 'Rejection Reason',
                    value: submission.rejectionReason,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

SubmissionStatus _sharedStatus(CapitalSubmissionStatus status) {
  return switch (status) {
    CapitalSubmissionStatus.approved => SubmissionStatus.approved,
    CapitalSubmissionStatus.rejected => SubmissionStatus.rejected,
    CapitalSubmissionStatus.pending => SubmissionStatus.pending,
  };
}

class _SuccessOverlay extends StatelessWidget {
  const _SuccessOverlay({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: AppColors.primary.withValues(alpha: .95),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 100,
              height: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .15),
              ),
              child: const Text(
                '✓',
                style: TextStyle(fontSize: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Approved!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Capital ledger has been updated',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: .75),
              ),
            ),
            const SizedBox(height: 28),
            Material(
              color: Colors.white.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(14),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApprovalAvatar extends StatelessWidget {
  const _ApprovalAvatar({
    required this.initials,
    required this.color,
    this.size = 36,
    this.radius = 12,
  });

  final String initials;
  final Color color;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
