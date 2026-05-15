part of 'admin_ledger_page.dart';

class _LedgerHeaderContent extends StatelessWidget {
  const _LedgerHeaderContent({
    required this.statement,
    required this.isPosting,
    required this.onAdd,
  });

  final AdminLedgerStatement? statement;
  final bool isPosting;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final List<({String label, String value})> stats =
        <({String label, String value})>[
          (label: 'Total In', value: _formatCompactMoney(statement?.totalIn)),
          (label: 'Total Out', value: _formatCompactMoney(statement?.totalOut)),
          (label: 'Entries', value: '${statement?.entryCount ?? 0}'),
        ];

    return AppScreenHeader(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      gradientColors: const <Color>[Color(0xFF003D35), AppColors.primaryDk],
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Capital Ledger',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Tooltip(
                  message: 'Post ledger entry',
                  child: Material(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(13),
                    child: InkWell(
                      onTap: isPosting ? null : onAdd,
                      borderRadius: BorderRadius.circular(13),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          isPosting ? Icons.hourglass_empty_rounded : Icons.add,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: stats.map((({String label, String value}) s) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: s.label == stats.last.label ? 0 : 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        s.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
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
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
