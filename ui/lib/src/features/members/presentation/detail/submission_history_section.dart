part of 'member_detail_screen.dart';

class _SubmissionHistorySection extends StatelessWidget {
  const _SubmissionHistorySection({required this.controller});

  final MemberDetailSubmissionHistoryController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const AppCardList(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
        ],
      );
    }

    final String? error = controller.errorMessage;
    if (error != null) {
      return AppCardList(
        children: <Widget>[
          AppMessageCard(
            message: error,
            tone: AppMessageTone.neutral,
            background: Colors.transparent,
            textColor: AppThemeColors.textMuted(context),
            padding: const EdgeInsets.all(20),
            showBorder: false,
            showIcon: false,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    final List<SubmissionHistoryItem> submissions = controller.results;
    if (submissions.isEmpty) {
      return AppCardList(
        children: <Widget>[
          AppMessageCard(
            message: 'No submissions yet.',
            tone: AppMessageTone.neutral,
            background: Colors.transparent,
            textColor: AppThemeColors.textMuted(context),
            padding: const EdgeInsets.all(20),
            showBorder: false,
            showIcon: false,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return AppCardList(
      children: submissions
          .asMap()
          .entries
          .map(
            (MapEntry<int, SubmissionHistoryItem> entry) =>
                _SubmissionHistoryRow(
                  submission: entry.value,
                  isLast: entry.key == submissions.length - 1,
                ),
          )
          .toList(),
    );
  }
}

class _SubmissionHistoryRow extends StatelessWidget {
  const _SubmissionHistoryRow({required this.submission, this.isLast = false});

  final SubmissionHistoryItem submission;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final Color foreground = _submissionStatusForeground(
      context,
      submission.status,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showSubmissionDetails(context),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: isLast
                  ? BorderSide.none
                  : BorderSide(color: AppThemeColors.border(context)),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _submissionStatusBackground(
                    context,
                    submission.status,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _submissionStatusIcon(submission.status),
                  size: 18,
                  color: foreground,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${submission.requestType.label} · ${submission.paymentChannel.label}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppThemeColors.text(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${valueOrDash(submission.txnDate)} · ${submission.requestId}',
                      overflow: TextOverflow.ellipsis,
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
                    formatMoneyTextUnsigned(submission.amount),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AppStatusPill(
                    label: submission.status.label,
                    background: _submissionStatusBackground(
                      context,
                      submission.status,
                    ),
                    foreground: _submissionStatusForeground(
                      context,
                      submission.status,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubmissionDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppThemeColors.card(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (BuildContext context) {
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
                        color: _submissionStatusBackground(
                          context,
                          submission.status,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _submissionStatusIcon(submission.status),
                        size: 18,
                        color: _submissionStatusForeground(
                          context,
                          submission.status,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            submission.requestType.label,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppThemeColors.text(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _submissionMeta(submission),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppThemeColors.textMuted(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppStatusPill(
                      label: submission.status.label,
                      background: _submissionStatusBackground(
                        context,
                        submission.status,
                      ),
                      foreground: _submissionStatusForeground(
                        context,
                        submission.status,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  formatMoneyTextUnsigned(submission.amount),
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
                      borderColor: AppColors.border,
                      center: true,
                    ),
                    AppDetailBlock(
                      label: 'Channel',
                      value: submission.paymentChannel.label,
                      borderColor: AppColors.border,
                      center: true,
                    ),
                    AppDetailBlock(
                      label: 'Txn Date',
                      value: valueOrDash(submission.txnDate),
                      borderColor: AppColors.border,
                      center: true,
                    ),
                    AppDetailBlock(
                      label: 'Reviewed',
                      value: formatDateTimeShort(submission.reviewedAt),
                      borderColor: AppColors.border,
                      center: true,
                    ),
                    AppDetailBlock(
                      label: 'Reference',
                      value: valueOrDash(submission.externalReference),
                      borderColor: AppColors.border,
                      center: true,
                    ),
                    AppDetailBlock(
                      label: 'Reviewed By',
                      value: valueOrDash(submission.reviewedBy?.fullName),
                      borderColor: AppColors.border,
                      center: true,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AppDetailBlock(
                  label: 'Request ID',
                  value: valueOrDash(submission.requestId),
                  borderColor: AppColors.border,
                  selectable: true,
                ),
                if ((submission.memberName).trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  AppDetailBlock(
                    label: 'Member',
                    value: submission.memberName,
                    borderColor: AppColors.border,
                    selectable: true,
                  ),
                ],
                if ((submission.memberContact).trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  AppDetailBlock(
                    label: 'Contact',
                    value: submission.memberContact,
                    borderColor: AppColors.border,
                    selectable: true,
                  ),
                ],
                if ((submission.reviewedBy?.userId ?? '')
                    .isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  AppDetailBlock(
                    label: 'Reviewer ID',
                    value: submission.reviewedBy!.userId,
                    borderColor: AppColors.border,
                    selectable: true,
                  ),
                ],
                if (submission.rejectionReason.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  AppDetailBlock(
                    label: 'Rejection Reason',
                    value: submission.rejectionReason,
                    borderColor: AppColors.border,
                    selectable: true,
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
