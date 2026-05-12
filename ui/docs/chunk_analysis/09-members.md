# Members

## Scope

- `features/members/domain/*`
- `features/members/data/*`
- `features/members/presentation/*`

## The Good

- Members have a clear domain/data/presentation split.
- Manage, edit, list, and detail screens are separated.
- Controllers exist for list, detail, ledger, submission history, and manage member flows.
- API layer supports search/filter parameters.

## Critical Issues

- `member_detail_screen.dart` is very large and should be split. It likely mixes profile rendering, ledger loading, submission history, and action logic.
- Member capital percentage and balance rules must be domain-defined, especially active versus inactive member treatment.
- Admin member management and member profile viewing are separate concerns but currently live close together.
- Route fallback for missing member detail args uses `members.first` from demo/shared data, which is unsafe for production navigation.

## Refactoring Opportunities

- Split member detail into:
  - profile header
  - balance summary
  - ledger preview
  - submission history
  - admin actions
- Replace route `extra` dependence with member ID route parameters and fetch by ID.
- Move member metric calculations into `member_metrics.dart` or member domain services.
- Create shared form fields for create/edit member forms.

## Performance Wins

- Load detail sub-sections independently so ledger/history refreshes do not rebuild the whole detail page.
- Use immutable member view models.
- Avoid sorting/filtering large member lists inside `build`; keep filtered list in controller state.

## Proposed Structure

```text
features/members/
  domain/
    member.dart
    member_metrics.dart
  data/
  presentation/
    list/
    detail/
    manage/
    widgets/
```

## Priority Tasks

- P0: Remove demo fallback from member detail routing.
- P0: Define active/inactive balance and capital percentage rules.
- P1: Split `member_detail_screen.dart`.
- P1: Route member detail by ID instead of passing full model via `extra`.
- P2: Add tests for search, filters, create/edit validation, and detail route behavior.
