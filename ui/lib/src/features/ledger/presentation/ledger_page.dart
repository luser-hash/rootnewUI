import 'package:flutter/material.dart';

import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_theme.dart';
import '../../shared/finance.dart';
import '../../shared/widgets/app_card_list.dart';

class LedgerPage extends StatelessWidget {
  const LedgerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SubmissionsBuilder(builder: _buildWithSubmissions);
  }

  Widget _buildWithSubmissions(List<Submission> submissions) {
    final List<_LedgerEntry> entries = <_LedgerEntry>[
      ...submissions
          .where((Submission s) => s.status == SubmissionStatus.approved)
          .map(
            (Submission s) => _LedgerEntry(
              id: s.id,
              member: s.member,
              amount: s.amount,
              date: s.date,
              dir: LedgerDir.sub,
              ref: s.ref.isEmpty ? s.channel : s.ref,
            ),
          ),
      ...txns
          .where((TransactionItem t) => t.type == TxnType.distribution)
          .map(
            (TransactionItem t) => _LedgerEntry(
              id: '${t.id}',
              member: t.label,
              amount: t.amount,
              date: t.date,
              dir: LedgerDir.dist,
              ref: t.sub,
            ),
          ),
      const _LedgerEntry(
        id: 'WD01',
        member: 'Tania Akter',
        amount: -5000,
        date: 'Mar 2026',
        dir: LedgerDir.withdrawal,
        ref: 'Withdrawal',
      ),
    ];
    final int totalIn = entries
        .where((_LedgerEntry e) => e.amount > 0)
        .fold(0, (int sum, _LedgerEntry e) => sum + e.amount);
    final int totalOut = entries
        .where((_LedgerEntry e) => e.amount < 0)
        .fold(0, (int sum, _LedgerEntry e) => sum + e.amount.abs());

    return Column(
      children: <Widget>[
        _LedgerHeader(
          totalIn: totalIn,
          totalOut: totalOut,
          entries: entries.length,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
          child: AppCardList(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            children: entries
                .asMap()
                .entries
                .map(
                  (MapEntry<int, _LedgerEntry> entry) => _LedgerRow(
                    entry: entry.value,
                    isLast: entry.key == entries.length - 1,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

enum LedgerDir { sub, dist, withdrawal }

class _LedgerEntry {
  const _LedgerEntry({
    required this.id,
    required this.member,
    required this.amount,
    required this.date,
    required this.dir,
    required this.ref,
  });

  final String id;
  final String member;
  final int amount;
  final String date;
  final LedgerDir dir;
  final String ref;
}

class _LedgerHeader extends StatelessWidget {
  const _LedgerHeader({
    required this.totalIn,
    required this.totalOut,
    required this.entries,
  });

  final int totalIn;
  final int totalOut;
  final int entries;

  @override
  Widget build(BuildContext context) {
    final List<({String label, String value})> stats =
        <({String label, String value})>[
          (label: 'Total In', value: fmtSh(totalIn)),
          (label: 'Total Out', value: fmtSh(totalOut)),
          (label: 'Entries', value: '$entries'),
        ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF003D35), AppColors.primaryDk],
        ),
      ),
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
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Text(
                    '+',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.entry, required this.isLast});

  final _LedgerEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final bool positive = entry.amount >= 0;
    final Color bg = switch (entry.dir) {
      LedgerDir.sub => AppColors.greenLt,
      LedgerDir.dist => AppColors.blueLt,
      LedgerDir.withdrawal => AppColors.redLt,
    };
    final String icon = switch (entry.dir) {
      LedgerDir.sub => '↓',
      LedgerDir.dist => '◈',
      LedgerDir.withdrawal => '↑',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  entry.member,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.ref} · ${entry.id}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMute,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '${positive ? '+' : ''}${fmt(entry.amount)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: positive ? AppColors.green : AppColors.red,
                ),
              ),
              Text(
                entry.date,
                style: const TextStyle(fontSize: 11, color: AppColors.textMute),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
