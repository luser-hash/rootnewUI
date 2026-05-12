# Ledger

## Scope

- `features/ledger/domain/member_ledger_statement.dart`
- `features/ledger/data/*`
- `features/ledger/presentation/ledger_page.dart`
- `features/ledger/presentation/member_ledger.dart`
- `features/ledger/presentation/*controller.dart`
- `features/ledger/presentation/total_balance_card.dart`

## The Good

- Member ledger is backend-backed through `MemberLedgerRepository`.
- Member ledger and admin ledger are separated by route and role.
- Ledger statement has dedicated domain models.
- Controllers exist for member and admin ledger entry points.

## Critical Issues

- Admin ledger is still demo-derived in `ledger_page.dart`. For a finance app, this is the most important correctness gap.
- Ledger must be an append-only accounting/audit source, not a UI reconstruction from submissions and sample transactions.
- `ledger_page.dart` is large and likely mixes ledger calculation, filtering, table rendering, and summary card rendering.
- Signed amount formatting must be correct and consistent across ledger views.

## Refactoring Opportunities

- Create admin ledger API/repository methods, not only member ledger statement calls.
- Add domain entities:
  - `LedgerEntry`
  - `LedgerEntryType`
  - `LedgerSource`
  - `LedgerStatement`
  - `LedgerFilter`
- Split admin ledger UI into summary, filters, entry table, and export/action widgets.
- Move totals and running balance calculations to domain/service code.

## Performance Wins

- Avoid rebuilding all ledger rows when filters change; derive filtered rows in controller state.
- Use virtualized/list-based rendering if ledger rows become large.
- Use tabular figure fonts consistently for money columns.

## Proposed Structure

```text
features/ledger/
  domain/
    ledger_entry.dart
    ledger_filter.dart
    ledger_statement.dart
  data/
    ledger_api.dart
    ledger_repository.dart
  presentation/
    admin/
    member/
    widgets/
```

## Priority Tasks

- P0: Replace admin demo ledger with backend ledger API.
- P0: Fix signed money display in all ledger surfaces.
- P1: Move ledger calculations to domain/application layer.
- P1: Split `ledger_page.dart`.
- P2: Add ledger calculation and filter tests.
