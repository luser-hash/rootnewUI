import '../domain/member_create_request.dart';
import 'member_management_api.dart';

abstract class MemberManagementRepository {
  Future<void> create(MemberCreateRequest request);
}

class ApiMemberManagementRepository implements MemberManagementRepository {
  const ApiMemberManagementRepository({required MemberManagementApi api})
    : _api = api;

  final MemberManagementApi _api;

  @override
  Future<void> create(MemberCreateRequest request) async {
    await _api.create(request);
  }
}
