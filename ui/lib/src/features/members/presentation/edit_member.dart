import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../auth/domain/auth_session.dart';
import '../../shared/widgets/app_action_button.dart';
import '../data/member_management_repository.dart';
import '../domain/member_management_models.dart';
import '../domain/member_update_request.dart';

class EditMemberPage extends StatefulWidget {
  const EditMemberPage({
    super.key,
    required this.repository,
    required this.user,
  });

  final MemberManagementRepository repository;
  final ManagedUser user;

  @override
  State<EditMemberPage> createState() => _EditMemberPageState();
}

class _EditMemberPageState extends State<EditMemberPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _notesController;

  late DateTime _joinDate;
  late UserRole _role;
  late ManagedUserStatus _status;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _phoneController = TextEditingController(text: widget.user.contactNo);
    _emailController = TextEditingController(text: widget.user.email);
    _notesController = TextEditingController(text: widget.user.notes);
    _joinDate = _parseJoinDate(widget.user.joinDate) ?? DateTime.now();
    _role = widget.user.role == UserRole.unknown
        ? UserRole.member
        : widget.user.role;
    _status = widget.user.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _EditMemberHeader(onBack: () => _closePage(context)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
              _EditMemberMessage(
                icon: Icons.error_outline,
                message: _errorMessage!,
                background: AppColors.redLt,
                foreground: AppColors.red,
              ),
              const SizedBox(height: 14),
            ],
            const _EditSectionLabel(title: 'Member details'),
            const SizedBox(height: 12),
            _EditTextField(
              controller: _nameController,
              label: 'Full name',
              icon: Icons.person_outline,
              validator: _required,
            ),
            const SizedBox(height: 12),
            _EditTextField(
              controller: _phoneController,
              label: 'Contact number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: _required,
            ),
            const SizedBox(height: 12),
            _EditTextField(
              controller: _emailController,
              label: 'Email address',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              validator: _email,
            ),
            const SizedBox(height: 12),
            _JoinDateField(
              value: _joinDate,
              onTap: _isSubmitting ? null : () => _pickJoinDate(context),
            ),
            const SizedBox(height: 18),
            const _EditSectionLabel(title: 'Access setup'),
            const SizedBox(height: 12),
            _RoleField(
              value: _role,
              enabled: !_isSubmitting,
              onChanged: (UserRole? value) {
                if (value != null) {
                  setState(() => _role = value);
                }
              },
            ),
            const SizedBox(height: 12),
            _StatusField(
              value: _status,
              enabled: !_isSubmitting,
              onChanged: (ManagedUserStatus? value) {
                if (value != null) {
                  setState(() => _status = value);
                }
              },
            ),
            const SizedBox(height: 12),
            _EditTextField(
              controller: _notesController,
              label: 'Admin notes',
              icon: Icons.notes_outlined,
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            AppActionButton(
              label: _isSubmitting ? 'Saving Changes...' : 'Save Changes',
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

  String? _email(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'This field is required.';
    }
    return text.contains('@') ? null : 'Enter a valid email address.';
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

    try {
      final ManagedUser updated = await widget.repository.update(
        widget.user.userId,
        MemberUpdateRequest(
          fullName: _nameController.text.trim(),
          contactNo: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          notes: _notesController.text.trim(),
          role: _role,
          status: _status,
          joinDate: _joinDate,
        ),
      );

      if (!mounted) {
        return;
      }

      context.pop(updated);
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
        _errorMessage = 'Unable to update member. Please try again.';
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

  DateTime? _parseJoinDate(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return DateTime.tryParse(trimmed);
  }
}

class _EditMemberHeader extends StatelessWidget {
  const _EditMemberHeader({required this.onBack});

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
          const Text(
            'Edit Member',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Update account details, access role, and member status.',
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

class _EditSectionLabel extends StatelessWidget {
  const _EditSectionLabel({required this.title});

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

class _EditTextField extends StatelessWidget {
  const _EditTextField({
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

class _JoinDateField extends StatelessWidget {
  const _JoinDateField({required this.value, required this.onTap});

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

class _RoleField extends StatelessWidget {
  const _RoleField({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final UserRole value;
  final bool enabled;
  final ValueChanged<UserRole?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<UserRole>(
      initialValue: value,
      decoration: _dropdownDecoration(
        label: 'Role',
        icon: Icons.admin_panel_settings_outlined,
      ),
      items: const <DropdownMenuItem<UserRole>>[
        DropdownMenuItem<UserRole>(
          value: UserRole.member,
          child: Text('Member'),
        ),
        DropdownMenuItem<UserRole>(
          value: UserRole.admin,
          child: Text('Admin'),
        ),
        DropdownMenuItem<UserRole>(
          value: UserRole.superAdmin,
          child: Text('Super Admin'),
        ),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}

class _StatusField extends StatelessWidget {
  const _StatusField({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final ManagedUserStatus value;
  final bool enabled;
  final ValueChanged<ManagedUserStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ManagedUserStatus>(
      initialValue: value,
      decoration: _dropdownDecoration(
        label: 'Status',
        icon: Icons.verified_user_outlined,
      ),
      items: const <DropdownMenuItem<ManagedUserStatus>>[
        DropdownMenuItem<ManagedUserStatus>(
          value: ManagedUserStatus.active,
          child: Text('Active'),
        ),
        DropdownMenuItem<ManagedUserStatus>(
          value: ManagedUserStatus.inactive,
          child: Text('Inactive'),
        ),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}

class _EditMemberMessage extends StatelessWidget {
  const _EditMemberMessage({
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: foreground),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _dropdownDecoration({
  required String label,
  required IconData icon,
}) {
  return InputDecoration(
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
  );
}

String _formatDate(DateTime value) {
  final String month = value.month.toString().padLeft(2, '0');
  final String day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
