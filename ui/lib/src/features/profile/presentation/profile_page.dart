import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../auth/domain/auth_session.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_scope.dart';
import '../../ledger/data/member_ledger_repository.dart';
import '../../ledger/presentation/member_ledger_controller.dart';
import '../../ledger/presentation/total_balance_card.dart';
import '../../shared/finance.dart';
import '../../shared/widgets/app_action_button.dart';
import '../../shared/widgets/app_message_card.dart';
import '../../shared/widgets/app_pill.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.ledgerRepository});

  final MemberLedgerRepository ledgerRepository;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final MemberLedgerController _ledgerController;

  @override
  void initState() {
    super.initState();
    _ledgerController = MemberLedgerController(
      repository: widget.ledgerRepository,
    );
    _ledgerController.load();
  }

  @override
  void dispose() {
    _ledgerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthUser? user = AuthScope.of(context).user;

    return AnimatedBuilder(
      animation: _ledgerController,
      builder: (BuildContext context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _ProfileHeader(
              user: user,
              onEdit: () => _showChangePasswordSheet(context),
            ),
            TotalBalanceCard(
              statement: _ledgerController.statement,
              isLoading: _ledgerController.isLoading,
              errorMessage: _ledgerController.errorMessage,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _ProfileDetailsCard(user: user),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showChangePasswordSheet(BuildContext context) async {
    final AuthController authController = AuthScope.of(context);
    final bool? changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (BuildContext context) {
        return _ChangePasswordSheet(authController: authController);
      },
    );

    if (!context.mounted || changed != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password changed successfully.')),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.onEdit});

  final AuthUser? user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final String name = _displayName(user);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
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
      child: Row(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: .22)),
            ),
            child: Text(
              _initials(name),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                AppPill(
                  label: user?.role.label ?? UserRole.unknown.label,
                  background: AppColors.accent.withValues(alpha: .22),
                  foreground: AppColors.accentLt,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            tooltip: 'Change password',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: .16),
              minimumSize: const Size(42, 42),
              side: BorderSide(color: Colors.white.withValues(alpha: .20)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailsCard extends StatelessWidget {
  const _ProfileDetailsCard({required this.user});

  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[AppColors.softShadow(opacity: 0.10, blur: 12)],
      ),
      child: Column(
        children: <Widget>[
          _ProfileInfoRow(
            icon: Icons.badge_outlined,
            label: 'Member ID',
            value: valueOrDash(user?.id),
          ),
          _ProfileInfoRow(
            icon: Icons.phone_outlined,
            label: 'Contact No',
            value: valueOrDash(user?.phone),
          ),
          _ProfileInfoRow(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: valueOrDash(user?.email),
          ),
          _ProfileInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Join Date',
            value: valueOrDash(user?.joinDate),
          ),
          _ProfileInfoRow(
            icon: Icons.verified_user_outlined,
            label: 'Status',
            value: valueOrDash(user?.status),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
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
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.greenLt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMute,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
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
    );
  }
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet({required this.authController});

  final AuthController authController;

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePasswords = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
                      Icons.lock_reset_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Update your account password.',
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
              ],
              const SizedBox(height: 16),
              _PasswordTextField(
                controller: _currentPasswordController,
                label: 'Current password',
                obscureText: _obscurePasswords,
                enabled: !_isSubmitting,
                textInputAction: TextInputAction.next,
                validator: _requiredPassword,
                onToggleVisibility: _togglePasswordVisibility,
              ),
              const SizedBox(height: 12),
              _PasswordTextField(
                controller: _newPasswordController,
                label: 'New password',
                obscureText: _obscurePasswords,
                enabled: !_isSubmitting,
                textInputAction: TextInputAction.next,
                validator: _newPassword,
                onToggleVisibility: _togglePasswordVisibility,
              ),
              const SizedBox(height: 12),
              _PasswordTextField(
                controller: _confirmPasswordController,
                label: 'Confirm new password',
                obscureText: _obscurePasswords,
                enabled: !_isSubmitting,
                textInputAction: TextInputAction.done,
                validator: _confirmPassword,
                onFieldSubmitted: (_) => _submit(),
                onToggleVisibility: _togglePasswordVisibility,
              ),
              const SizedBox(height: 18),
              AppActionButton(
                label: _isSubmitting
                    ? 'Changing Password...'
                    : 'Change Password',
                background: _isSubmitting
                    ? AppColors.textMute
                    : AppColors.primary,
                foreground: Colors.white,
                onTap: _isSubmitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePasswords = !_obscurePasswords);
  }

  String? _requiredPassword(String? value) {
    return (value?.isEmpty ?? true) ? 'This field is required.' : null;
  }

  String? _newPassword(String? value) {
    final String password = value ?? '';
    if (password.isEmpty) {
      return 'This field is required.';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  String? _confirmPassword(String? value) {
    final String password = value ?? '';
    if (password.isEmpty) {
      return 'This field is required.';
    }
    if (password != _newPasswordController.text) {
      return 'Passwords do not match.';
    }
    return null;
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
    });

    final String? error = await widget.authController.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) {
      return;
    }

    if (error == null) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isSubmitting = false;
      _errorMessage = error;
    });
  }
}

class _PasswordTextField extends StatelessWidget {
  const _PasswordTextField({
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.enabled,
    required this.textInputAction,
    required this.validator,
    required this.onToggleVisibility,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final bool enabled;
  final TextInputAction textInputAction;
  final FormFieldValidator<String> validator;
  final VoidCallback onToggleVisibility;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      validator: validator,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMute),
        suffixIcon: IconButton(
          onPressed: enabled ? onToggleVisibility : null,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.red, width: 1.4),
        ),
      ),
    );
  }
}

String _displayName(AuthUser? user) {
  final String? name = user?.name.trim();
  return name == null || name.isEmpty ? 'Member' : name;
}

String _initials(String name) {
  final List<String> parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((String part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return 'M';
  }
  if (parts.length == 1) {
    return parts.first.characters.first.toUpperCase();
  }
  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}
