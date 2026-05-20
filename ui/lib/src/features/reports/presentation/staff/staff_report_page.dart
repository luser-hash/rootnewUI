import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../shared/finance.dart';
import '../../../shared/widgets/app_data_table.dart';
import '../../../shared/widgets/app_metric_card.dart';
import '../../../shared/widgets/app_message_card.dart';
import '../../../shared/widgets/app_panel.dart';
import '../../../shared/widgets/app_screen_header.dart';
import '../../../shared/widgets/status_pills.dart';
import '../../data/staff_report_repository.dart';
import '../../domain/staff_report_models.dart';

part 'sections/association_summary_section.dart';
part 'sections/member_balances_section.dart';
part 'sections/investment_register_section.dart';
part 'sections/distribution_logs_section.dart';
part 'sections/approval_queue_section.dart';
part 'widgets/report_section_tabs.dart';
part 'widgets/report_timestamp_bar.dart';
part 'staff_report_controller.dart';

class StaffReportPage extends StatefulWidget {
  const StaffReportPage({super.key, required this.repository});

  final StaffReportRepository repository;

  @override
  State<StaffReportPage> createState() => _StaffReportPageState();
}

class _StaffReportPageState extends State<StaffReportPage> {
  _StaffReportSection _section = _StaffReportSection.summary;
  _MemberStatusFilter _memberStatus = _MemberStatusFilter.active;
  _MemberSort _memberSort = _MemberSort.total;
  bool _memberAscending = false;
  num _memberSortTotalCapital = 0;
  String _memberSearch = '';
  final TextEditingController _memberSearchController = TextEditingController();

  final Set<String> _investmentStatuses = <String>{};
  final Set<String> _investmentTypes = <String>{};
  final Set<String> _distributionStatuses = <String>{};
  String? _distributionInvestment;

