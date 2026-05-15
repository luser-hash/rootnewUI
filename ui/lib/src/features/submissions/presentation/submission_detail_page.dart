import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../shared/finance.dart';
import '../../shared/widgets/app_detail_row.dart';
import '../../shared/widgets/app_message_card.dart';
import '../../shared/widgets/app_pill.dart';
import '../../shared/widgets/app_screen_header.dart';
import '../data/capital_submission_repository.dart';
import '../domain/capital_submission_request.dart';
import 'submission_detail_controller.dart';

class SubmissionDetailPage extends StatefulWidget {
  const SubmissionDetailPage({
    super.key,
    required this.repository,
    required this.requestId,
  });

  final CapitalSubmissionRepository repository;
  final String requestId;

  @override
  State<SubmissionDetailPage> createState() => _SubmissionDetailPageState();
}

class _SubmissionDetailPageState extends State<SubmissionDetailPage> {
  late final SubmissionDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SubmissionDetailController(
      repository: widget.repository,
      requestId: widget.requestId,
    );
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const AppScreenHeader(
              title: 'Submission Detail',
              subtitle:
                  'Review the full request information and decision result.',
              padding: EdgeInsets.fromLTRB(20, 14, 20, 24),
              gradientColors: <Color>[
                AppColors.primary,
                AppColors.primaryDk,
                Color(0xFF003830),
              ],
              titleFontSize: 24,
              subtitleFontSize: 13,
            ),
            Padding(padding: const EdgeInsets.all(16), child: _buildBody()),
          ],
        );
      },
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 36),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final String? error = _controller.errorMessage;
    if (error != null) {
      return AppMessageCard(
        icon: Icons.error_outline,
        message: error,
        background: AppColors.redLt,
        foreground: AppColors.red,
      );
    }

    final CapitalSubmission? submission = _controller.submission;
    if (submission == null) {
      return const AppMessageCard(
        icon: Icons.inbox_outlined,
        message: 'Submission detail not found.',
        background: AppColors.surface,
        foreground: AppColors.textMute,
      );
    }

    return _SubmissionDetailCard(submission: submission);
  }
}

class _SubmissionDetailCard extends StatelessWidget {
  const _SubmissionDetailCard({required this.submission});

  final CapitalSubmission submission;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[AppColors.softShadow(opacity: 0.10, blur: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _statusBackground(submission.status),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  _statusIcon(submission.status),
                  size: 24,
                  color: _statusForeground(submission.status),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      submission.requestType.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '৳${submission.amount}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              AppPill(
                label: submission.status.label,
                background: _statusBackground(submission.status),
                foreground: _statusForeground(submission.status),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AppDetailRow(
            label: 'Request ID',
            value: submission.requestId,
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          AppDetailRow(
            label: 'Transaction Date',
            value: submission.txnDate,
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          AppDetailRow(
            label: 'Payment Channel',
            value: submission.paymentChannel.label,
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          AppDetailRow(
            label: 'Reference',
            value: submission.externalReference,
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          AppDetailRow(
            label: 'Notes',
            value: submission.notes,
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          AppDetailRow(
            label: 'Requested At',
            value: formatDateTimeShort(submission.requestedAt),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          if (submission.reviewedBy != null)
            AppDetailRow(
              label: 'Reviewed By',
              value: submission.reviewedBy!.fullName,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          if (submission.reviewedAt != null)
            AppDetailRow(
              label: 'Reviewed At',
              value: formatDateTimeShort(submission.reviewedAt),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          if ((submission.rejectionReason ?? '').trim().isNotEmpty)
            AppDetailRow(
              label: 'Rejection Reason',
              value: submission.rejectionReason!,
              valueColor: AppColors.red,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          if ((submission.resultingLedgerId ?? '').trim().isNotEmpty)
            AppDetailRow(
              label: 'Ledger ID',
              value: submission.resultingLedgerId!,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
        ],
      ),
    );
  }
}

Color _statusBackground(CapitalSubmissionStatus status) {
  return switch (status) {
    CapitalSubmissionStatus.pending => AppColors.amberLt,
    CapitalSubmissionStatus.approved => AppColors.greenLt,
    CapitalSubmissionStatus.rejected => AppColors.redLt,
  };
}

Color _statusForeground(CapitalSubmissionStatus status) {
  return switch (status) {
    CapitalSubmissionStatus.pending => AppColors.amber,
    CapitalSubmissionStatus.approved => AppColors.green,
    CapitalSubmissionStatus.rejected => AppColors.red,
  };
}

IconData _statusIcon(CapitalSubmissionStatus status) {
  return switch (status) {
    CapitalSubmissionStatus.pending => Icons.schedule_rounded,
    CapitalSubmissionStatus.approved => Icons.check_rounded,
    CapitalSubmissionStatus.rejected => Icons.close_rounded,
  };
}
