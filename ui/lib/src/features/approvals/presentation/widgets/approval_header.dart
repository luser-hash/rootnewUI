part of '../approval_page.dart';

class _ApprovalHeaderContent extends StatelessWidget {
  const _ApprovalHeaderContent({
    required this.reviewed,
    required this.pendingCount,
  });

  final List<SubmissionHistoryItem> reviewed;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final List<({String label, String value})>
    stats = <({String label, String value})>[
      (label: 'Pending', value: '$pendingCount'),
      (
        label: 'Approved',
        value:
            '${reviewed.where((SubmissionHistoryItem s) => s.status == CapitalSubmissionStatus.approved).length}',
      ),
      (
        label: 'Rejected',
        value:
            '${reviewed.where((SubmissionHistoryItem s) => s.status == CapitalSubmissionStatus.rejected).length}',
      ),
    ];

    return AppScreenHeader(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      gradientColors: const <Color>[AppColors.primary, AppColors.primaryDk],
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(0, 12, 0, 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Approval Queue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                AppPill(
                  label: '$pendingCount pending',
                  background: AppThemeColors.statusWarningBg(context),
                  foreground: AppThemeColors.statusWarningFg(context),
                ),
              ],
            ),
          ),
          Row(
            children: stats.map((({String label, String value}) s) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: s.label == stats.last.label ? 0 : 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        s.value,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        s.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: .65),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
