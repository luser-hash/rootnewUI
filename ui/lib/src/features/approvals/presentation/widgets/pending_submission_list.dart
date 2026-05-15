part of '../approval_page.dart';

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
