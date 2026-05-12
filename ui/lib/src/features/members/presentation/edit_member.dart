import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../auth/domain/auth_session.dart';
import '../../auth/presentation/auth_scope.dart';
import '../../shared/widgets/app_action_button.dart';
import '../../shared/widgets/app_form_fields.dart';
import '../../shared/widgets/app_message_card.dart';
import '../data/member_management_repository.dart';
import '../domain/member_management_models.dart';
import '../domain/member_update_request.dart';

enum EditMemberAction { updated, deleted }

class EditMemberResult {
  const EditMemberResult._({required this.action, this.user});

  final EditMemberAction action;
  final ManagedUser? user;

  const EditMemberResult.updated(ManagedUser user)
    : this._(action: EditMemberAction.updated, user: user);

  const EditMemberResult.deleted() : this._(action: EditMemberAction.deleted);
}

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
    final UserRole currentRole = AuthScope.of(context).role;
    final AuthUser? currentUser = AuthScope.of(context).user;
    final bool isSelf = currentUser?.id == widget.user.userId;
    final bool canDelete = currentRole.canManageMembers && !isSelf;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _EditMemberHeader(onBack: () => _closePage(context)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: _buildFormCard(context, isSelf: isSelf, canDelete: canDelete),
        ),
      ],
    );
  }

  Widget _buildFormCard(
    BuildContext context, {
    required bool isSelf,
    required bool canDelete,
  }) {
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
                textColor: AppColors.red,
                padding: const EdgeInsets.all(12),
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
              onTap: _isSubmitting ? null : () => _pickJoinDate(context),
            ),
            const SizedBox(height: 18),
            const AppSectionLabel(title: 'Access setup'),
            const SizedBox(height: 12),
            AppDropdownField<UserRole>(
              label: 'Role',
              value: _role,
              icon: Icons.admin_panel_settings_outlined,
              values: const <UserRole>[
                UserRole.member,
                UserRole.admin,
                UserRole.superAdmin,
              ],
              labelBuilder: _roleLabel,
              onChanged: _isSubmitting
                  ? null
                  : (UserRole? value) {
                      if (value != null) {
                        setState(() => _role = value);
                      }
                    },
            ),
            const SizedBox(height: 12),
            AppDropdownField<ManagedUserStatus>(
              label: 'Status',
              value: _status,
              icon: Icons.verified_user_outlined,
              values: const <ManagedUserStatus>[
                ManagedUserStatus.active,
                ManagedUserStatus.inactive,
              ],
              labelBuilder: _statusLabel,
              onChanged: _isSubmitting
                  ? null
                  : (ManagedUserStatus? value) {
                      if (value != null) {
                        setState(() => _status = value);
                      }
                    },
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
              label: _isSubmitting ? 'Saving Changes...' : 'Save Changes',
              background: _isSubmitting
                  ? AppColors.textMute
                  : AppColors.primary,
              foreground: Colors.white,
              onTap: _isSubmitting ? null : _submit,
            ),
            const SizedBox(height: 12),
            _DangerButton(
              label: isSelf ? 'Cannot Delete Your Account' : 'Delete Member',
              enabled: !_isSubmitting && canDelete,
              onTap: () => _delete(context),
            ),
            if (isSelf) ...<Widget>[
              const SizedBox(height: 10),
              const Text(
                'Your own account cannot be deactivated.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMute,
                ),
              ),
            ],
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

      context.pop(EditMemberResult.updated(updated));
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

  Future<void> _delete(BuildContext context) async {
    if (_isSubmitting) {
      return;
    }

    final bool confirmed = await _confirmDelete(context);
    if (!mounted || !confirmed) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.repository.delete(widget.user.userId);

      if (!mounted) {
        return;
      }

      context.pop(const EditMemberResult.deleted());
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
        _errorMessage = 'Unable to delete member. Please try again.';
      });
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Member'),
          content: const Text(
            'This will deactivate the member account. The account will not be permanently removed.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
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

class _DangerButton extends StatelessWidget {
  const _DangerButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = enabled ? AppColors.red : AppColors.textMute;

    return Material(
      color: enabled ? AppColors.redLt : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled
                  ? AppColors.red.withValues(alpha: .22)
                  : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _roleLabel(UserRole role) {
  return switch (role) {
    UserRole.member => 'Member',
    UserRole.admin => 'Admin',
    UserRole.superAdmin => 'Super Admin',
    UserRole.unknown => role.label,
  };
}

String _statusLabel(ManagedUserStatus status) {
  return switch (status) {
    ManagedUserStatus.active => 'Active',
    ManagedUserStatus.inactive => 'Inactive',
  };
}
