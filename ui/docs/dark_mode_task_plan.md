# Dark Mode Task Plan

## Problem

The app currently has a dark `ThemeData`, but most UI surfaces still use hardcoded light-mode colors from `AppColors`.

Examples:

- Cards use `AppColors.white`.
- Text uses `AppColors.text`, `AppColors.textMid`, or `AppColors.textMute`.
- Panels and form fields use `AppColors.surface`.
- Borders use `AppColors.border`.
- Status backgrounds use light pastel colors like `greenLt`, `redLt`, `blueLt`, and `amberLt`.

When dark mode is toggled, the shell/background changes, but many cards and widgets remain light. Some labels also become hard to read because text and background colors no longer have enough contrast.

The result is not a coherent dark design. It looks like a light UI placed on a dark background.

## Goal

Implement dark mode as a first-class design system feature.

Dark mode should:

- Keep all important text readable.
- Make cards, panels, tables, forms, and list rows use dark surfaces.
- Preserve brand identity.
- Keep status colors recognizable.
- Avoid page-by-page one-off fixes where a shared token or shared widget can solve the issue.
- Keep light mode visually unchanged unless an intentional cleanup is needed.

## Design Direction

Use semantic theme-aware color tokens instead of direct light-only color constants.

Recommended dark palette:

- App background: near-black green, not pure black.
- Card/surface: dark green-charcoal.
- Elevated surface: slightly lighter dark green-charcoal.
- Primary text: off-white.
- Secondary text: muted mint-gray.
- Borders: muted green-gray.
- Primary/accent: existing teal and gold, adjusted for contrast.
- Status surfaces: dark tinted variants of green, red, amber, blue, and purple.

## Core Solution

Add theme-aware semantic color helpers, for example:

```dart
AppThemeColors.background(context)
AppThemeColors.surface(context)
AppThemeColors.card(context)
AppThemeColors.text(context)
AppThemeColors.textMid(context)
AppThemeColors.textMuted(context)
AppThemeColors.border(context)
AppThemeColors.statusSuccessBg(context)
AppThemeColors.statusSuccessFg(context)
```

Widgets should prefer semantic colors when rendering UI surfaces or text.

Keep existing `AppColors` constants for:

- Brand colors.
- Compatibility during migration.
- Status identity colors where the color itself is not a surface/background.

## Implementation Flow

### Phase 1 - Theme Token Foundation

- [ ] Add `AppThemeColors` or equivalent theme extension/helper.
- [ ] Define light and dark values for:
  - background
  - surface
  - card
  - elevated surface
  - text
  - text mid
  - text muted
  - border
  - divider
  - shadow
- [ ] Define dark-aware status background/foreground pairs.
- [ ] Keep existing `AppColors` API in place during migration.
- [ ] Add small tests for semantic colors if practical.

### Phase 2 - Shared Widget Migration

Update shared widgets first because they affect many screens.

- [ ] `AppShell`
- [ ] `AppMessageCard`
- [ ] `AppDetailRow`
- [ ] `AppDetailBlock`
- [ ] `AppMetricCard`
- [ ] `AppMoneyMetricCard`
- [ ] `AppPanel`
- [ ] `AppSection`
- [ ] `AppDataTable`
- [ ] `AppFormFields`
- [ ] `AppScreenHeader`
- [ ] `AppCardList`
- [ ] `AppAvatar` if needed
- [ ] `AppStatusPill`

Acceptance checks:

- [ ] Shared cards use dark surfaces in dark mode.
- [ ] Shared text uses readable dark-mode text tokens.
- [ ] Shared borders are visible but subtle.
- [ ] Light mode remains visually equivalent.

### Phase 3 - Landing Dashboard

Fix the screen shown in the screenshot first.

- [ ] Quick action cards use dark card surfaces.
- [ ] Quick action labels use readable text.
- [ ] Quick action icon backgrounds use dark-aware tints.
- [ ] Section titles like `Quick Actions` and `Investments` are readable.
- [ ] Investment preview cards use dark surfaces.
- [ ] Member carousel cards use dark surfaces.
- [ ] Recent activity rows use dark surfaces.
- [ ] Bottom navigation remains readable in both modes.

Acceptance checks:

- [ ] Home screen looks intentionally dark, not mixed light/dark.
- [ ] Toggle button remains beside logout.
- [ ] All labels in the first viewport are readable.

### Phase 4 - High-Traffic Feature Screens

Migrate custom feature-specific cards and rows.

- [ ] Approvals page cards and filters.
- [ ] Members list cards.
- [ ] Member detail sections.
- [ ] Admin ledger page.
- [ ] Member ledger page.
- [ ] Investment list cards.
- [ ] Investment detail page.
- [ ] Submit funds form.
- [ ] Profile page.

Acceptance checks:

- [ ] No white cards remain in dark mode unless intentionally elevated.
- [ ] Forms are readable and focused states are visible.
- [ ] Tables/lists retain row separation.

### Phase 5 - Reports And Data-Dense Screens

Reports and tables need extra contrast checks.

- [x] Staff report summary section.
- [x] Staff report member balances section.
- [x] Staff report investment register.
- [x] Staff report distribution logs.
- [x] Staff report approval queue.
- [x] Member report summary cards.
- [x] Member report transaction panel.
- [x] Member report pending requests panel.
- [x] Member report distributions panel.

Acceptance checks:

- [x] Table headers are readable.
- [x] Money columns remain visually scannable.
- [x] Status pills are readable on dark report surfaces.

### Phase 6 - Theme Persistence

Current toggle behavior can be in-memory. Persist it after the visual migration is stable.

Implementation note: the selected theme mode is stored in secure storage under
`root_finance_theme_mode`. The app defaults to light mode when no stored
preference exists or when the stored value is invalid.

- [x] Decide storage location:
  - shared preferences, or
  - secure storage if avoiding a new dependency is preferred.
- [x] Save selected theme mode.
- [x] Restore selected theme mode during app startup.
- [x] Consider system mode support: light, dark, system.

Acceptance checks:

- [x] User selection survives app restart.
- [x] Default behavior is documented.

### Phase 7 - Verification

- [ ] Run `dart format .`.
- [ ] Run `flutter analyze`.
- [ ] Run `flutter test`.
- [ ] Manually verify light mode:
  - login
  - home
  - approvals
  - members
  - member detail
  - admin ledger
  - member ledger
  - investments
  - staff report
  - member report
- [ ] Manually verify dark mode on the same screens.
- [ ] Check first viewport screenshots on a phone-sized screen.
- [ ] Check text contrast for section titles, card labels, table headers, and form labels.

## Migration Rules

- Prefer shared semantic tokens over direct `AppColors.white`, `AppColors.text`, `AppColors.surface`, or `AppColors.border`.
- Do not redesign layouts during dark-mode migration unless the layout is directly causing contrast/readability issues.
- Keep light mode stable.
- Migrate shared widgets before page-specific widgets.
- Avoid adding page-local dark-mode conditionals when a shared token can solve the same issue.
- Preserve business behavior, routes, controllers, API calls, and form validation.

## Known Risk

Because the app has many hardcoded colors, partial migration can look inconsistent. Each implementation phase should leave the migrated screens coherent in both light and dark mode before moving to the next group.
