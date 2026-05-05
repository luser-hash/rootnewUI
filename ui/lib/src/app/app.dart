import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../features/auth/data/auth_api.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/auth_storage.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/auth_scope.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final SecureAuthStorage _authStorage;
  late final AuthController _authController;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _authStorage = SecureAuthStorage();
    final ApiClient apiClient = ApiClient(
      accessTokenProvider: () async {
        return _authController.session?.tokens.accessToken ??
            _authStorage.readAccessToken();
      },
    );

    _authController = AuthController(
      repository: ApiAuthRepository(
        api: AuthApi(apiClient),
        storage: _authStorage,
      ),
    );
    _router = AppRouter.router(_authController);
    _authController.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      controller: _authController,
      child: MaterialApp.router(
        title: 'Association Finance',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
