import '../../../../core/network/api_exception.dart';
import '../domain/auth_session.dart';
import 'auth_api.dart';
import 'auth_storage.dart';

abstract class AuthRepository {
  Future<AuthSession?> restoreSession();
  Future<AuthSession> signIn({
    required String phone,
    required String password,
    required bool rememberDevice,
  });
  Future<void> signOut({String? refreshToken});
}

class ApiAuthRepository implements AuthRepository {
  const ApiAuthRepository({required AuthApi api, required AuthStorage storage})
    : _api = api,
      _storage = storage;

  final AuthApi _api;
  final AuthStorage _storage;

  @override
  Future<AuthSession?> restoreSession() async {
    final AuthSession? session = await _storage.readSession();
    if (session == null) {
      return null;
    }

    if (session.tokens.accessToken.isEmpty || session.tokens.isExpired) {
      await _storage.clearSession();
      return null;
    }

    try {
      final AuthUser user = await _api.me(
        accessToken: session.tokens.accessToken,
      );
      final AuthSession refreshed = session.copyWith(user: user);
      await _storage.saveSession(refreshed);
      return refreshed;
    } on ApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        await _storage.clearSession();
        return null;
      }

      return session;
    }
  }

  @override
  Future<AuthSession> signIn({
    required String phone,
    required String password,
    required bool rememberDevice,
  }) async {
    final AuthSession session = await _api.login(
      phone: phone,
      password: password,
      rememberDevice: rememberDevice,
    );

    if (session.tokens.accessToken.isEmpty) {
      throw const ApiException(message: 'Missing access token from server');
    }

    final AuthUser user = await _api.me(
      accessToken: session.tokens.accessToken,
    );
    final AuthSession verifiedSession = session.copyWith(user: user);

    if (rememberDevice) {
      await _storage.saveSession(verifiedSession);
    } else {
      await _storage.clearSession();
    }

    return verifiedSession;
  }

  @override
  Future<void> signOut({String? refreshToken}) async {
    final AuthSession? session = await _storage.readSession();
    final String? token = refreshToken ?? session?.tokens.refreshToken;

    try {
      if (token != null && token.isNotEmpty) {
        await _api.logout(token);
      }
    } on ApiException {
      // Local sign-out must still clear credentials if the server is offline.
    } finally {
      await _storage.clearSession();
    }
  }
}
