# UX Change Implementation Plan

This plan tracks the dashboard and finance UX changes described in `ux_change.md`.

## Plan

### Phase 1: Confirm Finance Semantics

1. Verify the backend meaning of `current_balance`.
2. Confirm whether distributions are already included in the member ledger balance.
3. Decide whether "Profit Wallet Balance" means:
   - total posted `DISTRIBUTION` entries minus reversals, or
   - a new separate backend wallet/account.
4. Decide whether admin profit distribution should remain investment-based or become a standalone cycle-based distribution.

### Phase 2: Member Dashboard/Profile

1. Add a dedicated member finance summary model.
2. Add a repository/API method for member dashboard summary.
3. Show four member widgets:
   - Total Submitted Amount / Capital Balance
   - Profit Wallet Balance / Dividend Balance
   - Total Amount / Net Balance
   - Transaction History
4. Split transaction labels clearly:
   - `SUBMISSION` -> Funds Given
   - `WITHDRAW` -> Funds Taken
   - `DISTRIBUTION` -> Profit Added
   - `DISTRIBUTION_REVERSAL` -> Profit Reversed
5. Reuse existing card/table styling from reports and ledger pages.

### Phase 3: Admin Dashboard

1. Replace or validate the existing landing `Total Association Capital` with an authoritative backend field.
2. Add Member-Wise Ratio Ledger:
   - member name
   - capital balance
   - ownership ratio percentage
   - optional profit wallet balance
3. Add an entry point from Quick Actions or Staff Reports.
4. Keep this read-only at first to reduce risk.

### Phase 4: Profit Distribution Workflow

1. If using the current investment flow:
   - improve visibility of the existing `Distribute P&L` action
   - add clearer preview/explanation before distribution
   - keep using captured capital snapshot
2. If adding standalone distribution:
   - create a backend endpoint for distribution preview
   - create a backend endpoint for posting distribution
   - create a frontend screen with amount input, preview table, confirmation, and success state
3. Never calculate final distribution amounts only on the frontend.

### Phase 5: Testing/Validation

1. Test the member role dashboard.
2. Test the admin role dashboard.
3. Test that report pages still load.
4. Test that investment distribution still works.
5. Verify routes and permissions still redirect correctly.
6. Run Flutter analyzer/tests.

## To Do List

- [ ] Confirm backend meaning of `current_balance`.
- [ ] Confirm source of truth for `profit_wallet_balance`.
- [ ] Confirm whether standalone profit distribution is required.
- [ ] Define member finance summary response shape.
- [ ] Define admin ratio ledger response shape.
- [ ] Add member finance summary domain model.
- [ ] Add member finance summary API/repository.
- [ ] Add member dashboard finance controller.
- [ ] Add member dashboard cards to `landing_page.dart`.
- [ ] Add compact transaction history widget.
- [ ] Rename transaction labels for member-facing clarity.
- [ ] Add admin ratio ledger model/API/repository.
- [ ] Add admin ratio ledger UI section.
- [ ] Add admin navigation/quick action if needed.
- [ ] Decide investment-based vs standalone distribution UI.
- [ ] Implement distribution preview if standalone.
- [ ] Implement distribution confirmation if standalone.
- [ ] Add loading, empty, and error states.
- [ ] Verify permissions by role.
- [ ] Run `flutter analyze`.
- [ ] Run available tests.
