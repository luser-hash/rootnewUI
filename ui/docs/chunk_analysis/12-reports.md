# Reports

## Scope

- `features/reports/domain/*`
- `features/reports/data/*`
- `features/reports/presentation/member_report.dart`
- `features/reports/presentation/staff_report.dart`

## The Good

- Reports have domain, data, and presentation layers.
- Member report and staff report are separated.
- Staff report covers useful audit surfaces: summary, member balances, investments, distributions, and approval queue.
- Report API and repository boundaries are present.

## Critical Issues

- `staff_report.dart` and `member_report.dart` are very large. They mix API-driven state, filters, formatting, tables, and report-specific widgets in one file.
- Report money parsing/formatting is local, while shared finance formatting also exists. This creates inconsistent currency behavior.
- Staff report state is managed with several separate `Future` fields and filter fields. This is workable but brittle as filters and refresh dependencies grow.
- Domain report models store many money/date values as strings, making sorting, totals, and validation fragile.

## Refactoring Opportunities

- Split reports by section:
  - summary
  - member balances
  - investment register
  - distribution logs
  - approval queue
- Create section controllers/view models instead of many nullable futures in the page state.
- Introduce shared report widgets:
  - report panel
  - timestamp bar
  - money cell
  - sortable table header
  - chip filter bar
- Convert money/date fields into typed values at the data/domain boundary where practical.

## Performance Wins

- Keep section futures/controllers alive without rebuilding all sections.
- Sort/filter report data in controllers, not table build methods.
- Use `PaginatedDataTable` or custom virtualized rendering for large reports.

## Proposed Structure

```text
features/reports/
  domain/
  data/
  presentation/
    member/
    staff/
      staff_report_page.dart
      sections/
      widgets/
      controllers/
```

## Priority Tasks

- P0: Centralize report money/date formatting.
- P1: Split `staff_report.dart` and `member_report.dart`.
- P1: Replace multi-future page state with section controllers.
- P2: Type money/date fields more strongly.
- P2: Add tests for API parsing, filtering, sorting, and empty/error states.
