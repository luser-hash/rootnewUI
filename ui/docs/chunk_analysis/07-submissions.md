# Submissions

## Scope

- `features/submissions/domain/*`
- `features/submissions/data/*`
- `features/submissions/presentation/*`

## The Good

- Submissions follow the intended feature layering: domain, data, presentation.
- Request/history/approval queue domain objects are separated.
- Repository and API classes are distinct.
- Presentation controllers exist for submit, list, and detail flows.

## Critical Issues

- Submission state is screen/controller-local. If submissions affect home, approvals, reports, and ledger, there needs to be a shared invalidation or state refresh strategy.
- Approval status transitions belong to domain/application logic, not only API button handlers.
- Validation rules for submission amount, payment channel, external reference, and attachments should be explicit and testable outside widgets.
- Member/admin behavior differs by product rules, but current permission policy may block admins from submit flows.

## Refactoring Opportunities

- Add `SubmissionService` or use-case layer for:
  - create submission
  - load history
  - load detail
  - approve/reject
  - invalidate related summaries
- Keep form validation in a pure Dart validator.
- Normalize request and response models around backend naming conventions.
- Add pagination/filter objects if history grows.

## Performance Wins

- Use immutable view states instead of multiple independent booleans in controllers.
- Prevent repeated API calls when returning from detail pages by caching list state or using route result invalidation.
- Use `const` for static form labels and helper widgets.

## Proposed Structure

```text
features/submissions/
  domain/
    submission.dart
    submission_filters.dart
    submission_validator.dart
  data/
    capital_submission_api.dart
    capital_submission_repository.dart
  application/
    submission_service.dart
  presentation/
    controllers/
    pages/
    widgets/
```

## Priority Tasks

- P0: Align submit permissions with product matrix.
- P1: Extract form validators and test them.
- P1: Add shared invalidation after create/approve/reject actions.
- P2: Add list/detail widget tests.
