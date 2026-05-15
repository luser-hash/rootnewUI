import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../shared/finance.dart';
import '../../shared/widgets/app_action_button.dart';
import '../../shared/widgets/app_detail_block.dart';
import '../../shared/widgets/app_detail_row.dart';
import '../../shared/widgets/app_metric_card.dart';
import '../../shared/widgets/app_message_card.dart';
import '../domain/investment_detail.dart';

class InvestmentDetailPage extends StatelessWidget {
  const InvestmentDetailPage({
    super.key,
    required this.investment,
    required this.detailFuture,
    required this.onDistributionRecord,
  });

  final Investment investment;
  final Future<InvestmentDetail> detailFuture;
  final VoidCallback onDistributionRecord;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<InvestmentDetail>(
        future: detailFuture,
        builder: (BuildContext context, AsyncSnapshot<InvestmentDetail> snap) {
          final Widget body;
          if (snap.connectionState != ConnectionState.done) {
            body = const Padding(
              padding: EdgeInsets.symmetric(vertical: 38),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          } else if (snap.hasError || !snap.hasData) {
            body = const AppMessageCard(
              icon: Icons.error_outline,
              message: 'Unable to load investment details. Please try again.',
              background: AppColors.redLt,
              foreground: AppColors.red,
              fullWidth: true,
            );
          } else {
            body = _InvestmentDetailContent(
              detail: snap.data!,
              onDistributionRecord: onDistributionRecord,
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              18,
              18,
              18,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.blueLt,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.account_balance_outlined,
                        color: AppColors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            investment.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            valueOrDash(investment.to),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMute,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                body,
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InvestmentDetailContent extends StatelessWidget {
  const _InvestmentDetailContent({
    required this.detail,
    required this.onDistributionRecord,
  });

  final InvestmentDetail detail;
  final VoidCallback onDistributionRecord;

  @override
  Widget build(BuildContext context) {
    final num invested = num.tryParse(detail.investedAmount) ?? 0;
    final num? returned = num.tryParse(detail.returnAmount ?? '');
    final num? pnl = num.tryParse(detail.pnlAmount ?? '');
    final bool hasDistributionRecord =
        detail.status == InvestmentStatus.distributed ||
        detail.status == InvestmentStatus.reversed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: AppMetricCard(
                label: 'Invested',
                value: fmt(invested),
                background: AppColors.surface,
                color: AppColors.text,
                borderRadius: 12,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                valueStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppMetricCard(
                label: 'P&L',
                value: pnl == null
                    ? 'Pending'
                    : '${pnl >= 0 ? '+' : '-'}${fmt(pnl)}',
                background: pnl == null
                    ? AppColors.surface
                    : pnl >= 0
                    ? AppColors.greenLt
                    : AppColors.redLt,
                color: pnl == null
                    ? AppColors.textMute
                    : pnl >= 0
                    ? AppColors.green
                    : AppColors.red,
                borderRadius: 12,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                valueStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: pnl == null
                      ? AppColors.textMute
                      : pnl >= 0
                      ? AppColors.green
                      : AppColors.red,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: <Widget>[
              AppDetailRow(
                label: 'Investment ID',
                value: detail.id,
                labelExpanded: true,
                valueTextAlign: TextAlign.end,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              AppDetailRow(
                label: 'Status',
                value: detail.status.label,
                labelExpanded: true,
                valueTextAlign: TextAlign.end,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              AppDetailRow(
                label: 'Type',
                value: prettyEnumLabel(detail.investmentType),
                labelExpanded: true,
                valueTextAlign: TextAlign.end,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              AppDetailRow(
                label: 'Invested To',
                value: detail.investedTo,
                labelExpanded: true,
                valueTextAlign: TextAlign.end,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              AppDetailRow(
                label: 'Created Date',
                value: detail.createdDate,
                labelExpanded: true,
                valueTextAlign: TextAlign.end,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              AppDetailRow(
                label: 'Return Amount',
                value: returned == null ? '-' : fmt(returned),
                labelExpanded: true,
                valueTextAlign: TextAlign.end,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              AppDetailRow(
                label: 'Close Date',
                value: valueOrDash(detail.closeDate),
                labelExpanded: true,
                valueTextAlign: TextAlign.end,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              AppDetailRow(
                label: 'Fund Released At',
                value: formatDateTimeShort(detail.fundReleasedAt),
                labelExpanded: true,
                valueTextAlign: TextAlign.end,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              AppDetailRow(
                label: 'Fund Released By',
                value: valueOrDash(detail.fundReleasedBy),
                labelExpanded: true,
                valueTextAlign: TextAlign.end,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              AppDetailRow(
                label: 'Created By',
                value: valueOrDash(detail.createdBy?.fullName),
                labelExpanded: true,
                valueTextAlign: TextAlign.end,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              AppDetailRow(
                label: 'Created By ID',
                value: valueOrDash(detail.createdBy?.userId),
                labelExpanded: true,
                valueTextAlign: TextAlign.end,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              AppDetailRow(
                label: 'Snapshot',
                value: detail.hasSnapshot ? 'Available' : 'Not available',
                labelExpanded: true,
                valueTextAlign: TextAlign.end,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              AppDetailRow(
                label: 'Created At',
                value: formatDateTimeShort(detail.createdAt),
                labelExpanded: true,
                valueTextAlign: TextAlign.end,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              AppDetailRow(
                label: 'Updated At',
                value: formatDateTimeShort(detail.updatedAt),
                isLast: true,
                labelExpanded: true,
                valueTextAlign: TextAlign.end,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ],
          ),
        ),
        if (detail.comment.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          AppDetailBlock(
            label: 'Comment',
            value: detail.comment,
            padding: const EdgeInsets.all(14),
            borderRadius: 16,
            valueColor: AppColors.textMid,
            valueFontSize: 13,
          ),
        ],
        if (detail.closureComment.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          AppDetailBlock(
            label: 'Closure Comment',
            value: detail.closureComment,
            padding: const EdgeInsets.all(14),
            borderRadius: 16,
            valueColor: AppColors.textMid,
            valueFontSize: 13,
          ),
        ],
        if (hasDistributionRecord) ...<Widget>[
          const SizedBox(height: 10),
          AppActionButton(
            label: 'Distribution Record',
            background: AppColors.blueLt,
            foreground: AppColors.blue,
            onTap: onDistributionRecord,
          ),
        ],
      ],
    );
  }
}
