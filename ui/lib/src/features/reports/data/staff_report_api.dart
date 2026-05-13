import '../../../../core/network/api_client.dart';
import '../domain/staff_report_models.dart';

class StaffReportApi {
  const StaffReportApi(this._apiClient);

  final ApiClient _apiClient;

  Future<AssociationSummaryReport> associationSummary() async {
    final Map<String, dynamic> response = await _apiClient.get(
      '/reports/association-summary/',
    );
    return AssociationSummaryReport.fromJson(_payload(response));
  }

  Future<StaffMemberBalancesReport> memberBalances({
    String? status,
    String? search,
  }) async {
    final Map<String, String> queryParams = <String, String>{
      if (status?.trim().isNotEmpty ?? false) 'status': status!.trim(),
      if (search?.trim().isNotEmpty ?? false) 'search': search!.trim(),
    };
    final Uri uri = Uri(
      path: '/reports/member-balances/',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    final Map<String, dynamic> response = await _apiClient.get(uri.toString());
    return StaffMemberBalancesReport.fromJson(_payload(response));
  }

  Future<StaffInvestmentRegisterReport> investmentRegister({
    String? status,
    String? investmentType,
  }) async {
    final Map<String, String> queryParams = <String, String>{
      if (status?.trim().isNotEmpty ?? false) 'status': status!.trim(),
      if (investmentType?.trim().isNotEmpty ?? false)
        'investment_type': investmentType!.trim(),
    };
    final Uri uri = Uri(
      path: '/reports/investment-register/',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    final Map<String, dynamic> response = await _apiClient.get(uri.toString());
    return StaffInvestmentRegisterReport.fromJson(_payload(response));
  }

  Future<StaffDistributionLogsReport> distributionLogs({
    String? status,
    String? investmentId,
  }) async {
    final Map<String, String> queryParams = <String, String>{
      if (status?.trim().isNotEmpty ?? false) 'status': status!.trim(),
      if (investmentId?.trim().isNotEmpty ?? false)
        'investment_id': investmentId!.trim(),
    };
    final Uri uri = Uri(
      path: '/reports/distribution-logs/',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    final Map<String, dynamic> response = await _apiClient.get(uri.toString());
    return StaffDistributionLogsReport.fromJson(_payload(response));
  }

  Future<StaffApprovalQueueReport> approvalQueueReport() async {
    final Map<String, dynamic> response = await _apiClient.get(
      '/reports/approval-queue-report/',
    );
    return StaffApprovalQueueReport.fromJson(_payload(response));
  }

  Future<InvestmentPnlProfileReport> investmentPnlProfile() async {
    final Map<String, dynamic> response = await _apiClient.get(
      '/reports/investment-pnl-profile/',
    );
    return InvestmentPnlProfileReport.fromJson(_payload(response));
  }

  Map<String, dynamic> _payload(Map<String, dynamic> response) {
    final Object? data = response['data'];
    return data is Map<String, dynamic> ? data : response;
  }
}
