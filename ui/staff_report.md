### UI Suggestions for Staff Report Endpoints

### 1. GET /api/reports/association-summary/

High-level financial snapshot of the entire association.

Response `200`:
```json
{
  "generated_at": "2024-08-15T10:00:00Z",
  "capital": {
    "total_authorized": "220000.00",
    "total_pending":     "15000.00",
    "total_invested":    "500000.00"
  },
  "members": {
    "total": 5, "active": 4, "inactive": 1
  },
  "investments": {
    "total": 3, "draft": 0, "open": 1,
    "closed": 0, "distributed": 1, "reversed": 1
  },
  "distributions": {
    "total_pnl_distributed": "34500.00"
  },
  "submissions": {
    "total": 12, "pending": 3, "approved": 8, "rejected": 1
  }
}
```

## Placement: The landing page of Admin > Reports. This is the first thing staff see when they open Reports.
## Layout suggestions:

## Top bar: A "Generated at: [timestamp]" label on the top-right with a manual Refresh button. Staff need to know they're looking at a point-in-time snapshot, not a live feed.

## KPI Card Row (primary): Four cards in a single horizontal row — Total Authorized Capital, Total Pending Capital, Total Invested Amount, Total P&L Distributed. These are the numbers that answer "how is the association doing right now" at a glance. Authorized and Pending capital should be visually distinguished — Pending in a muted/amber tone since it's unconfirmed money.

## Secondary stat row: Three smaller stat clusters below the KPI row — Members (Total / Active / Inactive), Investments (broken down by status: Draft, Open, Closed, Distributed, Reversed), Submissions (Pending / Approved / Rejected). These are operational health indicators, not financial figures, so they should be visually subordinate to the KPI row.

Investment status breakdown deserves a small horizontal pill-bar or mini status count chips rather than a table — because there are only a handful of statuses and the counts are small. A table would be overkill here.

## Quick-action links: Each stat cluster should have a subtle "View all →" link that navigates to the relevant dedicated report page (Member Balances, Investment Register, etc.). This turns the summary into a navigation hub, not just a read-only display.

No export button here — this is a summary snapshot, not tabular data. The export lives on the individual report pages.


### 2. GET /api/reports/member-balances/

Active members with current authorized balance.

Query params: `?status=ACTIVE|INACTIVE`  `?search=<name>`

Default: active members only. Pass `status=INACTIVE` for inactive-member audit
review.

Response `200`:
```json
{
  "total_capital": "220000.00",
  "member_count": 4,
  "members": [
    {
      "user_id": "uuid", "full_name": "Rahim Uddin",
      "contact_no": "01800000000", "email": "...",
      "join_date": "2024-01-15", "role": "MEMBER",
      "status": "ACTIVE", "balance": "72250.00"
    }
  ]
}
```

## Placement: Admin > Reports > Members — a dedicated full-page report, reachable from the Association Summary "View all →" link or directly from the Reports nav.
## Layout suggestions:

## Page header bar: Two elements — a Status filter toggle (Active / Inactive / All) and a Search box (searches by name). These are the only two query params so the filter surface should be minimal — no dropdowns, no date pickers. A toggle for status is cleaner than a dropdown here.

## Summary line: Directly below the filters, a single line: "Showing 4 active members — Total Capital: ৳2,20,000.00". This gives the sum of the filtered view so staff don't have to mentally add rows. Important: the total should update when the filter changes.

## Member balance table: Columns — Full Name, Contact, Join Date, Status (badge), Balance. Sort by Balance descending by default (largest contributors first — operationally most important). Every column should be sortable.

Balance column should be right-aligned and use monospace/tabular numerals so decimal points align vertically across rows.
Status badge — green pill for ACTIVE, grey for INACTIVE.
Row click navigates to that member's individual statement (the staff ledger view).


Inactive member audit note: When status=INACTIVE filter is active, show a subtle contextual banner: "Inactive members retain historical balances for audit purposes." This is a SRS rule (BR-05) and staff should be reminded of it in context.
No CSV export here — the individual member statement export handles per-member data. A bulk export of all balances is not defined in the endpoints, so don't invent a button for it.


### 3. GET /api/reports/investment-register/

All investments with financial summary.

