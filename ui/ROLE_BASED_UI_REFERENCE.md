# Role Based UI Reference

This document captures the current role based UI implementation in the Flutter app for future development. It describes what exists in code today, where role checks live, and where the implementation still differs from the intended product rules.

## Source Of Truth

Role data starts in the authenticated user session:

- `lib/src/features/auth/domain/auth_session.dart`
  - `AuthUser.role` stores the active user role.
  - `UserRole.fromApi()` maps API role strings into app roles.
  - `UserRolePermissions` defines the current permission getters.
- `lib/src/features/auth/presentation/auth_controller.dart`
  - Owns the current `AuthSession`.
  - Exposes `role`, `user`, `session`, and authentication status.
- `lib/src/features/auth/presentation/auth_scope.dart`
  - Provides the `AuthController` to widgets through `AuthScope.of(context)`.

The UI should read role state through:

```dart
final UserRole role = AuthScope.of(context).role;
```

Avoid adding scattered string comparisons against raw API role values. Add or adjust permission getters in `UserRolePermissions` first, then consume those getters from routing and widgets.

## Current Roles

The app currently knows four role values:

| Role | API value | Label | Meaning |
| --- | --- | --- | --- |
| `UserRole.member` | `MEMBER` | Member | Regular association member. |
| `UserRole.admin` | `ADMIN` | Admin | Admin level user. |
| `UserRole.superAdmin` | `SUPER_ADMIN` | Super Admin | Highest admin role. |
| `UserRole.unknown` | `UNKNOWN` | Unknown | Fallback for missing or unrecognized API roles. |

`UserRole.fromApi()` also accepts `SUPERADMIN` as a super admin alias.

## Current Permission Matrix

This matrix is based on the implemented `UserRolePermissions` extension, not on planned product behavior.

| Permission | Member | Admin | Super Admin | Unknown |
| --- | --- | --- | --- | --- |
| `canViewHome` | yes | yes | yes | no |
| `canSubmitFunds` | yes | no | no | no |
| `canViewOwnSubmissions` | yes | no | no | no |
| `canViewOwnProfile` | yes | yes | yes | no |
| `canViewApprovals` | no | yes | yes | no |
| `canViewMembers` | no | yes | yes | no |
| `canManageMembers` | no | yes | yes | no |
| `canViewOwnInvestments` | yes | yes | yes | no |
| `canViewAllInvestments` | no | yes | yes | no |
| `canViewOwnLedger` | yes | yes | yes | no |
| `canViewAllLedger` | no | yes | yes | no |
| `canDistribute` | no | yes | yes | no |
| `canViewOwnReports` | yes | yes | yes | no |
| `canViewAllReports` | no | yes | yes | no |
| `canManagePermissions` | no | no | yes | no |

Important: some permission getters exist before the corresponding screen or route exists. For example, reports and permissions appear as quick actions, but they do not currently have dedicated routes.

## Route Enforcement

Client-side route protection is centralized in `lib/core/routing/app_router.dart`.

`GoRouter` uses `AuthController` as `refreshListenable`, so authentication or role changes cause redirects to re-run.

Authentication redirects:

- `AuthStatus.unknown` and `AuthStatus.authenticating` do not redirect.
- `AuthStatus.unauthenticated` redirects every route except `/login` to `/login`.
- `AuthStatus.authenticated` redirects `/login` to `/`.
- Authenticated users are then checked by `_authorizedLocation(location, role)`.

Implemented route gates:

| Route | Name | Current allowed roles |
| --- | --- | --- |
| `/` | `RouteNames.home` | Any authenticated role, including `unknown` today. |
| `/profile` | `RouteNames.profile` | Member, Admin, Super Admin. |
| `/submit-funds` | `RouteNames.submitFunds` | Member only. |
| `/submissions` and details | `RouteNames.submissions` | Member only. |
| `/approvals` | `RouteNames.approvals` | Admin, Super Admin. |
| `/investments` | `RouteNames.investments` | Any authenticated role today. |
| `/members` and details | `RouteNames.members` | Admin, Super Admin. |
| `/members/manage` | `RouteNames.manageMembers` | Admin, Super Admin. |
| `/ledger` | `RouteNames.ledger` | Admin, Super Admin. |
| `/member-ledger` | `RouteNames.memberLedger` | Member only. |

When a user hits a route they are not allowed to view, the router sends them back to home.

## Navigation Visibility

Bottom navigation lives in `lib/src/features/shared/widgets/app_shell.dart`.

Current tab behavior:

| Tab | Route | Visible for |
| --- | --- | --- |
| Home | `/` | All roles passed into `AppShell`. |
| Profile | `/profile` | Member only. |
| Approvals | `/approvals` | Admin, Super Admin. |
| Invest | `/investments` | All roles passed into `AppShell`. |
| Members | `/members` | Admin, Super Admin. |
| Add Member | `/members/manage` | Admin, Super Admin through the Members header button. |
| Ledger | `/member-ledger` | Member only. |
| Ledger | `/ledger` | Admin, Super Admin. |

There is a small mismatch here: the router allows Admin and Super Admin users to access `/profile`, but the bottom navigation only shows Profile for Members.

## Home Screen Role Rendering

Home screen role rendering lives in `lib/src/features/landing/presentation/landing_page.dart`.

Current behavior:

