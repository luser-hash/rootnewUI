import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../shared/widgets/app_action_button.dart';
import '../../shared/widgets/app_form_fields.dart';
import '../../shared/widgets/app_message_card.dart';
import '../../shared/widgets/app_screen_header.dart';
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
            const AppScreenHeader(
              title: 'Submit Funds',
              subtitle: 'Create a capital submission request for review.',
              padding: EdgeInsets.fromLTRB(20, 14, 20, 26),
              gradientColors: <Color>[
                AppColors.primary,
                AppColors.primaryDk,
                Color(0xFF003830),
              ],
              titleFontSize: 24,
              subtitleFontSize: 13,
            ),
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
            AppDropdownField<CapitalRequestType>(
              label: 'Request Type',
              value: _requestType,
              values: CapitalRequestType.values,
              hint: 'Request Type',
              icon: Icons.tune_rounded,
              dropdownIcon: const Icon(Icons.keyboard_arrow_down_rounded),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
              focusedBorderWidth: 1.5,
              borderSideNone: false,
              labelBuilder: (CapitalRequestType value) => value.label,
              onChanged: (CapitalRequestType? value) {
                if (value != null) {
                  setState(() => _requestType = value);
                }
              },
            ),
            const SizedBox(height: 14),
            AppTextFormField(
              controller: _amountController,
              label: 'Amount',
              hint: '5000.00',
              icon: Icons.payments_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _validateAmount,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
              prefixIconSize: 20,
              focusedBorderWidth: 1.5,
              borderSideNone: false,
            ),
            const SizedBox(height: 14),
            AppDateField(
              value: _txnDate,
              onTap: _pickDate,
              label: 'Transaction Date',
              icon: Icons.calendar_today_outlined,
              inputDecorator: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
              focusedBorderWidth: 1.5,
              borderSideNone: false,
            ),
            const SizedBox(height: 14),
            AppDropdownField<PaymentChannel>(
              label: 'Payment Channel',
              value: _paymentChannel,
              values: PaymentChannel.values,
              hint: 'Payment Channel',
              icon: Icons.tune_rounded,
              dropdownIcon: const Icon(Icons.keyboard_arrow_down_rounded),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
              focusedBorderWidth: 1.5,
              borderSideNone: false,
              labelBuilder: (PaymentChannel value) => value.label,
              onChanged: (PaymentChannel? value) {
                if (value != null) {
                  setState(() => _paymentChannel = value);
                }
              },
            ),
            const SizedBox(height: 14),
            AppTextFormField(
              controller: _referenceController,
              label: 'External Reference',
              hint: 'TXN123456789',
              icon: Icons.receipt_long_outlined,
              validator: _required('External reference is required'),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
              prefixIconSize: 20,
              focusedBorderWidth: 1.5,
              borderSideNone: false,
            ),
            const SizedBox(height: 14),
            AppTextFormField(
              controller: _notesController,
              label: 'Notes',
              hint: 'June installment',
              icon: Icons.notes_outlined,
              maxLines: 3,
              validator: _required('Notes are required'),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
              prefixIconSize: 20,
              focusedBorderWidth: 1.5,
              borderSideNone: false,
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
