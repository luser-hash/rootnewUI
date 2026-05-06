import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../data/member_management_repository.dart';
import '../domain/member_create_request.dart';

class ManageMembersController extends ChangeNotifier {
  ManageMembersController({required MemberManagementRepository repository})
    : _repository = repository;

  final MemberManagementRepository _repository;

  bool _isSubmitting = false;
  String? _errorMessage;
  bool _submitted = false;

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get submitted => _submitted;

  Future<bool> create(MemberCreateRequest request) async {
    _isSubmitting = true;
    _errorMessage = null;
    _submitted = false;
    notifyListeners();

    try {
      await _repository.create(request);
      _submitted = true;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to create member. Please try again.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
