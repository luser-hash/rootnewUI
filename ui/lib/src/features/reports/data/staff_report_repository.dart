import '../domain/staff_report_models.dart';
import 'staff_report_api.dart';

abstract class StaffReportRepository {
  Future<AssociationSummaryReport> associationSummary();

  Future<StaffMemberBalancesReport> memberBalances({
    String? status,
    String? search,
  });

  Future<StaffInvestmentRegisterReport> investmentRegister({
    String? status,
    String? investmentType,
  });

  Future<StaffDistributionLogsReport> distributionLogs({
    String? status,
    String? investmentId,
  });

  Future<StaffApprovalQueueReport> approvalQueueReport();

  Future<InvestmentPnlProfileReport> investmentPnlProfile();
}

class ApiStaffReportRepository implements StaffReportRepository {
  const ApiStaffReportRepository({required StaffReportApi api}) : _api = api;

  final StaffReportApi _api;

  @override
  Future<AssociationSummaryReport> associationSummary() {
    return _api.associationSummary();
  }

  @override
  Future<StaffMemberBalancesReport> memberBalances({
    String? status,
    String? search,
  }) {
    return _api.memberBalances(status: status, search: search);
  }

  @override
  Future<StaffInvestmentRegisterReport> investmentRegister({
    String? status,
    String? investmentType,
  }) {
    return _api.investmentRegister(
      status: status,
      investmentType: investmentType,
    );
  }

  @override
  Future<StaffDistributionLogsReport> distributionLogs({
    String? status,
    String? investmentId,
  }) {
    return _api.distributionLogs(status: status, investmentId: investmentId);
  }

  @override
  Future<StaffApprovalQueueReport> approvalQueueReport() {
    return _api.approvalQueueReport();
  }

  @override
  Future<InvestmentPnlProfileReport> investmentPnlProfile() {
    return _api.investmentPnlProfile();
  }
}
