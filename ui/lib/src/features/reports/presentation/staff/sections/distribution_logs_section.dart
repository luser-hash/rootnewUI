part of '../staff_report_page.dart';

class _DistributionList extends StatelessWidget {
  const _DistributionList({required this.items});

  final List<StaffDistributionLogItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        final bool reversed = item.status.toUpperCase() == 'REVERSED';
        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: Container(
            decoration: BoxDecoration(
              color: reversed ? AppColors.surface : AppColors.white,
              border: const Border(top: BorderSide(color: AppColors.border)),
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 14),
              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              title: Row(
                children: <Widget>[
                  Expanded(flex: 2, child: AppTextCell(item.investmentTitle)),
                  Expanded(child: AppMoneyCell(item.pnlAmount)),
                  Expanded(child: AppMoneyCell(item.roundedTotal)),
                  Expanded(
                    child: AppMoneyCell(
                      item.remainderApplied,
                      color: (num.tryParse(item.remainderApplied) ?? 0) == 0
                          ? AppColors.text
                          : AppColors.amber,
                    ),
                  ),
                  Expanded(
                    child: AppStatusPill(
                      label: prettyEnumLabel(item.status),
                      color: reversed ? AppColors.red : AppColors.green,
                      strike: reversed,
                      showBorder: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      textHeight: null,
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                'Posted by ${valueOrDash(item.postedBy)} at ${formatDateTimeShort(item.postedAt)} - '
                'Reversed by ${valueOrDash(item.reversedBy)} at ${formatDateTimeShort(item.reversedAt)} - '
                '${item.memberCount} members',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMute,
                ),
              ),
              children: <Widget>[
                if (item.lines.isEmpty)
                  const AppMessageCard(
                    message: 'No per-member distribution lines returned.',
                    tone: AppMessageTone.neutral,
                    background: Colors.transparent,
                    padding: EdgeInsets.all(14),
                    showBorder: false,
                  )
                else
                  ...item.lines.map((line) {
                    return _DistributionLineTile(line: line);
                  }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ChipFilterBar extends StatelessWidget {
  const _ChipFilterBar({
    required this.title,
    required this.values,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final List<String> values;
  final Set<String> selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.textMute,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values.map((value) {
              final bool active = selected.contains(value);
              return FilterChip(
                selected: active,
                label: Text(prettyEnumLabel(value)),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.white,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: active ? Colors.white : AppColors.textMid,
                ),
                side: const BorderSide(color: AppColors.border),
                onSelected: (_) => onChanged(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _DropdownFilterField extends StatelessWidget {
  const _DropdownFilterField({
    required this.label,
    required this.icon,
    required this.value,
    required this.allLabel,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final String? value;
  final String allLabel;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: DropdownButtonFormField<String?>(
        initialValue: value,
        decoration: _fieldDecoration(label: label, icon: icon),
        items: <DropdownMenuItem<String?>>[
          DropdownMenuItem<String?>(value: null, child: Text(allLabel)),
          ...values.map(
            (String value) => DropdownMenuItem<String?>(
              value: value,
              child: Text(prettyEnumLabel(value)),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _DistributionLineTile extends StatelessWidget {
  const _DistributionLineTile({required this.line});

  final StaffDistributionLine line;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: AppTextCell(line.fullName)),
          Expanded(child: AppTextCell('Ratio ${valueOrDash(line.ratioUsed)}')),
          Expanded(child: AppMoneyCell(line.shareAmount)),
          Expanded(
            child: AppTextCell('Ledger ${valueOrDash(line.ledgerEntryId)}'),
          ),
        ],
      ),
    );
  }
}
