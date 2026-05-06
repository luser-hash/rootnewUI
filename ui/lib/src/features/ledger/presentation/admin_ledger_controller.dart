import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../data/member_ledger_repository.dart';
import '../domain/member_ledger_statement.dart';

class AdminLedgerController extends ChangeNotifier {
  AdminLedgerController({required MemberLedgerRepository repository})
    : _repository = repository;

  final MemberLedgerRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  MemberLedgerFilter _filter = const MemberLedgerFilter();
  AdminLedgerStatement? _statement;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MemberLedgerFilter get filter => _filter;
  AdminLedgerStatement? get statement => _statement;

  Future<void> load({MemberLedgerFilter? filter}) async {
    _isLoading = true;
    _errorMessage = null;
    _filter = filter ?? _filter;
    notifyListeners();

    try {
      _statement = await _repository.adminLedger(_filter);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load admin ledger. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearFilters() {
    return load(filter: const MemberLedgerFilter());
  }
}
