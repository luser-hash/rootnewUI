import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../shared/finance.dart';
import '../data/investment_repository.dart';

class InvestmentController extends ChangeNotifier {
  InvestmentController({required InvestmentRepository repository})
    : _repository = repository;

  final InvestmentRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Investment> _investments = <Investment>[];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Investment> get investments => List<Investment>.unmodifiable(
    _investments,
  );

  Future<void> load({
    InvestmentStatus? status,
    String? investmentType,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _investments = await _repository.list(
        status: status,
        investmentType: investmentType,
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load investments. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
