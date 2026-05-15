part of '../landing_page.dart';

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    this.screen,
    this.badge = 0,
  });

  final String icon;
  final String label;
  final Color color;
  final String? screen;
  final int badge;
}
