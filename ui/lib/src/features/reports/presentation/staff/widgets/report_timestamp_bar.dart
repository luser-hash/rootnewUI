part of '../staff_report_page.dart';

class _TimestampBar extends StatelessWidget {
  const _TimestampBar({required this.label, required this.onRefresh});

  final String label;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppThemeColors.textMuted(context),
            ),
          ),
        ),
        IconButton.filledTonal(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          tooltip: 'Refresh',
        ),
      ],
    );
  }
}
