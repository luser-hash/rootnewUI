import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../shared/finance.dart';
import '../../../shared/widgets/app_data_table.dart';
import '../../../shared/widgets/app_metric_card.dart';
import '../../../shared/widgets/app_message_card.dart';
import '../../../shared/widgets/app_screen_header.dart';
import '../../data/member_report_repository.dart';
import '../../domain/member_report_models.dart';

part 'sections/member_summary_section.dart';
part 'sections/transaction_panel.dart';
part 'sections/pending_requests_panel.dart';
part 'sections/distributions_panel.dart';
part 'member_report_controller.dart';

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
        const AppScreenHeader(
          title: 'Member Report',
          subtitle: 'Capital, balance, and transaction statement.',
          padding: EdgeInsets.fromLTRB(20, 12, 20, 24),
          gradientColors: <Color>[Color(0xFF5B4A1D), Color(0xFF2F473E)],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: FutureBuilder<_MemberReportData>(
            future: _reportFuture,
            builder:
                (
                  BuildContext context,
                  AsyncSnapshot<_MemberReportData> snapshot,
                ) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return const AppMessageCard(
                      icon: Icons.error_outline,
                      message:
                          'Unable to load member report. Please try again.',
                      foreground: AppColors.red,
                      background: AppColors.redLt,
                      padding: EdgeInsets.all(18),
                      borderRadius: 18,
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
