import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../data/member_management_repository.dart';
import '../domain/member_management_models.dart';

class MemberListController extends ChangeNotifier {
  MemberListController({required MemberManagementRepository repository})
    : _repository = repository;

  final MemberManagementRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  ManagedUserFilter _filter = const ManagedUserFilter();
  List<ManagedUser> _users = <ManagedUser>[];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ManagedUserFilter get filter => _filter;
  List<ManagedUser> get users => List<ManagedUser>.unmodifiable(_users);

  Future<void> load({ManagedUserFilter? filter}) async {
    _isLoading = true;
    _errorMessage = null;
    _filter = filter ?? _filter;
    notifyListeners();

    try {
      _users = await _repository.list(filter: _filter);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load members. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
