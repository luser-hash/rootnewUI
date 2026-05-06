import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../data/member_management_repository.dart';
import '../domain/member_management_models.dart';

class MemberDetailController extends ChangeNotifier {
  MemberDetailController({required MemberManagementRepository repository})
    : _repository = repository;

  final MemberManagementRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  ManagedUser? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ManagedUser? get user => _user;

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
      _user = await _repository.detail(userId);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load member profile. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
