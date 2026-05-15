part of '../approval_page.dart';

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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Text(
              'Reviewed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppThemeColors.textMuted(context),
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
              background: AppThemeColors.statusErrorBg(context),
              foreground: AppThemeColors.statusErrorFg(context),
            )
          else
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppThemeColors.card(context),
                borderRadius: BorderRadius.circular(18),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppThemeColors.shadow(
                      context,
                    ).withValues(alpha: .15),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                                : BorderSide(
                                    color: AppThemeColors.border(context),
                                  ),
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
                                    ? AppThemeColors.statusSuccessBg(context)
                                    : AppThemeColors.statusErrorBg(context),
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
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppThemeColors.text(context),
                                    ),
                                  ),
                                  Text(
                                    '${s.requestType.label} · ${s.txnDate}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppThemeColors.textMuted(context),
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
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppThemeColors.text(context),
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
      backgroundColor: AppThemeColors.card(context),
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
                            ? AppThemeColors.statusSuccessBg(context)
                            : AppThemeColors.statusErrorBg(context),
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
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppThemeColors.text(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            submission.memberContact.isEmpty
                                ? submission.requestId
                                : submission.memberContact,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppThemeColors.textMuted(context),
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
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppThemeColors.text(context),
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
                    AppDetailBlock(
                      label: 'Type',
                      value: submission.requestType.label,
                    ),
                    AppDetailBlock(
                      label: 'Channel',
                      value: submission.paymentChannel.label,
                    ),
                    AppDetailBlock(
                      label: 'Txn Date',
                      value: submission.txnDate,
                    ),
                    AppDetailBlock(
                      label: 'Reviewed',
                      value: _formatRequestedAt(submission.reviewedAt),
                    ),
                    AppDetailBlock(
                      label: 'Reference',
                      value: submission.externalReference.isEmpty
                          ? '-'
                          : submission.externalReference,
                    ),
                    AppDetailBlock(
                      label: 'Reviewed By',
                      value: submission.reviewedBy?.fullName ?? '-',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AppDetailBlock(
                  label: 'Request ID',
                  value: submission.requestId,
                ),
                if ((submission.reviewedBy?.userId ?? '')
                    .isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  AppDetailBlock(
                    label: 'Reviewer ID',
                    value: submission.reviewedBy!.userId,
                  ),
                ],
                if (submission.rejectionReason.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  AppDetailBlock(
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
