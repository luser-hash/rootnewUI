# Investments

## Scope

- `features/investments/domain/*`
- `features/investments/data/*`
- `features/investments/presentation/*`

## The Good

- Investments use domain/data/presentation folders.
- There are dedicated request models for create and close actions.
- Investment detail and distribution record are distinct pages.
- API and repository boundaries are present.

## Critical Issues

- Investment workflow is financially sensitive: create, release funds, close, distribute P/L, and reverse actions need explicit state transitions.
- Route guard for investments is not explicit enough. Members should see own investment exposure, while admins/super admins can manage all.
- Distribution affects ledger and reports, so post-action invalidation must be coordinated.
- UI pages are large and likely contain workflow logic directly.

## Refactoring Opportunities

- Add an `InvestmentWorkflowService` for:
  - create draft
  - release funds
  - close investment
  - distribute P/L
  - reverse distribution
- Model state transitions explicitly with allowed actions by status and role.
- Split `investment_page.dart`, `investment_create_page.dart`, and distribution record widgets.
- Create reusable money/date/status components shared with ledger/reports.

## Performance Wins

- Cache investment register/list state and reload only after mutation.
- Avoid recomputing status metrics inside widgets.
- Use immutable action availability view models.

## Proposed Structure

```text
features/investments/
  domain/
    investment.dart
    investment_status.dart
    investment_commands.dart
  application/
    investment_workflow_service.dart
  data/
  presentation/
    investment_page.dart
    pnl_wallet.dart
    list/
      investment_page.dart
      investments_header.dart
      investment_full_card.dart
      close_investment_sheet.dart
    investment_detail_page.dart
    investment_create_page.dart
    distribution_record.dart
    widgets/
```

Current cleanup status:

- `investment_page.dart` is now a compatibility export to `presentation/list/investment_page.dart`.
- `p&l_wallet.dart` was renamed to `pnl_wallet.dart` to satisfy Dart filename linting.
- Investment detail now uses shared text/date formatting helpers where behavior matched existing output.

## Priority Tasks

- P0: Define role-specific investment permissions and route guards.
- P0: Ensure distribution creates/refreshes ledger and reports.
- P1: Add explicit investment state transition rules.
- P1: Split large investment presentation files.
- P2: Add tests for create/close/distribute command validation.
