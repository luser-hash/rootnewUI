import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_mode_controller.dart';
import '../../activity/data/activity_repository.dart';
import '../../activity/domain/activity_feed.dart';
import '../../auth/domain/auth_session.dart';
import '../../auth/presentation/auth_scope.dart';
import '../../investments/data/investment_repository.dart';
import '../../ledger/data/member_ledger_repository.dart';
import '../../members/data/member_management_repository.dart';
import '../../members/domain/member_management_models.dart';
import '../../members/presentation/member_list_controller.dart';
import '../../reports/data/staff_report_repository.dart';
import '../../shared/finance.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_card_list.dart';
import '../../shared/widgets/app_small_button.dart';
import '../../shared/widgets/status_pills.dart';
import '../../submissions/data/capital_submission_repository.dart';
import 'landing_approval_summary_controller.dart';
import 'landing_hero_summary_controller.dart';

part 'widgets/home_status_bar.dart';
part 'widgets/home_hero.dart';
part 'widgets/quick_action_grid.dart';
part 'widgets/members_carousel.dart';
part 'widgets/recent_activity_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.activityRepository,
    required this.memberRepository,
    required this.memberLedgerRepository,
    required this.staffReportRepository,
    required this.capitalSubmissionRepository,
    required this.investmentRepository,
    required this.onNav,
    required this.onMemberSelect,
  });

  final ActivityRepository activityRepository;
  final MemberManagementRepository memberRepository;
  final MemberLedgerRepository memberLedgerRepository;
  final StaffReportRepository staffReportRepository;
  final CapitalSubmissionRepository capitalSubmissionRepository;
  final InvestmentRepository investmentRepository;
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
      staffReportRepository: widget.staffReportRepository,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final UserRole role = AuthScope.of(context).role;
    if (!_heroSummaryRequested) {
      _heroSummaryRequested = true;
      _heroController.load(
        canViewCapitalSummary: role.canViewAllLedger,
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
        _buildHero(totalCapital, totalPending, role),
        if (role.canViewApprovals && pendingCount > 0)
          _buildAlert(pendingCount),
        _buildQuickActions(pendingCount, role),
        _InvestmentsPreviewSection(
          repository: widget.investmentRepository,
          onNav: widget.onNav,
        ),
        _RecentActivitySection(
          repository: widget.activityRepository,
          onNav: widget.onNav,
        ),
        if (role.canViewMembers)
          _MembersCarousel(
            repository: widget.memberRepository,
            onNav: widget.onNav,
            onMemberSelect: widget.onMemberSelect,
          ),
      ],
    );
  }

  Widget _buildHero(num totalCapital, num totalPending, UserRole role) {
    final AuthUser? user = AuthScope.of(context).session?.user;
    final String displayName = _displayName(user);
    final String initials = _initials(displayName);
    final bool showCapitalSummary = role.canViewAllLedger;
    final AppThemeController themeController = AppThemeScope.of(context);

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
                          icon: themeController.isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          tooltip: themeController.isDark
                              ? 'Switch to light mode'
                              : 'Switch to dark mode',
                          onTap: themeController.toggleThemeMode,
                        ),
                        const SizedBox(width: 8),
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
              if (showCapitalSummary)
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
                            onTap: () => setState(
                              () => _balanceHidden = !_balanceHidden,
                            ),
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
                )
              else
                _buildMemberFinanceSummary(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberFinanceSummary() {
    final bool hasStatement = _heroController.memberStatement != null;
    final String capital = _memberWalletValue(
      hasStatement: hasStatement,
      value: _heroController.memberCapital,
      hiddenValue: '••••',
    );
    final String profit = _memberWalletValue(
      hasStatement: hasStatement,
      value: _heroController.memberProfitWallet,
      hiddenValue: '••••',
    );
    final String total = hasStatement
        ? (_balanceHidden ? '••••••' : fmtSh(_heroController.memberTotalAmount))
        : (_heroController.errorMessage == null ? 'Loading...' : '-');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'My Total Amount',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: .6),
                    letterSpacing: 0.66,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
            ],
          ),
          const SizedBox(height: 6),
          Text(
            total,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 31,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _HeroWalletMetric(
                  label: 'Capital',
                  value: capital,
                  icon: Icons.account_balance_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroWalletMetric(
                  label: 'Profit Wallet',
                  value: profit,
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _memberFinanceSummaryText(),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.accent.withValues(alpha: .9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _memberFinanceSummaryText() {
    if (_heroController.isLoading) {
      return 'Loading wallet summary...';
    }
    if (_heroController.errorMessage != null) {
      return 'Wallet summary unavailable';
    }
    return 'Capital and Profit Wallet';
  }

  String _memberWalletValue({
    required bool hasStatement,
    required num value,
    required String hiddenValue,
  }) {
    if (!hasStatement) {
      return '-';
    }
    return _balanceHidden ? hiddenValue : fmtSh(value);
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
    final Color background = AppThemeColors.statusWarningBg(context);
    final Color foreground = AppThemeColors.statusWarningFg(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[background, background.withValues(alpha: .72)],
        ),
        border: Border.all(color: foreground.withValues(alpha: .4), width: 1.5),
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
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppThemeColors.text(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Review submission requests',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppThemeColors.textMuted(context),
                  ),
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
    final List<_QuickAction> actions = _quickActionsFor(
      pendingCount: pendingCount,
      role: role,
    );
    final Color card = AppThemeColors.card(context);
    final Color text = AppThemeColors.textMid(context);
    final Color shadow = AppThemeColors.shadow(context).withValues(alpha: .06);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: text,
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
                    color: card,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
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
                              color: action.background(context),
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
                                  border: Border.all(color: card, width: 2),
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
                        style: TextStyle(
                          fontSize: 10,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: text,
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

class _HeroWalletMetric extends StatelessWidget {
  const _HeroWalletMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: .12)),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: .55),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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

class _InvestmentsPreviewSection extends StatefulWidget {
  const _InvestmentsPreviewSection({
    required this.repository,
    required this.onNav,
  });

  final InvestmentRepository repository;
  final ValueChanged<String> onNav;

  @override
  State<_InvestmentsPreviewSection> createState() =>
      _InvestmentsPreviewSectionState();
}

class _InvestmentsPreviewSectionState
    extends State<_InvestmentsPreviewSection> {
  late Future<List<Investment>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.list();
  }

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Investments',
      actionLabel: 'See All →',
      onAction: () => widget.onNav(RouteNames.investments),
      child: FutureBuilder<List<Investment>>(
        future: _future,
        builder:
            (BuildContext context, AsyncSnapshot<List<Investment>> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 150,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              if (snapshot.hasError) {
                return const _InvestmentPreviewMessage(
                  message: 'Unable to load investments.',
                );
              }

              final List<Investment> investments =
                  snapshot.data ?? <Investment>[];
              if (investments.isEmpty) {
                return const _InvestmentPreviewMessage(
                  message: 'No investments found.',
                );
              }

              return SizedBox(
                height: 186,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: investments.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (BuildContext context, int index) {
                    return _InvestmentPreviewCard(
                      investment: investments[index],
                    );
                  },
                ),
              );
            },
      ),
    );
  }
}

