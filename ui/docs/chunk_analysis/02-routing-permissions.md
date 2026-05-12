# Routing And Permissions

## Scope

- `lib/core/routing/app_router.dart`
- `lib/core/routing/route_names.dart`
- `lib/src/features/shared/widgets/app_shell.dart`
- `UserRolePermissions` in `auth_session.dart`

## The Good

- Route protection is centralized in `AppRouter._authorizedLocation()`.
- `GoRouter` listens to `AuthController`, so login/logout changes trigger redirects.
- Permission getters avoid raw string role checks in most places.
- Member ledger and admin ledger are already separated at the route level.

## Critical Issues

- The intended product matrix and current permissions do not match. The notes say Submit Funds is available to member, admin, and super admin, but `canSubmitFunds` currently allows member only.
- Route guards, bottom navigation, and home quick actions are not guaranteed to match. This creates discoverability bugs and route-redirect surprises.
- `/investments` is broadly accessible but not explicitly checked against investment permissions in `_authorizedLocation()`.
- `canViewHome` rejects `unknown`, but the router does not explicitly block unknown authenticated users from home.
- Permissions are client-side only; backend APIs must remain the real enforcement layer.

## Refactoring Opportunities

- Create a single `AppPermission` matrix and derive route/nav visibility from it.
- Keep direct role checks only for genuinely role-specific routing choices, such as member ledger versus admin ledger.
- Add a route metadata map:

```dart
class AppRoutePolicy {
  const AppRoutePolicy({required this.path, required this.allowed});
  final String path;
  final bool Function(UserRole role) allowed;
}
```

- Use this policy in router guards, nav tab creation, and home quick actions.

## Performance Wins

- Permission checks are cheap; the main win is reducing duplicate checks and rebuild mistakes.
- Avoid creating tab lists with heavy widgets on every shell rebuild. Keep route/tab metadata lightweight.

## Proposed Structure

```text
lib/core/routing/
  app_router.dart
  route_names.dart
  route_permissions.dart
```

## Priority Tasks

- P0: Update `UserRolePermissions` to match the intended role matrix.
- P0: Gate `/investments` explicitly.
- P1: Make bottom navigation and home quick actions consume the same permission source as route guards.
- P2: Add widget tests for member/admin/super admin route redirects and tab visibility.
