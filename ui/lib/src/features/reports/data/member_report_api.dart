import '../../../../core/network/api_client.dart';
import '../domain/member_report_models.dart';

class MemberReportApi {
  const MemberReportApi(this._apiClient);

  final ApiClient _apiClient;

  Future<MemberReportStatement> myStatement(
    MemberStatementFilter filter,
  ) async {
    final Map<String, String> queryParams = filter.toQueryParams();
    final Uri uri = Uri(
      path: '/reports/my-statement/',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    final Map<String, dynamic> response = await _apiClient.get(uri.toString());
    final Object? data = response['data'];
    return MemberReportStatement.fromJson(
      data is Map<String, dynamic> ? data : response,
    );
  }

  Future<MemberDistributionsReport> myDistributions() async {
    final Map<String, dynamic> response = await _apiClient.get(
      '/reports/my-distributions/',
    );
    final Object? data = response['data'];
    return MemberDistributionsReport.fromJson(
      data is Map<String, dynamic> ? data : response,
    );
  }
}
