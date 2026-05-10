import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../src/features/auth/presentation/auth_controller.dart';
import '../../src/features/auth/presentation/login_page.dart';
import '../../src/features/approvals/presentation/approval_page.dart';
import '../../src/features/auth/domain/auth_session.dart';
import '../../src/features/investments/data/investment_repository.dart';
import '../../src/features/investments/presentation/investment_create_page.dart';
import '../../src/features/investments/presentation/investment_page.dart';
import '../../src/features/landing/presentation/landing_page.dart';
import '../../src/features/ledger/presentation/ledger_page.dart';
import '../../src/features/ledger/data/member_ledger_repository.dart';
import '../../src/features/ledger/presentation/member_ledger.dart';
import '../../src/features/members/data/member_management_repository.dart';
import '../../src/features/members/domain/member_management_models.dart';
import '../../src/features/members/presentation/edit_member.dart';
import '../../src/features/members/presentation/manage_members.dart';
import '../../src/features/members/presentation/member_detail_screen.dart';
import '../../src/features/members/presentation/members_page.dart';
import '../../src/features/profile/presentation/profile_page.dart';
import '../../src/features/shared/finance.dart';
import '../../src/features/shared/widgets/app_shell.dart';
import '../../src/features/submissions/data/capital_submission_repository.dart';
import '../../src/features/submissions/presentation/submission_detail_page.dart';
import '../../src/features/submissions/presentation/submissions_page.dart';
import '../../src/features/submissions/presentation/submit_funds_page.dart';
import 'route_names.dart';

/// Centralized route configuration for the entire application.
///
/// Routes are wrapped in [AppShell] to share bottom navigation.
/// Nested routes are used for deeper list/detail style screens.
class AppRouter {
  AppRouter._();

  static GoRouter router({
    required AuthController authController,
    required CapitalSubmissionRepository capitalSubmissionRepository,
    required InvestmentRepository investmentRepository,
    required MemberLedgerRepository memberLedgerRepository,
    required MemberManagementRepository memberManagementRepository,
  }) {
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
                    memberRepository: memberManagementRepository,
                    memberLedgerRepository: memberLedgerRepository,
                    capitalSubmissionRepository: capitalSubmissionRepository,
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
                return _scroll(
                  ProfilePage(ledgerRepository: memberLedgerRepository),
                );
              },
            ),
            GoRoute(
              path: RouteNames.submitFunds,
              builder: (BuildContext context, GoRouterState state) {
                return _scroll(
                  SubmitFundsPage(repository: capitalSubmissionRepository),
                );
              },
            ),
            GoRoute(
              path: RouteNames.submissions,
              builder: (BuildContext context, GoRouterState state) {
                return _scroll(
                  SubmissionsPage(repository: capitalSubmissionRepository),
                );
              },
              routes: <RouteBase>[
                GoRoute(
                  path: RouteNames.submissionDetailSegment,
                  builder: (BuildContext context, GoRouterState state) {
                    final String requestId =
                        state.pathParameters['requestId'] ?? '';
                    return _scroll(
                      SubmissionDetailPage(
                        repository: capitalSubmissionRepository,
                        requestId: requestId,
                      ),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: RouteNames.approvals,
              builder: (BuildContext context, GoRouterState state) {
                return _scroll(
                  ApprovalPage(repository: capitalSubmissionRepository),
                );
              },
            ),
            GoRoute(
              path: RouteNames.investments,
              builder: (BuildContext context, GoRouterState state) {
                return _scroll(
                  InvestmentPage(repository: investmentRepository),
                );
              },
              routes: <RouteBase>[
                GoRoute(
                  path: RouteNames.investmentCreateSegment,
                  builder: (BuildContext context, GoRouterState state) {
                    return _scroll(
                      InvestmentCreatePage(repository: investmentRepository),
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: RouteNames.members,
              builder: (BuildContext context, GoRouterState state) {
                return _scroll(
                  MembersPage(
                    repository: memberManagementRepository,
                    onAdd: () => context.push(RouteNames.manageMembers),
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
                  path: RouteNames.manageMembersSegment,
                  builder: (BuildContext context, GoRouterState state) {
                    return _scroll(
                      ManageMembersPage(
                        repository: memberManagementRepository,
                      ),
                    );
                  },
                ),
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
                        repository: memberManagementRepository,
                        ledgerRepository: memberLedgerRepository,
                        submissionRepository: capitalSubmissionRepository,
                        member: args.member,
                        colorIdx: args.memberColorIdx,
                        onBack: () => _closeMemberDetail(context),
                      ),
                    );
                  },
                  routes: <RouteBase>[
                    GoRoute(
                      path: RouteNames.editMemberSegment,
                      builder: (BuildContext context, GoRouterState state) {
                        final Object? extra = state.extra;
                        final EditMemberRouteArgs? args =
                            extra is EditMemberRouteArgs ? extra : null;

                        if (args == null) {
                          return _scroll(const SizedBox.shrink());
                        }

                        return _scroll(
                          EditMemberPage(
                            repository: memberManagementRepository,
                            user: args.user,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: RouteNames.ledger,
              builder: (BuildContext context, GoRouterState state) {
                return _scroll(LedgerPage(repository: memberLedgerRepository));
              },
            ),
            GoRoute(
              path: RouteNames.memberLedger,
              builder: (BuildContext context, GoRouterState state) {
                return _scroll(
                  MemberLedgerPage(repository: memberLedgerRepository),
                );
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
    if (location == RouteNames.submitFunds && !role.canSubmitFunds) {
      return RouteNames.home;
    }
    if (location.startsWith(RouteNames.submissions) &&
        !role.canViewOwnSubmissions) {
      return RouteNames.home;
    }
    if (location == RouteNames.manageMembers && !role.canManageMembers) {
      return RouteNames.home;
    }
    if (location.startsWith(RouteNames.members) && !role.canViewMembers) {
      return RouteNames.home;
    }
    if (location == RouteNames.profile && !role.canViewOwnProfile) {
      return RouteNames.home;
    }
    if (location == RouteNames.ledger && !role.canViewAllLedger) {
      return RouteNames.home;
    }
    if (location == RouteNames.memberLedger && role != UserRole.member) {
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

class EditMemberRouteArgs {
  const EditMemberRouteArgs({required this.user});

  final ManagedUser user;
}
