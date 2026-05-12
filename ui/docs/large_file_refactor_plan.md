# Large File Refactor And Shared UI Improvement Plan

This document focuses on reducing large Flutter files and removing repeated UI code without changing behavior. The safest approach is incremental extraction: move repeated leaf widgets and pure helpers first, then split large screens into section files.

## Current Hotspots

These files are the highest priority because they combine page orchestration, async state, formatting, layout, and many private widgets in one file.

| Priority | File | Size | Main Problem |
| --- | --- | ---: | --- |
| P0 | `lib/src/features/reports/presentation/staff_report.dart` | 58 KB | Multiple report sections, local tables, local formatting, local reusable widgets |
| P0 | `lib/src/features/members/presentation/member_detail_screen.dart` | 45 KB | Profile, stats, submission history, ledger preview, detail widgets in one file |
| P0 | `lib/src/features/ledger/presentation/ledger_page.dart` | 41 KB | Admin ledger, filters, post sheet, row rendering, detail widgets in one file |
| P0 | `lib/src/features/approvals/presentation/approval_page.dart` | 38 KB | Queue page, cards, dialogs, reviewed list, detail blocks, success overlay |
| P1 | `lib/src/features/landing/presentation/landing_page.dart` | 35 KB | Dashboard sections, quick actions, carousel, recent activity, repeated cards |
| P1 | `lib/src/features/reports/presentation/member_report.dart` | 33 KB | Report header, summary cards, transaction table, filters, repeated messages |
| P1 | `lib/src/features/investments/presentation/investment_page.dart` | 28 KB | List, full card, close sheet, money boxes, messages |
| P2 | `edit_member.dart`, `profile_page.dart`, `member_ledger.dart`, `distribution_record.dart`, `manage_members.dart`, `login_page.dart`, `investment_create_page.dart` | 15-21 KB | Repeated form fields, headers, date buttons, message cards |

## Repeated Patterns To Extract

### 1. Message, Empty, Error, And Info Cards

Repeated private widgets:

- `_MessageCard`
- `_QueueMessageCard`
- `_InlineMessage`
- `_ReportMessage`
- `_SubmissionInfoMessage`
- `_LedgerInfoMessage`
- `_AccountInfoMessage`
- `_InvestmentMessage`
- `_MemberMessage`
- `_LoginErrorMessage`

Create:

```text
lib/src/features/shared/widgets/app_message_card.dart
```

Suggested API:

```dart
class AppMessageCard extends StatelessWidget {
  const AppMessageCard({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.tone = AppMessageTone.info,
    this.compact = false,
  });
}
```

Why this is safe:

- These widgets are mostly visual wrappers.
- Extraction does not change controller state or data flow.
- Existing private widgets can be replaced one file at a time.

### 2. Detail Rows And Label/Value Blocks

Repeated private widgets:

- `_DetailLine`
- `_DetailRow`
- `_DetailBox`
- `_DetailTextBlock`
- `_AccountInfoRow`
- `_ProfileInfoRow`
- `_ReferenceLine`
- `_ReferenceBlock`
- `_TextBlock`
- `_InfoBox`

Create:

```text
lib/src/features/shared/widgets/app_detail_row.dart
lib/src/features/shared/widgets/app_detail_block.dart
```

Suggested APIs:

```dart
class AppDetailRow extends StatelessWidget {
  const AppDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.monospace = false,
  });
}

class AppDetailBlock extends StatelessWidget {
  const AppDetailBlock({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.background,
  });
}
```

Best first targets:

- `submission_detail_page.dart`
- `investment_detail_page.dart`
- `distribution_record.dart`
- `approval_page.dart`
- `member_detail_screen.dart`
- `ledger_page.dart`

### 3. Status Pills

There is already `shared/widgets/status_pills.dart`, but large pages still define private status pills.

Repeated private widgets:

- `_StatusPill` in `staff_report.dart`
- `_SubmissionStatusPill` in `submissions_page.dart`
- `_SubmissionStatusPill` in `member_detail_screen.dart`
- local status coloring in investments, reports, ledger

Improve existing shared widgets:

```text
lib/src/features/shared/widgets/status_pills.dart
```

Add a generic pill:

```dart
class AppStatusPill extends StatelessWidget {
  const AppStatusPill({
    super.key,
    required this.label,
    required this.color,
    this.strike = false,
  });
}
```

