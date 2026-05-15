part of '../approval_page.dart';

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
                    AppDetailBlock(
                      label: 'Type',
                      value: submission.requestType.label,
                    ),
                    AppDetailBlock(
                      label: 'Channel',
                      value: submission.paymentChannel.label,
                    ),
                    AppDetailBlock(
                      label: 'Requested',
                      value: _formatRequestedAt(submission.requestedAt),
                    ),
                    AppDetailBlock(
                      label: 'Reference',
                      value: submission.externalReference.isEmpty
                          ? '-'
                          : submission.externalReference,
                    ),
                    AppDetailBlock(
                      label: 'Attachments',
                      value: '${submission.attachmentCount}',
                    ),
                    AppDetailBlock(label: 'ID', value: submission.requestId),
                  ],
                ),
                if (submission.notes.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10),
                  AppDetailBlock(label: 'Notes', value: submission.notes),
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
