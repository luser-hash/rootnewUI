part of '../member_report_page.dart';

class _DistributionsPanel extends StatelessWidget {
  const _DistributionsPanel({required this.report});

  final MemberDistributionsReport report;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Distributions (${report.distributionCount})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                ),
                Text(
                  formatMoneySigned(num.tryParse(report.totalReceived) ?? 0),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ),
          if (report.distributions.isEmpty)
            const AppMessageCard(
              message: 'No distribution history found.',
              tone: AppMessageTone.neutral,
              background: Colors.transparent,
              padding: EdgeInsets.all(14),
              showBorder: false,
            )
          else
            ...report.distributions.map(
              (MemberDistributionReportItem item) =>
                  _DistributionTile(item: item),
            ),
        ],
      ),
    );
  }
}

class _DistributionTile extends StatelessWidget {
  const _DistributionTile({required this.item});

  final MemberDistributionReportItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.investmentTitle.isEmpty
                      ? item.investmentId
                      : item.investmentTitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  '${item.distributionStatus} · ${formatDateTimeShort(item.postedAt)}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMute,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatMoneySigned(num.tryParse(item.shareAmount) ?? 0),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}
