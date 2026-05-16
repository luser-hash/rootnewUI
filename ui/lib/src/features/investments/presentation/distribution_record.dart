import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../shared/finance.dart';
import '../../shared/widgets/app_detail_block.dart';
import '../../shared/widgets/app_message_card.dart';
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
              context: context,
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
            builder:
                (
                  BuildContext context,
                  AsyncSnapshot<List<InvestmentDistributionRecord>> snapshot,
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

                  if (snapshot.hasError) {
                    return AppMessageCard(
                      icon: Icons.error_outline,
                      message:
                          'Unable to load distribution records. Please try again.',
                      background: AppThemeColors.statusErrorBg(context),
                      foreground: AppThemeColors.statusErrorFg(context),
                      fullWidth: true,
                    );
                  }

                  final List<InvestmentDistributionRecord> records =
                      snapshot.data ?? <InvestmentDistributionRecord>[];
                  if (records.isEmpty) {
                    return AppMessageCard(
                      icon: Icons.call_split_rounded,
                      message: 'No distribution record exists yet.',
                      background: AppThemeColors.surface(context),
                      foreground: AppThemeColors.textMuted(context),
                      fullWidth: true,
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
  const _DistributionHeader({required this.investmentId, required this.onBack});

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
          // Text(
          //   investmentId,
          //   overflow: TextOverflow.ellipsis,
          //   style: TextStyle(
          //     fontSize: 12,
          //     fontWeight: FontWeight.w700,
          //     color: Colors.white.withValues(alpha: .7),
          //   ),
          // ),
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
        ? AppThemeColors.statusSuccessBg(context)
        : AppThemeColors.statusErrorBg(context);
    final Color statusFg = record.status == InvestmentDistributionStatus.posted
        ? AppThemeColors.statusSuccessFg(context)
        : AppThemeColors.statusErrorFg(context);

    return Container(
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppThemeColors.border(context)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppThemeColors.shadow(context).withValues(alpha: .08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
            '${record.status.displayName} ${formatMoneyTextSigned(record.pnlAmount)}',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppThemeColors.text(context),
            ),
          ),
          subtitle: Text(
            'Posted ${formatDateTimeShort(record.postedAt)}',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppThemeColors.textMuted(context),
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
                AppDetailBlock(
                  label: 'Rounded',
                  value: formatMoneyTextSigned(record.roundedTotal),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  borderRadius: 12,
                  center: true,
                  valueMaxLines: 1,
                  valueFontSize: 13,
                  valueWeight: FontWeight.w800,
                ),
                AppDetailBlock(
                  label: 'Remainder',
                  value: formatMoneyTextSigned(record.remainderApplied),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  borderRadius: 12,
                  center: true,
                  valueMaxLines: 1,
                  valueFontSize: 13,
                  valueWeight: FontWeight.w800,
                ),
                AppDetailBlock(
                  label: 'Lines',
                  value: '${record.lines.length}',
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  borderRadius: 12,
                  center: true,
                  valueMaxLines: 1,
                  valueFontSize: 13,
                  valueWeight: FontWeight.w800,
                ),
                AppDetailBlock(
                  label: 'Posted By',
                  value: valueOrDash(record.postedBy?.fullName),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  borderRadius: 12,
                  center: true,
                  valueMaxLines: 1,
                  valueFontSize: 13,
                  valueWeight: FontWeight.w800,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // AppDetailBlock(
            //   label: 'Distribution ID',
            //   value: record.distributionId,
            //   fullWidth: true,
            //   selectable: true,
            // ),
            // const SizedBox(height: 8),
            // AppDetailBlock(
            //   label: 'Snapshot ID',
            //   value: record.snapshotId,
            //   fullWidth: true,
            //   selectable: true,
            // ),
            if (record.reversedAt != null ||
                record.reversedBy != null) ...<Widget>[
              const SizedBox(height: 8),
              AppDetailBlock(
                label: 'Reversed',
                value:
                    '${formatDateTimeShort(record.reversedAt)} by '
                    '${valueOrDash(record.reversedBy?.fullName)}',
                fullWidth: true,
                selectable: true,
              ),
            ],
            if (record.lines.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'MEMBER SHARES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppThemeColors.textMuted(context),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...record.lines.map(
                (InvestmentDistributionLine line) =>
                    _DistributionLineTile(line: line),
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
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  valueOrDash(line.fullName),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppThemeColors.text(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ratio ${valueOrDash(line.ratioUsed)}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppThemeColors.textMuted(context),
                  ),
                ),
                // Text(
                //   'Ledger ${valueOrDash(line.ledgerEntryId)}',
                //   overflow: TextOverflow.ellipsis,
                //   style: TextStyle(
                //     fontSize: 10,
                //     fontWeight: FontWeight.w600,
                //     color: AppThemeColors.textMuted(context),
                //   ),
                // ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            formatMoneyTextSigned(line.shareAmount),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppThemeColors.text(context),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _fieldDecoration({
  required BuildContext context,
  required String label,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 18),
    filled: true,
    fillColor: AppThemeColors.elevatedSurface(context),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: AppThemeColors.border(context)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: AppThemeColors.border(context)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 1.3,
      ),
    ),
  );
}
