import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../shared/finance.dart';
import '../../shared/widgets/app_action_button.dart';
import '../../shared/widgets/app_small_button.dart';
import '../../shared/widgets/status_pills.dart';
import '../data/investment_repository.dart';
import '../domain/investment_detail.dart';
import 'investment_controller.dart';

class InvestmentPage extends StatefulWidget {
  const InvestmentPage({super.key, required this.repository});

  final InvestmentRepository repository;

  @override
  State<InvestmentPage> createState() => _InvestmentPageState();
}

class _InvestmentPageState extends State<InvestmentPage> {
  late final InvestmentController _controller;

  @override
  void initState() {
    super.initState();
    _controller = InvestmentController(repository: widget.repository);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        final List<Investment> items = _controller.investments;

        return Column(
          children: <Widget>[
            _InvestmentsHeader(investments: items),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: _buildBody(items),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(List<Investment> items) {
    if (_controller.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 32),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final String? error = _controller.errorMessage;
    if (error != null) {
      return _InvestmentMessage(
        icon: Icons.error_outline,
        message: error,
        background: AppColors.redLt,
        foreground: AppColors.red,
      );
    }

    if (items.isEmpty) {
      return const _InvestmentMessage(
        icon: Icons.savings_outlined,
        message: 'No investments found.',
        background: AppColors.surface,
        foreground: AppColors.textMute,
      );
    }

    return Column(
      children: items
          .map(
            (Investment inv) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _InvestmentFullCard(
                inv: inv,
                onDetails: () => _showDetails(inv),
              ),
            ),
          )
          .toList(),
    );
  }

  Future<void> _showDetails(Investment investment) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (BuildContext context) {
        return _InvestmentDetailSheet(
          investment: investment,
          detailFuture: widget.repository.detail(investment.id),
        );
      },
    );
  }
}

class _InvestmentsHeader extends StatelessWidget {
  const _InvestmentsHeader({required this.investments});

  final List<Investment> investments;

  @override
  Widget build(BuildContext context) {
    final num pnlTotal = investments.fold<num>(
      0,
      (num sum, Investment item) => sum + (item.pnl ?? 0),
    );
    final List<({String label, String value})> stats = <({
      String label,
      String value,
    })>[
      (
        label: 'Open',
        value: '${investments.where(_isOpenInvestment).length}',
      ),
      (label: 'Total', value: '${investments.length}'),
      (
        label: 'P&L',
        value: '${pnlTotal >= 0 ? '+' : '-'}${fmtSh(pnlTotal)}',
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF1E3A5F), Color(0xFF152B45)],
        ),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Investments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                AppSmallButton(
                  label: '+ Create',
                  background: Colors.white.withValues(alpha: .15),
                  foreground: Colors.white,
                  onTap: () {},
                ),
              ],
            ),
          ),
          Row(
            children: stats
                .map(
                  (({String label, String value}) s) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        right: s.label == stats.last.label ? 0 : 8,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: <Widget>[
                          Text(
                            s.value,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            s.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: .55),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

bool _isOpenInvestment(Investment investment) {
  return investment.status == InvestmentStatus.open;
}

class _InvestmentFullCard extends StatelessWidget {
  const _InvestmentFullCard({required this.inv, required this.onDetails});

  final Investment inv;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final num? pnl = inv.pnl;
    final bool hasPrimaryAction =
        inv.status == InvestmentStatus.draft ||
        inv.status == InvestmentStatus.open ||
        inv.status == InvestmentStatus.closed;
    final Color border = inv.status == InvestmentStatus.open
        ? AppColors.primary.withValues(alpha: .3)
        : inv.status == InvestmentStatus.draft
        ? AppColors.amber.withValues(alpha: .3)
        : AppColors.border;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 1.5),
        boxShadow: <BoxShadow>[AppColors.softShadow()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      inv.title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      inv.to,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMute,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              InvestmentStatusPill(status: inv.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _MoneyBox(
                  label: 'Invested',
                  value: fmt(inv.amount),
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
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              if (inv.status == InvestmentStatus.draft)
                Expanded(
                  child: AppActionButton(
                    label: 'Release Funds',
                    background: AppColors.amberLt,
                    foreground: AppColors.amber,
                    onTap: () {},
                  ),
                ),
              if (inv.status == InvestmentStatus.open)
                Expanded(
                  child: AppActionButton(
                    label: 'Close',
                    background: AppColors.surface,
                    foreground: AppColors.text,
                    onTap: () {},
                  ),
                ),
              if (inv.status == InvestmentStatus.closed)
                Expanded(
                  child: AppActionButton(
                    label: 'Distribute P&L',
                    background: AppColors.primary,
                    foreground: Colors.white,
                    onTap: () {},
                  ),
                ),
              if (hasPrimaryAction) const SizedBox(width: 8),
              AppSmallButton(
                label: 'Details',
                background: AppColors.surface,
                foreground: AppColors.textMid,
                onTap: onDetails,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvestmentDetailSheet extends StatelessWidget {
  const _InvestmentDetailSheet({
    required this.investment,
    required this.detailFuture,
  });

  final Investment investment;
  final Future<InvestmentDetail> detailFuture;

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
            body = _InvestmentMessage(
              icon: Icons.error_outline,
              message: 'Unable to load investment details. Please try again.',
              background: AppColors.redLt,
              foreground: AppColors.red,
            );
          } else {
            body = _InvestmentDetailContent(detail: snap.data!);
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
  const _InvestmentDetailContent({required this.detail});

  final InvestmentDetail detail;

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
              _DetailRow(label: 'Status', value: detail.status.label),
              _DetailRow(
                label: 'Type',
                value: _prettyType(detail.investmentType),
              ),
              _DetailRow(label: 'Invested To', value: detail.investedTo),
              _DetailRow(label: 'Created Date', value: detail.createdDate),
              _DetailRow(
                label: 'Return Amount',
                value: returned == null ? '-' : fmt(returned),
              ),
              _DetailRow(
                label: 'Close Date',
                value: _valueOrDash(detail.closeDate),
              ),
              _DetailRow(
                label: 'Fund Released At',
                value: _formatDateTime(detail.fundReleasedAt),
              ),
              _DetailRow(
                label: 'Fund Released By',
                value: _valueOrDash(detail.fundReleasedBy),
              ),
              _DetailRow(
                label: 'Created By',
                value: _valueOrDash(detail.createdBy?.fullName),
              ),
              _DetailRow(
                label: 'Snapshot',
                value: detail.hasSnapshot ? 'Available' : 'Not available',
              ),
              _DetailRow(
                label: 'Created At',
                value: _formatDateTime(detail.createdAt),
              ),
              _DetailRow(
                label: 'Updated At',
                value: _formatDateTime(detail.updatedAt),
                isLast: true,
              ),
            ],
          ),
        ),
        if (detail.comment.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          _TextBlock(label: 'Comment', value: detail.comment),
        ],
        if (detail.closureComment.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          _TextBlock(label: 'Closure Comment', value: detail.closureComment),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textMute,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              _valueOrDash(value),
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textMute,
              letterSpacing: .4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w700,
              color: AppColors.textMid,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvestmentMessage extends StatelessWidget {
  const _InvestmentMessage({
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
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
      .map(
        (String part) => '${part[0].toUpperCase()}${part.substring(1)}',
      )
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
