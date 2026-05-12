import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../auth/domain/auth_session.dart';
import '../../auth/presentation/auth_scope.dart';
import '../../ledger/data/member_ledger_repository.dart';
import '../../ledger/domain/member_ledger_statement.dart';
import '../../ledger/presentation/total_balance_card.dart';
import '../../shared/finance.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_card_list.dart';
import '../../shared/widgets/app_detail_block.dart';
import '../../shared/widgets/app_detail_row.dart';
import '../../shared/widgets/app_message_card.dart';
import '../../shared/widgets/app_pill.dart';
import '../../shared/widgets/status_pills.dart';
import '../../submissions/data/capital_submission_repository.dart';
import '../../submissions/domain/capital_submission_request.dart';
import '../../submissions/domain/submission_history.dart';
import '../data/member_management_repository.dart';
import '../domain/member_management_models.dart';
import 'edit_member.dart';
import 'member_detail_controller.dart';
import 'member_detail_ledger_controller.dart';
import 'member_detail_submission_history_controller.dart';

class MemberDetailScreen extends StatefulWidget {
  const MemberDetailScreen({
    super.key,
    required this.repository,
    required this.ledgerRepository,
    required this.submissionRepository,
    required this.member,
    required this.colorIdx,
    required this.onBack,
  });

  final MemberManagementRepository repository;
  final MemberLedgerRepository ledgerRepository;
  final CapitalSubmissionRepository submissionRepository;
  final Member member;
  final int colorIdx;
  final VoidCallback onBack;

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  late final MemberDetailController _controller;
  late final MemberDetailLedgerController _ledgerController;
  late final MemberDetailSubmissionHistoryController
  _submissionHistoryController;
  late Member _member;

  @override
  void initState() {
    super.initState();
    _member = widget.member;
    _controller = MemberDetailController(repository: widget.repository);
    _ledgerController = MemberDetailLedgerController(
      repository: widget.ledgerRepository,
    );
    _submissionHistoryController = MemberDetailSubmissionHistoryController(
      repository: widget.submissionRepository,
    );
    _controller.load(widget.member.id);
    _ledgerController.load(widget.member.id);
    _submissionHistoryController.load(widget.member.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    _ledgerController.dispose();
    _submissionHistoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        _controller,
        _ledgerController,
        _submissionHistoryController,
      ]),
      builder: (BuildContext context, _) => _buildContent(),
    );
  }

  Widget _buildContent() {
    final List<SubmissionHistoryItem> submissions =
        _submissionHistoryController.results;
    final bool canEdit = AuthScope.of(context).role.canManageMembers;

    return Column(
      children: <Widget>[
        _MemberDetailHeader(
          member: _member,
          colorIdx: widget.colorIdx,
          onBack: widget.onBack,
          onEdit: _handleEdit,
          canEdit: canEdit,
          isEditEnabled: _controller.user != null,
        ),
        TotalBalanceCard(
          statement: _ledgerController.statement,
          isLoading: _ledgerController.isLoading,
          errorMessage: _ledgerController.errorMessage,
        ),
        _AccountDetailsCard(
          isLoading: _controller.isLoading,
          errorMessage: _controller.errorMessage,
          user: _controller.user,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _StatCard(
                  icon: '📋',
                  value: '${submissions.length}',
                  label: 'Submissions',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: '✓',
                  value: '${submissions.where(_isApprovedHistory).length}',
                  label: 'Approved',
                ),
              ),
            ],
          ),
        ),
        _Section(
          title: 'Submission History',
          paddingBottom: 24,
          child: _SubmissionHistorySection(
            controller: _submissionHistoryController,
          ),
        ),
        _Section(
          title: 'Member Ledger',
          paddingBottom: 24,
          child: _MemberLedgerSection(controller: _ledgerController),
        ),
      ],
    );
  }

  Future<void> _handleEdit() async {
    final ManagedUser? user = _controller.user;
    if (user == null) {
      return;
    }

    final EditMemberResult? result = await context.push<EditMemberResult>(
      RouteNames.editMember,
      extra: EditMemberRouteArgs(user: user),
    );

    if (!mounted || result == null) {
      return;
    }

    if (result.action == EditMemberAction.deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member deactivated successfully.')),
      );
      widget.onBack();
      return;
    }

    final ManagedUser updated = result.user!;
    _controller.setUser(updated);
    setState(() {
      _member = Member(
        id: updated.userId,
        name: updated.fullName.isEmpty ? _member.name : updated.fullName,
        initials: updated.initials,
        capital: _member.capital,
        status: updated.status.memberStatus,
        pending: _member.pending,
      );
    });
  }
}

