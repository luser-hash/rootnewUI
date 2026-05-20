# Capital and Profit Wallet Frontend Integration Plan

This plan adapts the Flutter UI to the backend accounting change where member capital and profit are now separated by ledger `wallet_type`.

Source documents:
- `docs/ui/ux_change.md`
- `docs/ui/ux_change_plan.md`
- Backend `backend/associatio_capital_and_profit_management.md`
- Backend `backend/api_reference.md`

## Current Backend Contract

The backend now keeps the existing immutable ledger but separates entries into two wallets:

| Ledger entry type | Wallet |
|---|---|
| `SUBMISSION` | `CAPITAL` |
| `WITHDRAW` | `CAPITAL` |
| `ADJUSTMENT` | `CAPITAL` or `PROFIT`, depending on admin request |
| `DISTRIBUTION` | `PROFIT` |
| `DISTRIBUTION_REVERSAL` | `PROFIT` |

Important accounting rule:

Profit wallet entries do not increase future investment capital ratios. Investment snapshots and capital summary use only `CAPITAL` wallet entries.

## Existing Endpoints To Use

No new frontend-only calculations should replace backend totals. Use these existing endpoints as the source of truth.

| UX requirement | Existing endpoint | Notes |
|---|---|---|
| Member capital balance | `GET /api/ledger/` or `GET /api/reports/my-statement/` | Use `capital_balance`. |
| Member profit wallet balance | `GET /api/ledger/` or `GET /api/reports/my-statement/` | Use `profit_wallet_balance`. |
| Member total amount | `GET /api/ledger/` or `GET /api/reports/my-statement/` | Use `total_amount`; `current_balance` is compatibility only. |
| Funds given / taken | `GET /api/ledger/` or `GET /api/reports/my-statement/` | Use `given_amount` and `taken_amount`. |
| Transaction history | `GET /api/ledger/` | Entries now include `wallet_type`. |
| Admin total association capital | `GET /api/reports/association-summary/` or `GET /api/ledger/admin/` | Prefer reports summary `capital.total_authorized`; do not derive from `total_in - total_out`. |
| Admin member-wise ratio ledger | `GET /api/reports/member-balances/` | Derive ratio from each member `capital_balance / total_capital`. |
| Investment distribution trigger | `POST /api/investments/{id}/distribute/` | Keep investment-based distribution. Do not add standalone distribution UI yet. |
| Distribution audit | `GET /api/investments/{id}/distribution/` and `GET /api/reports/distribution-logs/` | Existing screens can show distribution lines. |

## Current Frontend Gaps

1. `MemberLedgerStatement` only parses `current_balance` and `pending_total`.
   File: `lib/src/features/ledger/domain/member_ledger_statement.dart`

2. Ledger entries do not parse `wallet_type`.
   File: `lib/src/features/ledger/domain/member_ledger_statement.dart`

3. Admin ledger summary still uses `totalIn` and `totalOut`; the landing controller derives total capital manually.
   Files:
   - `lib/src/features/ledger/domain/member_ledger_statement.dart`
   - `lib/src/features/landing/presentation/landing_hero_summary_controller.dart`

4. Member report summary recalculates contributed capital by scanning `SUBMISSION` entries.
   File: `lib/src/features/reports/presentation/member/sections/member_summary_section.dart`

5. Staff report member balance models parse only `balance`, not the new wallet fields.
   File: `lib/src/features/reports/domain/staff_report_models.dart`

6. Existing labels are accounting-internal: `Submission`, `Withdraw`, `Distribution`.
   Member-facing UX needs clearer labels: `Funds Given`, `Funds Taken`, `Profit Added`, `Profit Reversed`.

7. `PnlWalletPage` currently shows aggregate investment P&L, not member profit wallet balances.
   File: `lib/src/features/investments/presentation/pnl_wallet.dart`

## Implementation Plan

### Phase 1: Domain Model Compatibility

Goal: Parse new backend fields without breaking old screens.

Update `lib/src/features/ledger/domain/member_ledger_statement.dart`:

- Add enum:
  - `LedgerWalletType.capital`
  - `LedgerWalletType.profit`
- Add fields to `MemberLedgerStatement`:
  - `givenAmount`
  - `takenAmount`
  - `capitalBalance`
  - `profitWalletBalance`
  - `totalAmount`
