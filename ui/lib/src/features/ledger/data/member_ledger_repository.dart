import '../domain/member_ledger_statement.dart';
import 'member_ledger_api.dart';

abstract class MemberLedgerRepository {
  Future<MemberLedgerStatement> statement(MemberLedgerFilter filter);
}

class ApiMemberLedgerRepository implements MemberLedgerRepository {
  const ApiMemberLedgerRepository({required MemberLedgerApi api}) : _api = api;

  final MemberLedgerApi _api;

  @override
  Future<MemberLedgerStatement> statement(MemberLedgerFilter filter) {
    return _api.statement(filter);
  }
}
