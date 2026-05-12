import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../shared/widgets/app_action_button.dart';
import '../../shared/widgets/app_message_card.dart';
import '../data/investment_repository.dart';
import '../domain/investment_create_request.dart';

class InvestmentCreatePage extends StatefulWidget {
  const InvestmentCreatePage({super.key, required this.repository});

  final InvestmentRepository repository;

  @override
  State<InvestmentCreatePage> createState() => _InvestmentCreatePageState();
}

class _InvestmentCreatePageState extends State<InvestmentCreatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _investedToController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  _InvestmentType _type = _InvestmentType.fixedDeposit;
  DateTime _createdDate = DateTime.now();
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _submitted = false;

  @override
  void dispose() {
    _titleController.dispose();
    _investedToController.dispose();
    _amountController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _InvestmentCreateHeader(onBack: () => _closePage(context)),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildFormCard(context),
        ),
      ],
    );
  }

  Widget _buildFormCard(BuildContext context) {
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
            if (_errorMessage != null) ...<Widget>[
              AppMessageCard(
                icon: Icons.error_outline,
                message: _errorMessage!,
                background: AppColors.redLt,
                foreground: AppColors.red,
                padding: const EdgeInsets.all(12),
                borderRadius: 14,
                iconSize: 18,
                compact: true,
              ),
              const SizedBox(height: 14),
            ],
            if (_submitted) ...<Widget>[
              const AppMessageCard(
                icon: Icons.check_circle_outline_rounded,
                message: 'Investment draft created successfully.',
                background: AppColors.greenLt,
                foreground: AppColors.green,
                padding: EdgeInsets.all(12),
                borderRadius: 14,
                iconSize: 18,
                compact: true,
              ),
              const SizedBox(height: 14),
            ],
            const _SectionLabel(title: 'Investment details'),
            const SizedBox(height: 12),
            _InvestmentTextField(
              controller: _titleController,
              label: 'Title',
              hint: 'Root Fixed Deposit',
              prefixIcon: Icons.title_rounded,
              validator: _required,
            ),
            const SizedBox(height: 14),
            _DropdownField<_InvestmentType>(
              label: 'Investment Type',
              value: _type,
              values: _InvestmentType.values,
              labelBuilder: (_InvestmentType value) => value.label,
              onChanged: _isSubmitting
                  ? null
                  : (_InvestmentType? value) {
                      if (value != null) {
                        setState(() => _type = value);
                      }
                    },
            ),
            const SizedBox(height: 14),
            _InvestmentTextField(
              controller: _investedToController,
              label: 'Invested To',
              hint: 'Bank Asia',
              prefixIcon: Icons.account_balance_outlined,
              validator: _required,
            ),
            const SizedBox(height: 14),
            _InvestmentTextField(
              controller: _amountController,
              label: 'Invested Amount',
              hint: '100000.00',
              prefixIcon: Icons.payments_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _amount,
            ),
            const SizedBox(height: 14),
            _DateField(
              value: _createdDate,
              onTap: _isSubmitting ? null : _pickDate,
            ),
            const SizedBox(height: 14),
            _InvestmentTextField(
              controller: _commentController,
              label: 'Comment',
              hint: 'Optional note',
              prefixIcon: Icons.notes_outlined,
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            AppActionButton(
              label: _isSubmitting
                  ? 'Creating Investment...'
                  : 'Create Investment',
              background: _isSubmitting
                  ? AppColors.textMute
                  : AppColors.primary,
              foreground: Colors.white,
              onTap: _isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    final String text = value?.trim() ?? '';
    return text.isEmpty ? 'This field is required.' : null;
  }

  String? _amount(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'This field is required.';
    }
    final num? parsed = num.tryParse(text);
    return parsed == null || parsed <= 0 ? 'Enter a valid amount.' : null;
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _createdDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _createdDate = picked);
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _submitted = false;
    });

    try {
      await widget.repository.create(
        InvestmentCreateRequest(
          title: _titleController.text.trim(),
          investmentType: _type.apiValue,
          investedTo: _investedToController.text.trim(),
          investedAmount: _amountController.text.trim(),
          createdDate: _createdDate,
          comment: _commentController.text.trim(),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _submitted = true;
      });
      context.pop(true);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Unable to create investment. Please try again.';
      });
    }
  }

  void _closePage(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(RouteNames.investments);
  }
}

class _InvestmentCreateHeader extends StatelessWidget {
  const _InvestmentCreateHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF1E3A5F), Color(0xFF152B45)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            tooltip: 'Back',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white24,
              minimumSize: const Size(42, 42),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Create Investment',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Prepare a draft investment record.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
    );
  }
}

class _InvestmentTextField extends StatelessWidget {
  const _InvestmentTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      decoration: _inputDecoration(
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
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: _inputDecoration(
        label: label,
        hint: '',
        prefixIcon: Icons.category_outlined,
      ),
      items: values
          .map(
            (T item) => DropdownMenuItem<T>(
              value: item,
              child: Text(labelBuilder(item)),
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
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: <Widget>[
              const Icon(Icons.event_outlined, color: AppColors.textMute),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Created date: ${_formatDate(value)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textMute,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration({
  required String label,
  required String hint,
  required IconData prefixIcon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(prefixIcon, color: AppColors.textMute),
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.red, width: 1.4),
    ),
  );
}

String _formatDate(DateTime value) {
  final String month = value.month.toString().padLeft(2, '0');
  final String day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

enum _InvestmentType {
  fixedDeposit('Fixed Deposit', 'FIXED_DEPOSIT'),
  equity('Equity', 'EQUITY'),
  realEstate('Real Estate', 'REAL_ESTATE'),
  lending('Lending', 'LENDING'),
  other('Other', 'OTHER');

  const _InvestmentType(this.label, this.apiValue);

  final String label;
  final String apiValue;
}
