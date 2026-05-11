import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../shared/finance.dart';
import '../data/investment_repository.dart';
import '../domain/investment_distribution_record.dart';

class DistributionRecordPage extends StatefulWidget {
  const DistributionRecordPage({
    super.key,
    required this.repository,
    required this.investmentId,
  });

  final InvestmentRepository repository;
  final String investmentId;

  @override
  State<DistributionRecordPage> createState() => _DistributionRecordPageState();
}

class _DistributionRecordPageState extends State<DistributionRecordPage> {
  InvestmentDistributionStatus? _status;
  late Future<List<InvestmentDistributionRecord>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = _loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _DistributionHeader(
          investmentId: widget.investmentId,
          onBack: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go(RouteNames.investments);
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: DropdownButtonFormField<InvestmentDistributionStatus?>(
            initialValue: _status,
            decoration: _fieldDecoration(
              label: 'Status',
              icon: Icons.tune_rounded,
            ),
            items: <DropdownMenuItem<InvestmentDistributionStatus?>>[
              const DropdownMenuItem<InvestmentDistributionStatus?>(
                value: null,
                child: Text('All Records'),
              ),
              ...InvestmentDistributionStatus.values.map(
                (InvestmentDistributionStatus status) =>
                    DropdownMenuItem<InvestmentDistributionStatus?>(
                      value: status,
                      child: Text(status.displayName),
                    ),
              ),
            ],
            onChanged: (InvestmentDistributionStatus? value) {
              setState(() {
                _status = value;
                _recordsFuture = _loadRecords();
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: FutureBuilder<List<InvestmentDistributionRecord>>(
            future: _recordsFuture,
            builder: (
              BuildContext context,
              AsyncSnapshot<List<InvestmentDistributionRecord>> snapshot,
            ) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              if (snapshot.hasError) {
                return const _MessageCard(
                  icon: Icons.error_outline,
                  message:
                      'Unable to load distribution records. Please try again.',
                  background: AppColors.redLt,
                  foreground: AppColors.red,
                );
              }

              final List<InvestmentDistributionRecord> records =
                  snapshot.data ?? <InvestmentDistributionRecord>[];
              if (records.isEmpty) {
                return const _MessageCard(
                  icon: Icons.call_split_rounded,
                  message: 'No distribution record exists yet.',
                  background: AppColors.surface,
                  foreground: AppColors.textMute,
                );
              }

              return Column(
                children: records
                    .map(
                      (InvestmentDistributionRecord record) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _DistributionRecordCard(record: record),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<List<InvestmentDistributionRecord>> _loadRecords() {
    return widget.repository.distributionRecords(
      widget.investmentId,
      status: _status,
    );
  }
}

class _DistributionHeader extends StatelessWidget {
  const _DistributionHeader({
    required this.investmentId,
    required this.onBack,
  });

  final String investmentId;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF1E3A5F), Color(0xFF152B45)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Material(
                color: Colors.white.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(12),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Distribution Records',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            investmentId,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: .7),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionRecordCard extends StatelessWidget {
  const _DistributionRecordCard({required this.record});

  final InvestmentDistributionRecord record;

  @override
  Widget build(BuildContext context) {
    final Color statusBg = record.status == InvestmentDistributionStatus.posted
        ? AppColors.greenLt
        : AppColors.redLt;
    final Color statusFg = record.status == InvestmentDistributionStatus.posted
        ? AppColors.green
        : AppColors.red;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: <BoxShadow>[AppColors.softShadow(opacity: 0.08, blur: 10)],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              record.status == InvestmentDistributionStatus.posted
                  ? Icons.call_split_rounded
                  : Icons.undo_rounded,
              color: statusFg,
              size: 18,
            ),
          ),
          title: Text(
            '${record.status.displayName} ${_money(record.pnlAmount)}',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          subtitle: Text(
            'Posted ${_formatDateTime(record.postedAt)}',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMute,
            ),
          ),
          children: <Widget>[
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.25,
              children: <Widget>[
                _InfoBox(label: 'Rounded', value: _money(record.roundedTotal)),
                _InfoBox(
                  label: 'Remainder',
                  value: _money(record.remainderApplied),
                ),
                _InfoBox(label: 'Lines', value: '${record.lines.length}'),
                _InfoBox(
                  label: 'Posted By',
                  value: _valueOrDash(record.postedBy?.fullName),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _TextBlock(label: 'Distribution ID', value: record.distributionId),
            const SizedBox(height: 8),
            _TextBlock(label: 'Snapshot ID', value: record.snapshotId),
            if (record.reversedAt != null || record.reversedBy != null) ...<Widget>[
              const SizedBox(height: 8),
              _TextBlock(
                label: 'Reversed',
                value:
                    '${_formatDateTime(record.reversedAt)} by '
                    '${_valueOrDash(record.reversedBy?.fullName)}',
              ),
            ],
            if (record.lines.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'MEMBER SHARES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMute,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...record.lines.map(
                (InvestmentDistributionLine line) => _DistributionLineTile(
                  line: line,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DistributionLineTile extends StatelessWidget {
  const _DistributionLineTile({required this.line});

  final InvestmentDistributionLine line;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _valueOrDash(line.fullName),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ratio ${_valueOrDash(line.ratioUsed)}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMute,
                  ),
                ),
                Text(
                  'Ledger ${_valueOrDash(line.ledgerEntryId)}',
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
          const SizedBox(width: 10),
          Text(
            _money(line.shareAmount),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textMute,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  const _TextBlock({required this.label, required this.value});

  final String label;
  final String value;

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
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.textMute,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            _valueOrDash(value),
            style: const TextStyle(
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: AppColors.textMid,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.message,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String message;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                height: 1.35,
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

String _money(String value) {
  final num amount = num.tryParse(value) ?? 0;
  return '${amount < 0 ? '-' : ''}${fmt(amount)}';
}

String _valueOrDash(String? value) {
  final String text = value?.trim() ?? '';
  return text.isEmpty ? '-' : text;
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
