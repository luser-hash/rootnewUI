part of 'admin_ledger_page.dart';

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
                      color: AppThemeColors.statusSuccessBg(context),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: AppThemeColors.statusSuccessFg(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Post Ledger Entry',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppThemeColors.text(context),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Create a direct admin ledger adjustment.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppThemeColors.textMuted(context),
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
                  context: context,
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
                  context: context,
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
                  context: context,
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
                  context: context,
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
                  context: context,
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
      _errorMessage = widget.errorMessage() ?? 'Unable to post ledger entry.';
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
        color: AppThemeColors.statusErrorBg(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppThemeColors.statusErrorFg(context).withValues(alpha: .2),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.error_outline, color: AppColors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppThemeColors.textMid(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
