# App Foundation

## Scope

- `lib/main.dart`
- `lib/src/app/app.dart`
- `lib/core/theme/app_theme.dart`
- Root dependency wiring for API client, repositories, auth controller, router, and theme.

## The Good

- The app now has one root `MaterialApp.router`, which is the correct shape for a `go_router` app.
- Repository and API dependencies are wired near the root instead of being recreated in every page.
- `AuthScope` gives the widget tree a consistent auth source.
- Theme is centralized in `AppTheme`, which is better than repeated top-level `ThemeData` construction.

## Critical Issues

- `App` manually wires every API and repository. This is acceptable at the current size, but it is already becoming a composition root with too much responsibility.
- Repository creation is tightly coupled to `App` and `ApiClient`, making test injection and feature-level replacement harder.
- `ApiClient` is not disposed. Because it owns an `http.Client`, the app should expose/close it when the root state is disposed.
- There is no app-level error boundary or global offline/session-expired UX. API exceptions are handled per screen, which will become inconsistent.

## Refactoring Opportunities

- Extract dependency creation into an `AppDependencies` class:
  - `ApiClient`
  - `AuthController`
  - repositories
  - router factory
- Add a `dispose()` method on dependencies that closes controllers and HTTP clients.
- Keep `App` focused on lifecycle plus `MaterialApp.router`.
- Consider replacing manual dependency construction with a lightweight inherited dependencies object before introducing a larger DI package.

## Performance Wins

- Keep repositories and controllers as `late final`, as already done.
- Add `const` constructors to static root-level widgets where possible.
- Avoid rebuilding router dependencies during `build`; current code correctly initializes router in `initState`.

## Proposed Structure

```text
lib/src/app/
  app.dart
  app_dependencies.dart
  app_bootstrap.dart
```

## Priority Tasks

- P0: Add disposal for `ApiClient`/HTTP client and controllers.
- P1: Extract root dependency wiring from `App`.
- P2: Add app-level session-expired/offline handling strategy.
