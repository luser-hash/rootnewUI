import '../../shared/finance.dart';
import '../domain/investment_close_request.dart';
import '../domain/investment_create_request.dart';
import '../domain/investment_detail.dart';
import '../domain/investment_distribution_record.dart';
import 'investment_api.dart';

abstract class InvestmentRepository {
  Future<List<Investment>> list({
    InvestmentStatus? status,
    String? investmentType,
  });
  Future<InvestmentDetail> detail(String investmentId);
  Future<Investment> create(InvestmentCreateRequest request);
  Future<InvestmentDetail> releaseFunds(String investmentId);
  Future<InvestmentDetail> closeInvestment(
    String investmentId,
    InvestmentCloseRequest request,
  );
  Future<InvestmentDetail> distribute(String investmentId);
  Future<List<InvestmentDistributionRecord>> distributionRecords(
    String investmentId, {
    InvestmentDistributionStatus? status,
  });
}

class ApiInvestmentRepository implements InvestmentRepository {
  const ApiInvestmentRepository({required InvestmentApi api}) : _api = api;

  final InvestmentApi _api;

  @override
  Future<List<Investment>> list({
    InvestmentStatus? status,
    String? investmentType,
  }) {
    return _api.list(status: status, investmentType: investmentType);
  }

  @override
  Future<InvestmentDetail> detail(String investmentId) {
    return _api.detail(investmentId);
  }

  @override
  Future<Investment> create(InvestmentCreateRequest request) {
    return _api.create(request);
  }

  @override
  Future<InvestmentDetail> releaseFunds(String investmentId) {
    return _api.releaseFunds(investmentId);
  }

  @override
  Future<InvestmentDetail> closeInvestment(
    String investmentId,
    InvestmentCloseRequest request,
  ) {
    return _api.closeInvestment(investmentId, request);
  }

  @override
  Future<InvestmentDetail> distribute(String investmentId) {
    return _api.distribute(investmentId);
  }

  @override
  Future<List<InvestmentDistributionRecord>> distributionRecords(
    String investmentId, {
    InvestmentDistributionStatus? status,
  }) {
    return _api.distributionRecords(investmentId, status: status);
  }
}
