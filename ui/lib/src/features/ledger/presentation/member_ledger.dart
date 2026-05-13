import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../shared/widgets/app_card_list.dart';
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
      return _MessageCard(
        icon: Icons.error_outline,
        message: error,
        background: AppColors.redLt,
        foreground: AppColors.red,
      );
    }

    final List<MemberLedgerEntry> entries =
        statement?.entries ?? <MemberLedgerEntry>[];
    if (entries.isEmpty) {
      return const _MessageCard(
        icon: Icons.menu_book_outlined,
        message: 'No ledger entries found for your account.',
        background: AppColors.surface,
        foreground: AppColors.textMute,
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
            value: _formatMoney(statement?.currentBalance ?? '0.00'),
          ),
          (
            label: 'Pending',
            value: _formatMoney(statement?.pendingTotal ?? '0.00'),
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
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: onClear,
                    borderRadius: BorderRadius.circular(12),
                    child: const SizedBox(
                      width: 46,
                      height: 54,
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.textMute,
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
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.textMute,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMute,
                      ),
                    ),
                    Text(
                      value == null ? 'Any date' : _formatDate(value!),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
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
    final Color bg = _entryBackground(entry.entryType);
    final Color fg = _entryForeground(entry.entryType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: <Widget>[
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
                Text(
                  entry.entryType.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.comment.isEmpty
                      ? '${entry.referenceType} · ${entry.referenceId}'
                      : entry.comment,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMute,
                  ),
                ),
                if (entry.createdByName.isNotEmpty)
                  Text(
                    'By ${entry.createdByName}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMute,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '${positive ? '+' : ''}${_formatMoney(entry.amount)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: positive ? AppColors.green : AppColors.red,
                ),
              ),
              Text(
                entry.txnDate,
                style: const TextStyle(fontSize: 11, color: AppColors.textMute),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.message,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String message;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: foreground.withValues(alpha: .18)),
        boxShadow: <BoxShadow>[AppColors.softShadow(opacity: 0.10, blur: 10)],
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: foreground),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: AppColors.textMid,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _fieldDecoration({
  required String label,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20, color: AppColors.textMute),
    filled: true,
    fillColor: AppColors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    labelStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppColors.textMute,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
  );
}

Color _entryBackground(MemberLedgerEntryType type) {
  return switch (type) {
    MemberLedgerEntryType.submission => AppColors.greenLt,
    MemberLedgerEntryType.withdraw => AppColors.redLt,
    MemberLedgerEntryType.adjustment => AppColors.amberLt,
    MemberLedgerEntryType.distribution => AppColors.blueLt,
    MemberLedgerEntryType.distributionReversal => AppColors.redLt,
  };
}

Color _entryForeground(MemberLedgerEntryType type) {
  return switch (type) {
    MemberLedgerEntryType.submission => AppColors.green,
    MemberLedgerEntryType.withdraw => AppColors.red,
    MemberLedgerEntryType.adjustment => AppColors.amber,
    MemberLedgerEntryType.distribution => AppColors.blue,
    MemberLedgerEntryType.distributionReversal => AppColors.red,
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

String _formatMoney(String value) {
  final double amount = double.tryParse(value) ?? 0;
  final String sign = amount < 0 ? '-' : '';
  final String fixed = amount.abs().toStringAsFixed(2);
  return '$sign৳$fixed';
}

String _formatDate(DateTime value) {
  final String month = value.month.toString().padLeft(2, '0');
  final String day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