Keep typed wrappers:

- `SubmissionStatusPill`
- `InvestmentStatusPill`
- `MemberStatusPill`
- add report/ledger wrappers only if statuses become stable domain enums.

### 4. Money, Date, Pretty Text, And Empty Value Formatting

Repeated local helpers:

- `_money`
- `_formatDateTime`
- `_valueOrDash`
- `_pretty`
- `_prettyType`

Create:

```text
lib/src/features/shared/utils/date_formatters.dart
lib/src/features/shared/utils/text_formatters.dart
```

Update:

```text
lib/src/features/shared/utils/finance_formatters.dart
```

Important fix:

- `fmt()` and `fmtSh()` currently call `abs()`, so negative money loses its minus sign.
- Add signed and unsigned variants instead of relying on color alone.

Suggested functions:

```dart
String formatMoneySigned(num value);
String formatMoneyUnsigned(num value);
String formatMoneyCompactSigned(num value);
String formatDateTimeShort(DateTime? value);
String valueOrDash(String? value);
String prettyEnumLabel(String value);
```

### 5. Tables And Table Cells

Repeated private widgets:

- `_TableHeader`
- `_TableRow`
- `_HeaderText`
- `_SortableHeader`
- `_Cell`
- `_MoneyCell`
- transaction table headers/rows in member report
- report table rows in staff report

Create:

```text
lib/src/features/shared/widgets/app_data_table.dart
```

Suggested widgets:

- `AppTableHeader`
- `AppTableRow`
- `AppHeaderCell`
- `AppTextCell`
- `AppMoneyCell`
- `AppSortableHeaderCell`

Where to apply first:

- `staff_report.dart`
- `member_report.dart`
- `ledger_page.dart`
- `member_ledger.dart`

Do this after formatter extraction, because table cells should use shared money/date helpers.

### 6. Form Fields, Date Pickers, Dropdowns

Repeated private widgets:

- `_LoginTextField`
- `_SubmissionTextField`
- `_InvestmentTextField`
- `_AppTextField`
- `_EditTextField`
- `_PasswordTextField`
- `_DateField`
- `_JoinDateField`
- `_RoleField`
- `_StatusField`

Create:

```text
lib/src/features/shared/widgets/app_form_fields.dart
```

Suggested widgets:

- `AppTextFormField`
- `AppPasswordField`
- `AppDateField`
- `AppDropdownField<T>`
- `AppSectionLabel`

Best first targets:

- `manage_members.dart`
- `edit_member.dart`
- `submit_funds_page.dart`
- `investment_create_page.dart`
- `login_page.dart`
- `profile_page.dart`

### 7. Screen Headers

Repeated private widgets:

- `_ApprovalHeader`
- `_InvestmentsHeader`
- `_InvestmentCreateHeader`
- `_SubmitFundsHeader`
- `_MembersHeader`
- `_ManageMembersHeader`
- `_EditMemberHeader`
- `_ProfileHeader`
- `_MemberLedgerHeader`
- `_LedgerHeader`
- `_ReportHeader`
- `_ReportHero`

Create:

```text
lib/src/features/shared/widgets/app_screen_header.dart
```

Suggested API:

```dart
class AppScreenHeader extends StatelessWidget {
  const AppScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actions = const <Widget>[],
    this.variant = AppScreenHeaderVariant.standard,
  });
}
```

Keep feature-specific headers only when the layout is genuinely unique.

### 8. Section Panels And Cards

Existing:

- `AppCardList`

Repeated local containers:

- `_ReportPanel`
- `_SummaryCard`
- `_StatCard`
- `_MoneyBox`
- `_SmallMetric`
- `_KpiCard`
- card-like detail/list panels across ledger, reports, members, investments

Create:

```text
lib/src/features/shared/widgets/app_panel.dart
lib/src/features/shared/widgets/app_metric_card.dart
```

Suggested widgets:

- `AppPanel`
- `AppMetricCard`
- `AppMoneyMetricCard`
- `AppSection`

## Large File Split Plan

### P0: `staff_report.dart`

Target structure:

```text
features/reports/presentation/staff/
  staff_report_page.dart
  staff_report_controller.dart
  sections/
    association_summary_section.dart
    member_balances_section.dart
    investment_register_section.dart
    distribution_logs_section.dart
    approval_queue_section.dart
  widgets/
    report_section_tabs.dart
    report_timestamp_bar.dart
```