- Pending approval alert is visible only when `role.canViewApprovals` and there are pending submissions.
- Members carousel is visible only when `role.canViewMembers`.
- Quick actions are assembled by role:
  - Submit Funds: `role.canSubmitFunds`
  - Profile: `role.canViewOwnProfile && role == UserRole.member`
  - Submissions: `role.canViewOwnSubmissions`
  - Approvals: `role.canViewApprovals`
  - Invest: always visible
  - Members: `role.canViewMembers`
  - Ledger: always visible, but route changes by role:
    - Member -> `/member-ledger`
    - Admin/Super Admin/Unknown -> `/ledger`
  - Distribute: `role.canDistribute`
  - Reports: `role.canViewOwnReports`
  - Permissions: `role.canManagePermissions`
- Recent Activity action also sends Members to `/member-ledger` and everyone else to `/ledger`.

Because quick actions can point to routes even when the route will reject the role, route redirects remain the effective safety net.

## Member Ledger vs Admin Ledger

There are currently two ledger experiences:

### Member Ledger

Files:

- `lib/src/features/ledger/presentation/member_ledger.dart`
- `lib/src/features/ledger/presentation/member_ledger_controller.dart`
- `lib/src/features/ledger/data/member_ledger_api.dart`
- `lib/src/features/ledger/domain/member_ledger_statement.dart`

Route:

- `/member-ledger`

Current access:

- Member only, enforced by `AppRouter._authorizedLocation()`.

Data flow:

- UI creates a `MemberLedgerController`.
- Controller loads `MemberLedgerRepository.statement(filter)`.
- API calls `GET /ledger/` with optional query params:
  - `entry_type`
  - `from_date`
  - `to_date`
- The authenticated user's access token is attached by `ApiClient`.
- The server is expected to scope this statement to the authenticated member.

### Admin Ledger

File:

- `lib/src/features/ledger/presentation/ledger_page.dart`

Route:

- `/ledger`

Current access:

- Admin and Super Admin, enforced by `role.canViewAllLedger`.

Data flow:

- This screen still builds demo ledger rows from approved submissions, demo distribution transactions, and one hard-coded withdrawal.
- It is not yet backed by the backend ledger API.

## Auth And Session Flow

The app root wires authentication in `lib/src/app/app.dart`.

Flow:

1. `App` creates `SecureAuthStorage`.
2. `ApiClient` is configured with an access token provider.
3. `AuthController` is created with `ApiAuthRepository`.
4. `AppRouter.router()` receives the `AuthController`.
5. `AuthScope` wraps `MaterialApp.router`.
6. `_authController.bootstrap()` restores a saved session.

Sign in flow:

1. `LoginPage` calls `AuthController.signIn()`.
2. `ApiAuthRepository.signIn()` calls `POST /auth/login/`.
3. It then calls `GET /auth/me/` to verify and refresh the user payload.
4. If "Remember this device" is checked, the verified session is saved in secure storage.
5. On success, the login page navigates to home.

Session restore flow:

1. `ApiAuthRepository.restoreSession()` reads secure storage.
2. Empty or expired access tokens clear the local session.
3. Valid stored sessions are refreshed through `GET /auth/me/`.
4. `401` and `403` during restore clear the stored session.
5. Other restore errors keep the stored session.

## Known Gaps And Mismatches

These are useful to keep visible before future role work:

- `PROJECT_AUDIT.md` notes a desired matrix where Submit Funds is available to Member, Admin, and Super Admin. The current code only allows Members.
- `canViewHome` returns false for `unknown`, but the router does not currently block unknown authenticated users from home.
- `/investments` is not route-gated by investment permissions yet. Bottom nav and home quick action show Invest broadly.
- Admin/Super Admin can access `/profile` directly, but Profile is hidden from their bottom navigation and home quick actions.
- Manage Members posts `full_name`, `contact_no`, `email`, `join_date`, fixed `role: MEMBER`, `notes`, and `password` to `POST /users/`. The backend must enforce `MANAGE_USERS`.
- Member Ledger is backend-backed and token-scoped. Admin Ledger is still demo-derived UI data.
- Reports, Permissions, and Distribute appear as role-gated quick actions, but some do not yet navigate to implemented flows.
- Route checks are client-side only. Backend APIs must still enforce permissions and ownership.

## Guidelines For Future Role Work

When adding or changing role behavior:

1. Update `UserRolePermissions` first.
2. Update `AppRouter._authorizedLocation()` for every protected route.
3. Update `AppShell._tabsForRole()` so navigation visibility matches route access.
4. Update feature-level conditional UI, especially home quick actions.
5. Prefer permission getters such as `role.canViewApprovals` over direct role checks.
6. Use direct role checks only when the behavior is truly role-specific, such as choosing Member Ledger vs Admin Ledger.
7. Add or update widget tests for route redirects and visible navigation items.

Before merging future changes, verify at least these role paths manually:

| Scenario | Expected result |
| --- | --- |
| Unauthenticated user opens `/members` | Redirects to `/login`. |
| Member opens `/members` | Redirects to `/`. |
| Member opens `/member-ledger` | Shows My Ledger Statement. |
| Admin opens `/member-ledger` | Redirects to `/`. |
| Admin opens `/ledger` | Shows Capital Ledger. |
| Super Admin opens home | Sees admin actions plus Permissions. |
| Unknown authenticated role | Should be explicitly decided before production. |
