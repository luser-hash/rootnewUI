import '../../shared/finance.dart';
import '../domain/investment_detail.dart';
import 'investment_api.dart';

abstract class InvestmentRepository {
  Future<List<Investment>> list({
    InvestmentStatus? status,
    String? investmentType,
  });
  Future<InvestmentDetail> detail(String investmentId);
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
}
