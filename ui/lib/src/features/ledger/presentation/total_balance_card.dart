import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
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
    final String balance = isLoading && statement == null
        ? 'Loading...'
        : _formatMoney(statement?.currentBalance);
    final double pending =
        double.tryParse(statement?.pendingTotal ?? '0') ?? 0;
    final String supportText =
        errorMessage ??
        (isLoading ? 'Refreshing balance' : 'Available ledger balance');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: .72)),
        boxShadow: <BoxShadow>[
          AppColors.softShadow(opacity: .08, blur: 22),
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
                  color: AppColors.greenLt,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 21,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'TOTAL BALANCE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMute,
                    letterSpacing: 0.55,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            balance,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
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
              color: errorMessage == null ? AppColors.textMute : AppColors.red,
            ),
          ),
          if (pending > 0)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: <Widget>[
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 16),
                  _BalanceMetaItem(
                    icon: Icons.schedule_rounded,
                    label: 'Pending',
                    value: '+${_formatMoney(statement?.pendingTotal)}',
                    foreground: AppColors.amber,
                    background: AppColors.amberLt,
                  ),
                ],
              ),
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
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textMute,
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

String _formatMoney(String? value) {
  final double amount = double.tryParse(value ?? '0') ?? 0;
  return '৳${amount.abs().toStringAsFixed(2)}';
}
