import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/state/app_state.dart';
import '../../shared/finance.dart';
import '../../shared/widgets/app_action_button.dart';
import '../../shared/widgets/app_pill.dart';
import '../../shared/widgets/status_pills.dart';

class ApprovalPage extends StatefulWidget {
  const ApprovalPage({super.key});

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  bool _successVisible = false;
  Timer? _successTimer;

  @override
  void dispose() {
    _successTimer?.cancel();
    super.dispose();
  }

  void _approve(String id) {
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

  void _reject(String id) {
    AppState.updateSubmissionStatus(id, SubmissionStatus.rejected);
  }

  @override
  Widget build(BuildContext context) {
    return SubmissionsBuilder(builder: _buildWithSubmissions);
  }

  Widget _buildWithSubmissions(List<Submission> submissions) {
    final List<Submission> pending = submissions
        .where((Submission s) => s.status == SubmissionStatus.pending)
        .toList();
    final List<Submission> reviewed = submissions
        .where((Submission s) => s.status != SubmissionStatus.pending)
        .toList();

    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _ApprovalHeader(subs: submissions, pendingCount: pending.length),
            if (pending.isNotEmpty)
              _PendingSubmissionList(
                pending: pending,
                onApprove: _approve,
                onReject: _reject,
              ),
            if (reviewed.isNotEmpty)
              _ReviewedSubmissionList(reviewed: reviewed),
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

class _ApprovalHeader extends StatelessWidget {
  const _ApprovalHeader({required this.subs, required this.pendingCount});

  final List<Submission> subs;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final List<({String label, String value})>
    stats = <({String label, String value})>[
      (
        label: 'Pending',
        value:
            '${subs.where((Submission s) => s.status == SubmissionStatus.pending).length}',
      ),
      (
        label: 'Approved',
        value:
            '${subs.where((Submission s) => s.status == SubmissionStatus.approved).length}',
      ),
      (
        label: 'Rejected',
        value:
            '${subs.where((Submission s) => s.status == SubmissionStatus.rejected).length}',
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
    required this.onApprove,
    required this.onReject,
  });

  final List<Submission> pending;
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
          ...pending.map(
            (Submission s) => _SubmissionCard(
              submission: s,
              onApprove: onApprove,
              onReject: onReject,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({
    required this.submission,
    required this.onApprove,
    required this.onReject,
  });

  final Submission submission;
  final ValueChanged<String> onApprove;
  final ValueChanged<String> onReject;

  @override
  Widget build(BuildContext context) {
    final int colorIdx = math.max(
      0,
      members.indexWhere((Member m) => m.name == submission.member),
    );
    final String initials = submission.member
        .split(' ')
        .map((String word) => word[0])
        .join()
        .substring(0, 2);

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
                            submission.member,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            submission.type,
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
                  fmt(submission.amount),
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
                    _DetailBox(label: 'Channel', value: submission.channel),
                    _DetailBox(label: 'Date', value: submission.date),
                    _DetailBox(
                      label: 'Reference',
                      value: submission.ref.isEmpty ? '—' : submission.ref,
                    ),
                    _DetailBox(label: 'ID', value: submission.id),
                  ],
                ),
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
                    label: '✕ Reject',
                    background: AppColors.redLt,
                    foreground: AppColors.red,
                    onTap: () => onReject(submission.id),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppActionButton(
                    label: '✓ Approve',
                    background: AppColors.primary,
                    foreground: Colors.white,
                    onTap: () => onApprove(submission.id),
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

class _ReviewedSubmissionList extends StatelessWidget {
  const _ReviewedSubmissionList({required this.reviewed});

  final List<Submission> reviewed;

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
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: <BoxShadow>[AppColors.softShadow()],
            ),
            child: Column(
              children: reviewed.asMap().entries.map((
                MapEntry<int, Submission> entry,
              ) {
                final Submission s = entry.value;
                final bool approved = s.status == SubmissionStatus.approved;
                return Container(
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
                          color: approved ? AppColors.greenLt : AppColors.redLt,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          approved ? '✓' : '✕',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              s.member,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                            Text(
                              '${s.type} · ${s.date}',
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
                            fmt(s.amount),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SubmissionStatusPill(status: s.status),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
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

