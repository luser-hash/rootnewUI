import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../shared/widgets/app_action_button.dart';
import '../../shared/widgets/app_form_fields.dart';
import '../../shared/widgets/app_message_card.dart';
import '../../shared/widgets/app_pill.dart';
import '../../shared/widgets/app_screen_header.dart';
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
            AppScreenHeader(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              gradientColors: const <Color>[
                AppColors.primaryDk,
                AppColors.primary,
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AppHeaderBackButton(onPressed: () => _closePage(context)),
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
            ),
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
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppThemeColors.shadow(context).withValues(alpha: .10),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
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
                tone: AppMessageTone.error,
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
                tone: AppMessageTone.success,
                padding: EdgeInsets.all(12),
                borderRadius: 14,
                showBorder: false,
              ),
              const SizedBox(height: 14),
            ],
            const AppSectionLabel(title: 'Member details'),
            const SizedBox(height: 12),
            AppTextFormField(
              controller: _nameController,
              label: 'Full name',
              icon: Icons.person_outline,
              validator: _required,
            ),
            const SizedBox(height: 12),
            AppTextFormField(
              controller: _phoneController,
              label: 'Contact number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: _required,
            ),
            const SizedBox(height: 12),
            AppTextFormField(
              controller: _emailController,
              label: 'Email address',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              validator: _email,
            ),
            const SizedBox(height: 12),
            AppDateField(
              value: _joinDate,
              label: 'Join date',
              onTap: () => _pickJoinDate(context),
            ),
            const SizedBox(height: 18),
            const AppSectionLabel(title: 'Access setup'),
            const SizedBox(height: 12),
            const AppReadOnlyField(
              label: 'Role',
              value: 'MEMBER',
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 12),
            AppPasswordField(
              controller: _passwordController,
              label: 'Initial password',
              obscureText: _obscurePassword,
              onToggleVisibility: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              validator: _password,
            ),
            const SizedBox(height: 12),
            AppTextFormField(
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
