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
              color: reversed
                  ? AppThemeColors.surface(context)
                  : AppThemeColors.card(context),
              border: Border(
                top: BorderSide(color: AppThemeColors.border(context)),
              ),
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
              iconColor: AppThemeColors.textMid(context),
              collapsedIconColor: AppThemeColors.textMid(context),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          valueOrDash(item.investmentTitle),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                            color: AppThemeColors.text(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppStatusPill(
                        label: prettyEnumLabel(item.status),
                        color: reversed ? AppColors.red : AppColors.green,
                        strike: reversed,
                        showBorder: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        textHeight: null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _DistributionAmountStrip(item: item),
                  const SizedBox(height: 8),
                  _DistributionMetaLine(item: item),
                ],
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

class _DistributionAmountStrip extends StatelessWidget {
  const _DistributionAmountStrip({required this.item});

  final StaffDistributionLogItem item;

  @override
  Widget build(BuildContext context) {
    final num remainder = num.tryParse(item.remainderApplied) ?? 0;
    return Row(
      children: <Widget>[
        Expanded(
          child: _DistributionAmountTile(
            label: 'P&L',
            value: item.pnlAmount,
            color: AppThemeColors.text(context),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _DistributionAmountTile(
            label: 'Rounded',
            value: item.roundedTotal,
            color: AppThemeColors.text(context),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _DistributionAmountTile(
            label: 'Remainder',
            value: item.remainderApplied,
            color: remainder == 0
                ? AppThemeColors.text(context)
                : AppThemeColors.statusWarningFg(context),
          ),
        ),
      ],
    );
  }
}

class _DistributionAmountTile extends StatelessWidget {
  const _DistributionAmountTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              height: 1,
              fontWeight: FontWeight.w900,
              color: AppThemeColors.textMuted(context),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatMoneyTextSigned(value),
              maxLines: 1,
              style: TextStyle(
                fontSize: 12,
                height: 1.05,
                fontWeight: FontWeight.w900,
                color: color,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionMetaLine extends StatelessWidget {
  const _DistributionMetaLine({required this.item});

  final StaffDistributionLogItem item;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        _DistributionMetaChip(
          icon: Icons.person_outline_rounded,
          text: valueOrDash(item.postedBy),
        ),
        _DistributionMetaChip(
          icon: Icons.schedule_rounded,
          text: formatDateTimeShort(item.postedAt),
        ),
        _DistributionMetaChip(
          icon: Icons.groups_outlined,
          text: '${item.memberCount} members',
        ),
        if (item.reversedBy.trim().isNotEmpty || item.reversedAt != null)
          _DistributionMetaChip(
            icon: Icons.undo_rounded,
            text:
                '${valueOrDash(item.reversedBy)} ${formatDateTimeShort(item.reversedAt)}',
          ),
      ],
    );
  }
}

class _DistributionMetaChip extends StatelessWidget {
  const _DistributionMetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 13, color: AppThemeColors.textMuted(context)),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 190),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.textMuted(context),
            ),
          ),
        ),
      ],
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
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppThemeColors.textMuted(context),
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
                backgroundColor: AppThemeColors.elevatedSurface(context),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: active ? Colors.white : AppThemeColors.textMid(context),
                ),
                side: BorderSide(color: AppThemeColors.border(context)),
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
        decoration: _fieldDecoration(context: context, label: label, icon: icon),
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
        color: AppThemeColors.surface(context),
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
