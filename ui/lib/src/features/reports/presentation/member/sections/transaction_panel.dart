part of '../member_report_page.dart';

class _TransactionPanel extends StatelessWidget {
  const _TransactionPanel({
    required this.statement,
    required this.entryType,
    required this.fromDate,
    required this.toDate,
    required this.onEntryTypeChanged,
    required this.onFromDateTap,
    required this.onToDateTap,
    required this.onClear,
    required this.onDownloadCsv,
  });

  final MemberReportStatement statement;
  final MemberReportEntryType? entryType;
  final DateTime? fromDate;
  final DateTime? toDate;
  final ValueChanged<MemberReportEntryType?> onEntryTypeChanged;
  final VoidCallback onFromDateTap;
  final VoidCallback onToDateTap;
  final VoidCallback? onClear;
  final VoidCallback onDownloadCsv;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(context),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Transactions (${statement.entryCount})',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppThemeColors.text(context),
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: onDownloadCsv,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text(
                    'Download CSV',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
            child: Column(
              children: <Widget>[
                DropdownButtonFormField<MemberReportEntryType?>(
                  initialValue: entryType,
                  decoration: _fieldDecoration(
                    context: context,
                    label: 'Entry Type',
                    icon: Icons.tune_rounded,
                  ),
                  items: <DropdownMenuItem<MemberReportEntryType?>>[
                    const DropdownMenuItem<MemberReportEntryType?>(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ...MemberReportEntryType.values.map(
                      (MemberReportEntryType type) =>
                          DropdownMenuItem<MemberReportEntryType?>(
                            value: type,
                            child: Text(type.label),
                          ),
                    ),
                  ],
                  onChanged: onEntryTypeChanged,
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _DateFilterButton(
                        label: 'From',
                        value: fromDate,
                        onTap: onFromDateTap,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DateFilterButton(
                        label: 'To',
                        value: toDate,
                        onTap: onToDateTap,
                      ),
                    ),
                    if (onClear != null) ...<Widget>[
                      const SizedBox(width: 8),
                      _ClearFiltersButton(onTap: onClear!),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const _TransactionTableHeader(),
          if (statement.entries.isEmpty)
            const AppMessageCard(
              message: 'No transactions match the filters.',
              tone: AppMessageTone.neutral,
              background: Colors.transparent,
              padding: EdgeInsets.all(14),
              showBorder: false,
            )
          else
            ...statement.entries.map(
              (MemberReportEntry entry) => _TransactionRow(entry: entry),
            ),
        ],
      ),
    );
  }
}

class _TransactionTableHeader extends StatelessWidget {
  const _TransactionTableHeader();

  @override
  Widget build(BuildContext context) {
    return const AppTableHeader(
      expandCells: false,
      cells: <Widget>[
        SizedBox(width: 86, child: AppHeaderCell('Date')),
        Expanded(child: AppHeaderCell('Entry')),
        SizedBox(
          width: 98,
          child: AppHeaderCell('Running Balance', textAlign: TextAlign.end),
        ),
      ],
    );
  }
}

class _TransactionSummaryCell extends StatelessWidget {
  const _TransactionSummaryCell({
    required this.comment,
    required this.fallbackLabel,
    required this.meta,
    required this.amountColor,
  });

  final String comment;
  final String fallbackLabel;
  final String meta;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppTextCell(
          comment.isEmpty ? fallbackLabel : comment,
          fontSize: 13,
          color: AppThemeColors.text(context),
        ),
        AppTextCell(
          meta,
          maxLines: 1,
          color: amountColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }
}

class _TransactionBalanceCell extends StatelessWidget {
  const _TransactionBalanceCell({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return AppMoneyCell(
      value,
      color: AppThemeColors.text(context),
      fontSize: 13,
    );
  }
}

class _TransactionDateCell extends StatelessWidget {
  const _TransactionDateCell({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return AppTextCell(
      value,
      maxLines: 1,
      color: AppThemeColors.textMuted(context),
      fontSize: 11,
      fontWeight: FontWeight.w700,
    );
  }
}

class _TransactionExpandIcon extends StatelessWidget {
  const _TransactionExpandIcon();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.expand_more_rounded,
      size: 18,
      color: AppThemeColors.textMuted(context),
    );
  }
}

class _TransactionTileTitle extends StatelessWidget {
  const _TransactionTileTitle({required this.entry});

  final MemberReportEntry entry;

  @override
  Widget build(BuildContext context) {
    final num amount = num.tryParse(entry.amount) ?? 0;
    return Row(
      children: <Widget>[
        SizedBox(width: 86, child: _TransactionDateCell(value: entry.txnDate)),
        const _TransactionExpandIcon(),
        const SizedBox(width: 4),
        Expanded(
          child: _TransactionSummaryCell(
            comment: entry.comment,
            fallbackLabel: entry.entryType.label,
            meta: '${entry.entryType.label} ${_signedMoney(amount)}',
            amountColor: amount >= 0 ? AppColors.green : AppColors.red,
          ),
        ),
        SizedBox(
          width: 98,
          child: _TransactionBalanceCell(value: entry.runningBalance),
        ),
      ],
    );
  }
}

class _TransactionReferenceCell extends StatelessWidget {
  const _TransactionReferenceCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final String text = value.trim().isEmpty ? '-' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: AppTextCell(
        '$label: $text',
        maxLines: 2,
        color: AppThemeColors.textMid(context),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.entry});

  final MemberReportEntry entry;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _referenceText(entry),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          trailing: const SizedBox.shrink(),
          title: _TransactionTileTitle(entry: entry),
          children: <Widget>[_ReferenceBlock(entry: entry)],
        ),
      ),
    );
  }
}

class _ReferenceBlock extends StatelessWidget {
  const _ReferenceBlock({required this.entry});

  final MemberReportEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _TransactionReferenceCell(label: 'Ledger ID', value: entry.ledgerId),
          _TransactionReferenceCell(
            label: 'Reference',
            value: _referenceText(entry),
          ),
          _TransactionReferenceCell(
            label: 'Created By',
            value: entry.createdByFullName,
          ),
          _TransactionReferenceCell(
            label: 'Created At',
            value: formatDateTimeShort(entry.createdAt),
          ),
        ],
      ),
    );
  }
}
