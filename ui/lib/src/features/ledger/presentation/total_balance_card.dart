import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../shared/finance.dart';
import '../domain/member_ledger_statement.dart';

class TotalBalanceCard extends StatelessWidget {
  const TotalBalanceCard({
    super.key,
    required this.statement,
    required this.isLoading,
    required this.errorMessage,
  });

  final MemberLedgerStatement? statement;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final String totalAmount = isLoading && statement == null
        ? 'Loading...'
        : formatMoneyTextUnsigned(statement?.totalAmount);
    final String capitalBalance = isLoading && statement == null
        ? '-'
        : formatMoneyTextUnsigned(statement?.capitalBalance);
    final String profitWallet = isLoading && statement == null
        ? '-'
        : formatMoneyTextUnsigned(statement?.profitWalletBalance);
    final String pendingAmount = isLoading && statement == null
        ? '-'
        : formatMoneyTextUnsigned(statement?.pendingTotal);
    final double pending = double.tryParse(statement?.pendingTotal ?? '0') ?? 0;
    final String supportText =
        errorMessage ??
        (isLoading
            ? 'Refreshing wallet balances'
            : 'Latest wallet summary');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppThemeColors.border(context).withValues(alpha: .72),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppThemeColors.shadow(context).withValues(alpha: .08),
            blurRadius: 22,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppThemeColors.statusSuccessBg(context),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 21,
                  color: AppThemeColors.statusSuccessFg(context),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'TOTAL AMOUNT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppThemeColors.textMuted(context),
                        letterSpacing: 0.55,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Capital + Profit Wallet',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppThemeColors.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            totalAmount,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppThemeColors.text(context),
              height: 1.08,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            supportText,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w700,
              color: errorMessage == null
                  ? AppThemeColors.textMuted(context)
                  : AppThemeColors.statusErrorFg(context),
            ),
          ),
          const SizedBox(height: 20),
          Divider(height: 1, color: AppThemeColors.divider(context)),
          const SizedBox(height: 16),
          _BalanceMetaItem(
            icon: Icons.account_balance_outlined,
            label: 'Capital Balance',
            value: capitalBalance,
            foreground: AppThemeColors.statusSuccessFg(context),
            background: AppThemeColors.statusSuccessBg(context),
          ),
          const SizedBox(height: 12),
          _BalanceMetaItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Profit Wallet',
            value: profitWallet,
            foreground: AppColors.blue,
            background: AppThemeColors.statusInfoBg(context),
          ),
          const SizedBox(height: 12),
          _BalanceMetaItem(
            icon: Icons.schedule_rounded,
            label: 'Pending',
            value: pending > 0 ? '+$pendingAmount' : pendingAmount,
            foreground: AppThemeColors.statusWarningFg(context),
            background: AppThemeColors.statusWarningBg(context),
          ),
          const SizedBox(height: 12),
          _BalanceMetaItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Total Amount',
            value: totalAmount,
            foreground: AppThemeColors.text(context),
            background: AppThemeColors.statusNeutralBg(context),
          ),
        ],
      ),
    );
  }
}

class _BalanceMetaItem extends StatelessWidget {
  const _BalanceMetaItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.foreground,
    required this.background,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: foreground),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.textMuted(context),
            ),
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: foreground,
          ),
        ),
      ],
    );
  }
}
