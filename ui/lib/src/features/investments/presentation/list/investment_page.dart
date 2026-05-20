import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../auth/domain/auth_session.dart';
import '../../../auth/presentation/auth_scope.dart';
import '../../../reports/data/staff_report_repository.dart';
import '../../../shared/finance.dart';
import '../../../shared/widgets/app_action_button.dart';
import '../../../shared/widgets/app_metric_card.dart';
import '../../../shared/widgets/app_message_card.dart';
import '../../../shared/widgets/app_screen_header.dart';
import '../../../shared/widgets/app_small_button.dart';
import '../../../shared/widgets/status_pills.dart';
import '../../data/investment_repository.dart';
import '../../domain/investment_close_request.dart';
import '../../domain/investment_capital_summary.dart';
import '../investment_controller.dart';
import '../investment_detail_page.dart';
import '../pnl_wallet.dart';

part 'investments_header.dart';
part 'investment_full_card.dart';
part 'close_investment_sheet.dart';

class InvestmentPage extends StatefulWidget {
  const InvestmentPage({
    super.key,
    required this.repository,
    required this.staffReportRepository,
  });

  final InvestmentRepository repository;
  final StaffReportRepository staffReportRepository;

  @override
  State<InvestmentPage> createState() => _InvestmentPageState();
}

class _InvestmentPageState extends State<InvestmentPage> {
  late final InvestmentController _controller;

  @override
  void initState() {
    super.initState();
    _controller = InvestmentController(repository: widget.repository);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        final List<Investment> items = _controller.investments;
        final UserRole role = AuthScope.of(context).role;
        final bool canManageInvestments = role.canViewAllInvestments;

        return Column(
          children: <Widget>[
            _InvestmentsHeaderContent(
              investments: items,
              capitalSummary: _controller.capitalSummary,
              onCreate: _openCreatePage,
              onWalletTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return PnlWalletPage(
                        repository: widget.staffReportRepository,
                      );
                    },
                  ),
                );
              },
              canCreate: canManageInvestments,
              showSummary: canManageInvestments,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: _buildBody(
                items,
                canManageInvestments: canManageInvestments,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(
    List<Investment> items, {
    required bool canManageInvestments,
  }) {
    if (_controller.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 32),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final String? error = _controller.errorMessage;
    if (error != null) {
      return AppMessageCard(
        icon: Icons.error_outline,
        message: error,
        tone: AppMessageTone.error,
        fullWidth: true,
      );
    }

    if (items.isEmpty) {
      return const AppMessageCard(
        icon: Icons.account_balance_wallet_outlined,
        message: 'No investments found.',
        tone: AppMessageTone.neutral,
        foreground: AppColors.blue,
        fullWidth: true,
      );
    }

    return Column(
      children: items
          .map(
            (Investment inv) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _InvestmentFullCard(
                inv: inv,
                onDetails: () => _showDetails(inv),
                onPnlTap: () {
                  context.push(RouteNames.investmentDistribution(inv.id));
                },
                onReleaseFunds: () => _releaseFunds(inv),
                onCloseInvestment: () => _closeInvestment(inv),
                onDistribute: () => _distribute(inv),
                onDelete: () => _deleteInvestment(inv),
                isReleasing: _controller.releasingInvestmentId == inv.id,
                isClosing: _controller.closingInvestmentId == inv.id,
                isDistributing: _controller.distributingInvestmentId == inv.id,
                isDeleting: _controller.deletingInvestmentId == inv.id,
                actionsDisabled: _controller.hasActionInFlight,
                canManageActions: canManageInvestments,
              ),
            ),
          )
          .toList(),
    );
  }

  Future<void> _showDetails(Investment investment) async {
    final BuildContext pageContext = context;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppThemeColors.card(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (BuildContext context) {
        return InvestmentDetailPage(
          investment: investment,
          detailFuture: widget.repository.detail(investment.id),
          onDistributionRecord: () {
            Navigator.of(context).pop();
            pageContext.push(RouteNames.investmentDistribution(investment.id));
          },
        );
      },
    );
  }

