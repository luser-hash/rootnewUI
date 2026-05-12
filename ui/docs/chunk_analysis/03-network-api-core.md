# Network And API Core

## Scope

- `lib/core/network/api_client.dart`
- `lib/core/network/api_exception.dart`
- `lib/core/config/api_config.dart`

## The Good

- `ApiClient` centralizes base URL, auth headers, timeouts, JSON encoding, and response handling.
- Unauthorized retry with a single in-flight refresh future avoids token refresh stampedes.
- Error message extraction handles strings, lists, maps, and common backend fields.
- API URL is configurable through Dart defines.

## Critical Issues

- `ApiClient` does not expose a `close()` method for its underlying `http.Client`.
- All successful responses are forced into `Map<String, dynamic>`. Endpoints that naturally return lists are wrapped as `{'data': decoded}`, which can hide API shape inconsistencies.
- No request cancellation strategy exists for screens that dispose during slow network calls.
- Retry behavior only handles token refresh. There is no consistent handling for transient network errors, offline mode, or maintenance responses.

## Refactoring Opportunities

- Add `void close() => _httpClient.close();`.
- Add typed helpers for `getMap`, `getList`, or a generic decoder callback:

```dart
Future<T> getDecoded<T>(String path, T Function(Object? json) decode)
```

- Move auth-specific retry concerns into a small `AuthenticatedApiClient` wrapper if the base client grows.
- Standardize endpoint path constants per feature to avoid string drift.

## Performance Wins

- Reuse the same `http.Client`, as already done.
- Avoid unnecessary response map wrapping for large list endpoints.
- Decode in repositories/models, not in widget controllers.

## Proposed Structure

```text
lib/core/network/
  api_client.dart
  api_exception.dart
  api_response.dart
```

## Priority Tasks

- P0: Add `close()` and call it from app disposal.
- P1: Add typed decode helpers or typed response wrappers.
- P2: Add unit tests for error extraction, token refresh retry, and non-map JSON responses.