First safe extraction:

- Move `_ReportPanel`, `_ReportMessage`, `_InlineMessage`, `_StatusPill`, table widgets, and formatter helpers to shared files.
- Then move each section builder into its own section widget.

### P0: `member_detail_screen.dart`

Target structure:

```text
features/members/presentation/detail/
  member_detail_screen.dart
  member_detail_header.dart
  account_details_card.dart
  member_stats_grid.dart
  submission_history_section.dart
  member_ledger_section.dart
  member_detail_widgets.dart
```

First safe extraction:

- Extract account detail rows, stat cards, submission history rows, ledger rows, and message widgets.
- Keep existing controllers unchanged during the first pass.

### P0: `ledger_page.dart`

Target structure:

```text
features/ledger/presentation/admin/
  admin_ledger_page.dart
  admin_ledger_filters.dart
  admin_ledger_post_sheet.dart
  admin_ledger_row.dart
  admin_ledger_header.dart
```

First safe extraction:

- Extract date filter button, message card, detail block, ledger row, and post sheet.
- Do not change backend/demo data behavior in the same PR as UI extraction.

### P0: `approval_page.dart`

Target structure:

```text
features/approvals/presentation/
  approval_page.dart
  widgets/
    approval_header.dart
    payment_channel_filter.dart
    pending_submission_list.dart
    submission_review_card.dart
    reviewed_submission_list.dart
    rejection_reason_dialog.dart
    approval_success_overlay.dart
```

First safe extraction:

- Move private widgets into `widgets/` with the same constructor parameters.
- Keep `ApprovalPage` state and controller untouched.

### P1: `landing_page.dart`

Target structure:

```text
features/landing/presentation/
  landing_page.dart
  widgets/
    home_status_bar.dart
    home_hero.dart
    quick_action_grid.dart
    members_carousel.dart
    recent_activity_section.dart
```

First safe extraction:

- Extract `_MembersCarousel`, `_RecentActivitySection`, `_TransactionRow`, `_Section`, and `_HeroIconButton`.
- Move quick action building to a small policy/helper later.

### P1: `member_report.dart`

Target structure:

```text
features/reports/presentation/member/
  member_report_page.dart
  sections/
    member_summary_section.dart
    transaction_panel.dart
    pending_requests_panel.dart
    distributions_panel.dart
  widgets/
```

First safe extraction:

- Reuse shared table cells, message cards, date buttons, and money formatting.

## Recommended Implementation Order

1. Add shared formatter helpers and tests.
2. Add `AppMessageCard`, then replace local message widgets in 2-3 files.
3. Add `AppDetailRow` and `AppDetailBlock`, then replace detail widgets in detail pages.
4. Add generic `AppStatusPill`, then remove duplicate private status pills.
5. Add shared form fields and migrate create/edit/login forms gradually.
6. Add shared table widgets and migrate reports/ledger.
7. Split the largest files into feature-local `widgets/` and `sections/` files.

## Safety Rules

- Do not change data loading, mutation, route behavior, or controller logic while extracting widgets.
- Start by moving private widgets with identical constructor parameters.
- After each extraction, run:

```powershell
flutter analyze
```

- For risky pages, also run the app and manually verify:
  - login
  - home
  - approvals
  - member detail
  - ledger
  - reports

## Suggested Pull Request Breakdown

### PR 1: Shared Formatters

- Add signed money/date/text helpers.
- Update only low-risk call sites.
- Add unit tests.

### PR 2: Shared Message And Detail Widgets

- Add `AppMessageCard`, `AppDetailRow`, `AppDetailBlock`.
- Replace repeated local widgets in submissions, investments, profile, and members.

### PR 3: Shared Form Fields

- Add common text/password/date/dropdown fields.
- Migrate manage member, edit member, submit funds, investment create, login.

### PR 4: Shared Table Widgets

- Add table header/row/cell widgets.
- Migrate report tables first, ledger second.

### PR 5: Split P0 Large Files

- Split `staff_report.dart`, `member_detail_screen.dart`, `ledger_page.dart`, and `approval_page.dart`.
- Keep behavior unchanged.

## Expected Result

- Large page files become orchestration files instead of widget dumps.
- Shared visual behavior becomes consistent across features.
- Formatters become reliable for finance data.
- Future feature changes become safer because table, card, status, form, and message behavior live in one place.
