# Android And Release

## Scope

- `android/*`
- `pubspec.yaml`
- Project metadata and release hygiene

## The Good

- Flutter Android project structure is present.
- README documents backend URL overrides and release APK command.
- Dependencies are minimal: `go_router`, `flutter_secure_storage`, and `http`.
- `analysis_options.yaml` and `flutter_lints` are present.

## Critical Issues

- `pubspec.yaml` still has generic name/description.
- Android application ID/package naming likely still needs production identity.
- Release signing must not use debug signing for production builds.
- Font family `Nunito` is referenced in theme but not declared in `pubspec.yaml`.
- No test suite exists yet, which blocks reliable CI.

## Refactoring Opportunities

- Rename project metadata:
  - app name
  - package/application ID
  - description
  - versioning strategy
- Add ignored signing properties and CI secret-based signing.
- Add launcher icon/splash configuration.
- Add test directory with initial unit tests for non-UI business rules.

## Performance Wins

- Review APK size once assets/fonts/icons are added.
- Avoid unused packages and generated assets.
- Enable release build checks in CI.

## Proposed Structure

```text
test/
  core/
  features/
android/
  key.properties.example
```

## Priority Tasks

- P0: Configure production Android app ID and signing strategy.
- P1: Fix or remove undeclared `Nunito` font usage.
- P1: Add baseline test suite and CI.
- P2: Update README with development, test, and release commands.
