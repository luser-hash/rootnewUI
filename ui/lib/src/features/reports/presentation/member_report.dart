import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../shared/finance.dart';
import '../data/member_report_repository.dart';
import '../domain/member_report_models.dart';

class MemberReportPage extends StatefulWidget {
  const MemberReportPage({super.key, required this.repository});

  final MemberReportRepository repository;

  @override
  State<MemberReportPage> createState() => _MemberReportPageState();
}

class _MemberReportPageState extends State<MemberReportPage> {
  MemberReportEntryType? _entryType;
  DateTime? _fromDate;
  DateTime? _toDate;
  late Future<_MemberReportData> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = _loadReport();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _ReportHeader(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: FutureBuilder<_MemberReportData>(
            future: _reportFuture,
            builder: (
              BuildContext context,
              AsyncSnapshot<_MemberReportData> snapshot,
            ) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return const _ReportMessage(
                  icon: Icons.error_outline,
                  message: 'Unable to load member report. Please try again.',
                  foreground: AppColors.red,
                  background: AppColors.redLt,
                );
              }

              final _MemberReportData report = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _StatementLabel(
                    date: DateTime.now(),
                    member: report.statement.member,
                  ),
                  const SizedBox(height: 12),
                  _SummaryCards(report: report),
                  const SizedBox(height: 16),
                  _TransactionPanel(
                    statement: report.statement,
                    entryType: _entryType,
                    fromDate: _fromDate,
                    toDate: _toDate,
                    onEntryTypeChanged: (MemberReportEntryType? value) {
                      setState(() {
                        _entryType = value;
                        _reportFuture = _loadReport();
                      });
                    },
                    onFromDateTap: () => _pickDate(
                      initialDate: _fromDate,
                      onPicked: (DateTime date) {
                        setState(() {
                          _fromDate = date;
                          _reportFuture = _loadReport();
                        });
                      },
                    ),
                    onToDateTap: () => _pickDate(
                      initialDate: _toDate,
                      onPicked: (DateTime date) {
                        setState(() {
                          _toDate = date;
                          _reportFuture = _loadReport();
                        });
                      },
                    ),
                    onClear: _filter.hasFilters
                        ? () {
                            setState(() {
                              _entryType = null;
                              _fromDate = null;
                              _toDate = null;
                              _reportFuture = _loadReport();
                            });
                          }
                        : null,
                    onDownloadCsv: () => _showCsv(report.statement),
                  ),
                  const SizedBox(height: 16),
                  _PendingRequestsPanel(statement: report.statement),
                  const SizedBox(height: 16),
                  _DistributionsPanel(report: report.distributions),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  MemberStatementFilter get _filter {
    return MemberStatementFilter(
      fromDate: _fromDate,
      toDate: _toDate,
      entryType: _entryType,
    );
  }

  Future<_MemberReportData> _loadReport() async {
    final List<Object> results = await Future.wait<Object>(<Future<Object>>[
      widget.repository.myStatement(_filter),
      widget.repository.myDistributions(),
    ]);
    return _MemberReportData(
      statement: results[0] as MemberReportStatement,
      distributions: results[1] as MemberDistributionsReport,
    );
  }

  Future<void> _pickDate({
    required DateTime? initialDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) {
      onPicked(_dateOnly(picked));
    }
  }

  void _showCsv(MemberReportStatement statement) {
    final String csv = _statementCsv(statement);
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Statement CSV'),
          content: SizedBox(
            width: double.maxFinite,
            child: SelectableText(csv),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF5B4A1D), Color(0xFF2F473E)],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Member Report',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Capital, balance, and transaction statement.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xCCFFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

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
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.textMute,
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.report});

  final _MemberReportData report;

  @override
  Widget build(BuildContext context) {
    final num contributed = report.statement.entries.fold<num>(
      0,
      (num sum, MemberReportEntry entry) {
        if (entry.entryType != MemberReportEntryType.submission) {
          return sum;
        }
        return sum + (num.tryParse(entry.amount) ?? 0);
      },
    );
    final List<_SummaryMetric> metrics = <_SummaryMetric>[
      _SummaryMetric(
        label: 'Total Capital Contributed',
        value: contributed,
        color: AppColors.primary,
      ),
      _SummaryMetric(
        label: 'Current Balance',
        value: num.tryParse(report.statement.currentBalance) ?? 0,
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
              child: _SummaryCard(metric: metric),
            );
          }).toList(),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.metric});

  final _SummaryMetric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            metric.label.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.textMute,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _money(metric.value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: metric.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionPanel extends StatelessWidget {
  const _TransactionPanel({
    required this.statement,
    required this.entryType,
    required this.fromDate,
    required this.toDate,
    required this.onEntryTypeChanged,
    required this.onFromDateTap,
    required this.onToDateTap,
    required this.onClear,
    required this.onDownloadCsv,
  });

  final MemberReportStatement statement;
  final MemberReportEntryType? entryType;
  final DateTime? fromDate;
  final DateTime? toDate;
  final ValueChanged<MemberReportEntryType?> onEntryTypeChanged;
  final VoidCallback onFromDateTap;
  final VoidCallback onToDateTap;
  final VoidCallback? onClear;
  final VoidCallback onDownloadCsv;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Transactions (${statement.entryCount})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: onDownloadCsv,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text(
                    'Download CSV',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
            child: Column(
              children: <Widget>[
                DropdownButtonFormField<MemberReportEntryType?>(
                  initialValue: entryType,
                  decoration: _fieldDecoration(
                    label: 'Entry Type',
                    icon: Icons.tune_rounded,
                  ),
                  items: <DropdownMenuItem<MemberReportEntryType?>>[
                    const DropdownMenuItem<MemberReportEntryType?>(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ...MemberReportEntryType.values.map(
                      (MemberReportEntryType type) =>
                          DropdownMenuItem<MemberReportEntryType?>(
                            value: type,
                            child: Text(type.label),
                          ),
                    ),
                  ],
                  onChanged: onEntryTypeChanged,
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _DateFilterButton(
                        label: 'From',
                        value: fromDate,
                        onTap: onFromDateTap,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DateFilterButton(
                        label: 'To',
                        value: toDate,
                        onTap: onToDateTap,
                      ),
                    ),
                    if (onClear != null) ...<Widget>[
                      const SizedBox(width: 8),
                      _ClearFiltersButton(onTap: onClear!),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const _TransactionTableHeader(),
          if (statement.entries.isEmpty)
            const _InlineMessage(message: 'No transactions match the filters.')
          else
            ...statement.entries.map(
              (MemberReportEntry entry) => _TransactionRow(entry: entry),
            ),
        ],
      ),
    );
  }
}

class _TransactionTableHeader extends StatelessWidget {
  const _TransactionTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: const Row(
        children: <Widget>[
          SizedBox(width: 86, child: _HeaderText('Date')),
          Expanded(child: _HeaderText('Entry')),
          SizedBox(
            width: 98,
            child: Text(
              'Running Balance',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColors.textMute,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.entry});

  final MemberReportEntry entry;

  @override
  Widget build(BuildContext context) {
    final num amount = num.tryParse(entry.amount) ?? 0;
    return Tooltip(
      message: _referenceText(entry),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          trailing: const SizedBox.shrink(),
          title: Row(
            children: <Widget>[
              SizedBox(
                width: 86,
                child: Text(
                  entry.txnDate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMute,
                  ),
                ),
              ),
              const Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: AppColors.textMute,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      entry.comment.isEmpty
                          ? entry.entryType.label
                          : entry.comment,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      '${entry.entryType.label} ${_signedMoney(amount)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: amount >= 0 ? AppColors.green : AppColors.red,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 98,
                child: Text(
                  _money(num.tryParse(entry.runningBalance) ?? 0),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
          children: <Widget>[_ReferenceBlock(entry: entry)],
        ),
      ),
    );
  }
}

class _ReferenceBlock extends StatelessWidget {
  const _ReferenceBlock({required this.entry});

  final MemberReportEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ReferenceLine(label: 'Ledger ID', value: entry.ledgerId),
          _ReferenceLine(label: 'Reference', value: _referenceText(entry)),
          _ReferenceLine(label: 'Created By', value: entry.createdByFullName),
          _ReferenceLine(
            label: 'Created At',
            value: _formatDateTime(entry.createdAt),
          ),
        ],
      ),
    );
  }
}

class _PendingRequestsPanel extends StatelessWidget {
  const _PendingRequestsPanel({required this.statement});

  final MemberReportStatement statement;

  @override
  Widget build(BuildContext context) {
    if (statement.pendingRequests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: _panelDecoration(),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Pending Requests '
                    '${_money(num.tryParse(statement.pendingTotal) ?? 0)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...statement.pendingRequests.map(
            (MemberReportPendingRequest request) {
              return _PendingRequestTile(request: request);
            },
          ),
        ],
      ),
    );
  }
}

