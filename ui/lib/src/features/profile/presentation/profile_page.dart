import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../auth/domain/auth_session.dart';
import '../../auth/presentation/auth_scope.dart';
import '../../shared/widgets/app_pill.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthUser? user = AuthScope.of(context).user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _ProfileHeader(user: user),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _ProfileDetailsCard(user: user),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final AuthUser? user;

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
            value: _valueOrDash(user?.id),
          ),
          _ProfileInfoRow(
            icon: Icons.phone_outlined,
            label: 'Contact No',
            value: _valueOrDash(user?.phone),
          ),
          _ProfileInfoRow(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: _valueOrDash(user?.email),
          ),
          _ProfileInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Join Date',
            value: _valueOrDash(user?.joinDate),
          ),
          _ProfileInfoRow(
            icon: Icons.verified_user_outlined,
            label: 'Status',
            value: _valueOrDash(user?.status),
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

String _valueOrDash(String? value) {
  final String? trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? '-' : trimmed;
}
