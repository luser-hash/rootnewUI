part of 'investment_page.dart';

class _InvestmentsHeaderContent extends StatelessWidget {
  const _InvestmentsHeaderContent({
    required this.investments,
    required this.capitalSummary,
    required this.onCreate,
    required this.onWalletTap,
    required this.canCreate,
    required this.showSummary,
  });

  final List<Investment> investments;
  final InvestmentCapitalSummary? capitalSummary;
  final VoidCallback onCreate;
  final VoidCallback onWalletTap;
  final bool canCreate;
  final bool showSummary;

  @override
  Widget build(BuildContext context) {
    final num pnlTotal = investments.fold<num>(
      0,
      (num sum, Investment item) => sum + (item.pnl ?? 0),
    );
    final InvestmentCapitalSummary? summary = capitalSummary;
    final List<({String label, String value})> stats =
        <({String label, String value})>[
          (
            label: 'Capital',
            value: summary == null
                ? '--'
                : _formatHeaderMoney(summary.totalCapital),
          ),
          (
            label: 'Open Invested',
            value: summary == null
                ? '--'
                : _formatHeaderMoney(summary.openInvestedAmount),
          ),
          (
            label: 'Available',
            value: summary == null
                ? '--'
                : _formatHeaderMoney(summary.availableInvestmentCapital),
          ),
        ];

    return AppScreenHeader(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      gradientColors: const <Color>[Color(0xFF1E3A5F), Color(0xFF152B45)],
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
                if (canCreate)
                  AppSmallButton(
                    label: '+ Create',
                    background: Colors.white.withValues(alpha: .15),
                    foreground: Colors.white,
                    onTap: onCreate,
                  ),
              ],
            ),
          ),
          if (showSummary) ...<Widget>[
            Row(
              children: stats
                  .map(
                    (({String label, String value}) s) => Expanded(
                      child: _HeaderStatTile(
                        label: s.label,
                        value: s.value,
                        margin: EdgeInsets.only(
                          right: s.label == stats.last.label ? 0 : 8,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
            _PnlWalletButton(
              value: '${pnlTotal >= 0 ? '+' : '-'}${fmtSh(pnlTotal)}',
              onTap: onWalletTap,
            ),
          ],
        ],
      ),
    );
  }
}

class _PnlWalletButton extends StatelessWidget {
  const _PnlWalletButton({required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(12);

    return Material(
      color: Colors.white.withValues(alpha: .12),
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Investment P&L Summary',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Colors.white.withValues(alpha: .7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderStatTile extends StatelessWidget {
  const _HeaderStatTile({
    required this.label,
    required this.value,
    required this.margin,
  });

  final String label;
  final String value;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(12);

    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 30,
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: .68),
                ),
              ),
            ),
          ),
          Material(
            color: Colors.white.withValues(alpha: .12),
            borderRadius: borderRadius,
            child: Container(
              height: 72,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatHeaderMoney(String value, {bool absolute = false}) {
  final num parsed = num.tryParse(value) ?? 0;
  final num amount = absolute ? parsed.abs() : parsed;
  final String sign = amount < 0 ? '-' : '';
  final String whole = amount.abs().round().toString();
  return '$sign৳${_groupHeaderMoney(whole)}';
}

String _groupHeaderMoney(String whole) {
  if (whole.length <= 3) {
    return whole;
  }

  final String lastThree = whole.substring(whole.length - 3);
  String head = whole.substring(0, whole.length - 3);
  final List<String> groups = <String>[];

  while (head.length > 2) {
    groups.insert(0, head.substring(head.length - 2));
    head = head.substring(0, head.length - 2);
  }
  if (head.isNotEmpty) {
    groups.insert(0, head);
  }

  return '${groups.join(',')},$lastThree';
}
