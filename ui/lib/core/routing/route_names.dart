/// Named route paths used across navigation calls.
///
/// Keeping paths centralized avoids hard-coded strings in UI files and helps
/// prevent route typos during refactors.
class RouteNames {
  const RouteNames._();

  static const String login = '/login';
  static const String home = '/';
  static const String profile = '/profile';
  static const String submitFunds = '/submit-funds';
  static const String submissions = '/submissions';
  static const String submissionDetailSegment = ':requestId';
  static const String approvals = '/approvals';
  static const String investments = '/investments';
  static const String investmentCreate = '/investments/create';
  static const String investmentCreateSegment = 'create';
  static const String investmentDistributionSegment =
      ':investmentId/distribution';
  static const String members = '/members';
  static const String manageMembers = '/members/manage';
  static const String manageMembersSegment = 'manage';
  static const String memberDetail = '/members/detail';
  static const String memberDetailSegment = 'detail';
  static const String editMember = '/members/detail/edit';
  static const String editMemberSegment = 'edit';
  static const String ledger = '/ledger';
  static const String memberLedger = '/member-ledger';
  static const String memberReport = '/reports/member';
  static const String staffReport = '/reports/staff';

  static String submissionDetail(String requestId) {
    return '$submissions/$requestId';
  }

  static String investmentDistribution(String investmentId) {
    return '$investments/${Uri.encodeComponent(investmentId)}/distribution';
  }
}
