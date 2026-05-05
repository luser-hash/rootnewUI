import '../models/finance_models.dart';

class MemberMetrics {
  const MemberMetrics._();

  static int totalActiveCapital(Iterable<Member> members) {
    return members
        .where((Member member) => member.status == MemberStatus.active)
        .fold(0, (int sum, Member member) => sum + member.capital);
  }

  static int activeMemberCount(Iterable<Member> members) {
    return members.where((Member member) => member.status == MemberStatus.active).length;
  }

  static int capitalSharePercent({
    required int memberCapital,
    required int totalCapital,
  }) {
    if (totalCapital <= 0) {
      return 0;
    }
    return ((memberCapital / totalCapital) * 100).round();
  }
}
