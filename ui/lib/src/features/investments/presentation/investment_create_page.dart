import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../shared/widgets/app_action_button.dart';
import '../../shared/widgets/app_form_fields.dart';
import '../../shared/widgets/app_message_card.dart';
import '../../shared/widgets/app_screen_header.dart';
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
        AppScreenHeader(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          gradientColors: const <Color>[Color(0xFF1E3A5F), Color(0xFF152B45)],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppHeaderBackButton(onPressed: () => _closePage(context)),
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
        ),
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
            const AppSectionLabel(title: 'Investment details'),
            const SizedBox(height: 12),
            AppTextFormField(
              controller: _titleController,
              label: 'Title',
              hint: 'Root Fixed Deposit',
              icon: Icons.title_rounded,
              validator: _required,
            ),
            const SizedBox(height: 14),
            AppDropdownField<_InvestmentType>(
              label: 'Investment Type',
              value: _type,
              values: _InvestmentType.values,
              icon: Icons.category_outlined,
              hint: '',
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
            AppTextFormField(
              controller: _investedToController,
              label: 'Invested To',
              hint: 'Bank Asia',
              icon: Icons.account_balance_outlined,
              validator: _required,
            ),
            const SizedBox(height: 14),
            AppTextFormField(
              controller: _amountController,
              label: 'Invested Amount',
              hint: '100000.00',
              icon: Icons.payments_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _amount,
            ),
            const SizedBox(height: 14),
            AppDateField(
              value: _createdDate,
              label: 'Created date',
              onTap: _isSubmitting ? null : _pickDate,
            ),
            const SizedBox(height: 14),
            AppTextFormField(
              controller: _commentController,
              label: 'Comment',
              hint: 'Optional note',
              icon: Icons.notes_outlined,
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
