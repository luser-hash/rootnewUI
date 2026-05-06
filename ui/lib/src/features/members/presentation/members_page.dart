import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../auth/domain/auth_session.dart';
import '../../auth/presentation/auth_scope.dart';
import '../../shared/models/finance_models.dart';
import '../../shared/utils/finance_formatters.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_pill.dart';
import '../../shared/widgets/app_small_button.dart';
import '../../shared/widgets/status_pills.dart';
import '../data/member_management_repository.dart';
import '../domain/member_management_models.dart';
import 'member_list_controller.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({
    super.key,
    required this.repository,
    required this.onAdd,
    required this.onSelect,
  });

  final MemberManagementRepository repository;
  final VoidCallback onAdd;
  final void Function(Member member, int index) onSelect;

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final TextEditingController _searchController = TextEditingController();
  late final MemberListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MemberListController(repository: widget.repository);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        return Column(
          children: <Widget>[
            _MembersHeader(
              filter: _controller.filter,
              searchController: _searchController,
              onAdd: widget.onAdd,
              onSearch: _applySearch,
              onStatusChanged: _applyStatus,
              onRoleChanged: _applyRole,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
              child: _buildBody(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 36),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final String? error = _controller.errorMessage;
    if (error != null) {
      return _MessageCard(
        icon: Icons.error_outline,
        message: error,
        background: AppColors.redLt,
        foreground: AppColors.red,
      );
    }

    final List<ManagedUser> users = _controller.users;
    if (users.isEmpty) {
      return const _MessageCard(
        icon: Icons.group_outlined,
        message: 'No members found for this filter.',
        background: AppColors.surface,
        foreground: AppColors.textMute,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[AppColors.softShadow()],
      ),
      child: Column(
        children: users.asMap().entries.map((MapEntry<int, ManagedUser> entry) {
          return _MemberRow(
            user: entry.value,
            index: entry.key,
            isLast: entry.key == users.length - 1,
            onTap: () => widget.onSelect(entry.value.toMember(), entry.key),
          );
        }).toList(),
      ),
    );
  }

  void _applySearch() {
    _controller.load(
      filter: ManagedUserFilter(
        status: _controller.filter.status,
        role: _controller.filter.role,
        search: _searchController.text,
      ),
    );
  }

  void _applyStatus(ManagedUserStatus? status) {
    _controller.load(
      filter: ManagedUserFilter(
        status: status,
        role: _controller.filter.role,
        search: _searchController.text,
      ),
    );
  }

  void _applyRole(UserRole? role) {
    _controller.load(
      filter: ManagedUserFilter(
        status: _controller.filter.status,
        role: role,
        search: _searchController.text,
      ),
    );
  }
}

class _MembersHeader extends StatelessWidget {
  const _MembersHeader({
    required this.filter,
    required this.searchController,
    required this.onAdd,
    required this.onSearch,
    required this.onStatusChanged,
    required this.onRoleChanged,
  });

  final ManagedUserFilter filter;
  final TextEditingController searchController;
  final VoidCallback onAdd;
  final VoidCallback onSearch;
  final ValueChanged<ManagedUserStatus?> onStatusChanged;
  final ValueChanged<UserRole?> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    final UserRole role = AuthScope.of(context).role;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.primaryDk, AppColors.primaryDk],
        ),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Members',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                if (role.canManageMembers)
                  AppSmallButton(
                    label: '+ Add',
                    background: AppColors.accent,
                    foreground: Colors.white,
                    onTap: onAdd,
                  ),
              ],
            ),
          ),
          TextField(
            controller: searchController,
            onSubmitted: (_) => onSearch(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: 'Search members',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: .55),
                fontSize: 13,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              suffixIcon: IconButton(
                onPressed: onSearch,
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                tooltip: 'Search',
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: .12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: _StatusFilter(
                  value: filter.status,
                  onChanged: onStatusChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _RoleFilter(
                  value: filter.role,
                  onChanged: onRoleChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.value, required this.onChanged});

  final ManagedUserStatus? value;
  final ValueChanged<ManagedUserStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return _FilterShell(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ManagedUserStatus?>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.primaryDk,
          iconEnabledColor: Colors.white,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          items: const <DropdownMenuItem<ManagedUserStatus?>>[
            DropdownMenuItem<ManagedUserStatus?>(
              child: Text('All status'),
            ),
            DropdownMenuItem<ManagedUserStatus?>(
              value: ManagedUserStatus.active,
              child: Text('Active'),
            ),
            DropdownMenuItem<ManagedUserStatus?>(
              value: ManagedUserStatus.inactive,
              child: Text('Inactive'),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _RoleFilter extends StatelessWidget {
  const _RoleFilter({required this.value, required this.onChanged});

  final UserRole? value;
  final ValueChanged<UserRole?> onChanged;

  @override
  Widget build(BuildContext context) {
    return _FilterShell(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UserRole?>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.primaryDk,
          iconEnabledColor: Colors.white,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          items: const <DropdownMenuItem<UserRole?>>[
            DropdownMenuItem<UserRole?>(child: Text('All roles')),
            DropdownMenuItem<UserRole?>(
              value: UserRole.member,
              child: Text('Member'),
            ),
            DropdownMenuItem<UserRole?>(
              value: UserRole.admin,
              child: Text('Admin'),
            ),
            DropdownMenuItem<UserRole?>(
              value: UserRole.superAdmin,
              child: Text('Super Admin'),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _FilterShell extends StatelessWidget {
  const _FilterShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(13),
      ),
      child: child,
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.user,
    required this.index,
    required this.isLast,
    required this.onTap,
  });

  final ManagedUser user;
  final int index;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
            AppAvatar(
              initials: user.initials,
              color: avatarColor(index),
              size: 46,
              radius: 15,
              active: user.status == ManagedUserStatus.active,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    user.fullName.isEmpty ? 'Unnamed Member' : user.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subtitle(user),
                    maxLines: 1,
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
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                AppPill(
                  label: user.role.label,
                  background: AppColors.blueLt,
                  foreground: AppColors.blue,
                ),
                const SizedBox(height: 6),
                MemberStatusPill(status: user.status.memberStatus),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _subtitle(ManagedUser user) {
    final List<String> parts = <String>[
      if (user.contactNo.isNotEmpty) user.contactNo,
      if (user.email.isNotEmpty) user.email,
    ];
    return parts.isEmpty ? 'No contact information' : parts.join(' - ');
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
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
