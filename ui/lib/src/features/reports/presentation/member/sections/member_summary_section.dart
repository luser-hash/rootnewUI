part of '../member_report_page.dart';

class _StatementLabel extends StatelessWidget {
  const _StatementLabel({required this.date, required this.member});

  final DateTime date;
  final MemberReportMember? member;

  @override
  Widget build(BuildContext context) {
    final String memberName = member?.fullName.trim() ?? '';
    return Text(
      memberName.isEmpty
          ? 'Statement as of ${_formatDate(date)}'
          : 'Statement as of ${_formatDate(date)} for $memberName',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppThemeColors.textMuted(context),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.report});

  final _MemberReportData report;

  @override
  Widget build(BuildContext context) {
    final num contributed = report.statement.entries.fold<num>(0, (
      num sum,
      MemberReportEntry entry,
    ) {
      if (entry.entryType != MemberReportEntryType.submission) {
        return sum;
      }
      return sum + (num.tryParse(entry.amount) ?? 0);
    });
    final List<_SummaryMetric> metrics = <_SummaryMetric>[
      _SummaryMetric(
        label: 'Total Capital Contributed',
        value: contributed,
        color: AppColors.primary,
      ),
      _SummaryMetric(
        label: 'Current Balance',
        value: num.tryParse(report.statement.totalAmount) ?? 0,
        color: AppColors.blue,
      ),
      _SummaryMetric(
        label: 'Distribution Received',
        value: num.tryParse(report.distributions.totalReceived) ?? 0,
        color: AppColors.green,
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool stacked = constraints.maxWidth < 520;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: metrics.map((_SummaryMetric metric) {
            return SizedBox(
              width: stacked
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 20) / 3,
              child: AppMoneyMetricCard(
                label: metric.label,
                value: metric.value,
                color: metric.color,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _SummaryMetric {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final num value;
  final Color color;
}
