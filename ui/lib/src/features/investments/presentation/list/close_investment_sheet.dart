part of 'investment_page.dart';

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
