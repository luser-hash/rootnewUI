# Large File Refactor Task List

Source plan: `docs/large_file_refactor_plan.md`

Goal: shorten large presentation files and remove repeated UI code without changing feature behavior, routes, API calls, or controller logic.

## Working Rules

- [ ] Keep each task behavior-preserving unless it explicitly says otherwise.
- [ ] Run `flutter analyze` after each extraction batch.
- [ ] Do not mix UI extraction with backend/API behavior changes.
- [ ] Prefer moving existing private widgets with the same constructor shape before redesigning shared APIs.
- [ ] Replace duplicated widgets gradually, one feature area at a time.

## Phase 1 - Shared Formatting Foundation

### Tasks

- [x] Update `lib/src/features/shared/utils/finance_formatters.dart`.
- [x] Add `formatMoneySigned(num value)`.
- [x] Add `formatMoneyUnsigned(num value)`.
- [x] Add `formatMoneyCompactSigned(num value)`.
- [x] Preserve minus signs for negative values.
- [x] Keep existing `fmt` and `fmtSh` temporarily as compatibility wrappers if many call sites still use them.
- [x] Add `lib/src/features/shared/utils/date_formatters.dart`.
- [x] Add `formatDateTimeShort(DateTime? value)`.
- [x] Add `lib/src/features/shared/utils/text_formatters.dart`.
- [x] Add `valueOrDash(String? value)`.
- [x] Add `prettyEnumLabel(String value)`.
- [x] Export new helper files from `lib/src/features/shared/finance.dart` or a new shared barrel if appropriate.

### First Replacement Targets

- [x] Replace `_money` in `reports/presentation/member_report.dart`.
- [x] Replace `_money` in `reports/presentation/staff_report.dart`.
- [x] Replace `_money` in `investments/presentation/distribution_record.dart`.
- [x] Replace `_formatDateTime` in `submission_detail_page.dart`.
- [x] Replace `_formatDateTime` in `member_detail_screen.dart`.
- [x] Replace `_formatDateTime` in `ledger_page.dart`.
- [x] Replace `_valueOrDash` in `member_detail_screen.dart`.
- [x] Replace `_valueOrDash` in `profile_page.dart`.
- [x] Replace `_valueOrDash` in `staff_report.dart`.

### Acceptance Checks

- [x] Negative values render with `-`.
- [x] Existing screens compile without changing visible business behavior.
- [x] `flutter analyze` passes or only reports unrelated pre-existing issues.

## Phase 2 - Shared Message Cards

### New Files

- [x] Add `lib/src/features/shared/widgets/app_message_card.dart`.

### New Widgets

- [x] Add `AppMessageTone`.
- [x] Add `AppMessageCard`.
- [x] Support info, success, warning, error, and neutral tones.
- [x] Support compact and regular layout.
- [x] Support optional title.
- [x] Support optional icon override.

### Replacement Targets

- [x] Replace `_MessageCard` in `submissions/presentation/submissions_page.dart`.
- [x] Replace `_MessageCard` in `submissions/presentation/submission_detail_page.dart`.
- [x] Replace `_SubmissionMessage` in `submissions/presentation/submit_funds_page.dart`.
- [x] Replace `_InvestmentMessage` in `investments/presentation/investment_page.dart`.
- [x] Replace `_InvestmentMessage` in `investments/presentation/investment_detail_page.dart`.
- [x] Replace `_MessageCard` in `investments/presentation/distribution_record.dart`.
- [x] Replace `_MemberMessage` in `members/presentation/manage_members.dart`.
- [x] Replace `_EditMemberMessage` in `members/presentation/edit_member.dart`.
- [x] Replace `_ProfileMessage` in `profile/presentation/profile_page.dart`.
- [x] Replace `_InlineMessage` and `_ReportMessage` in report pages after simpler pages are stable.

### Acceptance Checks

- [x] Empty/loading/error states look equivalent or intentionally more consistent.
- [x] No controller state changes.
- [x] `flutter analyze` reports only unrelated existing issues.

## Phase 3 - Shared Detail Rows And Blocks

### New Files

- [x] Add `lib/src/features/shared/widgets/app_detail_row.dart`.
- [x] Add `lib/src/features/shared/widgets/app_detail_block.dart`.

### New Widgets

- [x] Add `AppDetailRow`.
- [x] Add `AppDetailBlock`.
- [x] Support optional icon.
- [x] Support optional color.
- [x] Support monospace value.
- [x] Support max lines and overflow where needed.

### Replacement Targets

