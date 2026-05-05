import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/auth_session.dart';

abstract class AuthStorage {
  Future<AuthSession?> readSession();
  Future<String?> readAccessToken();
  Future<void> saveSession(AuthSession session);
  Future<void> clearSession();
}

class SecureAuthStorage implements AuthStorage {
  SecureAuthStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _sessionKey = 'root_finance_auth_session';

  final FlutterSecureStorage _storage;

  @override
  Future<AuthSession?> readSession() async {
    final String? raw = await _storage.read(key: _sessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      await clearSession();
      return null;
    }

    return AuthSession.fromJson(decoded);
  }

  @override
  Future<String?> readAccessToken() async {
    final AuthSession? session = await readSession();
    return session?.tokens.accessToken;
  }

  @override
  Future<void> saveSession(AuthSession session) {
    return _storage.write(
      key: _sessionKey,
      value: jsonEncode(session.toJson()),
    );
  }

  @override
  Future<void> clearSession() {
    return _storage.delete(key: _sessionKey);
  }
}
