import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../shared/finance.dart';
import '../../shared/widgets/app_action_button.dart';
import '../../shared/widgets/app_detail_block.dart';
import '../../shared/widgets/app_detail_row.dart';
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
                            _valueOrDash(investment.to),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _MoneyBox(
                label: 'Invested',
                value: fmt(invested),
                background: AppColors.surface,
                valueColor: AppColors.text,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MoneyBox(
                label: 'P&L',
                value: pnl == null
                    ? 'Pending'
                    : '${pnl >= 0 ? '+' : '-'}${fmt(pnl)}',
                background: pnl == null
                    ? AppColors.surface
                    : pnl >= 0
                    ? AppColors.greenLt
                    : AppColors.redLt,
                valueColor: pnl == null
                    ? AppColors.textMute
                    : pnl >= 0
                    ? AppColors.green
                    : AppColors.red,
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
                value: _prettyType(detail.investmentType),
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
                value: _valueOrDash(detail.closeDate),
                labelExpanded: true,
                valueTextAlign: TextAlign.end,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              AppDetailRow(
                label: 'Fund Released At',
                value: _formatDateTime(detail.fundReleasedAt),
                labelExpanded: true,
                valueTextAlign: TextAlign.end,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              AppDetailRow(
                label: 'Fund Released By',
                value: _valueOrDash(detail.fundReleasedBy),
                labelExpanded: true,
                valueTextAlign: TextAlign.end,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              AppDetailRow(
                label: 'Created By',
                value: _valueOrDash(detail.createdBy?.fullName),
                labelExpanded: true,
                valueTextAlign: TextAlign.end,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              AppDetailRow(
                label: 'Created By ID',
                value: _valueOrDash(detail.createdBy?.userId),
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
                value: _formatDateTime(detail.createdAt),
                labelExpanded: true,
                valueTextAlign: TextAlign.end,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              AppDetailRow(
                label: 'Updated At',
                value: _formatDateTime(detail.updatedAt),
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
          const SizedBox(height: 10),
          AppActionButton(
            label: 'Distributon Record',
            background: AppColors.blueLt,
            foreground: AppColors.blue,
            onTap: onDistributionRecord,
          ),
        ],
      ],
    );
  }
}

class _MoneyBox extends StatelessWidget {
  const _MoneyBox({
    required this.label,
    required this.value,
    required this.background,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color background;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMute,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

String _valueOrDash(String? value) {
  final String text = value?.trim() ?? '';
  return text.isEmpty ? '-' : text;
}

String _prettyType(String value) {
  final String normalized = value.trim().replaceAll('_', ' ').toLowerCase();
  if (normalized.isEmpty) {
    return '-';
  }
  return normalized
      .split(RegExp(r'\s+'))
      .where((String part) => part.isNotEmpty)
      .map((String part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
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
