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
      backgroundColor: AppColors.surface,
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
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: AppMessageCard(
                            icon: Icons.error_outline,
                            message:
                                'Unable to load P&L wallet. Please try again.',
                            background: AppColors.redLt,
                            foreground: AppColors.red,
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
                  color: AppColors.textMid,
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[AppColors.softShadow(opacity: 0.08, blur: 10)],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
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
                  'Net P&L',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMute,
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
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMute,
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
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
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textMute,
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
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
    this.valueColor = AppColors.text,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.border))
            : null,
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
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
