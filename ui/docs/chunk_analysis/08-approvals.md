# Approvals

## Scope

- `features/approvals/presentation/approval_page.dart`
- `features/approvals/presentation/approval_queue_controller.dart`
- Approval queue models in `features/submissions/domain`

## The Good

- There is a dedicated approval queue controller.
- Approval access is route-gated for admin and super admin.
- Approval queue is conceptually separated from member submission history.

## Critical Issues

- `approval_page.dart` is large and likely contains UI, filtering, action handling, and presentation decisions in one place.
- Approval actions must be treated as financial domain events. They should not only mutate a list or trigger a UI refresh; they should cause ledger and report state to become stale or update.
- Approval validation, rejection reason rules, and audit requirements should be explicit.
- If backend approval creates ledger entries, the UI should display that result or at least reload ledger-affecting summaries.

## Refactoring Opportunities

- Split approval screen into:
  - queue filter bar
  - queue table/list
  - approval detail panel
  - approve/reject dialogs
  - result/error banners
- Create an `ApprovalService` that coordinates repository calls and post-action invalidation.
- Use an immutable `ApprovalQueueState` with `loading`, `loaded`, `empty`, `error`, and `submittingAction`.
- Add domain-level action models: `ApproveSubmissionCommand`, `RejectSubmissionCommand`.

## Performance Wins

- Avoid rebuilding the whole approval page while one row action is loading.
- Use keyed rows for queue items.
- Cache filter choices separately from fetched result state.

## Proposed Structure

```text
features/approvals/
  application/
    approval_service.dart
  presentation/
    approval_page.dart
    approval_queue_controller.dart
    widgets/
```

## Priority Tasks

- P0: Ensure approve/reject updates or invalidates home, ledger, submissions, and reports.
- P1: Split the page into smaller widgets.
- P1: Add tests for approval state transitions.
- P2: Add audit-friendly rejection reason validation.
