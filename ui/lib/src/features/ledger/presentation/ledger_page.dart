import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../shared/widgets/app_card_list.dart';
import '../data/member_ledger_repository.dart';
import '../domain/member_ledger_statement.dart';
import 'admin_ledger_controller.dart';

class LedgerPage extends StatefulWidget {
  const LedgerPage({super.key, required this.repository});

  final MemberLedgerRepository repository;

  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  late final AdminLedgerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AdminLedgerController(repository: widget.repository);
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
        final AdminLedgerStatement? statement = _controller.statement;
        return Column(
          children: <Widget>[
            _LedgerHeader(
              statement: statement,
              isPosting: _controller.isPosting,
              onAdd: _showAdminPostSheet,
            ),
            _LedgerFilters(
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

  Widget _buildBody(AdminLedgerStatement? statement) {
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
        message: 'No ledger entries found.',
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
            (MapEntry<int, MemberLedgerEntry> entry) => _LedgerRow(
              entry: entry.value,
              isLast: entry.key == entries.length - 1,
            ),
          )
          .toList(),
    );
  }

  Future<void> _showAdminPostSheet() async {
    final AdminLedgerPostResult? result =
        await showModalBottomSheet<AdminLedgerPostResult>(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppColors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          builder: (BuildContext context) {
            return _AdminLedgerPostSheet(
              onSubmit: _controller.adminPost,
              errorMessage: () => _controller.postErrorMessage,
            );
          },
        );

    if (!mounted || result == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ledger entry posted. New balance ${result.newBalance}.'),
      ),
    );
  }
}

class _LedgerHeader extends StatelessWidget {
  const _LedgerHeader({
    required this.statement,
    required this.isPosting,
    required this.onAdd,
  });

