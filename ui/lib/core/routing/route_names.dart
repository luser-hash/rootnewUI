/// Named route paths used across navigation calls.
///
/// Keeping paths centralized avoids hard-coded strings in UI files and helps
/// prevent route typos during refactors.
class RouteNames {
  const RouteNames._();

  static const String login = '/login';
  static const String home = '/';
  static const String profile = '/profile';
  static const String approvals = '/approvals';
  static const String investments = '/investments';
  static const String members = '/members';
  static const String memberDetail = '/members/detail';
  static const String memberDetailSegment = 'detail';
  static const String ledger = '/ledger';
}
