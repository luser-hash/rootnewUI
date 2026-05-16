# About This App

## App Name

Root Finance

## Package Name

`com.rootfinance.app`

## Short Description

Member finance, capital submission, approval, ledger, investment, and reporting workflows in one secure mobile app.

## Full Description

Root Finance is a mobile finance operations app for member-based financial workflows. It helps members and staff manage capital submissions, approvals, member records, ledger activity, investments, and financial reports from a single Android app.

The app connects to the Root Finance backend and uses authenticated access so each user only sees the sections available to their role. Members can review their profile, submit funds, track submission history, view ledger activity, and access member reports. Staff and authorized users can manage approvals, members, investment records, ledger views, and organization-level reports.

Root Finance is built for finance teams that need a focused operational tool instead of spreadsheets, scattered messages, or manual tracking.

## Key Features

- Secure sign-in with backend-issued access and refresh tokens.
- Role-based navigation for members, staff, and approval users.
- Member dashboard with recent activity and finance summaries.
- Capital fund submission workflow.
- Submission history and submission detail views.
- Approval queue for reviewing pending capital submissions.
- Member directory and member management screens.
- Member detail view with account information, ledger history, and submission history.
- Investment register, investment creation, closing workflow, and distribution records.
- Ledger views for members and staff.
- Member report and staff report sections.
- Profile screen for authenticated users.

## Target Users

- Finance association members.
- Staff who manage member finance operations.
- Approval users who review capital submissions.
- Administrators responsible for member, ledger, investment, and report workflows.

## Data And Privacy Notes

Root Finance requires authenticated access to the Root Finance backend API. The app stores authentication tokens on the device using secure storage so users can remain signed in between sessions.

The app may process finance-related user data such as member details, submissions, approvals, ledger records, investment records, distribution records, and reports. Data visibility depends on the signed-in user role and backend permissions.

Do not publish this app publicly until the production backend, privacy policy, data handling rules, and Play Console data safety form are finalized.

## Permissions

- Internet access: required to communicate with the Root Finance backend API.

## Release Details

- Android application ID: `com.rootfinance.app`
- Release signing: `android/key.properties` plus `android/release-keystore.jks`
- Universal APK command:

```powershell
E:\flutter\flutter\bin\flutter.bat build apk --release --dart-define=API_BASE_URL=https://rootbackenddeploy.onrender.com/api
```

- ARM64 APK command for most modern Android phones:

```powershell
E:\flutter\flutter\bin\flutter.bat build apk --release --split-per-abi --dart-define=API_BASE_URL=https://rootbackenddeploy.onrender.com/api
```

Use this output for most direct Android distribution:

```text
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

## Play Store Listing Draft

### App Category

Finance

### Suggested Tags

Finance, member management, approvals, ledger, investment tracking, reporting

### Suggested Screenshots

- Login screen.
- Home dashboard.
- Submit funds screen.
- Approval queue.
- Member directory.
- Member detail and ledger.
- Investment register.
- Staff report.

### Suggested Release Notes

Initial Android release of Root Finance with secure sign-in, member finance dashboard, capital submissions, approval workflows, ledger views, investment tracking, and reports.

## Pre-Publish Checklist

- Confirm production backend URL.
- Confirm app name, icon, and splash screen.
- Confirm release keystore backup.
- Confirm privacy policy URL.
- Complete Play Console data safety section.
- Test login and each role-based route on a physical Android device.
- Build split APKs or Android App Bundle for optimized distribution.