  Future<void> _openCreatePage() async {
    final bool? created = await context.push<bool>(RouteNames.investmentCreate);
    if (created == true) {
      await _controller.load();
    }
  }

  Future<void> _releaseFunds(Investment investment) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Release funds?'),
          content: Text(
            'This will open "${investment.title}" and capture the current '
            'member capital snapshot. This snapshot is used for future '
            'distribution calculations.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Release Funds'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    final bool released = await _controller.releaseFunds(investment.id);
    if (!mounted) {
      return;
    }

    const String fallbackMessage = 'Unable to release funds. Please try again.';
    final String message = released
        ? 'Funds released successfully.'
        : (_controller.actionErrorMessage ?? fallbackMessage);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _closeInvestment(Investment investment) async {
    final InvestmentCloseRequest? request =
        await showModalBottomSheet<InvestmentCloseRequest>(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppThemeColors.card(context),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          builder: (BuildContext context) {
            return _CloseInvestmentSheet(investment: investment);
          },
        );

    if (!mounted || request == null) {
      return;
    }

    final bool closed = await _controller.closeInvestment(
      investment.id,
      request,
    );
    if (!mounted) {
      return;
    }

    const String fallbackMessage =
        'Unable to close investment. Please try again.';
    final String message = closed
        ? 'Investment closed successfully.'
        : (_controller.actionErrorMessage ?? fallbackMessage);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _distribute(Investment investment) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) =>
          _DistributionConfirmationDialog(investment: investment),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    final bool distributed = await _controller.distribute(investment.id);
    if (!mounted) {
      return;
    }

    const String fallbackMessage =
        'Unable to distribute P&L. Please try again.';
    final String message = distributed
        ? 'Profit/Loss distributed to Profit Wallets.'
        : (_controller.actionErrorMessage ?? fallbackMessage);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _deleteInvestment(Investment investment) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete draft investment?'),
          content: Text(
            'This will permanently delete "${investment.title}". This action '
            'is only available for draft investments.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    final bool deleted = await _controller.delete(investment.id);
    if (!mounted) {
      return;
    }

    const String fallbackMessage =
        'Unable to delete investment. Please try again.';
    final String message = deleted
        ? 'Investment deleted successfully.'
        : (_controller.actionErrorMessage ?? fallbackMessage);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _DistributionConfirmationDialog extends StatelessWidget {
  const _DistributionConfirmationDialog({required this.investment});

  final Investment investment;

  @override
  Widget build(BuildContext context) {
    final num? pnl = investment.pnl;
    final bool positivePnl = (pnl ?? 0) >= 0;
    final Color pnlColor = pnl == null
        ? AppThemeColors.textMuted(context)
        : positivePnl
        ? AppThemeColors.statusSuccessFg(context)
        : AppThemeColors.statusErrorFg(context);

    return AlertDialog(
      title: const Text('Distribute P&L?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            investment.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppThemeColors.text(context),
            ),
          ),
          const SizedBox(height: 12),
          _DistributionPreviewRow(
            label: 'Invested amount',
            value: fmt(investment.amount),
          ),
          const SizedBox(height: 8),
          _DistributionPreviewRow(
            label: 'P&L',
            value: pnl == null
                ? 'Pending'
                : '${positivePnl ? '+' : '-'}${fmt(pnl)}',
            valueColor: pnlColor,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppThemeColors.statusInfoBg(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppThemeColors.statusInfoFg(
                  context,
                ).withValues(alpha: .18),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 18,
                  color: AppColors.blue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "This posts each member's share to their Profit Wallet. "
                    'It will not be added to capital.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w800,
                      color: AppThemeColors.textMid(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Distribute to Profit Wallet'),
        ),
      ],
    );
  }
}

class _DistributionPreviewRow extends StatelessWidget {
  const _DistributionPreviewRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.textMuted(context),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: valueColor ?? AppThemeColors.text(context),
            ),
          ),
        ),
      ],
    );
  }
}
