part of '../approval_page.dart';

class _PaymentChannelFilter extends StatelessWidget {
  const _PaymentChannelFilter({
    required this.selected,
    required this.onSelected,
  });

  final PaymentChannel? selected;
  final ValueChanged<PaymentChannel?> onSelected;

  @override
  Widget build(BuildContext context) {
    final List<({String label, PaymentChannel? channel})> filters =
        <({String label, PaymentChannel? channel})>[
          (label: 'All', channel: null),
          for (final PaymentChannel channel in PaymentChannel.values)
            (label: channel.label, channel: channel),
        ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final ({String label, PaymentChannel? channel}) filter =
              filters[index];
          final bool active = selected == filter.channel;
          return ChoiceChip(
            selected: active,
            label: Text(filter.label),
            selectedColor: AppColors.primary,
            backgroundColor: AppThemeColors.card(context),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : AppThemeColors.textMid(context),
            ),
            side: BorderSide(color: AppThemeColors.border(context)),
            onSelected: (_) => onSelected(filter.channel),
          );
        },
      ),
    );
  }
}
