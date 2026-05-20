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
    required this.totalCapital,
    required this.sort,
    required this.ascending,
    required this.onSort,
  });

  final List<StaffMemberBalance> members;
  final String totalCapital;
  final _MemberSort sort;
  final bool ascending;
  final ValueChanged<_MemberSort> onSort;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1120,
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
                  text: 'Capital',
                  field: _MemberSort.capital,
                  active: sort,
                  ascending: ascending,
                  onTap: onSort,
                  alignEnd: true,
                ),
                AppSortableHeaderCell<_MemberSort>(
                  text: 'Profit Wallet',
                  field: _MemberSort.profitWallet,
                  active: sort,
                  ascending: ascending,
                  onTap: onSort,
                  alignEnd: true,
                ),
                AppSortableHeaderCell<_MemberSort>(
                  text: 'Total',
                  field: _MemberSort.total,
                  active: sort,
                  ascending: ascending,
                  onTap: onSort,
                  alignEnd: true,
                ),
                AppSortableHeaderCell<_MemberSort>(
                  text: 'Ownership Ratio',
                  field: _MemberSort.ratio,
                  active: sort,
                  ascending: ascending,
                  onTap: onSort,
                  alignEnd: true,
                ),
              ],
            ),
            ...members.map((member) {
              final String ratio = _ownershipRatioText(
                member: member,
                totalCapital: totalCapital,
              );
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
                  AppMoneyCell(member.capitalBalance),
                  AppMoneyCell(member.profitWalletBalance),
                  AppMoneyCell(member.totalAmount),
                  AppTextCell(
                    ratio,
                    textAlign: TextAlign.end,
                    color: AppThemeColors.text(context),
                    fontWeight: FontWeight.w900,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

String _ownershipRatioText({
  required StaffMemberBalance member,
  required String totalCapital,
}) {
  final num total = num.tryParse(totalCapital) ?? 0;
  if (total <= 0) {
    return '0.00%';
  }
  final num capital = num.tryParse(member.capitalBalance) ?? 0;
  return '${((capital / total) * 100).toStringAsFixed(2)}%';
}
