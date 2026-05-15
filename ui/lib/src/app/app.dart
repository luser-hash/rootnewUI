import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../features/activity/data/activity_api.dart';
import '../features/activity/data/activity_repository.dart';
import '../features/auth/data/auth_api.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/auth_storage.dart';
import '../features/auth/domain/auth_session.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/auth_scope.dart';
import '../features/investments/data/investment_api.dart';
import '../features/investments/data/investment_repository.dart';
import '../features/ledger/data/member_ledger_api.dart';
import '../features/ledger/data/member_ledger_repository.dart';
import '../features/members/data/member_management_api.dart';
import '../features/members/data/member_management_repository.dart';
import '../features/reports/data/member_report_api.dart';
import '../features/reports/data/member_report_repository.dart';
import '../features/reports/data/staff_report_api.dart';
import '../features/reports/data/staff_report_repository.dart';
import '../features/submissions/data/capital_submission_api.dart';
import '../features/submissions/data/capital_submission_repository.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final SecureAuthStorage _authStorage;
  late final AuthController _authController;
  late final ActivityRepository _activityRepository;
  late final CapitalSubmissionRepository _capitalSubmissionRepository;
  late final InvestmentRepository _investmentRepository;
  late final MemberLedgerRepository _memberLedgerRepository;
  late final MemberManagementRepository _memberManagementRepository;
  late final MemberReportRepository _memberReportRepository;
  late final StaffReportRepository _staffReportRepository;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _authStorage = SecureAuthStorage();
    late final ApiAuthRepository authRepository;
    final ApiClient apiClient = ApiClient(
      accessTokenProvider: () async {
        return await _authStorage.readAccessToken() ??
            _authController.session?.tokens.accessToken;
      },
      unauthorizedTokenRefresher: () async {
        final AuthSession? refreshed = await authRepository.refreshSession(
          session: _authController.session,
        );
        if (refreshed != null) {
          _authController.syncSession(refreshed);
        }
        return refreshed?.tokens.accessToken;
      },
    );

    authRepository = ApiAuthRepository(
      api: AuthApi(apiClient),
      storage: _authStorage,
    );
    _authController = AuthController(repository: authRepository);
    _activityRepository = ApiActivityRepository(api: ActivityApi(apiClient));
    _capitalSubmissionRepository = ApiCapitalSubmissionRepository(
      api: CapitalSubmissionApi(apiClient),
    );
    _investmentRepository = ApiInvestmentRepository(
      api: InvestmentApi(apiClient),
    );
    _memberLedgerRepository = ApiMemberLedgerRepository(
      api: MemberLedgerApi(apiClient),
    );
    _memberManagementRepository = ApiMemberManagementRepository(
      api: MemberManagementApi(apiClient),
    );
    _memberReportRepository = ApiMemberReportRepository(
      api: MemberReportApi(apiClient),
    );
    _staffReportRepository = ApiStaffReportRepository(
      api: StaffReportApi(apiClient),
    );
    _router = AppRouter.router(
      authController: _authController,
      activityRepository: _activityRepository,
      capitalSubmissionRepository: _capitalSubmissionRepository,
      investmentRepository: _investmentRepository,
      memberLedgerRepository: _memberLedgerRepository,
      memberManagementRepository: _memberManagementRepository,
      memberReportRepository: _memberReportRepository,
      staffReportRepository: _staffReportRepository,
    );
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
