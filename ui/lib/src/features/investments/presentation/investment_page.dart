import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../auth/domain/auth_session.dart';
import '../../auth/presentation/auth_scope.dart';
import '../../reports/data/staff_report_repository.dart';
import '../../shared/finance.dart';
import '../../shared/widgets/app_action_button.dart';
import '../../shared/widgets/app_metric_card.dart';
import '../../shared/widgets/app_message_card.dart';
import '../../shared/widgets/app_screen_header.dart';
import '../../shared/widgets/app_small_button.dart';
import '../../shared/widgets/status_pills.dart';
import '../data/investment_repository.dart';
import '../domain/investment_close_request.dart';
import '../domain/investment_capital_summary.dart';
import 'investment_controller.dart';
import 'investment_detail_page.dart';
import 'p&l_wallet.dart';

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
              canCreate: role.canViewAllInvestments,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: _buildBody(items),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(List<Investment> items) {
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
        background: AppColors.redLt,
        foreground: AppColors.red,
        fullWidth: true,
      );
    }

    if (items.isEmpty) {
      return const AppMessageCard(
        icon: Icons.savings_outlined,
        message: 'No investments found.',
        background: AppColors.surface,
        foreground: AppColors.textMute,
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
                isReleasing: _controller.releasingInvestmentId == inv.id,
                isClosing: _controller.closingInvestmentId == inv.id,
                isDistributing: _controller.distributingInvestmentId == inv.id,
                actionsDisabled: _controller.hasActionInFlight,
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
      backgroundColor: AppColors.white,
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
          backgroundColor: AppColors.white,
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
}

class _InvestmentsHeaderContent extends StatelessWidget {
  const _InvestmentsHeaderContent({
    required this.investments,
    required this.capitalSummary,
    required this.onCreate,
    required this.onWalletTap,
    required this.canCreate,
  });

  final List<Investment> investments;
  final InvestmentCapitalSummary? capitalSummary;
  final VoidCallback onCreate;
  final VoidCallback onWalletTap;
  final bool canCreate;

  @override
  Widget build(BuildContext context) {
    final num pnlTotal = investments.fold<num>(
      0,
      (num sum, Investment item) => sum + (item.pnl ?? 0),
    );
    final InvestmentCapitalSummary? summary = capitalSummary;
    final List<({String label, String value})> stats =
        <({String label, String value})>[
          (
            label: 'Capital',
            value: summary == null
                ? '--'
                : _formatHeaderMoney(summary.totalCapital),
          ),
          (
            label: 'Open Invested',
            value: summary == null
                ? '--'
                : _formatHeaderMoney(summary.openInvestedAmount),
          ),
          (
            label: 'Available',
            value: summary == null
                ? '--'
                : _formatHeaderMoney(summary.availableInvestmentCapital),
          ),
        ];

    return AppScreenHeader(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      gradientColors: const <Color>[Color(0xFF1E3A5F), Color(0xFF152B45)],
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Investments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                if (canCreate)
                  AppSmallButton(
                    label: '+ Create',
                    background: Colors.white.withValues(alpha: .15),
                    foreground: Colors.white,
                    onTap: onCreate,
                  ),
              ],
            ),
          ),
          Row(
            children: stats
                .map(
                  (({String label, String value}) s) => Expanded(
                        child: _HeaderStatTile(
                          label: s.label,
                          value: s.value,
                          margin: EdgeInsets.only(
                            right: s.label == stats.last.label ? 0 : 8,
                          ),
                        ),
                      ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          _PnlWalletButton(
            value: '${pnlTotal >= 0 ? '+' : '-'}${fmtSh(pnlTotal)}',
            onTap: onWalletTap,
          ),
        ],
      ),
    );
  }
}

class _PnlWalletButton extends StatelessWidget {
  const _PnlWalletButton({required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(12);

    return Material(
      color: Colors.white.withValues(alpha: .12),
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'P&L Wallet',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Colors.white.withValues(alpha: .7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderStatTile extends StatelessWidget {
  const _HeaderStatTile({
    required this.label,
    required this.value,
    required this.margin,
  });

  final String label;
  final String value;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(12);

    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 30,
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: .68),
                ),
              ),
            ),
          ),
          Material(
            color: Colors.white.withValues(alpha: .12),
            borderRadius: borderRadius,
            child: Container(
              height: 72,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatHeaderMoney(String value, {bool absolute = false}) {
  final num parsed = num.tryParse(value) ?? 0;
  final num amount = absolute ? parsed.abs() : parsed;
  final String sign = amount < 0 ? '-' : '';
  final String whole = amount.abs().round().toString();
  return '$sign৳${_groupHeaderMoney(whole)}';
}

String _groupHeaderMoney(String whole) {
  if (whole.length <= 3) {
    return whole;
  }

  final String lastThree = whole.substring(whole.length - 3);
  String head = whole.substring(0, whole.length - 3);
  final List<String> groups = <String>[];

  while (head.length > 2) {
    groups.insert(0, head.substring(head.length - 2));
    head = head.substring(0, head.length - 2);
  }
  if (head.isNotEmpty) {
    groups.insert(0, head);
  }

  return '${groups.join(',')},$lastThree';
}

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

  @override
  Widget build(BuildContext context) {
    final num? pnl = inv.pnl;
    final bool hasPrimaryAction =
        inv.status == InvestmentStatus.draft ||
        inv.status == InvestmentStatus.open ||
        inv.status == InvestmentStatus.closed;
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
              if (inv.status == InvestmentStatus.draft)
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
              if (inv.status == InvestmentStatus.open)
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
              if (inv.status == InvestmentStatus.closed)
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

class _CloseInvestmentSheet extends StatefulWidget {
  const _CloseInvestmentSheet({required this.investment});

  final Investment investment;

  @override
  State<_CloseInvestmentSheet> createState() => _CloseInvestmentSheetState();
}

class _CloseInvestmentSheetState extends State<_CloseInvestmentSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _returnAmountController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  DateTime _closeDate = DateTime.now();

  @override
  void dispose() {
    _returnAmountController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          18,
          18,
          18,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Close Investment',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.investment.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMute,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _returnAmountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Return Amount',
                  hintText: _amountHint(widget.investment.amount),
                  prefixIcon: const Icon(Icons.payments_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: _amount,
              ),
              const SizedBox(height: 14),
              Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _pickCloseDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: AppColors.textMute,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'Close Date',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMute,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _formatDate(_closeDate),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _commentController,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Closure Comment',
                  hintText: 'Optional note',
                  prefixIcon: const Icon(Icons.notes_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AppActionButton(
                label: 'Close Investment',
                background: AppColors.primary,
                foreground: Colors.white,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _amount(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'This field is required.';
    }
    final num? parsed = num.tryParse(text);
    return parsed == null || parsed < 0 ? 'Enter a valid amount.' : null;
  }

  Future<void> _pickCloseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _closeDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _closeDate = picked);
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    Navigator.of(context).pop(
      InvestmentCloseRequest(
        returnAmount: _returnAmountController.text.trim(),
        closeDate: _closeDate,
        closureComment: _commentController.text.trim(),
      ),
    );
  }
}

String _amountHint(num amount) {
  return amount.toStringAsFixed(2);
}

String _formatDate(DateTime value) {
  final String month = value.month.toString().padLeft(2, '0');
  final String day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
