import '../../../../core/network/api_client.dart';
import '../domain/member_ledger_statement.dart';

class MemberLedgerApi {
  const MemberLedgerApi(this._apiClient);

  final ApiClient _apiClient;

  Future<MemberLedgerStatement> statement(MemberLedgerFilter filter) async {
    final Uri uri = Uri(
      path: '/ledger/',
      queryParameters: filter.toQueryParams().isEmpty
          ? null
          : filter.toQueryParams(),
    );
    final Map<String, dynamic> response = await _apiClient.get(uri.toString());
    final Object? data = response['data'];
    return MemberLedgerStatement.fromJson(
      data is Map<String, dynamic> ? data : response,
    );
  }

  Future<MemberLedgerStatement> memberStatement(String userId) async {
    final String encodedUserId = Uri.encodeComponent(userId.trim());
    final Map<String, dynamic> response = await _apiClient.get(
      '/ledger/members/$encodedUserId/',
    );
    final Object? data = response['data'];
    return MemberLedgerStatement.fromJson(
      data is Map<String, dynamic> ? data : response,
    );
  }

  Future<AdminLedgerStatement> adminLedger(MemberLedgerFilter filter) async {
    final Map<String, String> queryParams = filter.toQueryParams();
    final Uri uri = Uri(
      path: '/ledger/admin/',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    final Map<String, dynamic> response = await _apiClient.get(uri.toString());
    final Object? data = response['data'];
    return AdminLedgerStatement.fromJson(
      data is Map<String, dynamic> ? data : response,
    );
  }
}
