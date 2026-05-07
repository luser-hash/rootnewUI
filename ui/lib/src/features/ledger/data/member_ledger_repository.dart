import '../domain/member_ledger_statement.dart';
import 'member_ledger_api.dart';

abstract class MemberLedgerRepository {
  Future<MemberLedgerStatement> statement(MemberLedgerFilter filter);
  Future<MemberLedgerStatement> memberStatement(String userId);
  Future<AdminLedgerStatement> adminLedger(MemberLedgerFilter filter);
  Future<AdminLedgerPostResult> adminPost(AdminLedgerPostRequest request);
}

class ApiMemberLedgerRepository implements MemberLedgerRepository {
  const ApiMemberLedgerRepository({required MemberLedgerApi api}) : _api = api;

  final MemberLedgerApi _api;

  @override
  Future<MemberLedgerStatement> statement(MemberLedgerFilter filter) {
    return _api.statement(filter);
  }

  @override
  Future<MemberLedgerStatement> memberStatement(String userId) {
    return _api.memberStatement(userId);
  }

  @override
  Future<AdminLedgerStatement> adminLedger(MemberLedgerFilter filter) {
    return _api.adminLedger(filter);
  }

  @override
  Future<AdminLedgerPostResult> adminPost(AdminLedgerPostRequest request) {
    return _api.adminPost(request);
  }
}