Query params:
- `?status=DRAFT|OPEN|CLOSED|DISTRIBUTED|REVERSED`
- `?investment_type=FIXED_DEPOSIT|EQUITY|REAL_ESTATE|LENDING|OTHER`

Response `200`:
```json
{
  "investment_count": 2,
  "investments": [
    {
      "investment_id":   "uuid",
      "title":           "Padma Bank FDR",
      "investment_type": "FIXED_DEPOSIT",
      "invested_to":     "Padma Bank Ltd.",
      "invested_amount": "500000.00",
      "return_amount":   "534500.00",
      "pnl_amount":      "34500.00",
      "created_date":    "2024-07-01",
      "close_date":      "2024-07-31",
      "status":          "DISTRIBUTED",
      "member_count":    3,
      "created_by":      "Finance Manager",
      "fund_released_by": "Accounts Manager",
      "fund_released_at": "2024-07-01T10:05:00Z"
    }
  ]
}
```

## Placement: Admin > Reports > Investments — dedicated full-page report.
Layout suggestions:

## Filter bar: Two filters — Status (multi-select chips: Draft, Open, Closed, Distributed, Reversed) and Investment Type (multi-select: Fixed Deposit, Equity, Real Estate, Lending, Other). Show all by default. Chips are better than a dropdown here because staff often want to combine two statuses (e.g., Closed + Distributed) in one view.
## Summary line: "Showing 2 investments" — simple count, no total here since mixing statuses makes a sum misleading.
Investment table: Columns — Title, Type, Invested To, Invested Amount, Return Amount, P&L, Status, Members, Created By, Fund Released By, Date. That's a wide table — recommend making it horizontally scrollable rather than truncating columns, since all fields are relevant for an investment register.

P&L column is the most important derived figure — color-code it: green for profit (positive), red for loss (negative), neutral for zero.
Status badge with distinct colors: Draft (grey), Open (blue), Closed (amber), Distributed (green), Reversed (red/strikethrough feel).
Row click/expand — opens an investment detail drawer or navigates to the investment detail page showing snapshot lines and distribution info.


Fund Released By — this is a segregation-of-duties audit field. It should be visually distinct (perhaps a smaller secondary line under the Created By cell, not its own column) to avoid crowding but still be inspectable.
No CSV export defined for this endpoint — do not add one. If it becomes needed later, it needs a new streaming endpoint first.


### 4. GET /api/reports/distribution-logs/

All distributions with POSTED/REVERSED status.

Query params: `?status=POSTED|REVERSED`  `?investment_id=<uuid>`

Response `200`:
```json
{
  "distribution_count": 2,
  "distributions": [
    {
      "distribution_id":   "uuid",
      "investment_title":  "Padma Bank FDR",
      "pnl_amount":        "34500.00",
      "rounded_total":     "34500.00",
      "remainder_applied": "0.00",
      "status":            "POSTED",
      "posted_by":         "Finance Manager",
      "posted_at":         "2024-08-01T09:00:00Z",
      "reversed_by":       null,
      "reversed_at":       null,
      "member_count":      3
    }
  ]
}
```

## Placement: Admin > Reports > Distributions — dedicated full-page report.
Layout suggestions:

## Filter bar: Two filters — Status (Posted / Reversed toggle, both shown by default) and an Investment selector (a searchable dropdown listing investment titles, for filtering to a specific one). The investment_id query param maps directly to this.
## Summary line: "Showing 2 distributions — [N] Posted, [N] Reversed."
Distribution table: Columns — Investment Title, P&L Amount, Rounded Total, Remainder Applied, Status, Posted By, Posted At, Reversed By, Reversed At, Members.

## Status badge: Posted (green), Reversed (red with a strikethrough visual cue). Reversed rows should have a slightly muted/grey row background to signal they are nullified — staff should immediately sense that a reversed row has no current financial effect.
## Remainder Applied column: This is a small but auditor-critical field. Show it, but it will often be "0.00". When it's non-zero, consider a subtle highlight so auditors notice the rounding remainder was applied.
Reversed By / Reversed At cells: Show a dash "—" when null (not empty, not blank). This is cleaner than empty cells in a financial table.


