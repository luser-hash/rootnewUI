# Shared UI And Finance Utilities

## Scope

- `features/shared/finance.dart`
- `features/shared/finance_demo_data.dart`
- `features/shared/models/finance_models.dart`
- `features/shared/data/finance_demo_fixtures.dart`
- `features/shared/utils/finance_formatters.dart`
- `features/shared/services/member_metrics.dart`
- `features/shared/widgets/*`

## The Good

- Shared widgets such as buttons, pills, avatars, shell, and card lists reduce some duplication.
- Demo fixtures have been moved away from the main export path.
- Finance formatters are centralized enough to be fixable in one place.
- `member_metrics.dart` is a good start for moving calculations out of UI.

## Critical Issues

- `fmt()` and `fmtSh()` call `abs()`, so negative values lose their sign. This is a financial correctness issue.
- Demo models still live in shared code and can blur the boundary between product domain and mock data.
- Shared finance models use primitive strings and ints for money/date/status rather than stronger domain types.
- Some report pages define local money/date/status helpers instead of using shared utilities, causing drift.

## Refactoring Opportunities

- Replace `fmt`/`fmtSh` with explicit functions:
  - `formatMoneySigned`
  - `formatMoneyUnsigned`
  - `formatCompactMoneySigned`
- Move demo-only models/fixtures under `features/demo` or `dev_fixtures`.
- Add a `Money` value object using integer minor units if backend allows it.
- Promote repeated report/table/status widgets into `shared/widgets`.

## Performance Wins

- Make shared widgets highly `const`-friendly.
- Avoid repeated formatter object creation in large tables.
- Prefer immutable data models with value equality for efficient change detection.

## Proposed Structure

```text
features/shared/
  widgets/
  formatting/
    money_formatter.dart
    date_formatter.dart
    status_formatter.dart
  domain/
    money.dart
  demo/
    finance_demo_fixtures.dart
```

## Priority Tasks

- P0: Fix signed money formatting and add tests.
- P1: Remove demo models from production-facing shared exports.
- P1: Centralize date/status/money formatting used by reports, ledger, and investments.
- P2: Add shared table/filter/empty/error widgets.