- Keep `currentBalance` for compatibility, but prefer `totalAmount` in UI.
- Add fields to `AdminLedgerStatement`:
  - `givenAmount`
  - `takenAmount`
  - `capitalBalance`
  - `profitWalletBalance`
  - `totalAmount`
- Add `walletType` to `MemberLedgerEntry`.
- Add `walletType` to `MemberLedgerFilter` so the UI can request `?wallet_type=CAPITAL|PROFIT`.
- Keep parsing fallbacks:
  - If `total_amount` is missing, fallback to `current_balance`.
  - If `capital_balance` is missing, fallback to old `current_balance`.
  - If `wallet_type` is missing, infer from `entry_type`.

Update `AdminLedgerPostRequest`:

- Add optional `walletType`.
- Only expose wallet choice in UI when `entryType == ADJUSTMENT`.
- Continue forcing `SUBMISSION` and `WITHDRAW` to capital wallet in the UI, matching backend behavior.

### Phase 2: Member Dashboard/Profile UX

Goal: Satisfy the four member widgets from `ux_change.md`.

Update `lib/src/features/ledger/presentation/total_balance_card.dart`:

- Replace single total card with compact wallet summary:
  - Capital Balance
  - Profit Wallet
  - Total Amount
  - Pending
- Use:
  - `statement.capitalBalance`
  - `statement.profitWalletBalance`
  - `statement.totalAmount`
  - `statement.pendingTotal`

Update `lib/src/features/profile/presentation/profile_page.dart`:

- Ensure it still uses `MemberLedgerRepository.statement`.
- Reuse the upgraded `TotalBalanceCard`.

Update member landing experience:

- For member role, add a small finance summary section under the hero or inside the hero:
  - `Capital`
  - `Profit Wallet`
  - `Total`
- Use `GET /api/ledger/`.
- Do not show admin association totals to members.

Recommended file changes:

- `lib/src/features/landing/presentation/landing_hero_summary_controller.dart`
- `lib/src/features/landing/presentation/landing_page.dart`

### Phase 3: Transaction History Labels and Filters

Goal: Make given/taken/profit streams explicit.

Update ledger labels:

| Backend type | Current label | New member-facing label |
|---|---|---|
| `SUBMISSION` | Submission | Funds Given |
| `WITHDRAW` | Withdraw | Funds Taken |
| `ADJUSTMENT` | Adjustment | Adjustment |
| `DISTRIBUTION` | Distribution | Profit Added |
| `DISTRIBUTION_REVERSAL` | Distribution Reversal | Profit Reversed |

Update:

- `MemberLedgerEntryType.label`
- `MemberReportEntryType.label`
- Ledger row icon/colour mappings where needed.

Add wallet filter:

- Ledger filter dropdown:
  - All Wallets
  - Capital Wallet
  - Profit Wallet
- Query param: `wallet_type=CAPITAL|PROFIT`

Files:

- `lib/src/features/ledger/presentation/member_ledger.dart`
- `lib/src/features/ledger/presentation/admin/admin_ledger_filters.dart`
- `lib/src/features/members/presentation/detail/member_stats_grid.dart`

### Phase 4: Admin Dashboard and Ratio Ledger

Goal: Provide accurate association capital and member ownership ratio.

Update `LandingHeroSummaryController`:

- Stop deriving capital from `totalIn - totalOut`.
- Prefer one of:
  - `GET /api/reports/association-summary/` using `capital.total_authorized`
  - or `GET /api/ledger/admin/` using `capital_balance`
- Recommended: use `StaffReportRepository.associationSummary()` for admin landing because it directly exposes association-level totals.

Update staff report models:

- `AssociationCapitalSummary`:
  - add `profitWalletTotal`
  - add `totalAmount`
- `StaffMemberBalancesReport`:
  - add `totalProfitWallet`
  - add `totalAmount`
- `StaffMemberBalance`:
  - add `capitalBalance`
  - add `profitWalletBalance`
  - add `totalAmount`

Update staff member balances UI:

- Add columns:
  - Capital
  - Profit Wallet
  - Total
  - Ownership Ratio
- Ownership ratio formula:
  - `capitalBalance / report.totalCapital * 100`
- Never use `profitWalletBalance` in ownership ratio.

Files:

