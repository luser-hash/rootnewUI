import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../shared/finance.dart';
import '../../shared/widgets/app_message_card.dart';
import '../../shared/widgets/status_pills.dart';

class PnlWalletPage extends StatelessWidget {
  const PnlWalletPage({super.key, required this.investments});

  final List<Investment> investments;

  @override
  Widget build(BuildContext context) {
    final num totalPnl = investments.fold<num>(
      0,
      (num sum, Investment item) => sum + (item.pnl ?? 0),
    );
    final List<Investment> pnlItems = investments
        .where((Investment item) => item.pnl != null)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _WalletHeader(
              totalPnl: totalPnl,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _WalletSummary(totalPnl: totalPnl),
                    const SizedBox(height: 14),
                    if (pnlItems.isEmpty)
                      const AppMessageCard(
                        icon: Icons.account_balance_wallet_outlined,
                        message: 'No P&L wallet entries found.',
                        background: AppColors.white,
                        foreground: AppColors.textMute,
                        fullWidth: true,
                      )
                    else
                      ...pnlItems.map(
                        (Investment investment) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _WalletInvestmentTile(
                            investment: investment,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletHeader extends StatelessWidget {
  const _WalletHeader({required this.totalPnl, required this.onBack});

  final num totalPnl;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final bool isProfit = totalPnl >= 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 18, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF1E3A5F), Color(0xFF152B45)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                color: Colors.white,
                tooltip: 'Back',
              ),
              const Expanded(
                child: Text(
                  'P&L Wallet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6),
            child: Text(
              '${isProfit ? '+' : '-'}${fmt(totalPnl)}',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: isProfit ? AppColors.greenLt : AppColors.redLt,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 2),
            child: Text(
              isProfit ? 'Total available profit' : 'Total recorded loss',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: .65),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletSummary extends StatelessWidget {
  const _WalletSummary({required this.totalPnl});

  final num totalPnl;

  @override
  Widget build(BuildContext context) {
    final bool isProfit = totalPnl >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[AppColors.softShadow(opacity: 0.08, blur: 10)],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isProfit ? AppColors.greenLt : AppColors.redLt,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: isProfit ? AppColors.green : AppColors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Wallet Balance',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMute,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${isProfit ? '+' : '-'}${fmt(totalPnl)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isProfit ? AppColors.green : AppColors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletInvestmentTile extends StatelessWidget {
  const _WalletInvestmentTile({required this.investment});

  final Investment investment;

  @override
  Widget build(BuildContext context) {
    final num pnl = investment.pnl ?? 0;
    final bool isProfit = pnl >= 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  investment.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  investment.to,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMute,
                  ),
                ),
                const SizedBox(height: 8),
                InvestmentStatusPill(status: investment.status),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${isProfit ? '+' : '-'}${fmt(pnl)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: isProfit ? AppColors.green : AppColors.red,
            ),
          ),
        ],
      ),
    );
  }
}
