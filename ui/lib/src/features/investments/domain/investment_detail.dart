import '../../shared/finance.dart';

class InvestmentDetail {
  const InvestmentDetail({
    required this.id,
    required this.title,
    required this.investmentType,
    required this.investedTo,
    required this.investedAmount,
    required this.createdDate,
    required this.comment,
    required this.status,
    required this.fundReleasedAt,
    required this.fundReleasedBy,
    required this.closeDate,
    required this.returnAmount,
    required this.pnlAmount,
    required this.closureComment,
    required this.hasSnapshot,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String investmentType;
  final String investedTo;
  final String investedAmount;
  final String createdDate;
  final String comment;
  final InvestmentStatus status;
  final DateTime? fundReleasedAt;
  final String? fundReleasedBy;
  final String? closeDate;
  final String? returnAmount;
  final String? pnlAmount;
  final String closureComment;
  final bool hasSnapshot;
  final InvestmentCreatedBy? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

class InvestmentCreatedBy {
  const InvestmentCreatedBy({required this.userId, required this.fullName});

  final String userId;
  final String fullName;
}
