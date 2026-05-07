import '../../../../core/network/api_client.dart';
import '../domain/member_create_request.dart';
import '../domain/member_management_models.dart';
import '../domain/member_update_request.dart';

class MemberManagementApi {
  const MemberManagementApi(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ManagedUser>> list({ManagedUserFilter? filter}) async {
    final Map<String, String> queryParams =
        filter?.toQueryParams() ?? <String, String>{};
    final Uri uri = Uri(
      path: '/users/',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    final Map<String, dynamic> response = await _apiClient.get(uri.toString());
    final Object? data = response['data'];
    final List<dynamic> items = _extractItems(data, response);

    return items
        .whereType<Map<String, dynamic>>()
        .map(ManagedUser.fromJson)
        .toList();
  }

  Future<ManagedUser> detail(String userId) async {
    final String encodedUserId = Uri.encodeComponent(userId);
    final Map<String, dynamic> response = await _apiClient.get(
      '/users/$encodedUserId/',
    );
    final Object? data = response['data'];
    return ManagedUser.fromJson(
      data is Map<String, dynamic> ? data : response,
    );
  }

  Future<Map<String, dynamic>> create(MemberCreateRequest request) {
    return _apiClient.post('/users/', body: request.toJson());
  }

  Future<ManagedUser> update(String userId, MemberUpdateRequest request) async {
    final String encodedUserId = Uri.encodeComponent(userId);
    final Map<String, dynamic> response = await _apiClient.patch(
      '/users/$encodedUserId/',
      body: request.toJson(),
    );
    final Object? data = response['data'];
    if (data == null && response.isEmpty) {
      return detail(userId);
    }
    return ManagedUser.fromJson(
      data is Map<String, dynamic> ? data : response,
    );
  }

  Future<void> delete(String userId) async {
    final String encodedUserId = Uri.encodeComponent(userId);
    await _apiClient.delete('/users/$encodedUserId/');
  }

  List<dynamic> _extractItems(
    Object? data,
    Map<String, dynamic> response,
  ) {
    if (data is List<dynamic>) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      final Object? nested =
          data['results'] ?? data['items'] ?? data['users'] ?? data['data'];
      if (nested is List<dynamic>) {
        return nested;
      }
    }

    final Object? topLevel =
        response['results'] ?? response['items'] ?? response['users'];
    return topLevel is List<dynamic> ? topLevel : <dynamic>[];
  }
}
