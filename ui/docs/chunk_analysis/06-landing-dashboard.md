# Landing Dashboard

## Scope

- `features/landing/presentation/landing_page.dart`
- `features/landing/presentation/landing_hero_summary_controller.dart`
- `features/landing/presentation/landing_approval_summary_controller.dart`

## The Good

- Landing has dedicated controllers for summary and approval summary loading.
- Role-aware rendering is already present for approvals, members, and quick actions.
- The dashboard has a clear business purpose: summary, pending actions, members, and recent activity.

## Critical Issues

- `landing_page.dart` is still large, which makes business rules, layout, and navigation intent hard to audit.
- Quick actions encode permission and route decisions locally. This should be derived from the same route permission source as `AppRouter`.
- Dashboard calculations and display formatting should not live directly in widget build methods.
- Home can link users to routes that may later reject them if permission logic drifts.

## Refactoring Opportunities

- Split into:
  - `HomeScreen`
  - `HomeHero`
  - `PendingApprovalBanner`
  - `QuickActionGrid`
  - `MemberSummaryCarousel`
  - `RecentActivityList`
- Move quick-action assembly into a `HomeActionPolicy`.
- Move computed dashboard metrics into a controller/view model.
- Replace role checks in widgets with semantic inputs like `List<HomeAction> actions`.

## Performance Wins

- Reduce rebuild scope by splitting sections into small `const`-friendly widgets.
- Avoid recomputing lists, totals, and filters in `build`.
- Use `LayoutBuilder` only around the responsive section that needs constraints.

## Proposed Structure

```text
features/landing/
  presentation/
    landing_page.dart
    landing_hero_summary_controller.dart
    landing_approval_summary_controller.dart
    widgets/
      home_status_bar.dart
      home_hero.dart
      quick_action_grid.dart
      members_carousel.dart
      recent_activity_section.dart
```

Current cleanup status:

- `landing_page.dart` now keeps orchestration/state while dashboard sections live in `widgets/`.
- Quick-action assembly moved into `quick_action_grid.dart`; a shared route-permission policy is still a future architecture task.

## Priority Tasks

- P0: Ensure home quick actions match route permissions.
- P1: Split `landing_page.dart` into section widgets.
- P1: Move dashboard metrics into a view model/controller.
- P2: Add widget tests for visible home actions by role.
