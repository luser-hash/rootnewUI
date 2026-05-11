import '../domain/member_report_models.dart';
import 'member_report_api.dart';

abstract class MemberReportRepository {
  Future<MemberReportStatement> myStatement(MemberStatementFilter filter);
  Future<MemberDistributionsReport> myDistributions();
}

class ApiMemberReportRepository implements MemberReportRepository {
  const ApiMemberReportRepository({required MemberReportApi api}) : _api = api;

  final MemberReportApi _api;

  @override
  Future<MemberReportStatement> myStatement(MemberStatementFilter filter) {
    return _api.myStatement(filter);
  }

  @override
  Future<MemberDistributionsReport> myDistributions() {
    return _api.myDistributions();
  }
}
