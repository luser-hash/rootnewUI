part of '../staff_report_page.dart';

class _InvestmentTable extends StatelessWidget {
  const _InvestmentTable({required this.items});

  final List<StaffInvestmentRegisterItem> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1160,
        child: Column(
          children: <Widget>[
            const AppTableHeader(
              cells: <Widget>[
                AppHeaderCell('Title'),
                AppHeaderCell('Type'),
                AppHeaderCell('Invested To'),
                AppHeaderCell('Invested'),
                AppHeaderCell('Return'),
                AppHeaderCell('P&L'),
                AppHeaderCell('Status'),
                AppHeaderCell('Members'),
                AppHeaderCell('Created/Fund'),
                AppHeaderCell('Date'),
              ],
            ),
            ...items.map((item) {
              final num pnl = num.tryParse(item.pnlAmount) ?? 0;
              return AppTableRow(
                onTap: () => context.go(RouteNames.investments),
                cells: <Widget>[
                  AppTextCell(item.title),
                  AppTextCell(prettyEnumLabel(item.investmentType)),
                  AppTextCell(item.investedTo),
                  AppMoneyCell(item.investedAmount),
                  AppMoneyCell(item.returnAmount),
                  AppMoneyCell(
                    item.pnlAmount,
                    color: pnl > 0
                        ? AppColors.green
                        : pnl < 0
                        ? AppColors.red
                        : AppColors.text,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppStatusPill(
                      label: prettyEnumLabel(item.status),
                      color: _investmentStatusColor(item.status),
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
                  AppTextCell('${item.memberCount}'),
                  AppTextCell(
                    '${valueOrDash(item.createdBy)}\nFund: ${valueOrDash(item.fundReleasedBy)}',
                  ),
                  AppTextCell(
                    item.closeDate.trim().isEmpty
                        ? item.createdDate
                        : '${item.createdDate}\nClose: ${item.closeDate}',
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
