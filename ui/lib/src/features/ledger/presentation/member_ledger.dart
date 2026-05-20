import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../shared/finance.dart';
import '../../shared/widgets/app_card_list.dart';
import '../../shared/widgets/app_data_table.dart';
import '../../shared/widgets/app_message_card.dart';
import '../../shared/widgets/app_screen_header.dart';
import '../data/member_ledger_repository.dart';
import '../domain/member_ledger_statement.dart';
import 'member_ledger_controller.dart';

class MemberLedgerPage extends StatefulWidget {
  const MemberLedgerPage({super.key, required this.repository});

  final MemberLedgerRepository repository;

  @override
  State<MemberLedgerPage> createState() => _MemberLedgerPageState();
}

class _MemberLedgerPageState extends State<MemberLedgerPage> {
  late final MemberLedgerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MemberLedgerController(repository: widget.repository);
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
        final MemberLedgerStatement? statement = _controller.statement;

        return Column(
          children: <Widget>[
            _MemberLedgerHeaderContent(statement: statement),
            _MemberLedgerFilters(
              filter: _controller.filter,
              onChanged: (MemberLedgerFilter filter) {
                _controller.load(filter: filter);
              },
              onClear: _controller.filter.hasFilters
                  ? _controller.clearFilters
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
              child: _buildBody(statement),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(MemberLedgerStatement? statement) {
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
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(18),
        borderRadius: 18,
      );
    }

    final List<MemberLedgerEntry> entries =
        statement?.entries ?? <MemberLedgerEntry>[];
    if (entries.isEmpty) {
      return const AppMessageCard(
        icon: Icons.menu_book_outlined,
        message: 'No ledger entries found for your account.',
        tone: AppMessageTone.neutral,
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.all(18),
        borderRadius: 18,
      );
    }

    return AppCardList(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      children: entries
          .asMap()
          .entries
          .map(
            (MapEntry<int, MemberLedgerEntry> entry) => _MemberLedgerRow(
              entry: entry.value,
              isLast: entry.key == entries.length - 1,
            ),
          )
          .toList(),
    );
  }
}

class _MemberLedgerHeaderContent extends StatelessWidget {
  const _MemberLedgerHeaderContent({required this.statement});

  final MemberLedgerStatement? statement;