- [x] Replace `_DetailLine` in `submissions/presentation/submission_detail_page.dart`.
- [x] Replace `_DetailLine` in `submissions/presentation/submissions_page.dart`.
- [x] Replace `_DetailRow` in `investments/presentation/investment_detail_page.dart`.
- [x] Replace `_TextBlock` in `investments/presentation/investment_detail_page.dart`.
- [x] Replace `_InfoBox` and `_TextBlock` in `investments/presentation/distribution_record.dart`.
- [x] Replace `_AccountInfoRow` in `members/presentation/member_detail_screen.dart`.
- [x] Replace `_ProfileInfoRow` in `profile/presentation/profile_page.dart`.
- [x] Replace `_DetailBox` and `_DetailTextBlock` in `approvals/presentation/approval_page.dart`.
- [x] Replace `_DetailBox` and `_DetailTextBlock` in `ledger/presentation/ledger_page.dart`.

### Acceptance Checks

- [x] Detail screens keep same data order.
- [x] Long text still truncates or wraps correctly.
- [x] `flutter analyze` reports only unrelated existing issues.

## Phase 4 - Status Pills

### Existing File To Improve

- [ ] Update `lib/src/features/shared/widgets/status_pills.dart`.

### Tasks

- [ ] Add generic `AppStatusPill`.
- [ ] Keep existing typed wrappers: `SubmissionStatusPill`, `InvestmentStatusPill`, `MemberStatusPill`.
- [ ] Add `strike` support for reversed report/distribution statuses.
- [ ] Add one generic color mapping helper only if it does not duplicate domain logic.

### Replacement Targets

- [ ] Replace `_SubmissionStatusPill` in `submissions/presentation/submissions_page.dart`.
- [ ] Replace `_SubmissionStatusPill` in `members/presentation/member_detail_screen.dart`.
- [ ] Replace `_StatusPill` in `reports/presentation/staff_report.dart`.
- [ ] Replace local investment status pill/card coloring where a typed wrapper already exists.

### Acceptance Checks

- [ ] Status labels and colors stay consistent.
- [ ] Existing typed wrappers continue working.
- [ ] `flutter analyze` passes.

## Phase 5 - Shared Form Fields

### New Files

- [ ] Add `lib/src/features/shared/widgets/app_form_fields.dart`.

### New Widgets

- [ ] Add `AppTextFormField`.
- [ ] Add `AppPasswordField`.
- [ ] Add `AppDateField`.
- [ ] Add `AppDropdownField<T>`.
- [ ] Add `AppSectionLabel`.

### Replacement Targets

- [ ] Replace `_AppTextField`, `_PasswordField`, `_JoinDateField`, and `_ReadOnlyRoleField` in `members/presentation/manage_members.dart`.
- [ ] Replace `_EditTextField`, `_JoinDateField`, `_RoleField`, and `_StatusField` in `members/presentation/edit_member.dart`.
- [ ] Replace `_SubmissionTextField` and `_DateField` in `submissions/presentation/submit_funds_page.dart`.
- [ ] Replace `_InvestmentTextField` and `_DateField` in `investments/presentation/investment_create_page.dart`.
- [ ] Replace `_LoginTextField` in `auth/presentation/login_page.dart`.
- [ ] Replace `_PasswordTextField` in `profile/presentation/profile_page.dart`.

### Acceptance Checks

- [ ] Form validation behavior is unchanged.
- [ ] Keyboard types, obscure text behavior, icons, and date picker behavior are preserved.
- [ ] `flutter analyze` passes.

## Phase 6 - Shared Screen Headers

### New Files

- [ ] Add `lib/src/features/shared/widgets/app_screen_header.dart`.

### New Widgets

- [ ] Add `AppScreenHeader`.
- [ ] Add `AppScreenHeaderVariant` if needed.
- [ ] Support title, subtitle, icon, actions, and optional trailing metadata.

### Replacement Targets

- [ ] Replace `_SubmitFundsHeader`.
- [ ] Replace `_InvestmentCreateHeader`.
- [ ] Replace `_InvestmentsHeader`.
- [ ] Replace `_MembersHeader`.
- [ ] Replace `_ManageMembersHeader`.
- [ ] Replace `_EditMemberHeader`.
- [ ] Replace `_ProfileHeader`.
- [ ] Replace `_MemberLedgerHeader`.
- [ ] Replace `_LedgerHeader`.
- [ ] Replace `_ApprovalHeader`.
- [ ] Evaluate `_ReportHeader` and `_ReportHero`; keep custom if materially different.

### Acceptance Checks

- [ ] Page titles, subtitles, and actions remain visible.
- [ ] Mobile layout does not overflow.
- [ ] `flutter analyze` passes.

## Phase 7 - Shared Panels, Cards, And Metrics

