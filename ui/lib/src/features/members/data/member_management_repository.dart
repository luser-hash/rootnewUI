import '../domain/member_create_request.dart';
import '../domain/member_management_models.dart';
import '../domain/member_update_request.dart';
import 'member_management_api.dart';

abstract class MemberManagementRepository {
  Future<List<ManagedUser>> list({ManagedUserFilter? filter});
  Future<ManagedUser> detail(String userId);
  Future<void> create(MemberCreateRequest request);
  Future<ManagedUser> update(String userId, MemberUpdateRequest request);
}

class ApiMemberManagementRepository implements MemberManagementRepository {
  const ApiMemberManagementRepository({required MemberManagementApi api})
    : _api = api;

  final MemberManagementApi _api;

  @override
  Future<List<ManagedUser>> list({ManagedUserFilter? filter}) {
    return _api.list(filter: filter);
  }

  @override
  Future<ManagedUser> detail(String userId) {
    return _api.detail(userId);
  }

  @override
  Future<void> create(MemberCreateRequest request) async {
    await _api.create(request);
  }

  @override
  Future<ManagedUser> update(String userId, MemberUpdateRequest request) {
    return _api.update(userId, request);
  }
}
