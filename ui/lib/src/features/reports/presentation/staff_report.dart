import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../shared/finance.dart';
import '../../shared/widgets/app_data_table.dart';
import '../../shared/widgets/app_metric_card.dart';
import '../../shared/widgets/app_message_card.dart';
import '../../shared/widgets/app_panel.dart';
import '../../shared/widgets/app_screen_header.dart';
import '../../shared/widgets/status_pills.dart';
import '../data/staff_report_repository.dart';
import '../domain/staff_report_models.dart';

class StaffReportPage extends StatefulWidget {
  const StaffReportPage({super.key, required this.repository});

  final StaffReportRepository repository;

  @override
  State<StaffReportPage> createState() => _StaffReportPageState();
}

class _StaffReportPageState extends State<StaffReportPage> {
  _StaffReportSection _section = _StaffReportSection.summary;
  _MemberStatusFilter _memberStatus = _MemberStatusFilter.active;
  _MemberSort _memberSort = _MemberSort.balance;
  bool _memberAscending = false;
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
            background: AppColors.redLt,
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
        color: AppColors.green,
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
                      : (constraints.maxWidth - 30) / 4,
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
                        AppColors.textMute,
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
                        AppColors.textMute,
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
                  'Total Capital: ${formatMoneyTextSigned(report.totalCapital)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textMid,
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textMid,
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textMid,
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
                      final Color color = _channelColor(entry.key);
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
            sum + (num.tryParse(member.balance) ?? 0),
      );
      _fetchedAt = DateTime.now();
      return StaffMemberBalancesReport(
        totalCapital: total.toStringAsFixed(2),
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
        _memberAscending = sort != _MemberSort.balance;
      }
    });
  }

  int _compareMembers(StaffMemberBalance a, StaffMemberBalance b) {
    final int result = switch (_memberSort) {
      _MemberSort.name => a.fullName.compareTo(b.fullName),
      _MemberSort.contact => a.contactNo.compareTo(b.contactNo),
      _MemberSort.joinDate => a.joinDate.compareTo(b.joinDate),
      _MemberSort.status => a.status.compareTo(b.status),
      _MemberSort.balance => (num.tryParse(a.balance) ?? 0).compareTo(
        num.tryParse(b.balance) ?? 0,
      ),
    };
    return _memberAscending ? result : -result;
  }
}

class _SectionTabs extends StatelessWidget {
  const _SectionTabs({required this.active, required this.onChanged});

  final _StaffReportSection active;
  final ValueChanged<_StaffReportSection> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _StaffReportSection.values.map((section) {
          final bool selected = active == section;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: selected,
              label: Text(section.label),
              avatar: Icon(section.icon, size: 16),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.white,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : AppColors.textMid,
              ),
              side: const BorderSide(color: AppColors.border),
              onSelected: (_) => onChanged(section),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TimestampBar extends StatelessWidget {
  const _TimestampBar({required this.label, required this.onRefresh});

  final String label;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textMute,
            ),
          ),
        ),
        IconButton.filledTonal(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          tooltip: 'Refresh',
        ),
      ],
    );
  }
}

