part of 'investment_page.dart';

class _InvestmentFullCard extends StatelessWidget {
  const _InvestmentFullCard({
    required this.inv,
    required this.onDetails,
    required this.onPnlTap,
    required this.onReleaseFunds,
    required this.onCloseInvestment,
    required this.onDistribute,
    required this.isReleasing,
    required this.isClosing,
    required this.isDistributing,
    required this.actionsDisabled,
    required this.canManageActions,
  });

  final Investment inv;
  final VoidCallback onDetails;
  final VoidCallback onPnlTap;
  final VoidCallback onReleaseFunds;
  final VoidCallback onCloseInvestment;
  final VoidCallback onDistribute;
  final bool isReleasing;
  final bool isClosing;
  final bool isDistributing;
  final bool actionsDisabled;
  final bool canManageActions;

  @override
  Widget build(BuildContext context) {
    final num? pnl = inv.pnl;
    final bool hasPrimaryAction =
        canManageActions &&
        (inv.status == InvestmentStatus.draft ||
            inv.status == InvestmentStatus.open ||
            inv.status == InvestmentStatus.closed);
    final Color border = inv.status == InvestmentStatus.open
        ? AppColors.primary.withValues(alpha: .3)
        : inv.status == InvestmentStatus.draft
        ? AppColors.amber.withValues(alpha: .3)
        : AppColors.border;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 1.5),
        boxShadow: <BoxShadow>[AppColors.softShadow()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      inv.title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      inv.to,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMute,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              InvestmentStatusPill(status: inv.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: AppMetricCard(
                  label: 'Invested',
                  value: fmt(inv.amount),
                  background: AppColors.surface,
                  color: AppColors.text,
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  valueStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppMetricCard(
                  label: 'P&L Detail',
                  value: pnl == null
                      ? 'Pending'
                      : '${pnl >= 0 ? '+' : '-'}${fmt(pnl)}',
                  background: pnl == null
                      ? AppColors.surface
                      : pnl >= 0
                      ? AppColors.greenLt
                      : AppColors.redLt,
                  color: pnl == null
                      ? AppColors.textMute
                      : pnl >= 0
                      ? AppColors.green
                      : AppColors.red,
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  valueStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: pnl == null
                        ? AppColors.textMute
                        : pnl >= 0
                        ? AppColors.green
                        : AppColors.red,
                  ),
                  onTap: onPnlTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              if (canManageActions && inv.status == InvestmentStatus.draft)
                Expanded(
                  child: AppActionButton(
                    label: isReleasing ? 'Releasing...' : 'Release Funds',
                    background: actionsDisabled && !isReleasing
                        ? AppColors.surface
                        : AppColors.amberLt,
                    foreground: actionsDisabled && !isReleasing
                        ? AppColors.textMute
                        : AppColors.amber,
                    onTap: actionsDisabled ? null : onReleaseFunds,
                  ),
                ),
              if (canManageActions && inv.status == InvestmentStatus.open)
                Expanded(
                  child: AppActionButton(
                    label: isClosing ? 'Closing...' : 'Close',
                    background: AppColors.surface,
                    foreground: actionsDisabled && !isClosing
                        ? AppColors.textMute
                        : AppColors.text,
                    onTap: actionsDisabled ? null : onCloseInvestment,
                  ),
                ),
              if (canManageActions && inv.status == InvestmentStatus.closed)
                Expanded(
                  child: AppActionButton(
                    label: isDistributing
                        ? 'Distributing...'
                        : 'Distribute P&L',
                    background: actionsDisabled && !isDistributing
                        ? AppColors.surface
                        : AppColors.primary,
                    foreground: actionsDisabled && !isDistributing
                        ? AppColors.textMute
                        : Colors.white,
                    onTap: actionsDisabled ? null : onDistribute,
                  ),
                ),
              if (hasPrimaryAction) const SizedBox(width: 8),
              AppSmallButton(
                label: 'Details',
                background: AppColors.surface,
                foreground: AppColors.textMid,
                onTap: onDetails,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
