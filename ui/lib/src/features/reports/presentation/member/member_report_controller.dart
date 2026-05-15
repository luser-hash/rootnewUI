part of 'member_report_page.dart';

class _DateFilterButton extends StatelessWidget {
  const _DateFilterButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppThemeColors.elevatedSurface(context),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppThemeColors.border(context)),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppThemeColors.textMuted(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppThemeColors.textMuted(context),
                      ),
                    ),
                    Text(
                      value == null ? 'Any date' : _formatDate(value!),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppThemeColors.text(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClearFiltersButton extends StatelessWidget {
  const _ClearFiltersButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppThemeColors.elevatedSurface(context),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 46,
          height: 54,
          child: Icon(
            Icons.close_rounded,
            color: AppThemeColors.textMuted(context),
          ),
        ),
      ),
    );
  }
}

class _MemberReportData {
  const _MemberReportData({
    required this.statement,
    required this.distributions,
  });

  final MemberReportStatement statement;
  final MemberDistributionsReport distributions;
}

InputDecoration _fieldDecoration({
  required BuildContext context,
  required String label,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 18),
    filled: true,
    fillColor: AppThemeColors.elevatedSurface(context),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: AppThemeColors.border(context)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: AppThemeColors.border(context)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 1.3,
      ),
    ),
  );
}

BoxDecoration _panelDecoration(BuildContext context) {
  return BoxDecoration(
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
  );
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

String _formatDate(DateTime value) {
  final String month = value.month.toString().padLeft(2, '0');
  final String day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

String _signedMoney(num value) {
  return '${value >= 0 ? '+' : ''}${formatMoneySigned(value)}';
}

String _referenceText(MemberReportEntry entry) {
  final String type = entry.referenceType.trim();
  final String id = entry.referenceId.trim();
  if (type.isEmpty && id.isEmpty) {
    return '-';
  }
  if (type.isEmpty) {
    return id;
  }
  if (id.isEmpty) {
    return type;
  }
  return '$type · $id';
}

String _statementCsv(MemberReportStatement statement) {
  final List<String> rows = <String>[
    <String>[
      'ledger_id',
      'entry_type',
      'amount',
      'currency',
      'txn_date',
      'running_balance',
      'reference_type',
      'reference_id',
      'comment',
      'created_at',
      'created_by',
    ].join(','),
    ...statement.entries.map((MemberReportEntry entry) {
      return <String>[
        entry.ledgerId,
        entry.entryType.apiValue,
        entry.amount,
        entry.currency,
        entry.txnDate,
        entry.runningBalance,
        entry.referenceType,
        entry.referenceId,
        entry.comment,
        entry.createdAt?.toIso8601String() ?? '',
        entry.createdByFullName,
      ].map(_csvCell).join(',');
    }),
  ];
  return rows.join('\n');
}

String _csvCell(String value) {
  final String escaped = value.replaceAll('"', '""');
  return '"$escaped"';
}