### New Files

- [ ] Add `lib/src/features/shared/widgets/app_panel.dart`.
- [ ] Add `lib/src/features/shared/widgets/app_metric_card.dart`.

### New Widgets

- [ ] Add `AppPanel`.
- [ ] Add `AppMetricCard`.
- [ ] Add `AppMoneyMetricCard`.
- [ ] Add `AppSection`.

### Replacement Targets

- [ ] Replace `_ReportPanel` in `reports/presentation/staff_report.dart`.
- [ ] Replace `_SummaryCard` in `reports/presentation/member_report.dart`.
- [ ] Replace `_StatCard` in `members/presentation/member_detail_screen.dart`.
- [ ] Replace `_MoneyBox` in `investments/presentation/investment_page.dart`.
- [ ] Replace `_MoneyBox` in `investments/presentation/investment_detail_page.dart`.
- [ ] Replace `_SmallMetric` and `_KpiCard` in `reports/presentation/staff_report.dart`.

### Acceptance Checks

- [ ] Visual spacing remains consistent.
- [ ] Cards do not nest unnecessarily.
- [ ] `flutter analyze` passes.

## Phase 8 - Shared Table Widgets

### New Files

- [ ] Add `lib/src/features/shared/widgets/app_data_table.dart`.

### New Widgets

- [ ] Add `AppTableHeader`.
- [ ] Add `AppTableRow`.
- [ ] Add `AppHeaderCell`.
- [ ] Add `AppTextCell`.
- [ ] Add `AppMoneyCell`.
- [ ] Add `AppSortableHeaderCell`.

### Replacement Targets

- [ ] Replace table widgets in `reports/presentation/staff_report.dart`.
- [ ] Replace transaction table widgets in `reports/presentation/member_report.dart`.
- [ ] Replace ledger row/cell pieces in `ledger/presentation/ledger_page.dart`.
- [ ] Replace member ledger row/cell pieces in `ledger/presentation/member_ledger.dart`.

### Acceptance Checks

- [ ] Horizontal scrolling still works where required.
- [ ] Sorting headers still trigger the same callbacks.
- [ ] Money columns remain right-aligned.
- [ ] `flutter analyze` passes.

## Phase 9 - Split P0 Large Files

### `staff_report.dart`

- [ ] Create `features/reports/presentation/staff/staff_report_page.dart`.
- [ ] Create `features/reports/presentation/staff/staff_report_controller.dart` only if state extraction is needed.
- [ ] Create `features/reports/presentation/staff/sections/association_summary_section.dart`.
- [ ] Create `features/reports/presentation/staff/sections/member_balances_section.dart`.
- [ ] Create `features/reports/presentation/staff/sections/investment_register_section.dart`.
- [ ] Create `features/reports/presentation/staff/sections/distribution_logs_section.dart`.
- [ ] Create `features/reports/presentation/staff/sections/approval_queue_section.dart`.
- [ ] Create `features/reports/presentation/staff/widgets/report_section_tabs.dart`.
- [ ] Create `features/reports/presentation/staff/widgets/report_timestamp_bar.dart`.
- [ ] Keep a temporary `staff_report.dart` export or adapter if route imports need compatibility.

### `member_detail_screen.dart`

- [ ] Create `features/members/presentation/detail/member_detail_screen.dart`.
- [ ] Create `features/members/presentation/detail/member_detail_header.dart`.
- [ ] Create `features/members/presentation/detail/account_details_card.dart`.
- [ ] Create `features/members/presentation/detail/member_stats_grid.dart`.
- [ ] Create `features/members/presentation/detail/submission_history_section.dart`.
- [ ] Create `features/members/presentation/detail/member_ledger_section.dart`.
- [ ] Keep existing controllers unchanged during the first split.

### `ledger_page.dart`

- [ ] Create `features/ledger/presentation/admin/admin_ledger_page.dart`.
- [ ] Create `features/ledger/presentation/admin/admin_ledger_filters.dart`.
- [ ] Create `features/ledger/presentation/admin/admin_ledger_post_sheet.dart`.
- [ ] Create `features/ledger/presentation/admin/admin_ledger_row.dart`.
- [ ] Create `features/ledger/presentation/admin/admin_ledger_header.dart`.
- [ ] Do not replace demo/admin ledger data behavior during this split.

### `approval_page.dart`

