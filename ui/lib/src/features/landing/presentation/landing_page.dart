import 'package:flutter/material.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../auth/domain/auth_session.dart';
import '../../auth/presentation/auth_scope.dart';
import '../../ledger/data/member_ledger_repository.dart';
import '../../members/data/member_management_repository.dart';
import '../../members/domain/member_management_models.dart';
import '../../members/presentation/member_list_controller.dart';
import '../../shared/finance.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_card_list.dart';
import '../../shared/widgets/app_small_button.dart';
import '../../shared/widgets/status_pills.dart';
import '../../submissions/data/capital_submission_repository.dart';
import 'landing_approval_summary_controller.dart';
import 'landing_hero_summary_controller.dart';

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: dark ? 0 : 0);
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.memberRepository,
    required this.memberLedgerRepository,
    required this.capitalSubmissionRepository,
    required this.onNav,
    required this.onMemberSelect,
  });

  final MemberManagementRepository memberRepository;
  final MemberLedgerRepository memberLedgerRepository;
  final CapitalSubmissionRepository capitalSubmissionRepository;
  final ValueChanged<String> onNav;
  final void Function(Member member, int memberColorIdx) onMemberSelect;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final LandingApprovalSummaryController _approvalController;
  late final LandingHeroSummaryController _heroController;
  bool _balanceHidden = false;
  bool _signingOut = false;
  bool _approvalSummaryRequested = false;
  bool _heroSummaryRequested = false;

  @override
  void initState() {
    super.initState();
    _approvalController = LandingApprovalSummaryController(
      repository: widget.capitalSubmissionRepository,
    );
    _heroController = LandingHeroSummaryController(
      ledgerRepository: widget.memberLedgerRepository,
      memberRepository: widget.memberRepository,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final UserRole role = AuthScope.of(context).role;
    if (!_heroSummaryRequested) {
      _heroSummaryRequested = true;
      _heroController.load(
        canViewAllLedger: role.canViewAllLedger,
        canViewMembers: role.canViewMembers,
      );
    }
    if (!_approvalSummaryRequested && role.canViewApprovals) {
      _approvalSummaryRequested = true;
      _approvalController.load();
    }
  }

  @override
  void dispose() {
    _approvalController.dispose();
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        _approvalController,
        _heroController,
      ]),
      builder: (BuildContext context, _) => _buildContent(),
    );
  }

  Widget _buildContent() {
    final UserRole role = AuthScope.of(context).role;
    final num totalCapital = _heroController.totalCapital;
    final int pendingCount = _approvalController.pendingCount;
    final num totalPending = _approvalController.pendingTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildHero(totalCapital, totalPending),
        if (role.canViewApprovals && pendingCount > 0) _buildAlert(pendingCount),
        _buildQuickActions(pendingCount, role),
        if (role.canViewMembers)
          _MembersCarousel(
            repository: widget.memberRepository,
            onNav: widget.onNav,
            onMemberSelect: widget.onMemberSelect,
          ),
        _InvestmentsCarousel(onNav: widget.onNav),
        _RecentActivitySection(onNav: widget.onNav),
      ],
    );
  }

  Widget _buildHero(num totalCapital, num totalPending) {
    final AuthUser? user = AuthScope.of(context).session?.user;
    final String displayName = _displayName(user);
    final String initials = _initials(displayName);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.primary,
            AppColors.primaryDk,
            Color(0xFF003830),
          ],
          stops: <double>[0, 0.6, 1],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .04),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: .08),
              ),
            ),
          ),
          Column(
            children: <Widget>[
              const _StatusBar(dark: true),
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'আস-সালামু আলাইকুম,',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: .7),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        _HeroIconButton(
                          icon: _signingOut
                              ? Icons.hourglass_empty_rounded
                              : Icons.logout_rounded,
                          tooltip: 'Sign out',
                          onTap: _signingOut ? null : _handleSignOut,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: .25),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            initials,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Total Association Capital',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: .6),
                        letterSpacing: 0.66,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        Text(
                          _balanceHidden ? '••••••' : fmtSh(totalCapital),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () =>
                              setState(() => _balanceHidden = !_balanceHidden),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _balanceHidden ? '🙈' : '👁',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: .8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 1,
                          height: 32,
                          color: Colors.white.withValues(alpha: .2),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                'Pending',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withValues(alpha: .5),
                                ),
                              ),
                              Text(
                                _balanceHidden ? '••••' : fmtSh(totalPending),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accentLt,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _heroSummaryText(),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.accent.withValues(alpha: .9),
                        fontWeight: FontWeight.w600,
                      ),
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

  String _heroSummaryText() {
    if (_heroController.isLoading) {
      return 'Loading dashboard summary...';
    }
    if (_heroController.errorMessage != null) {
      return 'Dashboard summary unavailable';
    }
    return '↑ ${fmtSh(_heroController.weeklyAdded)} added this week · '
        '${_heroController.activeMemberCount} active members';
  }

  Widget _buildAlert(int pendingCount) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            AppColors.amber.withValues(alpha: .15),
            AppColors.amber.withValues(alpha: .08),
          ],
        ),
        border: Border.all(
          color: AppColors.amber.withValues(alpha: .4),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          const Text('⚠️', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$pendingCount Pending Approvals',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Review submission requests',
                  style: TextStyle(fontSize: 11, color: AppColors.textMute),
                ),
              ],
            ),
          ),
          AppSmallButton(
            label: 'Review',
            background: AppColors.amber,
            foreground: Colors.white,
            onTap: () => widget.onNav(RouteNames.approvals),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(int pendingCount, UserRole role) {
    final List<_QuickAction> actions = <_QuickAction>[
      if (role.canSubmitFunds)
        const _QuickAction(
          icon: '📥',
          label: 'Submit Funds',
          color: Color(0xFFE8F5F3),
          screen: RouteNames.submitFunds,
        ),
      if (role.canViewOwnProfile && role == UserRole.member)
        const _QuickAction(
          icon: '👤',
          label: 'Profile',
          color: AppColors.surface,
          screen: RouteNames.profile,
        ),
      if (role.canViewOwnSubmissions)
        const _QuickAction(
          icon: '🧾',
          label: 'Submissions',
          color: AppColors.amberLt,
          screen: RouteNames.submissions,
        ),
      if (role.canViewApprovals)
        _QuickAction(
          icon: '📋',
          label: 'Approvals',
          color: AppColors.amberLt,
          screen: RouteNames.approvals,
          badge: pendingCount,
        ),
      const _QuickAction(
        icon: '📊',
        label: 'Investments',
        color: AppColors.blueLt,
        screen: RouteNames.investments,
      ),
      if (role.canViewMembers)
        const _QuickAction(
          icon: '👥',
          label: 'Members',
          color: AppColors.purpleLt,
          screen: RouteNames.members,
        ),
      _QuickAction(
        icon: '📖',
        label: 'Ledger',
        color: AppColors.greenLt,
        screen: role == UserRole.member
            ? RouteNames.memberLedger
            : RouteNames.ledger,
      ),
      if (role.canDistribute)
        const _QuickAction(
          icon: '📤',
          label: 'Distribute',
          color: Color(0xFFFEF0F0),
        ),
      if (role.canViewOwnReports)
        const _QuickAction(
          icon: '📈',
          label: 'Reports',
          color: Color(0xFFFFF8ED),
        ),
      if (role.canManagePermissions)
        const _QuickAction(
          icon: '⚙️',
          label: 'Permissions',
          color: AppColors.surface,
        ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textMid,
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              mainAxisExtent: 110,
            ),
            itemBuilder: (BuildContext context, int index) {
              final _QuickAction action = actions[index];
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: action.screen == null
                    ? null
                    : () => widget.onNav(action.screen!),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(4, 14, 4, 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: <BoxShadow>[
                      AppColors.softShadow(opacity: 0.06, blur: 8),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          Container(
                            width: 46,
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: action.color,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              action.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          if (action.badge > 0)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                width: 16,
                                height: 16,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  '${action.badge}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMid,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignOut() async {
    setState(() => _signingOut = true);

    await AuthScope.of(context).signOut();

    if (mounted) {
      setState(() => _signingOut = false);
    }
  }

  String _displayName(AuthUser? user) {
    final String? name = user?.name.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    final String? phone = user?.phone.trim();
    if (phone != null && phone.isNotEmpty) {
      return phone;
    }

    return 'Member';
  }

  String _initials(String value) {
    final List<String> parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'M';
    }

    if (parts.length == 1) {
      return _leadingChars(parts.first, 2).toUpperCase();
    }

    return '${_leadingChars(parts.first, 1)}${_leadingChars(parts.last, 1)}'
        .toUpperCase();
  }

  String _leadingChars(String value, int count) {
    return String.fromCharCodes(value.runes.take(count));
  }
}

class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    this.screen,
    this.badge = 0,
  });

  final String icon;
  final String label;
  final Color color;
  final String? screen;
  final int badge;
}

class _MembersCarousel extends StatefulWidget {
  const _MembersCarousel({
    required this.repository,
    required this.onNav,
    required this.onMemberSelect,
  });

  final MemberManagementRepository repository;
  final ValueChanged<String> onNav;
  final void Function(Member member, int memberColorIdx) onMemberSelect;

  @override
  State<_MembersCarousel> createState() => _MembersCarouselState();
}

class _MembersCarouselState extends State<_MembersCarousel> {
  late final MemberListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MemberListController(repository: widget.repository);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Members',
      actionLabel: 'See All →',
      onAction: () => widget.onNav(RouteNames.members),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, _) {
          return _buildBody();
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const SizedBox(
        height: 110,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final String? error = _controller.errorMessage;
    if (error != null) {
      return _MemberCarouselMessage(message: error);
    }

    final List<ManagedUser> users = _controller.users;
    if (users.isEmpty) {
      return const _MemberCarouselMessage(message: 'No members found.');
    }

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: users.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (BuildContext context, int index) {
          final ManagedUser user = users[index];
          final Member member = user.toMember();
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => widget.onMemberSelect(member, index),
            child: Container(
              width: 72,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: <BoxShadow>[
                  AppColors.softShadow(opacity: 0.15, blur: 8),
                ],
              ),
              child: Column(
                children: <Widget>[
                  AppAvatar(
                    initials: member.initials,
                    color: avatarColor(index),
                    size: 44,
                    radius: 14,
                    active: member.status == MemberStatus.active,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _firstName(member.name),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMid,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.role.label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMute,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _firstName(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Member';
    }
    return trimmed.split(RegExp(r'\s+')).first;
  }
}

class _MemberCarouselMessage extends StatelessWidget {
  const _MemberCarouselMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[AppColors.softShadow(opacity: 0.10, blur: 8)],
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: AppColors.textMute),
      ),
    );
  }
}

class _InvestmentsCarousel extends StatelessWidget {
  const _InvestmentsCarousel({required this.onNav});

  final ValueChanged<String> onNav;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Investments',
      actionLabel: 'See All →',
      onAction: () => onNav(RouteNames.investments),
      child: SizedBox(
        height: 165,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: investments.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (BuildContext context, int index) =>
              _InvestmentChip(inv: investments[index]),
        ),
      ),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection({required this.onNav});

  final ValueChanged<String> onNav;

  @override
  Widget build(BuildContext context) {
    final UserRole role = AuthScope.of(context).role;

    return _Section(
      title: 'Recent Activity',
      actionLabel: 'Ledger →',
      onAction: () => onNav(
        role == UserRole.member ? RouteNames.memberLedger : RouteNames.ledger,
      ),
      paddingBottom: 24,
      child: AppCardList(
        children: txns
            .map((TransactionItem t) => _TransactionRow(txn: t))
            .toList(),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
    this.paddingBottom = 0,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget child;
  final double paddingBottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, paddingBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              if (actionLabel != null)
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({this.txn, this.submission, this.isLast = false});

  final TransactionItem? txn;
  final Submission? submission;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final bool fromTxn = txn != null;
    final TxnType type =
        txn?.type ??
        (submission!.status == SubmissionStatus.approved
            ? TxnType.incoming
            : TxnType.outgoing);
    final Color iconBg = switch (type) {
      TxnType.incoming => AppColors.greenLt,
      TxnType.outgoing => AppColors.redLt,
      TxnType.distribution => AppColors.blueLt,
    };
    final Color iconColor = switch (type) {
      TxnType.incoming => AppColors.green,
      TxnType.outgoing => AppColors.red,
      TxnType.distribution => AppColors.blue,
    };
    final String icon =
        txn?.icon ??
        (submission!.status == SubmissionStatus.approved
            ? '✓'
            : submission!.status == SubmissionStatus.rejected
            ? '✕'
            : '⏳');
    final String label =
        txn?.label ?? '${submission!.type} · ${submission!.channel}';
    final String sub = txn?.sub ?? '${submission!.date} · ${submission!.id}';
    final int amount = txn?.amount ?? submission!.amount;
    final String date = txn?.date ?? '';

    return Container(
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
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              icon,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: iconColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
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
                '${fromTxn && amount > 0 ? '+' : ''}${fmt(amount)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 2),
              fromTxn
                  ? Text(
                      date,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMute,
                      ),
                    )
                  : SubmissionStatusPill(status: submission!.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvestmentChip extends StatelessWidget {
  const _InvestmentChip({required this.inv});

  final Investment inv;

  @override
  Widget build(BuildContext context) {
    final Color border = inv.status == InvestmentStatus.open
        ? AppColors.primary.withValues(alpha: .3)
        : inv.status == InvestmentStatus.draft
        ? AppColors.amber.withValues(alpha: .3)
        : Colors.transparent;
    final int? pnl = inv.pnl;
    return Container(
      width: 210,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 1.5),
        boxShadow: <BoxShadow>[AppColors.softShadow()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InvestmentStatusPill(status: inv.status),
          const SizedBox(height: 10),
          Text(
            inv.title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            inv.to,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.textMute),
          ),
          const SizedBox(height: 12),
          Text(
            fmt(inv.amount),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pnl == null
                ? 'P&L Pending'
                : '${pnl >= 0 ? '+' : ''}${fmt(pnl)} P&L',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: pnl == null
                  ? AppColors.textMute
                  : pnl >= 0
                  ? AppColors.green
                  : AppColors.red,
            ),
          ),
        ],
      ),
    );
  }
}
