import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../auth/domain/auth_session.dart';
import '../../auth/presentation/auth_scope.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  String _activeTab(UserRole role) {
    if (location.startsWith(RouteNames.members)) {
      return role.canViewMembers ? RouteNames.members : RouteNames.home;
    }

    if (<String>{
      RouteNames.profile,
      RouteNames.approvals,
      RouteNames.investments,
      RouteNames.ledger,
      RouteNames.memberLedger,
    }.contains(location)) {
      return location;
    }
    return RouteNames.home;
  }

  bool get _showBottomNav => location != RouteNames.memberDetail;

  @override
  Widget build(BuildContext context) {
    final UserRole role = AuthScope.of(context).role;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(child: child),
            if (_showBottomNav)
              _BottomNav(
                activeTab: _activeTab(role),
                tabs: _tabsForRole(role),
                onTap: (String routeName) => context.go(routeName),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec({required this.id, required this.icon, required this.label});

  final String id;
  final String icon;
  final String label;
}

List<_TabSpec> _tabsForRole(UserRole role) {
  return <_TabSpec>[
    const _TabSpec(id: RouteNames.home, icon: '🏠', label: 'Home'),
    if (role == UserRole.member)
      const _TabSpec(id: RouteNames.profile, icon: '👤', label: 'Profile'),
    if (role.canViewApprovals)
      const _TabSpec(id: RouteNames.approvals, icon: '📋', label: 'Approvals'),
    const _TabSpec(id: RouteNames.investments, icon: '📊', label: 'Invest'),
    if (role.canViewMembers)
      const _TabSpec(id: RouteNames.members, icon: '👥', label: 'Members'),
    if (role == UserRole.member)
      const _TabSpec(id: RouteNames.memberLedger, icon: '📖', label: 'Ledger'),
    if (role.canViewAllLedger)
      const _TabSpec(id: RouteNames.ledger, icon: '📖', label: 'Ledger'),
  ];
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.activeTab,
    required this.tabs,
    required this.onTap,
  });

  final String activeTab;
  final List<_TabSpec> tabs;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: tabs.map((_TabSpec tab) {
          final bool active = activeTab == tab.id;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onTap(tab.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AnimatedScale(
                      scale: active ? 1.1 : 1,
                      duration: const Duration(milliseconds: 180),
                      child: Text(
                        tab.icon,
                        style: const TextStyle(fontSize: 18, height: 1),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tab.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: active ? AppColors.primary : AppColors.textMute,
                        letterSpacing: 0.2,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: active ? 4 : 0,
                      height: active ? 4 : 0,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