class _MemberDetailHeader extends StatelessWidget {
  const _MemberDetailHeader({
    required this.member,
    required this.colorIdx,
    required this.onBack,
    required this.onEdit,
    required this.canEdit,
    required this.isEditEnabled,
  });

  final Member member;
  final int colorIdx;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final bool canEdit;
  final bool isEditEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.primary, Color(0xFF004A40)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _StatusBar(dark: true),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 16),
            child: Row(
              children: <Widget>[
                Material(
                  color: Colors.white.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(10),
                    child: const SizedBox(
                      width: 36,
                      height: 36,
                      child: Center(
                        child: Text(
                          '←',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Member Profile',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                if (canEdit)
                  IconButton(
                    onPressed: isEditEnabled ? onEdit : null,
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    tooltip: 'Edit member',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: .15),
                      minimumSize: const Size(40, 40),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              AppAvatar(
                initials: member.initials,
                color: avatarColor(colorIdx),
                size: 64,
                radius: 20,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Member ID: ${member.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: .7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppPill(
                      label: member.status.label,
                      background: member.status == MemberStatus.active
                          ? AppColors.green.withValues(alpha: .25)
                          : Colors.white.withValues(alpha: .15),
                      foreground: member.status == MemberStatus.active
                          ? const Color(0xFF6EFCB8)
                          : Colors.white.withValues(alpha: .7),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountDetailsCard extends StatelessWidget {
  const _AccountDetailsCard({
    required this.isLoading,
    required this.errorMessage,
    required this.user,
  });

  final bool isLoading;
  final String? errorMessage;
  final ManagedUser? user;

  @override
  Widget build(BuildContext context) {
    final String? error = errorMessage;
    final ManagedUser? profile = user;

    return _Section(
      title: 'Account Details',
      paddingBottom: 16,
      child: AppCardList(
        children: <Widget>[
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (error != null)
            AppMessageCard(
              message: error,
              tone: AppMessageTone.neutral,
              background: Colors.transparent,
              textColor: AppColors.textMute,
              padding: const EdgeInsets.all(20),
              showBorder: false,
              showIcon: false,
              textAlign: TextAlign.center,
            )
          else if (profile == null)
            const AppMessageCard(
              message: 'No account details found.',
              tone: AppMessageTone.neutral,
              background: Colors.transparent,
              textColor: AppColors.textMute,
              padding: EdgeInsets.all(20),
              showBorder: false,
              showIcon: false,
              textAlign: TextAlign.center,
            )
          else ...<Widget>[
            AppDetailRow(
              icon: Icons.badge_outlined,
              label: 'User ID',
              value: valueOrDash(profile.userId),
            ),
            AppDetailRow(
              icon: Icons.phone_outlined,
              label: 'Contact No',
              value: valueOrDash(profile.contactNo),
            ),
            AppDetailRow(
              icon: Icons.mail_outline,
              label: 'Email',
              value: valueOrDash(profile.email),
            ),
            AppDetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Join Date',
              value: valueOrDash(profile.joinDate),
            ),
            AppDetailRow(
              icon: Icons.admin_panel_settings_outlined,
              label: 'Role',
              value: profile.role.label,
            ),
            AppDetailRow(
              icon: Icons.verified_user_outlined,
              label: 'Status',
              value: profile.status.label,
            ),
            AppDetailRow(
              icon: Icons.notes_outlined,
              label: 'Notes',
              value: valueOrDash(profile.notes),
            ),
            AppDetailRow(
              icon: Icons.history_outlined,
              label: 'Created At',
              value: formatDateTimeShort(profile.createdAt),
            ),
            AppDetailRow(
              icon: Icons.update_outlined,
              label: 'Updated At',
              value: formatDateTimeShort(profile.updatedAt),
              isLast: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final String icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[AppColors.softShadow(opacity: 0.15, blur: 8)],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMute,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
            textColor: AppColors.textMute,
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
      return const AppCardList(
        children: <Widget>[
          AppMessageCard(
            message: 'No submissions yet.',
            tone: AppMessageTone.neutral,
            background: Colors.transparent,
            textColor: AppColors.textMute,
            padding: EdgeInsets.all(20),
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
    final Color foreground = _submissionStatusForeground(submission.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showSubmissionDetails(context),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: isLast
                  ? BorderSide.none
                  : const BorderSide(color: AppColors.border),
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
                  color: _submissionStatusBackground(submission.status),
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
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${valueOrDash(submission.txnDate)} · ${submission.requestId}',
                      overflow: TextOverflow.ellipsis,
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
                    _formatMoney(submission.amount),
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
                      submission.status,
                    ),
                    foreground: _submissionStatusForeground(
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
      backgroundColor: AppColors.white,
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
                        color: _submissionStatusBackground(submission.status),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _submissionStatusIcon(submission.status),
                        size: 18,
                        color: _submissionStatusForeground(submission.status),
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
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _submissionMeta(submission),
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
                      background: _submissionStatusBackground(
                        submission.status,
                      ),
                      foreground: _submissionStatusForeground(
                        submission.status,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _formatMoney(submission.amount),
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

class _MemberLedgerSection extends StatelessWidget {
  const _MemberLedgerSection({required this.controller});

  final MemberDetailLedgerController controller;

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
            textColor: AppColors.textMute,
            padding: const EdgeInsets.all(20),
            showBorder: false,
            showIcon: false,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    final MemberLedgerStatement? statement = controller.statement;
    final List<MemberLedgerEntry> entries =
        statement?.entries ?? <MemberLedgerEntry>[];
    if (entries.isEmpty) {
      return const AppCardList(
        children: <Widget>[
          AppMessageCard(
            message: 'No ledger entries yet.',
            tone: AppMessageTone.neutral,
            background: Colors.transparent,
            textColor: AppColors.textMute,
            padding: EdgeInsets.all(20),
            showBorder: false,
            showIcon: false,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return AppCardList(
      children: entries
          .asMap()
          .entries
          .map(
            (MapEntry<int, MemberLedgerEntry> entry) => _MemberLedgerRow(
              statement: statement,
              entry: entry.value,
              isLast: entry.key == entries.length - 1,
            ),
          )
          .toList(),
    );
  }
}

class _MemberLedgerRow extends StatelessWidget {
  const _MemberLedgerRow({
    required this.statement,
    required this.entry,
    required this.isLast,
  });

  final MemberLedgerStatement? statement;
  final MemberLedgerEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final double amount = double.tryParse(entry.amount) ?? 0;
    final bool positive = _isLedgerInflow(entry.entryType, amount);
    final Color foreground = _ledgerEntryForeground(entry.entryType);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLedgerDetails(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: isLast
                  ? BorderSide.none
                  : const BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _ledgerEntryBackground(entry.entryType),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  _ledgerEntryIcon(entry.entryType),
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
                      entry.txnDate.isEmpty ? '-' : entry.txnDate,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.entryType.label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMute,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${positive ? '+' : '-'}${_formatMoney(entry.amount)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: positive ? AppColors.green : AppColors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLedgerDetails(BuildContext context) {
    final MemberLedgerUser? user = statement?.user;
    final double amount = double.tryParse(entry.amount) ?? 0;
    final bool positive = _isLedgerInflow(entry.entryType, amount);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
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
                        color: _ledgerEntryBackground(entry.entryType),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _ledgerEntryIcon(entry.entryType),
                        size: 18,
                        color: _ledgerEntryForeground(entry.entryType),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            entry.entryType.label,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            valueOrDash(
                              user?.fullName.isNotEmpty == true
                                  ? user?.fullName
                                  : entry.memberName,
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMute,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${positive ? '+' : '-'}${_formatMoney(entry.amount)}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: positive ? AppColors.green : AppColors.red,
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
                      label: 'Balance',
                      value: _formatMoney(statement?.currentBalance),
                      borderColor: AppColors.border,
                      center: true,
                    ),
                    AppDetailBlock(
                      label: 'Pending',
                      value: _formatMoney(statement?.pendingTotal),
                      borderColor: AppColors.border,
                      center: true,
                    ),
                    AppDetailBlock(
                      label: 'Entries',
                      value: '${statement?.entryCount ?? 0}',
                      borderColor: AppColors.border,
                      center: true,
                    ),
                    AppDetailBlock(
                      label: 'Currency',
                      value: entry.currency,
                      borderColor: AppColors.border,
                      center: true,
                    ),
                    AppDetailBlock(
                      label: 'Txn Date',
                      value: valueOrDash(entry.txnDate),
                      borderColor: AppColors.border,
                      center: true,
                    ),
                    AppDetailBlock(
                      label: 'Created',
                      value: formatDateTimeShort(entry.createdAt),
                      borderColor: AppColors.border,
                      center: true,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AppDetailBlock(
                  label: 'User ID',
                  value: valueOrDash(user?.userId ?? entry.userId),
                  borderColor: AppColors.border,
                  selectable: true,
                ),
                const SizedBox(height: 8),
                AppDetailBlock(
                  label: 'Full Name',
                  value: valueOrDash(user?.fullName ?? entry.memberName),
                  borderColor: AppColors.border,
                  selectable: true,
                ),
                const SizedBox(height: 8),
                AppDetailBlock(
                  label: 'Contact No',
                  value: valueOrDash(user?.contactNo ?? entry.memberContact),
                  borderColor: AppColors.border,
                  selectable: true,
                ),
                const SizedBox(height: 8),
                AppDetailBlock(
                  label: 'Ledger ID',
                  value: entry.ledgerId,
                  borderColor: AppColors.border,
                  selectable: true,
                ),
                const SizedBox(height: 8),
                AppDetailBlock(
                  label: 'Reference Type',
                  value: valueOrDash(entry.referenceType),
                  borderColor: AppColors.border,
                  selectable: true,
                ),
                const SizedBox(height: 8),
                AppDetailBlock(
                  label: 'Reference ID',
                  value: valueOrDash(entry.referenceId),
                  borderColor: AppColors.border,
                  selectable: true,
                ),
                const SizedBox(height: 8),
                AppDetailBlock(
                  label: 'Comment',
                  value: valueOrDash(entry.comment),
                  borderColor: AppColors.border,
                  selectable: true,
                ),
                const SizedBox(height: 8),
                AppDetailBlock(
                  label: 'Created By',
                  value: valueOrDash(entry.createdByName),
                  borderColor: AppColors.border,
                  selectable: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.paddingBottom = 0,
  });

  final String title;
  final Widget child;
  final double paddingBottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, paddingBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: dark ? 0 : 0);
  }
}

bool _isApprovedHistory(SubmissionHistoryItem submission) {
  return submission.isApproved;
}

String _submissionMeta(SubmissionHistoryItem submission) {
  return '${submission.paymentChannel.label} · ${valueOrDash(submission.txnDate)}';
}

Color _submissionStatusBackground(CapitalSubmissionStatus status) {
  return switch (status) {
    CapitalSubmissionStatus.pending => AppColors.amberLt,
    CapitalSubmissionStatus.approved => AppColors.greenLt,
    CapitalSubmissionStatus.rejected => AppColors.redLt,
  };
}

Color _submissionStatusForeground(CapitalSubmissionStatus status) {
  return switch (status) {
    CapitalSubmissionStatus.pending => AppColors.amber,
    CapitalSubmissionStatus.approved => AppColors.green,
    CapitalSubmissionStatus.rejected => AppColors.red,
  };
}

IconData _submissionStatusIcon(CapitalSubmissionStatus status) {
  return switch (status) {
    CapitalSubmissionStatus.pending => Icons.schedule_rounded,
    CapitalSubmissionStatus.approved => Icons.check_rounded,
    CapitalSubmissionStatus.rejected => Icons.close_rounded,
  };
}

Color _ledgerEntryBackground(MemberLedgerEntryType type) {
  return switch (type) {
    MemberLedgerEntryType.submission => AppColors.greenLt,
    MemberLedgerEntryType.withdraw => AppColors.redLt,
    MemberLedgerEntryType.adjustment => AppColors.amberLt,
    MemberLedgerEntryType.distribution => AppColors.blueLt,
    MemberLedgerEntryType.distributionReversal => AppColors.redLt,
  };
}

Color _ledgerEntryForeground(MemberLedgerEntryType type) {
  return switch (type) {
    MemberLedgerEntryType.submission => AppColors.green,
    MemberLedgerEntryType.withdraw => AppColors.red,
    MemberLedgerEntryType.adjustment => AppColors.amber,
    MemberLedgerEntryType.distribution => AppColors.blue,
    MemberLedgerEntryType.distributionReversal => AppColors.red,
  };
}

IconData _ledgerEntryIcon(MemberLedgerEntryType type) {
  return switch (type) {
    MemberLedgerEntryType.submission => Icons.south_rounded,
    MemberLedgerEntryType.withdraw => Icons.north_rounded,
    MemberLedgerEntryType.adjustment => Icons.tune_rounded,
    MemberLedgerEntryType.distribution => Icons.call_split_rounded,
    MemberLedgerEntryType.distributionReversal => Icons.undo_rounded,
  };
}

bool _isLedgerInflow(MemberLedgerEntryType type, double amount) {
  if (amount < 0) {
    return false;
  }
  return switch (type) {
    MemberLedgerEntryType.withdraw => false,
    MemberLedgerEntryType.distributionReversal => false,
    _ => true,
  };
}

String _formatMoney(String? value) {
  final double amount = double.tryParse(value ?? '0') ?? 0;
  return '৳${amount.abs().toStringAsFixed(2)}';
}
