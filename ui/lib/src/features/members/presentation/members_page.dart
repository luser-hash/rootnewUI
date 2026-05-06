import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../auth/domain/auth_session.dart';
import '../../auth/presentation/auth_scope.dart';
import '../../shared/finance.dart';
import '../../shared/services/member_metrics.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_small_button.dart';
import '../../shared/widgets/status_pills.dart';

class MembersPage extends StatelessWidget {
  const MembersPage({super.key, required this.onAdd, required this.onSelect});

  final VoidCallback onAdd;
  final void Function(Member member, int index) onSelect;

  @override
  Widget build(BuildContext context) {
    final int totalCapital = MemberMetrics.totalActiveCapital(members);

    return Column(
      children: <Widget>[
        _MembersHeader(onAdd: onAdd),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: <BoxShadow>[AppColors.softShadow()],
            ),
            child: Column(
              children: members.asMap().entries.map((
                MapEntry<int, Member> entry,
              ) {
                final int index = entry.key;
                final Member member = entry.value;
                final int pct = MemberMetrics.capitalSharePercent(
                  memberCapital: member.capital,
                  totalCapital: totalCapital,
                );

                return InkWell(
                  onTap: () => onSelect(member, index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: index == members.length - 1
                            ? BorderSide.none
                            : const BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        AppAvatar(
                          initials: member.initials,
                          color: avatarColor(index),
                          size: 46,
                          radius: 15,
                          active: member.status == MemberStatus.active,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                member.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: pct / 100,
                                        minHeight: 4,
                                        backgroundColor: AppColors.surface,
                                        color: avatarColor(index),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$pct%',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMute,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              fmtSh(member.capital),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            MemberStatusPill(status: member.status),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _MembersHeader extends StatelessWidget {
  const _MembersHeader({required this.onAdd});

  final VoidCallback onAdd;

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: <Widget>[
                const Text('🔍', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  'Search members…',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: .5),
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
