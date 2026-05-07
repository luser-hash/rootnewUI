import '../../../../core/network/api_client.dart';
import '../domain/auth_session.dart';

class AuthApi {
  const AuthApi(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthSession> login({
    required String phone,
    required String password,
    required bool rememberDevice,
  }) async {
    final Map<String, dynamic> response = await _apiClient.post(
      '/auth/login/',
      body: <String, dynamic>{'contact_no': phone, 'password': password},
    );

    return AuthSession.fromJson(response);
  }

  Future<void> logout(String refreshToken) async {
    await _apiClient.post(
      '/auth/logout/',
      body: <String, dynamic>{'refresh': refreshToken},
    );
  }

  Future<AuthTokens> refreshToken(String refreshToken) async {
    final Map<String, dynamic> response = await _apiClient.post(
      '/api/auth/token/refresh/',
      body: <String, dynamic>{'refresh': refreshToken},
    );
    return AuthTokens.fromJson(response);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _apiClient.post(
      '/auth/change-password/',
      body: <String, dynamic>{
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );
  }

  Future<AuthUser> me({String? accessToken}) async {
    final Map<String, dynamic> response = await _apiClient.get(
      '/auth/me/',
      accessToken: accessToken,
    );
    final Map<String, dynamic> data =
        response['data'] as Map<String, dynamic>? ?? response;
    return AuthUser.fromJson(data['user'] as Map<String, dynamic>? ?? data);
  }
}
