part of '../staff_report_page.dart';

class _MemberFilters extends StatelessWidget {
  const _MemberFilters({
    required this.status,
    required this.searchController,
    required this.onStatusChanged,
    required this.onSearch,
  });

  final _MemberStatusFilter status;
  final TextEditingController searchController;
  final ValueChanged<_MemberStatusFilter> onStatusChanged;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _MemberStatusFilter.values.map((value) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    selected: status == value,
                    label: Text(value.label),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppThemeColors.elevatedSurface(context),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: status == value
                          ? Colors.white
                          : AppThemeColors.textMid(context),
                    ),
                    side: BorderSide(color: AppThemeColors.border(context)),
                    onSelected: (_) => onStatusChanged(value),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearch(),
            decoration:
                _fieldDecoration(
                  context: context,
                  label: 'Search member',
                  icon: Icons.search_rounded,
                ).copyWith(
                  suffixIcon: IconButton(
                    onPressed: onSearch,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    tooltip: 'Search',
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _MemberTable extends StatelessWidget {
  const _MemberTable({
    required this.members,
    required this.sort,
    required this.ascending,
    required this.onSort,
  });

  final List<StaffMemberBalance> members;
  final _MemberSort sort;
  final bool ascending;
  final ValueChanged<_MemberSort> onSort;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 760,
        child: Column(
          children: <Widget>[
            AppTableHeader(
              cells: <Widget>[
                AppSortableHeaderCell<_MemberSort>(
                  text: 'Full Name',
                  field: _MemberSort.name,
                  active: sort,
                  ascending: ascending,
                  onTap: onSort,
                ),
                AppSortableHeaderCell<_MemberSort>(
                  text: 'Contact',
                  field: _MemberSort.contact,
                  active: sort,
                  ascending: ascending,
                  onTap: onSort,
                ),
                AppSortableHeaderCell<_MemberSort>(
                  text: 'Join Date',
                  field: _MemberSort.joinDate,
                  active: sort,
                  ascending: ascending,
                  onTap: onSort,
                ),
                AppSortableHeaderCell<_MemberSort>(
                  text: 'Status',
                  field: _MemberSort.status,
                  active: sort,
                  ascending: ascending,
                  onTap: onSort,
                ),
                AppSortableHeaderCell<_MemberSort>(
                  text: 'Balance',
                  field: _MemberSort.balance,
                  active: sort,
                  ascending: ascending,
                  onTap: onSort,
                  alignEnd: true,
                ),
              ],
            ),
            ...members.map((member) {
              return AppTableRow(
                onTap: () => context.go(RouteNames.ledger),
                cells: <Widget>[
                  AppTextCell(member.fullName),
                  AppTextCell(member.contactNo),
                  AppTextCell(member.joinDate),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppStatusPill(
                      label: valueOrDash(member.status),
                      color: member.status.toUpperCase() == 'ACTIVE'
                          ? AppColors.green
                          : AppThemeColors.textMuted(context),
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
                  AppMoneyCell(member.balance),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
