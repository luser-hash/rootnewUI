import '../../../../core/network/api_client.dart';
import '../domain/member_create_request.dart';

class MemberManagementApi {
  const MemberManagementApi(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> create(MemberCreateRequest request) {
    return _apiClient.post('/users/', body: request.toJson());
  }
}