class _StatCluster extends StatelessWidget {
  const _StatCluster({
    required this.title,
    required this.subtitle,
    required this.stats,
    required this.action,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final List<_TinyStat> stats;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMute,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: stats.map((_TinyStat stat) {
                return AppStatusPill(
                  label: '${stat.label} ${stat.value}',
                  color: stat.color,
                  showBorder: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  textHeight: null,
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(onPressed: onTap, child: Text('$action ->')),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberFilters extends StatelessWidget {
  const _MemberFilters({
    required this.status,
    required this.searchController,
    required this.onStatusChanged,
    required this.onSearch,
  });

  final _MemberStatusFilter status;
  final TextEditingController searchController;
  final ValueChanged<_MemberStatusFilter> onStatusChanged;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _MemberStatusFilter.values.map((value) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    selected: status == value,
                    label: Text(value.label),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.white,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: status == value ? Colors.white : AppColors.textMid,
                    ),
                    side: const BorderSide(color: AppColors.border),
                    onSelected: (_) => onStatusChanged(value),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearch(),
            decoration:
                _fieldDecoration(
                  label: 'Search member',
                  icon: Icons.search_rounded,
                ).copyWith(
                  suffixIcon: IconButton(
                    onPressed: onSearch,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    tooltip: 'Search',
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _MemberTable extends StatelessWidget {
  const _MemberTable({
    required this.members,
    required this.sort,
    required this.ascending,
    required this.onSort,
  });

  final List<StaffMemberBalance> members;
  final _MemberSort sort;
  final bool ascending;
  final ValueChanged<_MemberSort> onSort;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 760,
        child: Column(
          children: <Widget>[
            AppTableHeader(
              cells: <Widget>[
                AppSortableHeaderCell<_MemberSort>(
                  text: 'Full Name',
                  field: _MemberSort.name,
                  active: sort,
                  ascending: ascending,
                  onTap: onSort,
                ),
                AppSortableHeaderCell<_MemberSort>(
                  text: 'Contact',
                  field: _MemberSort.contact,
                  active: sort,
                  ascending: ascending,
                  onTap: onSort,
                ),
                AppSortableHeaderCell<_MemberSort>(
                  text: 'Join Date',
                  field: _MemberSort.joinDate,
                  active: sort,
                  ascending: ascending,
                  onTap: onSort,
                ),
                AppSortableHeaderCell<_MemberSort>(
                  text: 'Status',
                  field: _MemberSort.status,
                  active: sort,
                  ascending: ascending,
                  onTap: onSort,
                ),
                AppSortableHeaderCell<_MemberSort>(
                  text: 'Balance',
                  field: _MemberSort.balance,
                  active: sort,
                  ascending: ascending,
                  onTap: onSort,
                  alignEnd: true,
                ),
              ],
            ),
            ...members.map((member) {
              return AppTableRow(
                onTap: () => context.go(RouteNames.ledger),
                cells: <Widget>[
                  AppTextCell(member.fullName),
                  AppTextCell(member.contactNo),
                  AppTextCell(member.joinDate),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppStatusPill(
                      label: valueOrDash(member.status),
                      color: member.status.toUpperCase() == 'ACTIVE'
                          ? AppColors.green
                          : AppColors.textMute,
                      showBorder: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      textHeight: null,
                    ),
                  ),
                  AppMoneyCell(member.balance),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _InvestmentTable extends StatelessWidget {
  const _InvestmentTable({required this.items});

  final List<StaffInvestmentRegisterItem> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1160,
        child: Column(
          children: <Widget>[
            const AppTableHeader(
              cells: <Widget>[
                AppHeaderCell('Title'),
                AppHeaderCell('Type'),
                AppHeaderCell('Invested To'),
                AppHeaderCell('Invested'),
                AppHeaderCell('Return'),
                AppHeaderCell('P&L'),
                AppHeaderCell('Status'),
                AppHeaderCell('Members'),
                AppHeaderCell('Created/Fund'),
                AppHeaderCell('Date'),
              ],
            ),
            ...items.map((item) {
              final num pnl = num.tryParse(item.pnlAmount) ?? 0;
              return AppTableRow(
                onTap: () => context.go(RouteNames.investments),
                cells: <Widget>[
                  AppTextCell(item.title),
                  AppTextCell(prettyEnumLabel(item.investmentType)),
                  AppTextCell(item.investedTo),
                  AppMoneyCell(item.investedAmount),
                  AppMoneyCell(item.returnAmount),
                  AppMoneyCell(
                    item.pnlAmount,
                    color: pnl > 0
                        ? AppColors.green
                        : pnl < 0
                        ? AppColors.red
                        : AppColors.text,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppStatusPill(
                      label: prettyEnumLabel(item.status),
                      color: _investmentStatusColor(item.status),
                      showBorder: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      textHeight: null,
                    ),
                  ),
                  AppTextCell('${item.memberCount}'),
                  AppTextCell(
                    '${valueOrDash(item.createdBy)}\nFund: ${valueOrDash(item.fundReleasedBy)}',
                  ),
                  AppTextCell(
                    item.closeDate.trim().isEmpty
                        ? item.createdDate
                        : '${item.createdDate}\nClose: ${item.closeDate}',
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _DistributionList extends StatelessWidget {
  const _DistributionList({required this.items});

  final List<StaffDistributionLogItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        final bool reversed = item.status.toUpperCase() == 'REVERSED';
        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: Container(
            decoration: BoxDecoration(
              color: reversed ? AppColors.surface : AppColors.white,
              border: const Border(top: BorderSide(color: AppColors.border)),
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 14),
              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              title: Row(
                children: <Widget>[
                  Expanded(flex: 2, child: AppTextCell(item.investmentTitle)),
                  Expanded(child: AppMoneyCell(item.pnlAmount)),
                  Expanded(child: AppMoneyCell(item.roundedTotal)),
                  Expanded(
                    child: AppMoneyCell(
                      item.remainderApplied,
                      color: (num.tryParse(item.remainderApplied) ?? 0) == 0
                          ? AppColors.text
                          : AppColors.amber,
                    ),
                  ),
                  Expanded(
                    child: AppStatusPill(
                      label: prettyEnumLabel(item.status),
                      color: reversed ? AppColors.red : AppColors.green,
                      strike: reversed,
                      showBorder: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      textHeight: null,
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                'Posted by ${valueOrDash(item.postedBy)} at ${formatDateTimeShort(item.postedAt)} - '
                'Reversed by ${valueOrDash(item.reversedBy)} at ${formatDateTimeShort(item.reversedAt)} - '
                '${item.memberCount} members',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMute,
                ),
              ),
              children: <Widget>[
                if (item.lines.isEmpty)
                  const AppMessageCard(
                    message: 'No per-member distribution lines returned.',
                    tone: AppMessageTone.neutral,
                    background: Colors.transparent,
                    padding: EdgeInsets.all(14),
                    showBorder: false,
                  )
                else
                  ...item.lines.map((line) {
                    return _DistributionLineTile(line: line);
                  }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ApprovalQueueTable extends StatelessWidget {
  const _ApprovalQueueTable({required this.items});

  final List<StaffApprovalQueueItem> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1040,
        child: Column(
          children: <Widget>[
            const AppTableHeader(
              cells: <Widget>[
                AppHeaderCell('Member'),
                AppHeaderCell('Contact'),
                AppHeaderCell('Type'),
                AppHeaderCell('Amount'),
                AppHeaderCell('Txn Date'),
                AppHeaderCell('Channel'),
                AppHeaderCell('Reference'),
                AppHeaderCell('Notes'),
                AppHeaderCell('Files'),
                AppHeaderCell('Requested'),
              ],
            ),
            ...items.map((item) {
              final Color channelColor = _channelColor(item.paymentChannel);
              final bool missingReference =
                  item.paymentChannel.toUpperCase() == 'BKASH' &&
                  item.externalReference.trim().isEmpty;
              return AppTableRow(
                cells: <Widget>[
                  AppTextCell(item.memberName),
                  AppTextCell(item.memberContact),
                  AppTextCell(prettyEnumLabel(item.requestType)),
                  AppMoneyCell(item.amount),
                  AppTextCell(item.txnDate),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppStatusPill(
                      label: prettyEnumLabel(item.paymentChannel),
                      color: channelColor,
                      showBorder: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      textHeight: null,
                    ),
                  ),
                  AppTextCell(
                    valueOrDash(item.externalReference),
                    color: missingReference ? AppColors.red : AppColors.text,
                    mono: true,
                  ),
                  AppTextCell(valueOrDash(item.notes), maxLines: 1),
                  AppTextCell('clip ${item.attachmentCount}'),
                  AppTextCell(formatDateTimeShort(item.requestedAt)),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ChipFilterBar extends StatelessWidget {
  const _ChipFilterBar({
    required this.title,
    required this.values,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final List<String> values;
  final Set<String> selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.textMute,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values.map((value) {
              final bool active = selected.contains(value);
              return FilterChip(
                selected: active,
                label: Text(prettyEnumLabel(value)),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.white,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: active ? Colors.white : AppColors.textMid,
                ),
                side: const BorderSide(color: AppColors.border),
                onSelected: (_) => onChanged(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _DropdownFilterField extends StatelessWidget {
  const _DropdownFilterField({
    required this.label,
    required this.icon,
    required this.value,
    required this.allLabel,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final String? value;
  final String allLabel;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: DropdownButtonFormField<String?>(
        initialValue: value,
        decoration: _fieldDecoration(label: label, icon: icon),
        items: <DropdownMenuItem<String?>>[
          DropdownMenuItem<String?>(
            value: null,
            child: Text(allLabel),
          ),
          ...values.map(
            (String value) => DropdownMenuItem<String?>(
              value: value,
              child: Text(prettyEnumLabel(value)),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _DistributionLineTile extends StatelessWidget {
  const _DistributionLineTile({required this.line});

  final StaffDistributionLine line;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: AppTextCell(line.fullName)),
          Expanded(child: AppTextCell('Ratio ${valueOrDash(line.ratioUsed)}')),
          Expanded(child: AppMoneyCell(line.shareAmount)),
          Expanded(
            child: AppTextCell('Ledger ${valueOrDash(line.ledgerEntryId)}'),
          ),
        ],
      ),
    );
  }
}

class _AuditBanner extends StatelessWidget {
  const _AuditBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.amberLt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.amber.withValues(alpha: .18)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.info_outline_rounded, color: AppColors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textMid,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyMetric {
  const _MoneyMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;
}

class _TinyStat {
  const _TinyStat(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;
}

enum _StaffReportSection {
  summary('Summary', Icons.dashboard_outlined),
  members('Members', Icons.groups_outlined),
  investments('Investments', Icons.account_balance_outlined),
  distributions('Distributions', Icons.call_split_rounded),
  approvalQueue('Approval Queue', Icons.pending_actions_outlined);

  const _StaffReportSection(this.label, this.icon);

  final String label;
  final IconData icon;
}

enum _MemberStatusFilter {
  active('Active'),
  inactive('Inactive'),
  all('All');

  const _MemberStatusFilter(this.label);

  final String label;
}

enum _MemberSort { name, contact, joinDate, status, balance }

const List<String> _investmentStatusValues = <String>[
  'DRAFT',
  'OPEN',
  'CLOSED',
  'DISTRIBUTED',
  'REVERSED',
];

const List<String> _investmentTypeValues = <String>[
  'FIXED_DEPOSIT',
  'EQUITY',
  'REAL_ESTATE',
  'LENDING',
  'OTHER',
];

const List<String> _distributionStatusValues = <String>['POSTED', 'REVERSED'];

InputDecoration _fieldDecoration({
  required String label,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 18),
    filled: true,
    fillColor: AppColors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.3),
    ),
  );
}

void _toggle(Set<String> selected, String value) {
  if (!selected.add(value)) {
    selected.remove(value);
  }
}

Color _investmentStatusColor(String status) {
  return switch (status.toUpperCase()) {
    'OPEN' => AppColors.blue,
    'CLOSED' => AppColors.amber,
    'DISTRIBUTED' => AppColors.green,
    'REVERSED' => AppColors.red,
    _ => AppColors.textMute,
  };
}

Color _channelColor(String channel) {
  return switch (channel.toUpperCase()) {
    'BKASH' => const Color(0xFFD82B7D),
    'BANK' || 'BANK_TRANSFER' => AppColors.blue,
    _ => AppColors.textMute,
  };
}