class _InvestmentPreviewCard extends StatelessWidget {
  const _InvestmentPreviewCard({required this.investment});

  final Investment investment;

  @override
  Widget build(BuildContext context) {
    final num? pnl = investment.pnl;
    final bool positivePnl = (pnl ?? 0) >= 0;
    final Color shadow = AppThemeColors.shadow(context).withValues(alpha: .10);

    return Container(
      width: 236,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppThemeColors.border(context).withValues(alpha: .65),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(color: shadow, blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InvestmentStatusPill(status: investment.status),
          const SizedBox(height: 12),
          Text(
            investment.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppThemeColors.text(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            investment.to.trim().isEmpty ? '-' : investment.to,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppThemeColors.textMuted(context),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            fmt(investment.amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: AppThemeColors.text(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pnl == null
                ? 'Pending P&L'
                : '${positivePnl ? '+' : '-'}${fmt(pnl)} P&L',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: pnl == null
                  ? AppThemeColors.textMuted(context)
                  : positivePnl
                  ? AppThemeColors.statusSuccessFg(context)
                  : AppThemeColors.statusErrorFg(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvestmentPreviewMessage extends StatelessWidget {
  const _InvestmentPreviewMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final Color shadow = AppThemeColors.shadow(context).withValues(alpha: .10);

    return Container(
      height: 150,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(color: shadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: AppThemeColors.textMuted(context),
        ),
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppThemeColors.text(context),
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
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
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
