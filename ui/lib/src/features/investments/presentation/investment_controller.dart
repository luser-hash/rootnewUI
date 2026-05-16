import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../shared/finance.dart';
import '../data/investment_repository.dart';
import '../domain/investment_close_request.dart';
import '../domain/investment_capital_summary.dart';
import '../domain/investment_detail.dart';

class InvestmentController extends ChangeNotifier {
  InvestmentController({required InvestmentRepository repository})
    : _repository = repository;

  final InvestmentRepository _repository;

  bool _isLoading = false;
  String? _releasingInvestmentId;
  String? _closingInvestmentId;
  String? _distributingInvestmentId;
  String? _deletingInvestmentId;
  String? _errorMessage;
  String? _actionErrorMessage;
  List<Investment> _investments = <Investment>[];
  InvestmentCapitalSummary? _capitalSummary;

  bool get isLoading => _isLoading;
  String? get releasingInvestmentId => _releasingInvestmentId;
  String? get closingInvestmentId => _closingInvestmentId;
  String? get distributingInvestmentId => _distributingInvestmentId;
  String? get deletingInvestmentId => _deletingInvestmentId;
  bool get hasActionInFlight {
    return _releasingInvestmentId != null ||
        _closingInvestmentId != null ||
        _distributingInvestmentId != null ||
        _deletingInvestmentId != null;
  }

  String? get errorMessage => _errorMessage;
  String? get actionErrorMessage => _actionErrorMessage;
  InvestmentCapitalSummary? get capitalSummary => _capitalSummary;
  List<Investment> get investments =>
      List<Investment>.unmodifiable(_investments);

  Future<void> load({InvestmentStatus? status, String? investmentType}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<Object> results = await Future.wait<Object>(<Future<Object>>[
        _repository.list(status: status, investmentType: investmentType),
        _repository.capitalSummary(),
      ]);
      _investments = results[0] as List<Investment>;
      _capitalSummary = results[1] as InvestmentCapitalSummary;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load investments. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> releaseFunds(String investmentId) async {
    if (hasActionInFlight) {
      return false;
    }

    _releasingInvestmentId = investmentId;
    _actionErrorMessage = null;
    notifyListeners();

    try {
      final InvestmentDetail released = await _repository.releaseFunds(
        investmentId,
      );
      _replaceInvestment(_investmentFromDetail(released));
      await _refreshCapitalSummary();
      return true;
    } on ApiException catch (error) {
      _actionErrorMessage = error.message;
      return false;
    } catch (_) {
      _actionErrorMessage = 'Unable to release funds. Please try again.';
      return false;
    } finally {
      _releasingInvestmentId = null;
      notifyListeners();
    }
  }

  Future<bool> closeInvestment(
    String investmentId,
    InvestmentCloseRequest request,
  ) async {
    if (hasActionInFlight) {
      return false;
    }

    _closingInvestmentId = investmentId;
    _actionErrorMessage = null;
    notifyListeners();

    try {
      final InvestmentDetail closed = await _repository.closeInvestment(
        investmentId,
        request,
      );
      _replaceInvestment(_investmentFromDetail(closed));
      await _refreshCapitalSummary();
      return true;
    } on ApiException catch (error) {
      _actionErrorMessage = error.message;
      return false;
    } catch (_) {
      _actionErrorMessage = 'Unable to close investment. Please try again.';
      return false;
    } finally {
      _closingInvestmentId = null;
      notifyListeners();
    }
  }

  Future<bool> distribute(String investmentId) async {
    if (hasActionInFlight) {
      return false;
    }

    _distributingInvestmentId = investmentId;
    _actionErrorMessage = null;
    notifyListeners();

    try {
      final InvestmentDetail distributed = await _repository.distribute(
        investmentId,
      );
      _replaceInvestment(_investmentFromDetail(distributed));
      await _refreshCapitalSummary();
      return true;
    } on ApiException catch (error) {
      _actionErrorMessage = error.message;
      return false;
    } catch (_) {
      _actionErrorMessage = 'Unable to distribute P&L. Please try again.';
      return false;
    } finally {
      _distributingInvestmentId = null;
      notifyListeners();
    }
  }

  Future<bool> delete(String investmentId) async {
    if (hasActionInFlight) {
      return false;
    }

    _deletingInvestmentId = investmentId;
    _actionErrorMessage = null;
    notifyListeners();

    try {
      await _repository.delete(investmentId);
      _removeInvestment(investmentId);
      await _refreshCapitalSummary();
      return true;
    } on ApiException catch (error) {
      _actionErrorMessage = error.message;
      return false;
    } catch (_) {
      _actionErrorMessage = 'Unable to delete investment. Please try again.';
      return false;
    } finally {
      _deletingInvestmentId = null;
      notifyListeners();
    }
  }

  Future<void> _refreshCapitalSummary() async {
    try {
      _capitalSummary = await _repository.capitalSummary();
    } catch (_) {
      return;
    } finally {
      notifyListeners();
    }
  }

  void _replaceInvestment(Investment investment) {
    _investments = _investments
        .map((Investment item) => item.id == investment.id ? investment : item)
        .toList();
    notifyListeners();
  }

  void _removeInvestment(String investmentId) {
    _investments = _investments
        .where((Investment item) => item.id != investmentId)
        .toList();
    notifyListeners();
  }

  Investment _investmentFromDetail(InvestmentDetail detail) {
    return Investment(
      id: detail.id,
      title: detail.title,
      to: detail.investedTo,
      amount: num.tryParse(detail.investedAmount) ?? 0,
      pnl: num.tryParse(detail.pnlAmount ?? ''),
      status: detail.status,
      date: detail.createdDate,
    );
  }
}