class _PendingRequestTile extends StatelessWidget {
  const _PendingRequestTile({required this.request});

  final MemberReportPendingRequest request;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '${request.requestType} via ${request.paymentChannel}',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
          ),
          Text(
            _money(num.tryParse(request.amount) ?? 0),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.amber,
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionsPanel extends StatelessWidget {
  const _DistributionsPanel({required this.report});

  final MemberDistributionsReport report;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Distributions (${report.distributionCount})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                ),
                Text(
                  _money(num.tryParse(report.totalReceived) ?? 0),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ),
          if (report.distributions.isEmpty)
            const _InlineMessage(message: 'No distribution history found.')
          else
            ...report.distributions.map(
              (MemberDistributionReportItem item) =>
                  _DistributionTile(item: item),
            ),
        ],
      ),
    );
  }
}

class _DistributionTile extends StatelessWidget {
  const _DistributionTile({required this.item});

  final MemberDistributionReportItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.investmentTitle.isEmpty
                      ? item.investmentId
                      : item.investmentTitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  '${item.distributionStatus} · ${_formatDateTime(item.postedAt)}',
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
            _money(num.tryParse(item.shareAmount) ?? 0),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateFilterButton extends StatelessWidget {
  const _DateFilterButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.textMute,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMute,
                      ),
                    ),
                    Text(
                      value == null ? 'Any date' : _formatDate(value!),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClearFiltersButton extends StatelessWidget {
  const _ClearFiltersButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: const SizedBox(
          width: 46,
          height: 54,
          child: Icon(Icons.close_rounded, color: AppColors.textMute),
        ),
      ),
    );
  }
}

