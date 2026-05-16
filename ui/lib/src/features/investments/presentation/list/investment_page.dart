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
        icon: Icons.savings_outlined,
        message: 'No investments found.',
        tone: AppMessageTone.neutral,
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Distribute P&L?'),
          content: Text(
            'This will distribute the computed profit or loss for '
            '"${investment.title}" to all members using the captured capital '
            'snapshot.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Distribute'),
            ),
          ],
        );
      },
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
        ? 'P&L distributed successfully.'
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
