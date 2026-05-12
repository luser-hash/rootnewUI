# Profile

## Scope

- `features/profile/presentation/profile_page.dart`
- Auth session data used by profile
- Ledger repository data used by profile

## The Good

- Profile is separated as its own feature.
- Profile can use authenticated session context rather than requiring caller-passed user data.
- Connection to ledger repository allows personal finance summary presentation.

## Critical Issues

- Profile is presentation-only right now. If profile editing or password/security settings grow, it needs domain/data boundaries.
- Router allows admin and super admin to access profile, but navigation visibility currently focuses on member profile. Product behavior needs to be explicit.
- Profile should not duplicate ledger summary calculations already owned by ledger.
- Any personal financial summary should come from backend/member-ledger state, not demo/shared state.

## Refactoring Opportunities

- Split profile into:
  - identity header
  - account metadata
  - balance summary
  - security actions
  - recent ledger preview
- Add `ProfileController` if data loading expands beyond session-only fields.
- Reuse ledger summary widgets instead of creating profile-specific financial cards.
- Decide whether admin profile is supported or hidden consistently.

## Performance Wins

- Keep session-only parts separate from async ledger summary parts.
- Avoid reloading ledger summary when profile identity fields rebuild.
- Use shared `TotalBalanceCard` or a smaller shared financial summary widget.

## Proposed Structure

```text
features/profile/
  presentation/
    profile_page.dart
    profile_controller.dart
    widgets/
```

## Priority Tasks

- P0: Decide and align admin/super admin profile route and nav visibility.
- P1: Reuse ledger summary/domain calculations.
- P1: Split `profile_page.dart` into widgets.
- P2: Add widget tests for member/admin profile visibility.
