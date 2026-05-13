class InvestmentCapitalSummary {
  const InvestmentCapitalSummary({
    required this.totalCapital,
    required this.openInvestedAmount,
    required this.availableInvestmentCapital,
  });

  final String totalCapital;
  final String openInvestedAmount;
  final String availableInvestmentCapital;

  factory InvestmentCapitalSummary.fromJson(Map<String, dynamic> json) {
    return InvestmentCapitalSummary(
      totalCapital: '${json['total_capital'] ?? '0.00'}',
      openInvestedAmount: '${json['open_invested_amount'] ?? '0.00'}',
      availableInvestmentCapital:
          '${json['available_investment_capital'] ?? '0.00'}',
    );
  }
}