class _ReportMessage extends StatelessWidget {
  const _ReportMessage({
    required this.icon,
    required this.message,
    required this.foreground,
    required this.background,
  });

  final IconData icon;
  final String message;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
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

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: <Widget>[
          const Icon(Icons.info_outline_rounded, color: AppColors.textMute),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
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

class _HeaderText extends StatelessWidget {
  const _HeaderText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: AppColors.textMute,
      ),
    );
  }
}

class _ReferenceLine extends StatelessWidget {
  const _ReferenceLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final String text = value.trim().isEmpty ? '-' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$label: $text',
        style: const TextStyle(
          fontSize: 12,
          height: 1.35,
          fontWeight: FontWeight.w700,
          color: AppColors.textMid,
        ),
      ),
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

class _MemberReportData {
  const _MemberReportData({
    required this.statement,
    required this.distributions,
  });

  final MemberReportStatement statement;
  final MemberDistributionsReport distributions;
}

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

BoxDecoration _panelDecoration() {
  return BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: AppColors.border),
    boxShadow: <BoxShadow>[AppColors.softShadow(opacity: 0.08, blur: 10)],
  );
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

String _formatDate(DateTime value) {
  final String month = value.month.toString().padLeft(2, '0');
  final String day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

String _formatDateTime(DateTime? value) {
  if (value == null) {
    return '-';
  }
  final DateTime local = value.toLocal();
  final String month = local.month.toString().padLeft(2, '0');
  final String day = local.day.toString().padLeft(2, '0');
  final String hour = local.hour.toString().padLeft(2, '0');
  final String minute = local.minute.toString().padLeft(2, '0');
  return '${local.year}-$month-$day $hour:$minute';
}

String _money(num value) {
  return '${value < 0 ? '-' : ''}${fmt(value)}';
}

String _signedMoney(num value) {
  return '${value >= 0 ? '+' : '-'}${fmt(value)}';
}

String _referenceText(MemberReportEntry entry) {
  final String type = entry.referenceType.trim();
  final String id = entry.referenceId.trim();
  if (type.isEmpty && id.isEmpty) {
    return '-';
  }
  if (type.isEmpty) {
    return id;
  }
  if (id.isEmpty) {
    return type;
  }
  return '$type · $id';
}

String _statementCsv(MemberReportStatement statement) {
  final List<String> rows = <String>[
    <String>[
      'ledger_id',
      'entry_type',
      'amount',
      'currency',
      'txn_date',
      'running_balance',
      'reference_type',
      'reference_id',
      'comment',
      'created_at',
      'created_by',
    ].join(','),
    ...statement.entries.map((MemberReportEntry entry) {
      return <String>[
        entry.ledgerId,
        entry.entryType.apiValue,
        entry.amount,
        entry.currency,
        entry.txnDate,
        entry.runningBalance,
        entry.referenceType,
        entry.referenceId,
        entry.comment,
        entry.createdAt?.toIso8601String() ?? '',
        entry.createdByFullName,
      ].map(_csvCell).join(',');
    }),
  ];
  return rows.join('\n');
}

String _csvCell(String value) {
  final String escaped = value.replaceAll('"', '""');
  return '"$escaped"';
}