- `lib/src/features/reports/domain/staff_report_models.dart`
- `lib/src/features/reports/presentation/staff/sections/association_summary_section.dart`
- `lib/src/features/reports/presentation/staff/sections/member_balances_section.dart`
- `lib/src/features/landing/presentation/landing_hero_summary_controller.dart`

### Phase 5: Profit Distribution Workflow

Goal: Keep the current project functional and avoid inventing unsupported backend behavior.

Decision:

Keep distribution investment-based.

Reason:

The backend already has a closed-investment distribution endpoint that:

- uses the frozen investment snapshot,
- distributes only after project close,
- writes to profit wallet,
- excludes profit from future capital ratios,
- supports reversal.

Do not build a standalone profit distribution trigger yet. The UX requirement can be satisfied by making the existing investment `Distribute P&L` action clearer.

Frontend changes:

- On closed investment cards, keep `Distribute P&L`.
- Before calling `POST /api/investments/{id}/distribute/`, show a confirmation sheet:
  - investment title,
  - invested amount,
  - return amount / P&L if available,
  - message: "This posts each member's share to their Profit Wallet. It will not be added to capital."
- After success:
  - refresh investments,
  - refresh ledger/report state where visible,
  - show success: "Profit/Loss distributed to Profit Wallets."

Files:

- `lib/src/features/investments/presentation/list/investment_page.dart`
- `lib/src/features/investments/presentation/list/investment_full_card.dart`
- `lib/src/features/investments/presentation/distribution_record.dart`

Optional later backend feature:

- Add a distribution preview endpoint.
- Until then, the frontend must not calculate final per-member distribution amounts.

### Phase 6: Reports and P&L Wallet Naming

Goal: Avoid confusing "investment P&L profile" with member profit wallet balances.

Current `PnlWalletPage` uses:

- `GET /api/reports/investment-pnl-profile/`

This endpoint reports finalized investment profit/loss, not wallet balances.

Plan:

- Rename the page title from `P&L Wallet` to `Investment P&L Summary`.
- If a true admin profit wallet view is needed, use:
  - `GET /api/reports/member-balances/`
  - show aggregate `total_profit_wallet` and per-member `profit_wallet_balance`.

Recommended minimal change:

- Keep route and file for compatibility.
- Change visible title/copy only.

### Phase 7: Backward Compatibility Rules

Do not break existing app flows while migrating.

1. Keep `currentBalance` in domain models.
2. Use new fields when present, fallback to old fields.
3. Keep old `balance` in `StaffMemberBalance`, but set it from `total_amount` when available.
4. Do not remove existing routes.
5. Do not change auth/permission guards.
6. Do not add standalone distribution screens until backend supports preview/post endpoints.

### Phase 8: Test Plan

Run after implementation:

```powershell
flutter analyze
flutter test
```

Manual checks:

1. Member login:
   - dashboard shows capital, profit wallet, total amount, pending.
   - transaction history labels show funds/profit wording.
   - filtering by capital/profit wallet works.

2. Admin login:
   - landing total association capital equals backend `capital.total_authorized`.
   - member balances report shows capital, profit wallet, total, ownership ratio.
   - ratio uses capital only.

3. Investment distribution:
   - create/open/close investment.
   - distribute P&L.
   - member profit wallet increases.
   - capital balance does not increase.
   - next investment snapshot ratio remains based on capital only.

4. Existing pages:
   - submissions load.
   - approvals load.
   - member details load.
   - staff reports load.
   - profile page loads.

## Suggested Work Order

1. Update ledger domain models and parsing fallbacks.
2. Update report domain models.
3. Update member balance/profile UI.
4. Update admin landing total capital source.
5. Update staff member balances with ownership ratio.
6. Update transaction labels and wallet filters.
7. Improve investment distribution confirmation copy.
8. Rename P&L wallet visible title to avoid semantic confusion.
9. Run analyzer/tests and manual role checks.

## Open Decisions

1. Should admin `ADJUSTMENT` allow profit-wallet adjustment in the UI now, or should it remain capital-only until a separate finance approval process exists?

Recommended answer: keep the UI capital-only for now unless profit correction is a confirmed admin workflow.

2. Should member dashboard use `/api/ledger/` or `/api/reports/my-statement/`?

Recommended answer: use `/api/ledger/` for dashboard/profile because it is already wired into profile and ledger screens.

3. Should admin landing use `/api/reports/association-summary/`?

Recommended answer: yes. It is more authoritative than deriving totals from admin ledger rows.
