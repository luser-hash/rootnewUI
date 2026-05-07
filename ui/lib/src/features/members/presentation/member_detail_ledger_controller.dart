import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../ledger/data/member_ledger_repository.dart';
import '../../ledger/domain/member_ledger_statement.dart';

class MemberDetailLedgerController extends ChangeNotifier {
  MemberDetailLedgerController({required MemberLedgerRepository repository})
    : _repository = repository;

  final MemberLedgerRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  MemberLedgerStatement? _statement;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MemberLedgerStatement? get statement => _statement;

  Future<void> load(String userId) async {
    if (userId.trim().isEmpty) {
      _errorMessage = 'Missing member ID.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _statement = await _repository.memberStatement(userId);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load member ledger. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
