part of '../member_report_page.dart';

class _PendingRequestsPanel extends StatelessWidget {
  const _PendingRequestsPanel({required this.statement});

  final MemberReportStatement statement;

  @override
  Widget build(BuildContext context) {
    if (statement.pendingRequests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: _panelDecoration(context),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Pending Requests '
                    '${formatMoneySigned(num.tryParse(statement.pendingTotal) ?? 0)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppThemeColors.text(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...statement.pendingRequests.map((
            MemberReportPendingRequest request,
          ) {
            return _PendingRequestTile(request: request);
          }),
        ],
      ),
    );
  }
}

class _PendingRequestTile extends StatelessWidget {
  const _PendingRequestTile({required this.request});

  final MemberReportPendingRequest request;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '${request.requestType} via ${request.paymentChannel}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppThemeColors.text(context),
              ),
            ),
          ),
          Text(
            formatMoneySigned(num.tryParse(request.amount) ?? 0),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.amber,
            ),
          ),
        ],
      ),
    );
  }
}
