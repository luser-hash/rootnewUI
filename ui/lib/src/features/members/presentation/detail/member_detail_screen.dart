import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/routing/app_router.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../auth/domain/auth_session.dart';
import '../../../auth/presentation/auth_scope.dart';
import '../../../ledger/data/member_ledger_repository.dart';
import '../../../ledger/domain/member_ledger_statement.dart';
import '../../../ledger/presentation/total_balance_card.dart';
import '../../../shared/finance.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_card_list.dart';
import '../../../shared/widgets/app_detail_block.dart';
import '../../../shared/widgets/app_detail_row.dart';
import '../../../shared/widgets/app_metric_card.dart';
import '../../../shared/widgets/app_message_card.dart';
import '../../../shared/widgets/app_panel.dart';
import '../../../shared/widgets/app_pill.dart';
import '../../../shared/widgets/app_screen_header.dart';
import '../../../shared/widgets/status_pills.dart';
import '../../../submissions/data/capital_submission_repository.dart';
import '../../../submissions/domain/capital_submission_request.dart';
import '../../../submissions/domain/submission_history.dart';
import '../../data/member_management_repository.dart';
import '../../domain/member_management_models.dart';
import '../edit_member.dart';
import '../member_detail_controller.dart';
import '../member_detail_ledger_controller.dart';
import '../member_detail_submission_history_controller.dart';

part 'member_detail_header.dart';
part 'account_details_card.dart';
part 'member_stats_grid.dart';
part 'submission_history_section.dart';
part 'member_ledger_section.dart';

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
                child: AppMetricCard(
                  value: '${submissions.length}',
                  label: 'Submissions',
                  iconText: '📋',
                  iconBackground: AppThemeColors.surface(context),
                  horizontal: true,
                  uppercaseLabel: false,
                  valueFirst: true,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppThemeColors.shadow(
                        context,
                      ).withValues(alpha: .15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppThemeColors.textMuted(context),
                  ),
                  valueStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppThemeColors.text(context),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppMetricCard(
                  value: '${submissions.where(_isApprovedHistory).length}',
                  label: 'Approved',
                  iconText: '✓',
                  iconBackground: AppThemeColors.surface(context),
                  horizontal: true,
                  uppercaseLabel: false,
                  valueFirst: true,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppThemeColors.shadow(
                        context,
                      ).withValues(alpha: .15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppThemeColors.textMuted(context),
                  ),
                  valueStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppThemeColors.text(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSection(
          title: 'Submission History',
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: _SubmissionHistorySection(
            controller: _submissionHistoryController,
          ),
        ),
        AppSection(
          title: 'Member Ledger',
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
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
