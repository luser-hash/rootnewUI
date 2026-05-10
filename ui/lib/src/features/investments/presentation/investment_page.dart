import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../shared/finance.dart';
import '../../shared/widgets/app_action_button.dart';
import '../../shared/widgets/app_small_button.dart';
import '../../shared/widgets/status_pills.dart';
import '../data/investment_repository.dart';
import 'investment_controller.dart';
import 'investment_detail_page.dart';

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
        return InvestmentDetailPage(
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
