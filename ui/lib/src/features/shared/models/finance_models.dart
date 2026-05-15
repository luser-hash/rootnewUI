class Member {
  const Member({
    required this.id,
    required this.name,
    required this.initials,
    required this.capital,
    required this.status,
    required this.pending,
  });

  final String id;
  final String name;
  final String initials;
  final int capital;
  final MemberStatus status;
  final int pending;
}

enum MemberStatus { active, inactive }

extension MemberStatusX on MemberStatus {
  String get label => this == MemberStatus.active ? 'ACTIVE' : 'INACTIVE';
}

enum SubmissionStatus { pending, approved, rejected }

extension SubmissionStatusX on SubmissionStatus {
  String get label {
    switch (this) {
      case SubmissionStatus.pending:
        return 'PENDING';
      case SubmissionStatus.approved:
        return 'APPROVED';
      case SubmissionStatus.rejected:
        return 'REJECTED';
    }
  }
}

class Investment {
  const Investment({
    required this.id,
    required this.title,
    required this.to,
    required this.amount,
    required this.pnl,
    required this.status,
    required this.date,
  });

  final String id;
  final String title;
  final String to;
  final num amount;
  final num? pnl;
  final InvestmentStatus status;
  final String date;
}

enum InvestmentStatus { distributed, closed, open, draft, reversed }

extension InvestmentStatusX on InvestmentStatus {
  String get label {
    switch (this) {
      case InvestmentStatus.distributed:
        return 'DISTRIBUTED';
      case InvestmentStatus.closed:
        return 'CLOSED';
      case InvestmentStatus.open:
        return 'OPEN';
      case InvestmentStatus.draft:
        return 'DRAFT';
      case InvestmentStatus.reversed:
        return 'REVERSED';
    }
  }
}
