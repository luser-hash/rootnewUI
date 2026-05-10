class InvestmentCreateRequest {
  const InvestmentCreateRequest({
    required this.title,
    required this.investmentType,
    required this.investedTo,
    required this.investedAmount,
    required this.createdDate,
    required this.comment,
  });

  final String title;
  final String investmentType;
  final String investedTo;
  final String investedAmount;
  final DateTime createdDate;
  final String comment;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'investment_type': investmentType,
      'invested_to': investedTo,
      'invested_amount': investedAmount,
      'created_date': _formatDate(createdDate),
      'comment': comment,
    };
  }

  String _formatDate(DateTime value) {
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
