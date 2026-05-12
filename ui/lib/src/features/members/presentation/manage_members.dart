import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../shared/widgets/app_action_button.dart';
import '../../shared/widgets/app_message_card.dart';
import '../../shared/widgets/app_pill.dart';
import '../data/member_management_repository.dart';
import '../domain/member_create_request.dart';
import 'manage_members_controller.dart';

class ManageMembersPage extends StatefulWidget {
  const ManageMembersPage({super.key, required this.repository});

  final MemberManagementRepository repository;

  @override
  State<ManageMembersPage> createState() => _ManageMembersPageState();
}

class _ManageMembersPageState extends State<ManageMembersPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final ManageMembersController _controller;
  DateTime _joinDate = DateTime.now();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _controller = ManageMembersController(repository: widget.repository);
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    _passwordController.dispose();
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
            _ManageMembersHeader(onBack: () => _closePage(context)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: _buildFormCard(context),
            ),
          ],
        );
      },
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
            if (_controller.errorMessage != null) ...<Widget>[
              AppMessageCard(
                icon: Icons.error_outline,
                message: _controller.errorMessage!,
                background: AppColors.redLt,
                foreground: AppColors.red,
                textColor: AppColors.red,
                padding: const EdgeInsets.all(12),
                borderRadius: 14,
                showBorder: false,
              ),
              const SizedBox(height: 14),
            ],
            if (_controller.submitted) ...<Widget>[
              const AppMessageCard(
                icon: Icons.check_circle_outline,
                message: 'Member created successfully.',
                background: AppColors.greenLt,
                foreground: AppColors.green,
                textColor: AppColors.green,
                padding: EdgeInsets.all(12),
                borderRadius: 14,
                showBorder: false,
              ),
              const SizedBox(height: 14),
            ],
            const _SectionLabel(title: 'Member details'),
            const SizedBox(height: 12),
            _AppTextField(
              controller: _nameController,
              label: 'Full name',
              icon: Icons.person_outline,
              validator: _required,
            ),
            const SizedBox(height: 12),
            _AppTextField(
              controller: _phoneController,
              label: 'Contact number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: _required,
            ),
            const SizedBox(height: 12),
            _AppTextField(
              controller: _emailController,
              label: 'Email address',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              validator: _email,
            ),
            const SizedBox(height: 12),
            _JoinDateField(
              value: _joinDate,
              onTap: () => _pickJoinDate(context),
            ),
            const SizedBox(height: 18),
            const _SectionLabel(title: 'Access setup'),
            const SizedBox(height: 12),
            const _ReadOnlyRoleField(),
            const SizedBox(height: 12),
            _PasswordField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              onToggle: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              validator: _password,
            ),
            const SizedBox(height: 12),
            _AppTextField(
              controller: _notesController,
              label: 'Admin notes',
              icon: Icons.notes_outlined,
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            AppActionButton(
              label: _controller.isSubmitting
                  ? 'Creating Member...'
                  : 'Create Member',
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

  String? _required(String? value) {
    final String text = value?.trim() ?? '';
    return text.isEmpty ? 'This field is required.' : null;
  }

  String? _email(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'This field is required.';
    }
    return text.contains('@') ? null : 'Enter a valid email address.';
  }

  String? _password(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'This field is required.';
    }
    return text.length >= 8 ? null : 'Password must be at least 8 characters.';
  }

  Future<void> _pickJoinDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _joinDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _joinDate = picked);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final bool created = await _controller.create(
      MemberCreateRequest(
        fullName: _nameController.text.trim(),
        contactNo: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        joinDate: _joinDate,
        notes: _notesController.text.trim(),
        password: _passwordController.text,
      ),
    );

    if (!mounted) {
      return;
    }

    if (created) {
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _notesController.clear();
      _passwordController.clear();
      setState(() {
        _joinDate = DateTime.now();
        _obscurePassword = true;
      });
    }
  }

  void _closePage(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(RouteNames.members);
  }
}

class _ManageMembersHeader extends StatelessWidget {
  const _ManageMembersHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.primaryDk, AppColors.primary],
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Manage Members',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Create member accounts with MANAGE_USERS access.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              AppPill(
                label: 'ADMIN',
                background: AppColors.accent,
                foreground: Colors.white,
              ),
            ],
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

class _AppTextField extends StatelessWidget {
  const _AppTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textMute),
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
      ),
    );
  }
}

class _JoinDateField extends StatelessWidget {
  const _JoinDateField({required this.value, required this.onTap});

  final DateTime value;
  final VoidCallback onTap;

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
                  'Join date: ${_formatDate(value)}',
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

class _ReadOnlyRoleField extends StatelessWidget {
  const _ReadOnlyRoleField();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.badge_outlined, color: AppColors.textMute),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Role: MEMBER',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscureText,
    required this.onToggle,
    required this.validator,
  });

  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggle;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      decoration: InputDecoration(
        labelText: 'Initial password',
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMute),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.textMute,
          ),
          tooltip: obscureText ? 'Show password' : 'Hide password',
        ),
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
      ),
    );
  }
}

String _formatDate(DateTime value) {
  final String month = value.month.toString().padLeft(2, '0');
  final String day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