- [ ] Create `features/approvals/presentation/widgets/approval_header.dart`.
- [ ] Create `features/approvals/presentation/widgets/payment_channel_filter.dart`.
- [ ] Create `features/approvals/presentation/widgets/pending_submission_list.dart`.
- [ ] Create `features/approvals/presentation/widgets/submission_review_card.dart`.
- [ ] Create `features/approvals/presentation/widgets/reviewed_submission_list.dart`.
- [ ] Create `features/approvals/presentation/widgets/rejection_reason_dialog.dart`.
- [ ] Create `features/approvals/presentation/widgets/approval_success_overlay.dart`.
- [ ] Keep `ApprovalPage` state and controller unchanged during first split.

### Acceptance Checks

- [ ] Existing import paths are updated or compatibility exports exist.
- [ ] No route paths change.
- [ ] No controller behavior changes.
- [ ] `flutter analyze` passes.

## Phase 10 - Split P1 Large Files

### `landing_page.dart`

- [ ] Create `features/landing/presentation/widgets/home_status_bar.dart`.
- [ ] Create `features/landing/presentation/widgets/home_hero.dart`.
- [ ] Create `features/landing/presentation/widgets/quick_action_grid.dart`.
- [ ] Create `features/landing/presentation/widgets/members_carousel.dart`.
- [ ] Create `features/landing/presentation/widgets/recent_activity_section.dart`.
- [ ] Move quick action building to a policy/helper only after visual extraction is stable.

### `member_report.dart`

- [ ] Create `features/reports/presentation/member/member_report_page.dart`.
- [ ] Create `features/reports/presentation/member/sections/member_summary_section.dart`.
- [ ] Create `features/reports/presentation/member/sections/transaction_panel.dart`.
- [ ] Create `features/reports/presentation/member/sections/pending_requests_panel.dart`.
- [ ] Create `features/reports/presentation/member/sections/distributions_panel.dart`.
- [ ] Keep old `member_report.dart` as adapter/export if needed.

### `investment_page.dart`

- [ ] Create `features/investments/presentation/list/investment_page.dart`.
- [ ] Create `features/investments/presentation/list/investments_header.dart`.
- [ ] Create `features/investments/presentation/list/investment_full_card.dart`.
- [ ] Create `features/investments/presentation/list/close_investment_sheet.dart`.
- [ ] Keep investment controller behavior unchanged.

### Acceptance Checks

- [ ] Home, member report, and investment routes still resolve.
- [ ] Existing callbacks still fire.
- [ ] `flutter analyze` passes.

## Phase 11 - Tests

### Unit Tests

- [ ] Add tests for signed money formatting.
- [ ] Add tests for unsigned money formatting.
- [ ] Add tests for compact money formatting.
- [ ] Add tests for `valueOrDash`.
- [ ] Add tests for `prettyEnumLabel`.
- [ ] Add tests for date formatting null behavior.

### Widget Tests

- [ ] Add smoke test for `AppMessageCard`.
- [ ] Add smoke test for `AppDetailRow`.
- [ ] Add smoke test for `AppStatusPill`.
- [ ] Add smoke test for shared form fields.
- [ ] Add smoke test for shared table widgets.

### Manual Verification

- [ ] Login page renders.
- [ ] Home renders.
- [ ] Submit funds form renders.
- [ ] Approvals render and action dialogs open.
- [ ] Member list renders.
- [ ] Member detail renders.
- [ ] Admin ledger renders.
- [ ] Member ledger renders.
- [ ] Investment list renders.
- [ ] Staff report renders.
- [ ] Member report renders.

## Phase 12 - Cleanup

- [ ] Remove old private widgets after their call sites are fully migrated.
- [ ] Remove duplicate local formatter helpers.
- [ ] Remove unused imports.
- [ ] Run `dart format .`.
- [ ] Run `flutter analyze`.
- [ ] Update `docs/large_file_refactor_plan.md` with completed decisions if APIs changed.
- [ ] Update chunk analysis docs if final structure differs from the proposed structure.

## Suggested Implementation Batches

### Batch A - Lowest Risk

- [ ] Shared formatters.
- [ ] Shared message card.
- [ ] Replace message cards in submissions and investments.

### Batch B - Medium Risk

- [ ] Shared detail rows/blocks.
- [ ] Shared status pills.
- [ ] Replace detail/status widgets in submissions, investments, profile, and members.

### Batch C - Form Cleanup

- [ ] Shared form fields.
- [ ] Migrate manage/edit member forms.
- [ ] Migrate submit funds and investment create forms.
- [ ] Migrate login/profile password fields.

### Batch D - Reports And Tables

- [ ] Shared panel/metric cards.
- [ ] Shared data table widgets.
- [ ] Migrate staff report.
- [ ] Migrate member report.

### Batch E - File Splitting

- [ ] Split P0 large files.
- [ ] Split P1 large files.
- [ ] Remove adapter exports only after imports are stable.
