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

List<_QuickAction> _quickActionsFor({
  required int pendingCount,
  required UserRole role,
}) {
  return <_QuickAction>[
    if (role.canSubmitFunds)
      const _QuickAction(
        icon: '📥',
        label: 'Submit Funds',
        color: Color(0xFFE8F5F3),
        screen: RouteNames.submitFunds,
      ),
    if (role.canViewOwnProfile && role == UserRole.member)
      const _QuickAction(
        icon: '👤',
        label: 'Profile',
        color: AppColors.surface,
        screen: RouteNames.profile,
      ),
    if (role.canViewOwnSubmissions)
      const _QuickAction(
        icon: '🧾',
        label: 'Submissions',
        color: AppColors.amberLt,
        screen: RouteNames.submissions,
      ),
    if (role.canViewApprovals)
      _QuickAction(
        icon: '📋',
        label: 'Approvals',
        color: AppColors.amberLt,
        screen: RouteNames.approvals,
        badge: pendingCount,
      ),
    const _QuickAction(
      icon: '📊',
      label: 'Investments',
      color: AppColors.blueLt,
      screen: RouteNames.investments,
    ),
    if (role.canViewMembers)
      const _QuickAction(
        icon: '👥',
        label: 'Members',
        color: AppColors.purpleLt,
        screen: RouteNames.members,
      ),
    _QuickAction(
      icon: '📖',
      label: 'Ledger',
      color: AppColors.greenLt,
      screen: role == UserRole.member
          ? RouteNames.memberLedger
          : RouteNames.ledger,
    ),
    if (role.canDistribute)
      const _QuickAction(
        icon: '📤',
        label: 'Distribute',
        color: Color(0xFFFEF0F0),
      ),
    if (role.canViewOwnReports)
      const _QuickAction(
        icon: '📈',
        label: 'Reports',
        color: Color(0xFFFFF8ED),
        screen: RouteNames.memberReport,
      ),
    if (role.canViewAllReports)
      const _QuickAction(
        icon: '📈',
        label: 'Reports',
        color: Color(0xFFFFF8ED),
        screen: RouteNames.staffReport,
      ),
    if (role.canManagePermissions)
      const _QuickAction(
        icon: '⚙️',
        label: 'Permissions',
        color: AppColors.surface,
      ),
  ];
}
