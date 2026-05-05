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
