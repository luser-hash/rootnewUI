# Chunk Analysis Index

Generated from `master_prompt.md` standards: architectural integrity, state/data flow, SOLID/DRY, performance/immutability, and standardization.

## Chunks

1. [App Foundation](01-app-foundation.md)
2. [Routing And Permissions](02-routing-permissions.md)
3. [Network And API Core](03-network-api-core.md)
4. [Authentication](04-authentication.md)
5. [Shared UI And Finance Utilities](05-shared-ui-finance.md)
6. [Landing Dashboard](06-landing-dashboard.md)
7. [Submissions](07-submissions.md)
8. [Approvals](08-approvals.md)
9. [Members](09-members.md)
10. [Ledger](10-ledger.md)
11. [Investments](11-investments.md)
12. [Reports](12-reports.md)
13. [Profile](13-profile.md)
14. [Android And Release](14-android-release.md)

## Cross-Cutting Priorities

### P0 - Correctness

- Align `UserRolePermissions`, route guards, bottom navigation, and home actions with the intended product role matrix.
- Make ledger and balances backend/domain authoritative, especially admin ledger.
- Fix signed money formatting in shared finance formatters.
- Add explicit loading/error/empty states for every API-backed screen.

### P1 - Architecture

- Keep feature internals layered as `domain`, `data`, and `presentation`.
- Move business rules out of widgets and into controllers/use cases.
- Replace screen-owned async state with reusable state objects or notifiers where multiple screens consume the same data.
- Split very large pages into focused widgets and controllers.

### P2 - DRY And UI System

- Standardize table, filter, KPI, status pill, empty state, and error panel widgets.
- Centralize money/date/status formatting.
- Replace copied responsive layout logic with shared layout helpers.

### P3 - Testing

- Add unit tests for role permissions, money formatting, API model parsing, approval transitions, and ledger calculations.
- Add widget tests for route guards, navigation visibility, submission flows, report filters, and ledger filters.

### P4 - Release Readiness

- Configure real Android application ID, app label, icons, and release signing.
- Add CI for `flutter analyze`, `dart format --set-exit-if-changed .`, `flutter test`, and Android build.
