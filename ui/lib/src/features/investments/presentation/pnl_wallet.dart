import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../reports/data/staff_report_repository.dart';
import '../../reports/domain/staff_report_models.dart';
import '../../shared/finance.dart';
import '../../shared/widgets/app_message_card.dart';

class PnlWalletPage extends StatefulWidget {
  const PnlWalletPage({super.key, required this.repository});

  final StaffReportRepository repository;

  @override
  State<PnlWalletPage> createState() => _PnlWalletPageState();
}

class _PnlWalletPageState extends State<PnlWalletPage> {
  late Future<InvestmentPnlProfileReport> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = widget.repository.investmentPnlProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _WalletHeader(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: FutureBuilder<InvestmentPnlProfileReport>(
                future: _profileFuture,
                builder:
                    (
                      BuildContext context,
                      AsyncSnapshot<InvestmentPnlProfileReport> snapshot,
                    ) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }

                      if (snapshot.hasError || !snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: AppMessageCard(
                            icon: Icons.error_outline,
                            message:
                                'Unable to load P&L wallet. Please try again.',
                            background: AppThemeColors.statusErrorBg(context),
                            foreground: AppThemeColors.statusErrorFg(context),
                            fullWidth: true,
                          ),
                        );
                      }

                      return _WalletContent(summary: snapshot.data!.summary);
                    },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletHeader extends StatelessWidget {
  const _WalletHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 18, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF1E3A5F), Color(0xFF152B45)],
        ),
      ),
      child: Row(
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
    );
  }
}

class _WalletContent extends StatelessWidget {
  const _WalletContent({required this.summary});

  final InvestmentPnlProfileSummary summary;

  @override
  Widget build(BuildContext context) {
    final num netPnl = num.tryParse(summary.netPnl) ?? 0;
    final bool isProfit = netPnl >= 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _NetPnlCard(summary: summary, isProfit: isProfit),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _CountCard(
                  label: 'Profitable',
                  value: summary.profitableCount,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CountCard(
                  label: 'Loss',
                  value: summary.lossCount,
                  color: AppColors.red,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CountCard(
                  label: 'Break Even',
                  value: summary.breakEvenCount,
                  color: AppThemeColors.textMid(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MoneyGrid(summary: summary),
        ],
      ),
    );
  }
}

class _NetPnlCard extends StatelessWidget {
  const _NetPnlCard({required this.summary, required this.isProfit});

  final InvestmentPnlProfileSummary summary;
  final bool isProfit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isProfit
                  ? AppThemeColors.statusSuccessBg(context)
                  : AppThemeColors.statusErrorBg(context),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: isProfit
                  ? AppThemeColors.statusSuccessFg(context)
                  : AppThemeColors.statusErrorFg(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Net P&L',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppThemeColors.textMuted(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatMoneyTextSigned(summary.netPnl),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isProfit ? AppColors.green : AppColors.red,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${summary.investmentCount} finalized investments',
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
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.textMuted(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyGrid extends StatelessWidget {
  const _MoneyGrid({required this.summary});

  final InvestmentPnlProfileSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Column(
        children: <Widget>[
          _MoneyRow(
            label: 'Total Invested',
            value: formatMoneyTextSigned(summary.totalInvestedAmount),
          ),
          _MoneyRow(
            label: 'Total Return',
            value: formatMoneyTextSigned(summary.totalReturnAmount),
          ),
          _MoneyRow(
            label: 'Total Profit',
            value: formatMoneyTextSigned(summary.totalProfit),
            valueColor: AppColors.green,
          ),
          _MoneyRow(
            label: 'Total Loss',
            value: formatMoneyTextSigned(summary.totalLoss),
            valueColor: AppColors.red,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: AppThemeColors.border(context)))
            : null,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppThemeColors.textMuted(context),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: valueColor ?? AppThemeColors.text(context),
            ),
          ),
        ],
      ),
    );
  }
}
