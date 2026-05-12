import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../shared/widgets/app_action_button.dart';
import '../../shared/widgets/app_message_card.dart';
import '../data/capital_submission_repository.dart';
import '../domain/capital_submission_request.dart';
import 'capital_submission_controller.dart';

class SubmitFundsPage extends StatefulWidget {
  const SubmitFundsPage({super.key, required this.repository});

  final CapitalSubmissionRepository repository;

  @override
  State<SubmitFundsPage> createState() => _SubmitFundsPageState();
}

class _SubmitFundsPageState extends State<SubmitFundsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  late final CapitalSubmissionController _controller;
  CapitalRequestType _requestType = CapitalRequestType.installment;
  PaymentChannel _paymentChannel = PaymentChannel.bkash;
  DateTime _txnDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = CapitalSubmissionController(repository: widget.repository);
  }

  @override
  void dispose() {
    _controller.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _SubmitFundsHeader(),
            Padding(padding: const EdgeInsets.all(16), child: _buildFormCard()),
          ],
        );
      },
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[AppColors.softShadow(opacity: 0.10, blur: 12)],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (_controller.errorMessage != null) ...<Widget>[
              AppMessageCard(
                icon: Icons.error_outline,
                message: _controller.errorMessage!,
                background: AppColors.redLt,
                foreground: AppColors.red,
                padding: const EdgeInsets.all(12),
                borderRadius: 14,
                iconSize: 18,
                compact: true,
              ),
              const SizedBox(height: 14),
            ],
            if (_controller.submitted) ...<Widget>[
              const AppMessageCard(
                icon: Icons.check_circle_outline_rounded,
                message: 'Submission request created successfully.',
                background: AppColors.greenLt,
                foreground: AppColors.green,
                padding: EdgeInsets.all(12),
                borderRadius: 14,
                iconSize: 18,
                compact: true,
              ),
              const SizedBox(height: 14),
            ],
            _DropdownField<CapitalRequestType>(
              label: 'Request Type',
              value: _requestType,
              values: CapitalRequestType.values,
              labelBuilder: (CapitalRequestType value) => value.label,
              onChanged: (CapitalRequestType? value) {
                if (value != null) {
                  setState(() => _requestType = value);
                }
              },
            ),
            const SizedBox(height: 14),
            _SubmissionTextField(
              controller: _amountController,
              label: 'Amount',
              hint: '5000.00',
              prefixIcon: Icons.payments_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _validateAmount,
            ),
            const SizedBox(height: 14),
            _DateField(value: _txnDate, onTap: _pickDate),
            const SizedBox(height: 14),
            _DropdownField<PaymentChannel>(
              label: 'Payment Channel',
              value: _paymentChannel,
              values: PaymentChannel.values,
              labelBuilder: (PaymentChannel value) => value.label,
              onChanged: (PaymentChannel? value) {
                if (value != null) {
                  setState(() => _paymentChannel = value);
                }
              },
            ),
            const SizedBox(height: 14),
            _SubmissionTextField(
              controller: _referenceController,
              label: 'External Reference',
              hint: 'TXN123456789',
              prefixIcon: Icons.receipt_long_outlined,
              validator: _required('External reference is required'),
            ),
            const SizedBox(height: 14),
            _SubmissionTextField(
              controller: _notesController,
              label: 'Notes',
              hint: 'June installment',
              prefixIcon: Icons.notes_outlined,
              maxLines: 3,
              validator: _required('Notes are required'),
            ),
            const SizedBox(height: 22),
            AppActionButton(
              label: _controller.isSubmitting
                  ? 'Submitting...'
                  : 'Submit Request',
              background: _controller.isSubmitting
                  ? AppColors.textMute
                  : AppColors.primary,
              foreground: Colors.white,
              onTap: _controller.isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  String? _validateAmount(String? value) {
    final String raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return 'Amount is required';
    }

    final double? amount = double.tryParse(raw);
    if (amount == null || amount <= 0) {
      return 'Enter a valid amount';
    }
    return null;
  }

  FormFieldValidator<String> _required(String message) {
    return (String? value) {
      final String raw = value?.trim() ?? '';
      return raw.isEmpty ? message : null;
    };
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _txnDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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

    final bool success = await _controller.submit(
      CapitalSubmissionRequest(
        requestType: _requestType,
        amount: _formatAmount(_amountController.text),
        txnDate: _txnDate,
        paymentChannel: _paymentChannel,
        externalReference: _referenceController.text.trim(),
        notes: _notesController.text.trim(),
      ),
    );

    if (!mounted || !success) {
      return;
    }

    _amountController.clear();
    _referenceController.clear();
    _notesController.clear();
  }

  String _formatAmount(String value) {
    final double amount = double.parse(value.trim());
    return amount.toStringAsFixed(2);
  }
}

class _SubmitFundsHeader extends StatelessWidget {
  const _SubmitFundsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.primary,
            AppColors.primaryDk,
            Color(0xFF003830),
          ],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Submit Funds',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.15,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create a capital submission request for review.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: Color(0xCFFFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmissionTextField extends StatelessWidget {
  const _SubmissionTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final int maxLines;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      decoration: _fieldDecoration(
        label: label,
        hint: hint,
        prefixIcon: prefixIcon,
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.values,
    required this.labelBuilder,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) labelBuilder;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: _fieldDecoration(
        label: label,
        hint: label,
        prefixIcon: Icons.tune_rounded,
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      items: values
          .map(
            (T value) => DropdownMenuItem<T>(
              value: value,
              child: Text(labelBuilder(value)),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.onTap});

  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: _fieldDecoration(
          label: 'Transaction Date',
          hint: 'Transaction Date',
          prefixIcon: Icons.calendar_today_outlined,
        ),
        child: Text(
          _formatDate(value),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

InputDecoration _fieldDecoration({
  required String label,
  required String hint,
  required IconData prefixIcon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.textMute),
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    labelStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppColors.textMute,
    ),
    hintStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textMute,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.red, width: 1.5),
    ),
  );
}