## Row expand: Clicking a distribution row should expand it inline to show the per-member breakdown — member name, ratio used, share amount, and the linked ledger entry ID. This is the distribution line data. It should NOT navigate away from the page; an expandable row keeps the list context intact.
POSTED → REVERSED visual pairing: If a reversal exists for a distribution, consider visually pairing them — the REVERSED row should appear directly below its parent POSTED row (not sorted separately), with a subtle indented or connected visual. This helps staff understand the compensating entry relationship at a glance.


### 5. GET /api/reports/approval-queue-report/

All pending submission requests summarised by payment channel.

Response `200`:
```json
{
  "total_pending_amount": "15000.00",
  "total_pending_count":  3,
  "by_channel": {
    "BKASH":     { "count": 2, "total_amount": "10000.00" },
    "HAND_CASH": { "count": 1, "total_amount":  "5000.00" }
  },
  "items": [
    {
      "request_id":        "uuid",
      "member_name":       "Karim Miah",
      "member_contact":    "01900000000",
      "request_type":      "INSTALLMENT",
      "amount":            "5000.00",
      "txn_date":          "2024-08-10",
      "payment_channel":   "BKASH",
      "external_reference": "TXN987654321",
      "notes":             "",
      "requested_at":      "2024-08-10T08:00:00Z",
      "attachment_count":  1
    }
  ]
}
```

## Placement and framing: This endpoint is a reporting view of the queue, not the action surface. The actual approve/reject actions live in the Submissions module. In the UI, this report should live in Admin > Reports > Pending Submissions — it gives staff a financial overview of what's waiting, not a workflow interface.
However, the nav item for this should also appear prominently as "Approval Queue" in the main staff navigation with a badge count showing total_pending_count — because this is operationally time-sensitive. Staff need to see pending count without navigating to Reports.
## Layout suggestions:

## Top summary bar: Three prominent numbers — Total Pending Count, Total Pending Amount, and a channel breakdown displayed as a small horizontal stat row (e.g., "bKash: 2 items — ৳10,000 | Hand Cash: 1 item — ৳5,000"). The by_channel object maps directly to this. This gives the approver a financial picture before they start reviewing individual items.

The channel breakdown is operationally meaningful — bKash items can be verified against a reference ID, while Hand Cash items require physical confirmation. Grouping them visually helps the approver mentally triage.


## Pending items table: Columns — Member Name, Contact, Type (badge: Installment/Submission), Amount, Txn Date, Channel (badge), Reference ID, Notes, Attachments, Requested At.

## Channel badge: Distinct color per channel (e.g., pink for bKash, grey for Hand Cash, blue for Bank) — since verification steps differ per channel, this visual distinction is operationally important.
Attachment count: Show as a small paperclip icon with a count number. Clicking it should open the attachment inline (signed URL fetch) — not navigate away. An approver needs to see the payment slip without losing their place in the queue.
Reference ID: If present, show it as a monospace string (looks like a transaction ID). If absent, show "—". A missing reference on a bKash payment is a red flag — staff should notice it.
Notes field: Truncate to one line with a "..." expand — notes can be long but the table shouldn't break for them.


"Go to Action Queue →" link: Since this is a reporting view and not where approvals happen, place a clear contextual link at the top: "To approve or reject, go to the Submission Approval Queue →". This prevents staff from being confused about why there are no action buttons on this report page.
No export defined for this endpoint — do not add a CSV button. The data is time-sensitive and ephemeral; exporting a pending queue snapshot has limited practical value and the endpoint doesn't support it.


### Cross-Cutting UI Patterns for All Staff Reports

Permission gate display: If a staff member lacks VIEW_ALL_REPORTS, don't render report menu items at all — don't grey them out, don't show a lock icon, just don't show them. The nav should reflect exactly what the user can do.
"Generated at" timestamp: Every report page should show when the data was fetched. Staff making financial decisions need to know data freshness. A subtle timestamp in the top-right corner of each report page is sufficient.
Bengali currency formatting: Per NFR-05, all monetary amounts should render in BDT format (৳) with comma separators in the Bengali style (e.g., ৳2,20,000.00 not ৳220,000.00). Apply this consistently across all report tables.
Empty states: Every report table needs a thoughtful empty state — "No investments match the selected filters" is more useful than a blank table. For the approval queue specifically, an empty state ("No pending submissions — all caught up") is actually a positive signal and should be framed as such.
Back navigation: All detail views (member ledger, investment detail, distribution expand) should have a clear back path to the report list. Staff frequently drill down and back up across these pages.