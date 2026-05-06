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
}
