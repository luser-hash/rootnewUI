part of 'admin_ledger_page.dart';

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.entry, required this.isLast});

  final MemberLedgerEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final double amount = double.tryParse(entry.amount) ?? 0;
    final bool positive = _isInflow(entry.entryType, amount);
    final Color bg = _entryBackground(context, entry.entryType);
    final Color fg = _entryForeground(context, entry.entryType);

    return AppTableRow(
      onTap: () => _showLedgerDetails(context, entry),
      expandCells: false,
      showTopBorder: false,
      showBottomBorder: !isLast,
      background: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      cells: <Widget>[
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(_entryIcon(entry.entryType), size: 18, color: fg),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppTextCell(
                entry.memberName.isEmpty
                    ? entry.entryType.label
                    : entry.memberName,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(height: 2),
              AppTextCell(
                entry.memberContact.isEmpty
                    ? '${entry.referenceType} · ${entry.referenceId}'
                    : entry.memberContact,
                maxLines: 1,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppThemeColors.textMuted(context),
              ),
              AppTextCell(
                entry.comment.isEmpty
                    ? '${entry.entryType.label} · ${entry.ledgerId}'
                    : entry.comment,
                maxLines: 1,
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: AppThemeColors.textMuted(context),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            AppTextCell(
              '${positive ? '+' : '-'}${formatMoneyTextUnsigned(entry.amount)}',
              color: positive
                  ? AppThemeColors.statusSuccessFg(context)
                  : AppThemeColors.statusErrorFg(context),
              fontSize: 14,
            ),
            AppTextCell(
              entry.txnDate,
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppThemeColors.textMuted(context),
            ),
          ],
        ),
      ],
    );
  }

  void _showLedgerDetails(BuildContext context, MemberLedgerEntry entry) {
    final double amount = double.tryParse(entry.amount) ?? 0;
    final bool positive = _isInflow(entry.entryType, amount);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppThemeColors.card(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _entryBackground(context, entry.entryType),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _entryIcon(entry.entryType),
                        size: 18,
                        color: _entryForeground(context, entry.entryType),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            entry.memberName.isEmpty
                                ? entry.entryType.label
                                : entry.memberName,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppThemeColors.text(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            entry.memberContact.isEmpty
                                ? entry.userId
                                : entry.memberContact,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppThemeColors.textMuted(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${positive ? '+' : '-'}${formatMoneyTextUnsigned(entry.amount)}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: positive
                        ? AppThemeColors.statusSuccessFg(context)
                        : AppThemeColors.statusErrorFg(context),
                  ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.45,
                  children: <Widget>[
                    AppDetailBlock(label: 'Type', value: entry.entryType.label),
                    AppDetailBlock(label: 'Currency', value: entry.currency),
                    AppDetailBlock(label: 'Txn Date', value: entry.txnDate),
                    AppDetailBlock(
                      label: 'Created',
                      value: formatDateTimeShort(entry.createdAt),
                    ),
                    AppDetailBlock(
                      label: 'Reference Type',
                      value: entry.referenceType.isEmpty
                          ? '-'
                          : entry.referenceType,
                    ),
                    // AppDetailBlock(
                    //   label: 'Reference ID',
                    //   value: entry.referenceId.isEmpty
                    //       ? '-'
                    //       : entry.referenceId,
                    // ),
                  ],
                ),
                // const SizedBox(height: 8),
                // AppDetailBlock(
                //   label: 'Ledger ID',
                //   value: entry.ledgerId,
                //   selectable: true,
                // ),
                // if (entry.userId.isNotEmpty) ...<Widget>[
                //   const SizedBox(height: 8),
                //   AppDetailBlock(
                //     label: 'User ID',
                //     value: entry.userId,
                //     selectable: true,
                //   ),
                // ],
                if (entry.comment.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  AppDetailBlock(
                    label: 'Comment',
                    value: entry.comment,
                    selectable: true,
                  ),
                ],
                if (entry.createdByName.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  AppDetailBlock(
                    label: 'Created By',
                    value: entry.createdByName,
                    selectable: true,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

InputDecoration _fieldDecoration({
  required BuildContext context,
  required String label,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20, color: AppThemeColors.textMuted(context)),
    filled: true,
    fillColor: AppThemeColors.elevatedSurface(context),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    labelStyle: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppThemeColors.textMuted(context),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppThemeColors.border(context)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 1.5,
      ),
    ),
  );
}

Color _entryBackground(BuildContext context, MemberLedgerEntryType type) {
  return switch (type) {
    MemberLedgerEntryType.submission => AppThemeColors.statusSuccessBg(context),
    MemberLedgerEntryType.withdraw => AppThemeColors.statusErrorBg(context),
    MemberLedgerEntryType.adjustment => AppThemeColors.statusWarningBg(context),
    MemberLedgerEntryType.distribution => AppThemeColors.statusInfoBg(context),
    MemberLedgerEntryType.distributionReversal => AppThemeColors.statusErrorBg(
      context,
    ),
  };
}

Color _entryForeground(BuildContext context, MemberLedgerEntryType type) {
  return switch (type) {
    MemberLedgerEntryType.submission => AppThemeColors.statusSuccessFg(context),
    MemberLedgerEntryType.withdraw => AppThemeColors.statusErrorFg(context),
    MemberLedgerEntryType.adjustment => AppThemeColors.statusWarningFg(context),
    MemberLedgerEntryType.distribution => AppThemeColors.statusInfoFg(context),
    MemberLedgerEntryType.distributionReversal => AppThemeColors.statusErrorFg(
      context,
    ),
  };
}

IconData _entryIcon(MemberLedgerEntryType type) {
  return switch (type) {
    MemberLedgerEntryType.submission => Icons.south_rounded,
    MemberLedgerEntryType.withdraw => Icons.north_rounded,
    MemberLedgerEntryType.adjustment => Icons.tune_rounded,
    MemberLedgerEntryType.distribution => Icons.call_split_rounded,
    MemberLedgerEntryType.distributionReversal => Icons.undo_rounded,
  };
}

bool _isInflow(MemberLedgerEntryType type, double amount) {
  if (amount < 0) {
    return false;
  }
  return switch (type) {
    MemberLedgerEntryType.withdraw => false,
    MemberLedgerEntryType.distributionReversal => false,
    _ => true,
  };
}

String _formatCompactMoney(String? value) {
  final double amount = double.tryParse(value ?? '0')?.abs() ?? 0;
  return formatMoneyCompactSigned(amount);
}

String _formatDate(DateTime value) {
  final String month = value.month.toString().padLeft(2, '0');
  final String day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
