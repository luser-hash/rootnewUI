part of '../staff_report_page.dart';

class _StatCluster extends StatelessWidget {
  const _StatCluster({
    required this.title,
    required this.subtitle,
    required this.stats,
    required this.action,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final List<_TinyStat> stats;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppThemeColors.text(context),
                    ),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppThemeColors.textMuted(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: stats.map((_TinyStat stat) {
                return AppStatusPill(
                  label: '${stat.label} ${stat.value}',
                  color: stat.color,
                  showBorder: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  textHeight: null,
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(onPressed: onTap, child: Text('$action ->')),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuditBanner extends StatelessWidget {
  const _AuditBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemeColors.statusWarningBg(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppThemeColors.statusWarningFg(context).withValues(alpha: .2),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.info_outline_rounded, color: AppColors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppThemeColors.textMid(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
