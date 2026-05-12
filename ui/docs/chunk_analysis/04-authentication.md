# Authentication

## Scope

- `features/auth/domain/auth_session.dart`
- `features/auth/data/auth_api.dart`
- `features/auth/data/auth_repository.dart`
- `features/auth/data/auth_storage.dart`
- `features/auth/presentation/auth_controller.dart`
- `features/auth/presentation/login_page.dart`
- `features/auth/presentation/auth_scope.dart`

## The Good

- Auth is separated into domain, data, and presentation layers.
- `AuthController` is a clear `ChangeNotifier` source for auth state.
- Secure storage is abstracted behind repository/storage classes.
- `UserRole.fromApi()` tolerates multiple API role spellings.
- JWT expiry parsing reduces stale-token restores.

## Critical Issues

- Permission rules live in the auth domain model. Role identity and product permissions are related, but permission policy may grow enough to deserve its own routing/security policy file.
- `AuthController` mixes session state, login orchestration, password change, sign out, and error message state.
- Login page is large and likely owns too much UI state directly.
- Stored-session restore can keep a local session on some non-auth restore errors. That may be pragmatic for offline behavior, but the UX should clearly distinguish "restored locally" from "verified by server" if finance data depends on trust.

## Refactoring Opportunities

- Move permission matrix to `core/security/role_permissions.dart` or `core/routing/route_permissions.dart`.
- Split auth state:
  - `AuthSessionState`
  - `AuthActionController`
  - `PasswordController` if password flows expand
- Extract login form widgets and validation helpers from `login_page.dart`.
- Add a typed auth failure enum while keeping user-facing messages in the presentation layer.

## Performance Wins

- Use selectors or smaller inherited scopes if auth changes cause large subtree rebuilds.
- Keep token/session parsing outside `build`.
- Add `const` to static login subwidgets after extraction.

## Proposed Structure

```text
features/auth/
  domain/
    auth_session.dart
    auth_tokens.dart
  data/
    auth_api.dart
    auth_repository.dart
    auth_storage.dart
  presentation/
    auth_controller.dart
    auth_scope.dart
    login_page.dart
    widgets/
```

## Priority Tasks

- P0: Align permission getters with product matrix.
- P1: Extract permission policy from auth session models.
- P1: Split login page into smaller form/header/action widgets.
- P2: Add tests for role parsing, token expiry parsing, restore behavior, and route redirects.