  final AdminLedgerStatement? statement;
  final bool isPosting;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final List<({String label, String value})> stats =
        <({String label, String value})>[
          (label: 'Total In', value: _formatCompactMoney(statement?.totalIn)),
          (label: 'Total Out', value: _formatCompactMoney(statement?.totalOut)),
          (label: 'Entries', value: '${statement?.entryCount ?? 0}'),
        ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF003D35), AppColors.primaryDk],
        ),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Capital Ledger',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Tooltip(
                  message: 'Post ledger entry',
                  child: Material(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(13),
                    child: InkWell(
                      onTap: isPosting ? null : onAdd,
                      borderRadius: BorderRadius.circular(13),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          isPosting
                              ? Icons.hourglass_empty_rounded
                              : Icons.add,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: stats.map((({String label, String value}) s) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: s.label == stats.last.label ? 0 : 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        s.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.label,
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

class _AdminLedgerPostSheet extends StatefulWidget {
  const _AdminLedgerPostSheet({
    required this.onSubmit,
    required this.errorMessage,
  });

  final Future<AdminLedgerPostResult?> Function(AdminLedgerPostRequest request)
  onSubmit;
  final String? Function() errorMessage;

  @override
  State<_AdminLedgerPostSheet> createState() => _AdminLedgerPostSheetState();
}

class _AdminLedgerPostSheetState extends State<_AdminLedgerPostSheet> {
  static const List<MemberLedgerEntryType> _allowedTypes =
      <MemberLedgerEntryType>[
        MemberLedgerEntryType.submission,
        MemberLedgerEntryType.withdraw,
        MemberLedgerEntryType.adjustment,
      ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();

  MemberLedgerEntryType _entryType = MemberLedgerEntryType.adjustment;
  DateTime _txnDate = DateTime.now();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _contactNoController.dispose();
    _amountController.dispose();
    _commentController.dispose();
    _referenceController.dispose();
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
                      color: AppColors.greenLt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Post Ledger Entry',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Create a direct admin ledger adjustment.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMute,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_errorMessage != null) ...<Widget>[
                const SizedBox(height: 14),
                _InlineError(message: _errorMessage!),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactNoController,
                decoration: _fieldDecoration(
                  label: 'Contact No',
                  icon: Icons.phone_outlined,
                ),
                validator: _required,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<MemberLedgerEntryType>(
                initialValue: _entryType,
                decoration: _fieldDecoration(
                  label: 'Entry Type',
                  icon: Icons.tune_rounded,
                ),
                items: _allowedTypes
                    .map(
                      (MemberLedgerEntryType type) =>
                          DropdownMenuItem<MemberLedgerEntryType>(
                            value: type,
                            child: Text(type.label),
                          ),
                    )
                    .toList(),
                onChanged: _isSubmitting
                    ? null
                    : (MemberLedgerEntryType? value) {
                        if (value != null) {
                          setState(() => _entryType = value);
                        }
                      },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: _fieldDecoration(
                  label: 'Amount',
                  icon: Icons.payments_outlined,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                validator: _amount,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              _DateFilterButton(
                label: 'Txn Date',
                value: _txnDate,
                onTap: _pickTxnDate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _commentController,
                decoration: _fieldDecoration(
                  label: 'Comment',
                  icon: Icons.notes_outlined,
                ),
                validator: _required,
                minLines: 2,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _referenceController,
                decoration: _fieldDecoration(
                  label: 'Reference ID',
                  icon: Icons.tag_outlined,
                ),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: Icon(
                  _isSubmitting
                      ? Icons.hourglass_empty_rounded
                      : Icons.add_rounded,
                ),
                label: Text(
                  _isSubmitting ? 'Posting Entry...' : 'Post Entry',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) {
    return (value?.trim().isEmpty ?? true) ? 'This field is required.' : null;
  }

  String? _amount(String? value) {
    final String text = value?.trim() ?? '';
    final num? amount = num.tryParse(text);
    if (amount == null) {
      return 'Enter a valid amount.';
    }
    if (amount == 0) {
      return 'Amount cannot be zero.';
    }
    if (_entryType == MemberLedgerEntryType.submission && amount <= 0) {
      return 'Submission amount must be positive.';
    }
    if (_entryType == MemberLedgerEntryType.withdraw && amount >= 0) {
      return 'Withdraw amount must be negative.';
    }
    return null;
  }

  Future<void> _pickTxnDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _txnDate,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _txnDate = picked);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final AdminLedgerPostResult? result = await widget.onSubmit(
      AdminLedgerPostRequest(
        contactNo: _contactNoController.text.trim(),
        entryType: _entryType,
        amount: _amountController.text.trim(),
        txnDate: _txnDate,
        comment: _commentController.text.trim(),
        referenceId: _referenceController.text.trim(),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result != null) {
      Navigator.of(context).pop(result);
      return;
    }

    setState(() {
      _isSubmitting = false;
      _errorMessage =
          widget.errorMessage() ?? 'Unable to post ledger entry.';
    });
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.redLt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.red.withValues(alpha: .18)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.error_outline, color: AppColors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
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

class _LedgerFilters extends StatefulWidget {
  const _LedgerFilters({
    required this.filter,
    required this.onChanged,
    required this.onClear,
  });

  final MemberLedgerFilter filter;
  final ValueChanged<MemberLedgerFilter> onChanged;
  final VoidCallback? onClear;

  @override
  State<_LedgerFilters> createState() => _LedgerFiltersState();
}

class _LedgerFiltersState extends State<_LedgerFilters> {
  late final TextEditingController _userIdController;

  @override
  void initState() {
    super.initState();
    _userIdController = TextEditingController(text: widget.filter.userId ?? '');
  }

  @override
  void didUpdateWidget(covariant _LedgerFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String nextUserId = widget.filter.userId ?? '';
    if (nextUserId != _userIdController.text) {
      _userIdController.text = nextUserId;
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MemberLedgerFilter filter = widget.filter;
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
              widget.onChanged(
                MemberLedgerFilter(
                  entryType: entryType,
                  fromDate: filter.fromDate,
                  toDate: filter.toDate,
                  userId: filter.userId,
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
                      widget.onChanged(
                        MemberLedgerFilter(
                          entryType: filter.entryType,
                          fromDate: date,
                          toDate: filter.toDate,
                          userId: filter.userId,
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
                      widget.onChanged(
                        MemberLedgerFilter(
                          entryType: filter.entryType,
                          fromDate: filter.fromDate,
                          toDate: date,
                          userId: filter.userId,
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (widget.onClear != null) ...<Widget>[
                const SizedBox(width: 8),
                Material(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: widget.onClear,
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
          const SizedBox(height: 10),
          TextField(
            controller: _userIdController,
            decoration: _fieldDecoration(
              label: 'Member User ID',
              icon: Icons.person_search_rounded,
            ).copyWith(suffixIcon: _UserIdApplyButton(onTap: _applyUserId)),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _applyUserId(),
          ),
        ],
      ),
    );
  }

  void _applyUserId() {
    widget.onChanged(
      MemberLedgerFilter(
        entryType: widget.filter.entryType,
        fromDate: widget.filter.fromDate,
        toDate: widget.filter.toDate,
        userId: _userIdController.text.trim(),
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

class _UserIdApplyButton extends StatelessWidget {
  const _UserIdApplyButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: 'Apply member filter',
      icon: const Icon(Icons.search_rounded, color: AppColors.textMute),
    );
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

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.entry, required this.isLast});

  final MemberLedgerEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final double amount = double.tryParse(entry.amount) ?? 0;
    final bool positive = _isInflow(entry.entryType, amount);
    final Color bg = _entryBackground(entry.entryType);
    final Color fg = _entryForeground(entry.entryType);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLedgerDetails(context, entry),
        child: Container(
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
                      entry.memberName.isEmpty
                          ? entry.entryType.label
                          : entry.memberName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.memberContact.isEmpty
                          ? '${entry.referenceType} · ${entry.referenceId}'
                          : entry.memberContact,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMute,
                      ),
                    ),
                    Text(
                      entry.comment.isEmpty
                          ? '${entry.entryType.label} · ${entry.ledgerId}'
                          : entry.comment,
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
                    '${positive ? '+' : '-'}${_formatMoney(entry.amount)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: positive ? AppColors.green : AppColors.red,
                    ),
                  ),
                  Text(
                    entry.txnDate,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMute,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLedgerDetails(BuildContext context, MemberLedgerEntry entry) {
    final double amount = double.tryParse(entry.amount) ?? 0;
    final bool positive = _isInflow(entry.entryType, amount);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
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
                        color: _entryBackground(entry.entryType),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _entryIcon(entry.entryType),
                        size: 18,
                        color: _entryForeground(entry.entryType),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            entry.memberName.isEmpty
                                ? entry.entryType.label
                                : entry.memberName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            entry.memberContact.isEmpty
                                ? entry.userId
                                : entry.memberContact,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMute,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${positive ? '+' : '-'}${_formatMoney(entry.amount)}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: positive ? AppColors.green : AppColors.red,
                  ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.45,
                  children: <Widget>[
                    _DetailBox(label: 'Type', value: entry.entryType.label),
                    _DetailBox(label: 'Currency', value: entry.currency),
                    _DetailBox(label: 'Txn Date', value: entry.txnDate),
                    _DetailBox(
                      label: 'Created',
                      value: _formatDateTime(entry.createdAt),
                    ),
                    _DetailBox(
                      label: 'Reference Type',
                      value: entry.referenceType.isEmpty
                          ? '-'
                          : entry.referenceType,
                    ),
                    _DetailBox(
                      label: 'Reference ID',
                      value: entry.referenceId.isEmpty
                          ? '-'
                          : entry.referenceId,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _DetailTextBlock(label: 'Ledger ID', value: entry.ledgerId),
                if (entry.userId.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  _DetailTextBlock(label: 'User ID', value: entry.userId),
                ],
                if (entry.comment.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  _DetailTextBlock(label: 'Comment', value: entry.comment),
                ],
                if (entry.createdByName.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  _DetailTextBlock(
                    label: 'Created By',
                    value: entry.createdByName,
                  ),
                ],
              ],
            ),
          ),
        );
      },
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

class _DetailBox extends StatelessWidget {
  const _DetailBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMute,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTextBlock extends StatelessWidget {
  const _DetailTextBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMute,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
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

bool _isInflow(MemberLedgerEntryType type, double amount) {
  if (amount < 0) {
    return false;
  }
  return switch (type) {
    MemberLedgerEntryType.withdraw => false,
    MemberLedgerEntryType.distributionReversal => false,
    _ => true,
  };
}

String _formatMoney(String? value) {
  final double amount = double.tryParse(value ?? '0') ?? 0;
  return '৳${amount.abs().toStringAsFixed(2)}';
}

String _formatCompactMoney(String? value) {
  final double amount = double.tryParse(value ?? '0')?.abs() ?? 0;
  if (amount >= 1000) {
    return '৳${(amount / 1000).toStringAsFixed(1)}K';
  }
  return '৳${amount.toStringAsFixed(0)}';
}

String _formatDate(DateTime value) {
  final String month = value.month.toString().padLeft(2, '0');
  final String day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

String _formatDateTime(DateTime? value) {
  if (value == null) {
    return '-';
  }

  final DateTime local = value.toLocal();
  final String month = local.month.toString().padLeft(2, '0');
  final String day = local.day.toString().padLeft(2, '0');
  final String hour = local.hour.toString().padLeft(2, '0');
  final String minute = local.minute.toString().padLeft(2, '0');
  return '${local.year}-$month-$day $hour:$minute';
}
