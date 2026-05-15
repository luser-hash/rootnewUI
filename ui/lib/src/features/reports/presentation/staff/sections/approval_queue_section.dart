part of '../staff_report_page.dart';

class _ApprovalQueueTable extends StatelessWidget {
  const _ApprovalQueueTable({required this.items});

  final List<StaffApprovalQueueItem> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1040,
        child: Column(
          children: <Widget>[
            const AppTableHeader(
              cells: <Widget>[
                AppHeaderCell('Member'),
                AppHeaderCell('Contact'),
                AppHeaderCell('Type'),
                AppHeaderCell('Amount'),
                AppHeaderCell('Txn Date'),
                AppHeaderCell('Channel'),
                AppHeaderCell('Reference'),
                AppHeaderCell('Notes'),
                AppHeaderCell('Files'),
                AppHeaderCell('Requested'),
              ],
            ),
            ...items.map((item) {
              final Color channelColor = _channelColor(
                context,
                item.paymentChannel,
              );
              final bool missingReference =
                  item.paymentChannel.toUpperCase() == 'BKASH' &&
                  item.externalReference.trim().isEmpty;
              return AppTableRow(
                cells: <Widget>[
                  AppTextCell(item.memberName),
                  AppTextCell(item.memberContact),
                  AppTextCell(prettyEnumLabel(item.requestType)),
                  AppMoneyCell(item.amount),
                  AppTextCell(item.txnDate),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppStatusPill(
                      label: prettyEnumLabel(item.paymentChannel),
                      color: channelColor,
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
                  AppTextCell(
                    valueOrDash(item.externalReference),
                    color: missingReference
                        ? AppColors.red
                        : AppThemeColors.text(context),
                    mono: true,
                  ),
                  AppTextCell(valueOrDash(item.notes), maxLines: 1),
                  AppTextCell('clip ${item.attachmentCount}'),
                  AppTextCell(formatDateTimeShort(item.requestedAt)),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
