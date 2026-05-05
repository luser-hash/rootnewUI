import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../data/auth_repository.dart';
import '../domain/auth_session.dart';

enum AuthStatus { unknown, unauthenticated, authenticating, authenticated }

class AuthController extends ChangeNotifier {
  AuthController({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.unknown;
  AuthSession? _session;
  String? _errorMessage;

  AuthStatus get status => _status;
  AuthSession? get session => _session;
  AuthUser? get user => _session?.user;
  UserRole get role => _session?.user.role ?? UserRole.unknown;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isBusy => _status == AuthStatus.authenticating;

  Future<void> bootstrap() async {
    final AuthSession? restored = await _repository.restoreSession();
    _session = restored;
    _status = restored == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    notifyListeners();
  }

  Future<bool> signIn({
    required String phone,
    required String password,
    required bool rememberDevice,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      _session = await _repository.signIn(
        phone: phone,
        password: password,
        rememberDevice: rememberDevice,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _session = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (_) {
      _session = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Unable to sign in. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _repository.signOut(refreshToken: _session?.tokens.refreshToken);
    _session = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
