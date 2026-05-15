part of '../landing_page.dart';

enum _QuickActionTone { success, neutral, warning, info, purple, error }

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.tone,
    this.screen,
    this.badge = 0,
    this.lightBackground,
  });

  final String icon;
  final String label;
  final _QuickActionTone tone;
  final String? screen;
  final int badge;
  final Color? lightBackground;

  Color background(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light &&
        lightBackground != null) {
      return lightBackground!;
    }

    return switch (tone) {
      _QuickActionTone.success => AppThemeColors.statusSuccessBg(context),
      _QuickActionTone.neutral => AppThemeColors.surface(context),
      _QuickActionTone.warning => AppThemeColors.statusWarningBg(context),
      _QuickActionTone.info => AppThemeColors.statusInfoBg(context),
      _QuickActionTone.purple => AppThemeColors.statusPurpleBg(context),
      _QuickActionTone.error => AppThemeColors.statusErrorBg(context),
    };
  }
}

List<_QuickAction> _quickActionsFor({
  required int pendingCount,
  required UserRole role,
}) {
  return <_QuickAction>[
    if (role.canSubmitFunds)
      const _QuickAction(
        icon: '📥',
        label: 'Submit Funds',
        tone: _QuickActionTone.success,
        lightBackground: Color(0xFFE8F5F3),
        screen: RouteNames.submitFunds,
      ),
    if (role.canViewOwnProfile && role == UserRole.member)
      const _QuickAction(
        icon: '👤',
        label: 'Profile',
        tone: _QuickActionTone.neutral,
        screen: RouteNames.profile,
      ),
    if (role.canViewOwnSubmissions)
      const _QuickAction(
        icon: '🧾',
        label: 'Submissions',
        tone: _QuickActionTone.warning,
        screen: RouteNames.submissions,
      ),
    if (role.canViewApprovals)
      _QuickAction(
        icon: '📋',
        label: 'Approvals',
        tone: _QuickActionTone.warning,
        screen: RouteNames.approvals,
        badge: pendingCount,
      ),
    const _QuickAction(
      icon: '📊',
      label: 'Investments',
      tone: _QuickActionTone.info,
      screen: RouteNames.investments,
    ),
    if (role.canViewMembers)
      const _QuickAction(
        icon: '👥',
        label: 'Members',
        tone: _QuickActionTone.purple,
        screen: RouteNames.members,
      ),
    _QuickAction(
      icon: '📖',
      label: 'Ledger',
      tone: _QuickActionTone.success,
      screen: role == UserRole.member
          ? RouteNames.memberLedger
          : RouteNames.ledger,
    ),
    if (role.canDistribute)
      const _QuickAction(
        icon: '📤',
        label: 'Distribute',
        tone: _QuickActionTone.error,
        lightBackground: Color(0xFFFEF0F0),
      ),
    if (role.canViewOwnReports)
      const _QuickAction(
        icon: '📈',
        label: 'Reports',
        tone: _QuickActionTone.warning,
        lightBackground: Color(0xFFFFF8ED),
        screen: RouteNames.memberReport,
      ),
    if (role.canViewAllReports)
      const _QuickAction(
        icon: '📈',
        label: 'Reports',
        tone: _QuickActionTone.warning,
        lightBackground: Color(0xFFFFF8ED),
        screen: RouteNames.staffReport,
      ),
    if (role.canManagePermissions)
      const _QuickAction(
        icon: '⚙️',
        label: 'Permissions',
        tone: _QuickActionTone.neutral,
      ),
  ];
}
