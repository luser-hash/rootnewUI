part of '../staff_report_page.dart';

class _SectionTabs extends StatelessWidget {
  const _SectionTabs({required this.active, required this.onChanged});

  final _StaffReportSection active;
  final ValueChanged<_StaffReportSection> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _StaffReportSection.values.map((section) {
          final bool selected = active == section;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: selected,
              label: Text(section.label),
              avatar: Icon(section.icon, size: 16),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.white,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : AppColors.textMid,
              ),
              side: const BorderSide(color: AppColors.border),
              onSelected: (_) => onChanged(section),
            ),
          );
        }).toList(),
      ),
    );
  }
}