  late Future<AssociationSummaryReport> _summaryFuture;
  Future<StaffMemberBalancesReport>? _memberFuture;
  Future<StaffInvestmentRegisterReport>? _investmentFuture;
  Future<StaffDistributionLogsReport>? _distributionFuture;
  Future<StaffApprovalQueueReport>? _approvalFuture;
  DateTime _fetchedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _summaryFuture = _track(widget.repository.associationSummary());
  }

  @override
  void dispose() {
    _memberSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const AppScreenHeader(
          title: 'Staff Reports',
          subtitle:
              'Association summary, balances, investments, distributions, and pending submissions.',
          padding: EdgeInsets.fromLTRB(20, 12, 20, 24),
          gradientColors: <Color>[Color(0xFF003D35), AppColors.primaryDk],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _SectionTabs(
                active: _section,
                onChanged: (section) {
                  setState(() {
                    _section = section;
                    _ensureSectionFuture(section);
                  });
                },
              ),
              const SizedBox(height: 14),
              _buildSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection() {
    return switch (_section) {
      _StaffReportSection.summary => _future<AssociationSummaryReport>(
        future: _summaryFuture,
        error: 'Unable to load association summary. Please try again.',
        builder: _buildSummary,
      ),
      _StaffReportSection.members => _future<StaffMemberBalancesReport>(
        future: _memberFuture ??= _loadMemberBalances(),
        error: 'Unable to load member balances. Please try again.',
        builder: _buildMembers,
      ),
      _StaffReportSection.investments => _future<StaffInvestmentRegisterReport>(
        future: _investmentFuture ??= _track(
          widget.repository.investmentRegister(),
        ),
        error: 'Unable to load investment register. Please try again.',
        builder: _buildInvestments,
      ),
      _StaffReportSection.distributions => _future<StaffDistributionLogsReport>(
        future: _distributionFuture ??= _track(
          widget.repository.distributionLogs(),
        ),
        error: 'Unable to load distribution logs. Please try again.',
        builder: _buildDistributions,
      ),
      _StaffReportSection.approvalQueue => _future<StaffApprovalQueueReport>(
        future: _approvalFuture ??= _track(
          widget.repository.approvalQueueReport(),
        ),
        error: 'Unable to load approval queue report. Please try again.',
        builder: _buildApprovalQueue,
      ),
    };
  }

  Widget _future<T>({
    required Future<T> future,
    required String error,
    required Widget Function(T data) builder,
  }) {
    return FutureBuilder<T>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.only(top: 32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return AppMessageCard(
            icon: Icons.error_outline,
            message: error,
            foreground: AppColors.red,
            background: AppThemeColors.statusErrorBg(context),
            padding: const EdgeInsets.all(18),
            borderRadius: 18,
          );
        }
        return builder(snapshot.data as T);
      },
    );
  }

  Widget _buildSummary(AssociationSummaryReport report) {
    final List<_MoneyMetric> metrics = <_MoneyMetric>[
      _MoneyMetric(
        label: 'Authorized Capital',
        value: report.capital.totalAuthorized,
        color: AppColors.primary,
        icon: Icons.account_balance_wallet_outlined,
      ),
      _MoneyMetric(
        label: 'Profit Wallet',
        value: report.capital.profitWalletTotal,
        color: AppColors.blue,
        icon: Icons.account_balance_wallet_outlined,
      ),
      _MoneyMetric(
        label: 'Total Amount',
        value: report.capital.totalAmount,
        color: AppColors.primaryDk,
        icon: Icons.account_balance_wallet_outlined,
      ),
      _MoneyMetric(
        label: 'Pending Capital',
        value: report.capital.totalPending,
        color: AppColors.amber,
        icon: Icons.hourglass_top_rounded,
      ),
      _MoneyMetric(
        label: 'Invested Amount',
        value: report.capital.totalInvested,
        color: AppColors.blue,
        icon: Icons.trending_up_rounded,
      ),
      _MoneyMetric(
        label: 'P&L Distributed',
        value: report.distributions.totalPnlDistributed,
        color: AppThemeColors.textMuted(context),
        icon: Icons.payments_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _TimestampBar(
          label: 'Generated at: ${formatDateTimeShort(report.generatedAt)}',
          onRefresh: () {
            setState(() {
              _summaryFuture = _track(widget.repository.associationSummary());
            });
          },
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool compact = constraints.maxWidth < 720;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: metrics.map((_MoneyMetric metric) {
                return SizedBox(
                  width: compact
                      ? (constraints.maxWidth - 10) / 2
                      : (constraints.maxWidth - 50) / 6,
                  child: AppMoneyMetricCard(
                    label: metric.label,
                    textValue: metric.value,
                    color: metric.color,
                    icon: metric.icon,
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool stacked = constraints.maxWidth < 760;
            final double width = stacked
                ? constraints.maxWidth
                : (constraints.maxWidth - 20) / 3;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                SizedBox(
                  width: width,
                  child: _StatCluster(
                    title: 'Members',
                    subtitle: 'Total ${report.members.total}',
                    stats: <_TinyStat>[
                      _TinyStat(
                        'Active',
                        report.members.active,
                        AppColors.green,
                      ),
                      _TinyStat(
                        'Inactive',
                        report.members.inactive,
                        AppThemeColors.textMuted(context),
                      ),
                    ],
                    action: 'View members',
                    onTap: () => setState(() {
                      _section = _StaffReportSection.members;
                      _memberFuture ??= _loadMemberBalances();
                    }),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _StatCluster(
                    title: 'Investments',
                    subtitle: 'Total ${report.investments.total}',
                    stats: <_TinyStat>[
                      _TinyStat(
                        'Draft',
                        report.investments.draft,
                        AppThemeColors.textMuted(context),
                      ),
                      _TinyStat(
                        'Open',
                        report.investments.open,
                        AppColors.blue,
                      ),
                      _TinyStat(
                        'Closed',
                        report.investments.closed,
                        AppColors.amber,
                      ),
                      _TinyStat(
                        'Distributed',
                        report.investments.distributed,
                        AppColors.green,
                      ),
                      _TinyStat(
                        'Reversed',
                        report.investments.reversed,
                        AppColors.red,
                      ),
                    ],
                    action: 'View investments',
                    onTap: () => setState(() {
                      _section = _StaffReportSection.investments;
                      _investmentFuture ??= _track(
                        widget.repository.investmentRegister(),
                      );
                    }),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _StatCluster(
                    title: 'Submissions',
                    subtitle: 'Total ${report.submissions.total}',
                    stats: <_TinyStat>[
                      _TinyStat(
                        'Pending',
                        report.submissions.pending,
                        AppColors.amber,
                      ),
                      _TinyStat(
                        'Approved',
                        report.submissions.approved,
                        AppColors.green,
                      ),
                      _TinyStat(
                        'Rejected',
                        report.submissions.rejected,
                        AppColors.red,
                      ),
                    ],
                    action: 'View queue',
                    onTap: () => setState(() {
                      _section = _StaffReportSection.approvalQueue;
                      _approvalFuture ??= _track(
                        widget.repository.approvalQueueReport(),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMembers(StaffMemberBalancesReport report) {
    _memberSortTotalCapital = num.tryParse(report.totalCapital) ?? 0;
    final List<StaffMemberBalance> members = <StaffMemberBalance>[
      ...report.members,
    ]..sort(_compareMembers);
    final String statusText = switch (_memberStatus) {
      _MemberStatusFilter.active => 'active',
      _MemberStatusFilter.inactive => 'inactive',
      _MemberStatusFilter.all => 'all',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _TimestampBar(
          label: 'Fetched at: ${formatDateTimeShort(_fetchedAt)}',
          onRefresh: () =>
              setState(() => _memberFuture = _loadMemberBalances()),
        ),
        const SizedBox(height: 12),
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _MemberFilters(
                status: _memberStatus,
                searchController: _memberSearchController,
                onStatusChanged: (value) {
                  setState(() {
                    _memberStatus = value;
                    _memberFuture = _loadMemberBalances();
                  });
                },
                onSearch: _applyMemberSearch,
              ),
              if (_memberStatus == _MemberStatusFilter.inactive)
                const Padding(
                  padding: EdgeInsets.fromLTRB(14, 0, 14, 12),
                  child: _AuditBanner(
                    message:
                        'Inactive members retain historical balances for audit purposes.',
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Text(
                  'Showing ${report.memberCount} $statusText members - '
                  'Capital: ${formatMoneyTextSigned(report.totalCapital)} - '
                  'Profit Wallet: ${formatMoneyTextSigned(report.totalProfitWallet)} - '
                  'Total: ${formatMoneyTextSigned(report.totalAmount)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppThemeColors.textMid(context),
                  ),
                ),
              ),
              if (members.isEmpty)
                const AppMessageCard(
                  message: 'No members match the selected filters.',
                  tone: AppMessageTone.neutral,
                  background: Colors.transparent,
                  padding: EdgeInsets.all(14),
                  showBorder: false,
                )
              else
                _MemberTable(
                  members: members,
                  totalCapital: report.totalCapital,
                  sort: _memberSort,
                  ascending: _memberAscending,
                  onSort: _setMemberSort,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInvestments(StaffInvestmentRegisterReport report) {
    final List<StaffInvestmentRegisterItem> investments = report.investments
        .where(
          (item) =>
              _investmentStatuses.isEmpty ||
              _investmentStatuses.contains(item.status.toUpperCase()),
        )
        .where(
          (item) =>
              _investmentTypes.isEmpty ||
              _investmentTypes.contains(item.investmentType.toUpperCase()),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _TimestampBar(
          label: 'Fetched at: ${formatDateTimeShort(_fetchedAt)}',
          onRefresh: () => setState(() {
            _investmentFuture = _track(widget.repository.investmentRegister());
          }),
        ),
        const SizedBox(height: 12),
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _DropdownFilterField(
                label: 'Status',
                icon: Icons.fact_check_outlined,
                value: _investmentStatuses.isEmpty
                    ? null
                    : _investmentStatuses.first,
                allLabel: 'All statuses',
                values: _investmentStatusValues,
                onChanged: (value) => setState(() {
                  _investmentStatuses
                    ..clear()
                    ..addAll(value == null ? <String>[] : <String>[value]);
                }),
              ),
              _DropdownFilterField(
                label: 'Type',
                icon: Icons.category_outlined,
                value: _investmentTypes.isEmpty ? null : _investmentTypes.first,
                allLabel: 'All types',
                values: _investmentTypeValues,
                onChanged: (value) => setState(() {
                  _investmentTypes
                    ..clear()
                    ..addAll(value == null ? <String>[] : <String>[value]);
                }),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Text(
                  'Showing ${investments.length} investments',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppThemeColors.textMid(context),
                  ),
                ),
              ),
              if (investments.isEmpty)
                const AppMessageCard(
                  message: 'No investments match the selected filters.',
                  tone: AppMessageTone.neutral,
                  background: Colors.transparent,
                  padding: EdgeInsets.all(14),
                  showBorder: false,
                )
              else
                _InvestmentTable(items: investments),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDistributions(StaffDistributionLogsReport report) {
    final List<StaffDistributionLogItem> distributions = report.distributions
        .where(
          (item) =>
              _distributionStatuses.isEmpty ||
              _distributionStatuses.contains(item.status.toUpperCase()),
        )
        .where(
          (item) =>
              _distributionInvestment == null ||
              item.investmentTitle == _distributionInvestment,
        )
        .toList();
    final int posted = distributions
        .where((item) => item.status.toUpperCase() == 'POSTED')
        .length;
    final int reversed = distributions
        .where((item) => item.status.toUpperCase() == 'REVERSED')
        .length;
    final List<String> investmentNames =
        report.distributions
            .map((item) => item.investmentTitle)
            .where((title) => title.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _TimestampBar(
          label: 'Fetched at: ${formatDateTimeShort(_fetchedAt)}',
          onRefresh: () => setState(() {
            _distributionFuture = _track(widget.repository.distributionLogs());
          }),
        ),
        const SizedBox(height: 12),
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _ChipFilterBar(
                title: 'Status',
                values: _distributionStatusValues,
                selected: _distributionStatuses,
                onChanged: (value) =>
                    setState(() => _toggle(_distributionStatuses, value)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: DropdownButtonFormField<String?>(
                  initialValue: _distributionInvestment,
                  decoration: _fieldDecoration(
                    context: context,
                    label: 'Investment',
                    icon: Icons.search_rounded,
                  ),
                  items: <DropdownMenuItem<String?>>[
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All investments'),
                    ),
                    ...investmentNames.map(
                      (String title) => DropdownMenuItem<String?>(
                        value: title,
                        child: Text(title),
                      ),
                    ),
                  ],
                  onChanged: (String? value) {
                    setState(() => _distributionInvestment = value);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Text(
                  'Showing ${distributions.length} distributions - '
                  '$posted Posted, $reversed Reversed',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppThemeColors.textMid(context),
                  ),
                ),
              ),
              if (distributions.isEmpty)
                const AppMessageCard(
                  message: 'No distributions match the selected filters.',
                  tone: AppMessageTone.neutral,
                  background: Colors.transparent,
                  padding: EdgeInsets.all(14),
                  showBorder: false,
                )
              else
                _DistributionList(items: distributions),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApprovalQueue(StaffApprovalQueueReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _TimestampBar(
          label: 'Fetched at: ${formatDateTimeShort(_fetchedAt)}',
          onRefresh: () => setState(() {
            _approvalFuture = _track(widget.repository.approvalQueueReport());
          }),
        ),
        const SizedBox(height: 12),
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(14),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    SizedBox(
                      width: 160,
                      child: AppMetricCard(
                        label: 'Pending Count',
                        value: '${report.totalPendingCount}',
                        color: AppColors.amber,
                        background: AppColors.amber.withValues(alpha: .1),
                        borderRadius: 14,
                        padding: const EdgeInsets.all(12),
                        labelMaxLines: 1,
                        valueStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.amber,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: AppMetricCard(
                        label: 'Pending Amount',
                        value: formatMoneyTextSigned(report.totalPendingAmount),
                        color: AppColors.primary,
                        background: AppColors.primary.withValues(alpha: .1),
                        borderRadius: 14,
                        padding: const EdgeInsets.all(12),
                        labelMaxLines: 1,
                        valueStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    ...report.byChannel.entries.map((entry) {
                      final Color color = _channelColor(context, entry.key);
                      return SizedBox(
                        width: 160,
                        child: AppMetricCard(
                          label: prettyEnumLabel(entry.key),
                          value:
                              '${entry.value.count} - ${formatMoneyTextSigned(entry.value.totalAmount)}',
                          color: color,
                          background: color.withValues(alpha: .1),
                          borderRadius: 14,
                          padding: const EdgeInsets.all(12),
                          labelMaxLines: 1,
                          valueStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: color,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => context.go(RouteNames.approvals),
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: const Text('Go to Action Queue'),
                  ),
                ),
              ),
              if (report.items.isEmpty)
                const AppMessageCard(
                  message: 'No pending submissions - all caught up.',
                  tone: AppMessageTone.neutral,
                  background: Colors.transparent,
                  padding: EdgeInsets.all(14),
                  showBorder: false,
                )
              else
                _ApprovalQueueTable(items: report.items),
            ],
          ),
        ),
      ],
    );
  }

  Future<T> _track<T>(Future<T> future) async {
    final T value = await future;
    if (mounted) {
      setState(() => _fetchedAt = DateTime.now());
    } else {
      _fetchedAt = DateTime.now();
    }
    return value;
  }

  Future<StaffMemberBalancesReport> _loadMemberBalances() async {
    final String? search = _memberSearch.trim().isEmpty ? null : _memberSearch;
    if (_memberStatus == _MemberStatusFilter.all) {
      final List<StaffMemberBalancesReport> reports = await Future.wait(
        <Future<StaffMemberBalancesReport>>[
          widget.repository.memberBalances(status: 'ACTIVE', search: search),
          widget.repository.memberBalances(status: 'INACTIVE', search: search),
        ],
      );
      final List<StaffMemberBalance> members = <StaffMemberBalance>[
        ...reports.first.members,
        ...reports.last.members,
      ];
      final num total = members.fold<num>(
        0,
        (num sum, StaffMemberBalance member) =>
            sum + (num.tryParse(member.capitalBalance) ?? 0),
      );
      final num totalProfitWallet = members.fold<num>(
        0,
        (num sum, StaffMemberBalance member) =>
            sum + (num.tryParse(member.profitWalletBalance) ?? 0),
      );
      final num totalAmount = members.fold<num>(
        0,
        (num sum, StaffMemberBalance member) =>
            sum + (num.tryParse(member.totalAmount) ?? 0),
      );
      _fetchedAt = DateTime.now();
      return StaffMemberBalancesReport(
        totalCapital: total.toStringAsFixed(2),
        totalProfitWallet: totalProfitWallet.toStringAsFixed(2),
        totalAmount: totalAmount.toStringAsFixed(2),
        memberCount: members.length,
        members: members,
      );
    }

    final String status = _memberStatus == _MemberStatusFilter.active
        ? 'ACTIVE'
        : 'INACTIVE';
    return _track(
      widget.repository.memberBalances(status: status, search: search),
    );
  }

  void _ensureSectionFuture(_StaffReportSection section) {
    switch (section) {
      case _StaffReportSection.summary:
        break;
      case _StaffReportSection.members:
        _memberFuture ??= _loadMemberBalances();
      case _StaffReportSection.investments:
        _investmentFuture ??= _track(widget.repository.investmentRegister());
      case _StaffReportSection.distributions:
        _distributionFuture ??= _track(widget.repository.distributionLogs());
      case _StaffReportSection.approvalQueue:
        _approvalFuture ??= _track(widget.repository.approvalQueueReport());
    }
  }

  void _applyMemberSearch() {
    setState(() {
      _memberSearch = _memberSearchController.text.trim();
      _memberFuture = _loadMemberBalances();
    });
  }

  void _setMemberSort(_MemberSort sort) {
    setState(() {
      if (_memberSort == sort) {
        _memberAscending = !_memberAscending;
      } else {
        _memberSort = sort;
        _memberAscending = sort != _MemberSort.total;
      }
    });
  }

  int _compareMembers(StaffMemberBalance a, StaffMemberBalance b) {
    final int result = switch (_memberSort) {
      _MemberSort.name => a.fullName.compareTo(b.fullName),
      _MemberSort.contact => a.contactNo.compareTo(b.contactNo),
      _MemberSort.joinDate => a.joinDate.compareTo(b.joinDate),
      _MemberSort.status => a.status.compareTo(b.status),
      _MemberSort.capital => (num.tryParse(a.capitalBalance) ?? 0).compareTo(
        num.tryParse(b.capitalBalance) ?? 0,
      ),
      _MemberSort.profitWallet =>
        (num.tryParse(a.profitWalletBalance) ?? 0).compareTo(
          num.tryParse(b.profitWalletBalance) ?? 0,
        ),
      _MemberSort.total => (num.tryParse(a.totalAmount) ?? 0).compareTo(
        num.tryParse(b.totalAmount) ?? 0,
      ),
      _MemberSort.ratio => _ownershipRatio(a, _memberSortTotalCapital)
          .compareTo(_ownershipRatio(b, _memberSortTotalCapital)),
    };
    return _memberAscending ? result : -result;
  }

  num _ownershipRatio(StaffMemberBalance member, num totalCapital) {
    if (totalCapital <= 0) {
      return 0;
    }
    final num capital = num.tryParse(member.capitalBalance) ?? 0;
    return capital / totalCapital;
  }
}
