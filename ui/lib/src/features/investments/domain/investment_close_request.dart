class InvestmentCloseRequest {
  const InvestmentCloseRequest({
    required this.returnAmount,
    required this.closeDate,
    required this.closureComment,
  });

  final String returnAmount;
  final DateTime closeDate;
  final String closureComment;

  Map<String, dynamic> toJson() {
    final String trimmedComment = closureComment.trim();
    return <String, dynamic>{
      'return_amount': returnAmount.trim(),
      'close_date': _formatDate(closeDate),
      if (trimmedComment.isNotEmpty) 'closure_comment': trimmedComment,
    };
  }

  String _formatDate(DateTime value) {
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
