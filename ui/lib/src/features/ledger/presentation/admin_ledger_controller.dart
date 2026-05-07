import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../data/member_ledger_repository.dart';
import '../domain/member_ledger_statement.dart';

class AdminLedgerController extends ChangeNotifier {
  AdminLedgerController({required MemberLedgerRepository repository})
    : _repository = repository;

  final MemberLedgerRepository _repository;

  bool _isLoading = false;
  bool _isPosting = false;
  String? _errorMessage;
  String? _postErrorMessage;
  MemberLedgerFilter _filter = const MemberLedgerFilter();
  AdminLedgerStatement? _statement;

  bool get isLoading => _isLoading;
  bool get isPosting => _isPosting;
  String? get errorMessage => _errorMessage;
  String? get postErrorMessage => _postErrorMessage;
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

  Future<AdminLedgerPostResult?> adminPost(
    AdminLedgerPostRequest request,
  ) async {
    if (_isPosting) {
      return null;
    }

    _isPosting = true;
    _postErrorMessage = null;
    notifyListeners();

    try {
      final AdminLedgerPostResult result = await _repository.adminPost(request);
      await load();
      return result;
    } on ApiException catch (error) {
      _postErrorMessage = error.message;
      return null;
    } catch (_) {
      _postErrorMessage = 'Unable to post ledger entry. Please try again.';
      return null;
    } finally {
      _isPosting = false;
      notifyListeners();
    }
  }
}
