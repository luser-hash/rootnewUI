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
        : AppThemeColors.border(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 1.5),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppThemeColors.shadow(context).withValues(alpha: .15),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppThemeColors.text(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      inv.to,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppThemeColors.textMuted(context),
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
                  background: AppThemeColors.surface(context),
                  color: AppThemeColors.text(context),
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  valueStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppThemeColors.text(context),
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
                      ? AppThemeColors.surface(context)
                      : pnl >= 0
                      ? AppThemeColors.statusSuccessBg(context)
                      : AppThemeColors.statusErrorBg(context),
                  color: pnl == null
                      ? AppThemeColors.textMuted(context)
                      : pnl >= 0
                      ? AppThemeColors.statusSuccessFg(context)
                      : AppThemeColors.statusErrorFg(context),
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  valueStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: pnl == null
                        ? AppThemeColors.textMuted(context)
                        : pnl >= 0
                        ? AppThemeColors.statusSuccessFg(context)
                        : AppThemeColors.statusErrorFg(context),
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
                        ? AppThemeColors.surface(context)
                        : AppThemeColors.statusWarningBg(context),
                    foreground: actionsDisabled && !isReleasing
                        ? AppThemeColors.textMuted(context)
                        : AppThemeColors.statusWarningFg(context),
                    onTap: actionsDisabled ? null : onReleaseFunds,
                  ),
                ),
              if (canManageActions && inv.status == InvestmentStatus.open)
                Expanded(
                  child: AppActionButton(
                    label: isClosing ? 'Closing...' : 'Close',
                    background: AppThemeColors.surface(context),
                    foreground: actionsDisabled && !isClosing
                        ? AppThemeColors.textMuted(context)
                        : AppThemeColors.text(context),
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
                        ? AppThemeColors.surface(context)
                        : AppColors.primary,
                    foreground: actionsDisabled && !isDistributing
                        ? AppThemeColors.textMuted(context)
                        : Colors.white,
                    onTap: actionsDisabled ? null : onDistribute,
                  ),
                ),
              if (hasPrimaryAction) const SizedBox(width: 8),
              AppSmallButton(
                label: 'Details',
                background: AppThemeColors.surface(context),
                foreground: AppThemeColors.textMid(context),
                onTap: onDetails,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