  @override
  Widget build(BuildContext context) {
    final List<({String label, String value})> stats =
        <({String label, String value})>[
          (
            label: 'Balance',
            value: formatMoneyTextSigned(statement?.currentBalance),
          ),
          (
            label: 'Pending',
            value: formatMoneyTextSigned(statement?.pendingTotal),
          ),
          (label: 'Entries', value: '${statement?.entryCount ?? 0}'),
        ];

    return AppScreenHeader(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      gradientColors: const <Color>[Color(0xFF003D35), AppColors.primaryDk],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'My Ledger Statement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Balance includes posted entries only.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: .62),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: stats.map((({String label, String value}) stat) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: stat.label == stats.last.label ? 0 : 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        stat.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stat.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: .55),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MemberLedgerFilters extends StatelessWidget {
  const _MemberLedgerFilters({
    required this.filter,
    required this.onChanged,
    required this.onClear,
  });

  final MemberLedgerFilter filter;
  final ValueChanged<MemberLedgerFilter> onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        children: <Widget>[
          DropdownButtonFormField<MemberLedgerEntryType?>(
            initialValue: filter.entryType,
            decoration: _fieldDecoration(
              context: context,
              label: 'Entry Type',
              icon: Icons.tune_rounded,
            ),
            items: <DropdownMenuItem<MemberLedgerEntryType?>>[
              const DropdownMenuItem<MemberLedgerEntryType?>(
                value: null,
                child: Text('All Types'),
              ),
              ...MemberLedgerEntryType.values.map(
                (MemberLedgerEntryType value) =>
                    DropdownMenuItem<MemberLedgerEntryType?>(
                      value: value,
                      child: Text(value.label),
                    ),
              ),
            ],
            onChanged: (MemberLedgerEntryType? entryType) {
              onChanged(
                MemberLedgerFilter(
                  entryType: entryType,
                  walletType: filter.walletType,
                  fromDate: filter.fromDate,
                  toDate: filter.toDate,
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<LedgerWalletType?>(
            initialValue: filter.walletType,
            decoration: _fieldDecoration(
              context: context,
              label: 'Wallet',
              icon: Icons.account_balance_wallet_outlined,
            ),
            items: <DropdownMenuItem<LedgerWalletType?>>[
              const DropdownMenuItem<LedgerWalletType?>(
                value: null,
                child: Text('All Wallets'),
              ),
              ...LedgerWalletType.values.map(
                (LedgerWalletType value) => DropdownMenuItem<LedgerWalletType?>(
                  value: value,
                  child: Text(value.label),
                ),
              ),
            ],
            onChanged: (LedgerWalletType? walletType) {
              onChanged(
                MemberLedgerFilter(
                  entryType: filter.entryType,
                  walletType: walletType,
                  fromDate: filter.fromDate,
                  toDate: filter.toDate,
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: _DateFilterButton(
                  label: 'From',
                  value: filter.fromDate,
                  onTap: () => _pickDate(
                    context: context,
                    initialDate: filter.fromDate,
                    onPicked: (DateTime date) {
                      onChanged(
                        MemberLedgerFilter(
                          entryType: filter.entryType,
                          walletType: filter.walletType,
                          fromDate: date,
                          toDate: filter.toDate,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateFilterButton(
                  label: 'To',
                  value: filter.toDate,
                  onTap: () => _pickDate(
                    context: context,
                    initialDate: filter.toDate,
                    onPicked: (DateTime date) {
                      onChanged(
                        MemberLedgerFilter(
                          entryType: filter.entryType,
                          walletType: filter.walletType,
                          fromDate: filter.fromDate,
                          toDate: date,
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (onClear != null) ...<Widget>[
                const SizedBox(width: 8),
                Material(
                  color: AppThemeColors.card(context),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: onClear,
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 46,
                      height: 54,
                      child: Icon(
                        Icons.close_rounded,
                        color: AppThemeColors.textMuted(context),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate({
    required BuildContext context,
    required DateTime? initialDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) {
      onPicked(picked);
    }
  }
}

class _DateFilterButton extends StatelessWidget {
  const _DateFilterButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppThemeColors.card(context),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppThemeColors.border(context)),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppThemeColors.textMuted(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppThemeColors.textMuted(context),
                      ),
                    ),
                    Text(
                      value == null ? 'Any date' : _formatDate(value!),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppThemeColors.text(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberLedgerRow extends StatelessWidget {
  const _MemberLedgerRow({required this.entry, required this.isLast});

  final MemberLedgerEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final double amount = double.tryParse(entry.amount) ?? 0;
    final bool positive = amount >= 0;
    final Color bg = _entryBackground(context, entry.entryType);
    final Color fg = _entryForeground(context, entry.entryType);

    return AppTableRow(
      expandCells: false,
      showTopBorder: false,
      showBottomBorder: !isLast,
      background: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      cells: <Widget>[
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(_entryIcon(entry.entryType), size: 18, color: fg),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppTextCell(
                entry.entryType.label,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(height: 2),
              AppTextCell(
                entry.comment.isEmpty
                    ? _entryMeta(entry)
                    : entry.comment,
                maxLines: 1,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppThemeColors.textMuted(context),
              ),
              if (entry.createdByName.isNotEmpty)
                AppTextCell(
                  '${entry.walletType.label} · By ${entry.createdByName}',
                  maxLines: 1,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: AppThemeColors.textMuted(context),
                ),
              if (entry.createdByName.isEmpty &&
                  _entryMeta(entry) != entry.walletType.label)
                AppTextCell(
                  entry.walletType.label,
                  maxLines: 1,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: AppThemeColors.textMuted(context),
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            AppTextCell(
              '${positive ? '+' : ''}${formatMoneyTextSigned(entry.amount)}',
              color: positive
                  ? AppThemeColors.statusSuccessFg(context)
                  : AppThemeColors.statusErrorFg(context),
              fontSize: 14,
            ),
            AppTextCell(
              entry.txnDate,
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppThemeColors.textMuted(context),
            ),
          ],
        ),
      ],
    );
  }
}

String _entryMeta(MemberLedgerEntry entry) {
  final String reference = <String>[
    entry.referenceType,
    entry.referenceId,
  ].where((String value) => value.trim().isNotEmpty).join(' · ');
  return reference.isEmpty ? entry.walletType.label : reference;
}

InputDecoration _fieldDecoration({
  required BuildContext context,
  required String label,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20, color: AppThemeColors.textMuted(context)),
    filled: true,
    fillColor: AppThemeColors.card(context),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    labelStyle: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppThemeColors.textMuted(context),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppThemeColors.border(context)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
  );
}

Color _entryBackground(BuildContext context, MemberLedgerEntryType type) {
  return switch (type) {
    MemberLedgerEntryType.submission => AppThemeColors.statusSuccessBg(context),
    MemberLedgerEntryType.withdraw => AppThemeColors.statusErrorBg(context),
    MemberLedgerEntryType.adjustment => AppThemeColors.statusWarningBg(context),
    MemberLedgerEntryType.distribution => AppThemeColors.statusInfoBg(context),
    MemberLedgerEntryType.distributionReversal => AppThemeColors.statusErrorBg(
      context,
    ),
  };
}

Color _entryForeground(BuildContext context, MemberLedgerEntryType type) {
  return switch (type) {
    MemberLedgerEntryType.submission => AppThemeColors.statusSuccessFg(context),
    MemberLedgerEntryType.withdraw => AppThemeColors.statusErrorFg(context),
    MemberLedgerEntryType.adjustment => AppThemeColors.statusWarningFg(context),
    MemberLedgerEntryType.distribution => AppThemeColors.statusInfoFg(context),
    MemberLedgerEntryType.distributionReversal => AppThemeColors.statusErrorFg(
      context,
    ),
  };
}

IconData _entryIcon(MemberLedgerEntryType type) {
  return switch (type) {
    MemberLedgerEntryType.submission => Icons.south_rounded,
    MemberLedgerEntryType.withdraw => Icons.north_rounded,
    MemberLedgerEntryType.adjustment => Icons.tune_rounded,
    MemberLedgerEntryType.distribution => Icons.call_split_rounded,
    MemberLedgerEntryType.distributionReversal => Icons.undo_rounded,
  };
}

String _formatDate(DateTime value) {
  final String month = value.month.toString().padLeft(2, '0');
  final String day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
