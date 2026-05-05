import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../src/features/auth/presentation/auth_controller.dart';
import '../../src/features/auth/presentation/login_page.dart';
import '../../src/features/approvals/presentation/approval_page.dart';
import '../../src/features/auth/domain/auth_session.dart';
import '../../src/features/investments/presentation/investment_page.dart';
import '../../src/features/landing/presentation/landing_page.dart';
import '../../src/features/ledger/presentation/ledger_page.dart';
import '../../src/features/members/presentation/members_page.dart';
import '../../src/features/profile/presentation/profile_page.dart';
import '../../src/features/shared/finance.dart';
import '../../src/features/shared/widgets/app_shell.dart';
import 'route_names.dart';

/// Centralized route configuration for the entire application.
///
/// Routes are wrapped in [AppShell] to share bottom navigation.
/// Nested routes are used for deeper list/detail style screens.
class AppRouter {
  AppRouter._();

  static GoRouter router(AuthController authController) {
    return GoRouter(
      initialLocation: RouteNames.login,
      refreshListenable: authController,
      redirect: (BuildContext context, GoRouterState state) {
        final String location = state.uri.path;
        final bool isLogin = location == RouteNames.login;

        return switch (authController.status) {
          AuthStatus.unknown => null,
          AuthStatus.authenticating => null,
          AuthStatus.unauthenticated => isLogin ? null : RouteNames.login,
          AuthStatus.authenticated =>
            isLogin
                ? RouteNames.home
                : _authorizedLocation(location, authController.role),
        };
      },
      routes: <RouteBase>[
        GoRoute(
          path: RouteNames.login,
          builder: (BuildContext context, GoRouterState state) {
            return const LoginPage();
          },
        ),
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return AppShell(location: state.uri.path, child: child);
          },
          routes: <RouteBase>[
            GoRoute(
              path: RouteNames.home,
              builder: (BuildContext context, GoRouterState state) {
                return _scroll(
                  HomeScreen(
                    onNav: context.go,
                    onMemberSelect: (Member member, int memberColorIdx) {
                      context.push(
                        RouteNames.memberDetail,
                        extra: MemberDetailRouteArgs(
                          member: member,
                          memberColorIdx: memberColorIdx,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            GoRoute(
              path: RouteNames.profile,
              builder: (BuildContext context, GoRouterState state) {
                return _scroll(const ProfilePage());
              },
            ),
            GoRoute(
              path: RouteNames.approvals,
              builder: (BuildContext context, GoRouterState state) {
                return _scroll(const ApprovalPage());
              },
            ),
            GoRoute(
              path: RouteNames.investments,
              builder: (BuildContext context, GoRouterState state) {
                return _scroll(const InvestmentPage());
              },
            ),
            GoRoute(
              path: RouteNames.members,
              builder: (BuildContext context, GoRouterState state) {
                return _scroll(
                  MembersPage(
                    onSelect: (Member member, int memberColorIdx) {
                      context.push(
                        RouteNames.memberDetail,
                        extra: MemberDetailRouteArgs(
                          member: member,
                          memberColorIdx: memberColorIdx,
                        ),
                      );
                    },
                  ),
                );
              },
              routes: <RouteBase>[
                GoRoute(
                  path: RouteNames.memberDetailSegment,
                  builder: (BuildContext context, GoRouterState state) {
                    final Object? extra = state.extra;
                    final MemberDetailRouteArgs args =
                        extra is MemberDetailRouteArgs
                        ? extra
                        : MemberDetailRouteArgs(
                            member: members.first,
                            memberColorIdx: 0,
                          );

                    return _scroll(
                      MemberDetailScreen(
                        member: args.member,
                        colorIdx: args.memberColorIdx,
                        onBack: () => _closeMemberDetail(context),
                      ),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: RouteNames.ledger,
              builder: (BuildContext context, GoRouterState state) {
                return _scroll(const LedgerPage());
              },
            ),
          ],
        ),
      ],
    );
  }

  static Widget _scroll(Widget child) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: child,
    );
  }

  static String? _authorizedLocation(String location, UserRole role) {
    if (location == RouteNames.approvals && !role.canViewApprovals) {
      return RouteNames.home;
    }
    if (location.startsWith(RouteNames.members) && !role.canViewMembers) {
      return RouteNames.home;
    }
    if (location == RouteNames.profile && !role.canViewOwnProfile) {
      return RouteNames.home;
    }

    return null;
  }

  static void _closeMemberDetail(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(RouteNames.members);
  }
}

class MemberDetailRouteArgs {
  const MemberDetailRouteArgs({
    required this.member,
    required this.memberColorIdx,
  });

  final Member member;
  final int memberColorIdx;
}
