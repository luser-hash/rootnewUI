import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../shared/widgets/app_detail_row.dart';
import '../../shared/widgets/app_message_card.dart';
import '../../shared/widgets/status_pills.dart';
import '../data/capital_submission_repository.dart';
import '../domain/capital_submission_request.dart';
import 'submission_list_controller.dart';

class SubmissionsPage extends StatefulWidget {
  const SubmissionsPage({super.key, required this.repository});

  final CapitalSubmissionRepository repository;

  @override
  State<SubmissionsPage> createState() => _SubmissionsPageState();
}

class _SubmissionsPageState extends State<SubmissionsPage> {
  late final SubmissionListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SubmissionListController(repository: widget.repository);
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
            const _SubmissionsHeader(),
            _StatusFilterBar(
              selected: _controller.status,
              onSelected: (CapitalSubmissionStatus? status) {
                _controller.load(status: status);
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: _buildBody(),
            ),
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
        margin: const EdgeInsets.only(top: 8),
      );
    }

    if (_controller.submissions.isEmpty) {
      return const AppMessageCard(
        icon: Icons.inbox_outlined,
        message: 'No submissions found for this filter.',
        background: AppColors.surface,
        foreground: AppColors.textMute,
        margin: EdgeInsets.only(top: 8),
      );
    }

    return Column(
      children: _controller.submissions
          .map(
            (CapitalSubmission submission) => _SubmissionCard(
              submission: submission,
              onTap: () {
                context.push(RouteNames.submissionDetail(submission.requestId));
              },
            ),
          )
          .toList(),
    );
  }
}

class _SubmissionsHeader extends StatelessWidget {
  const _SubmissionsHeader();

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
            'My Submissions',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.15,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Track your submitted fund requests and review status.',
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

class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar({required this.selected, required this.onSelected});

  final CapitalSubmissionStatus? selected;
  final ValueChanged<CapitalSubmissionStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    final List<({String label, CapitalSubmissionStatus? status})> filters =
        <({String label, CapitalSubmissionStatus? status})>[
          (label: 'All', status: null),
          for (final CapitalSubmissionStatus status
              in CapitalSubmissionStatus.values)
            (label: status.label, status: status),
        ];

    return SizedBox(
      height: 64,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final ({String label, CapitalSubmissionStatus? status}) filter =
              filters[index];
          final String label = filter.label;
          final CapitalSubmissionStatus? status = filter.status;
          final bool active = selected == status;
          return ChoiceChip(
            selected: active,
            label: Text(label),
            showCheckmark: false,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.white,
            side: BorderSide(
              color: active ? AppColors.primary : AppColors.border,
            ),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: active ? Colors.white : AppColors.textMid,
            ),
            onSelected: (_) => onSelected(status),
          );
        },
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({required this.submission, required this.onTap});

  final CapitalSubmission submission;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: <BoxShadow>[
              AppColors.softShadow(opacity: 0.10, blur: 10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _statusBackground(submission.status),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _statusIcon(submission.status),
                      size: 22,
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
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${submission.paymentChannel.label} · ${submission.txnDate}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMute,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppStatusPill(
                    label: submission.status.label,
                    background: _statusBackground(submission.status),
                    foreground: _statusForeground(submission.status),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '৳${submission.amount}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  height: 1,
                ),
              ),
              const SizedBox(height: 12),
              AppDetailRow(
                label: 'Reference',
                value: submission.externalReference,
                labelWidth: 96,
                padding: const EdgeInsets.only(bottom: 7),
                showDivider: false,
                valueWeight: FontWeight.w700,
              ),
              AppDetailRow(
                label: 'Notes',
                value: submission.notes,
                labelWidth: 96,
                padding: const EdgeInsets.only(bottom: 7),
                showDivider: false,
                valueWeight: FontWeight.w700,
              ),
              if (submission.reviewedBy != null)
                AppDetailRow(
                  label: 'Reviewed By',
                  value: submission.reviewedBy!.fullName,
                  labelWidth: 96,
                  padding: const EdgeInsets.only(bottom: 7),
                  showDivider: false,
                  valueWeight: FontWeight.w700,
                ),
              if ((submission.rejectionReason ?? '').trim().isNotEmpty)
                AppDetailRow(
                  label: 'Rejection Reason',
                  value: submission.rejectionReason!,
                  valueColor: AppColors.red,
                  labelWidth: 96,
                  padding: const EdgeInsets.only(bottom: 7),
                  showDivider: false,
                  valueWeight: FontWeight.w700,
                ),
              if ((submission.resultingLedgerId ?? '').trim().isNotEmpty)
                AppDetailRow(
                  label: 'Ledger ID',
                  value: submission.resultingLedgerId!,
                  labelWidth: 96,
                  padding: const EdgeInsets.only(bottom: 7),
                  showDivider: false,
                  valueWeight: FontWeight.w700,
                ),
              const SizedBox(height: 4),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: AppColors.textMute,
                ),
              ),
            ],
          ),
        ),
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
