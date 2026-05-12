import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../shared/finance.dart';
import '../../shared/widgets/app_pill.dart';
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
            const _DetailHeader(),
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
      return _MessageCard(
        icon: Icons.error_outline,
        message: error,
        background: AppColors.redLt,
        foreground: AppColors.red,
      );
    }

    final CapitalSubmission? submission = _controller.submission;
    if (submission == null) {
      return const _MessageCard(
        icon: Icons.inbox_outlined,
        message: 'Submission detail not found.',
        background: AppColors.surface,
        foreground: AppColors.textMute,
      );
    }

    return _SubmissionDetailCard(submission: submission);
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.primary,
            AppColors.primaryDk,
            Color(0xFF003830),
          ],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Submission Detail',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.15,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Review the full request information and decision result.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: Color(0xCFFFFFFF),
            ),
          ),
        ],
      ),
    );
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
          _DetailLine(label: 'Request ID', value: submission.requestId),
          _DetailLine(label: 'Transaction Date', value: submission.txnDate),
          _DetailLine(
            label: 'Payment Channel',
            value: submission.paymentChannel.label,
          ),
          _DetailLine(label: 'Reference', value: submission.externalReference),
          _DetailLine(label: 'Notes', value: submission.notes),
          _DetailLine(
            label: 'Requested At',
            value: formatDateTimeShort(submission.requestedAt),
          ),
          if (submission.reviewedBy != null)
            _DetailLine(
              label: 'Reviewed By',
              value: submission.reviewedBy!.fullName,
            ),
          if (submission.reviewedAt != null)
            _DetailLine(
              label: 'Reviewed At',
              value: formatDateTimeShort(submission.reviewedAt),
            ),
          if ((submission.rejectionReason ?? '').trim().isNotEmpty)
            _DetailLine(
              label: 'Rejection Reason',
              value: submission.rejectionReason!,
              valueColor: AppColors.red,
            ),
          if ((submission.resultingLedgerId ?? '').trim().isNotEmpty)
            _DetailLine(
              label: 'Ledger ID',
              value: submission.resultingLedgerId!,
            ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.label,
    required this.value,
    this.valueColor = AppColors.text,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 116,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textMute,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '-' : value,
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: foreground.withValues(alpha: .18)),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: foreground),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: AppColors.textMid,
              ),
            ),
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
