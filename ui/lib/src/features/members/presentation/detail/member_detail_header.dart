part of 'member_detail_screen.dart';

class _MemberDetailHeader extends StatelessWidget {
  const _MemberDetailHeader({
    required this.member,
    required this.colorIdx,
    required this.onBack,
    required this.onEdit,
    required this.canEdit,
    required this.isEditEnabled,
  });

  final Member member;
  final int colorIdx;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final bool canEdit;
  final bool isEditEnabled;

  @override
  Widget build(BuildContext context) {
    return AppScreenHeader(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      gradientColors: const <Color>[AppColors.primary, Color(0xFF004A40)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _StatusBar(dark: true),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 16),
            child: Row(
              children: <Widget>[
                Material(
                  color: Colors.white.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(10),
                    child: const SizedBox(
                      width: 36,
                      height: 36,
                      child: Center(
                        child: Text(
                          '←',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Member Profile',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                if (canEdit)
                  IconButton(
                    onPressed: isEditEnabled ? onEdit : null,
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    tooltip: 'Edit member',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: .15),
                      minimumSize: const Size(40, 40),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              AppAvatar(
                initials: member.initials,
                color: avatarColor(colorIdx),
                size: 64,
                radius: 20,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Member ID: ${member.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: .7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppPill(
                      label: member.status.label,
                      background: member.status == MemberStatus.active
                          ? AppColors.green.withValues(alpha: .25)
                          : Colors.white.withValues(alpha: .15),
                      foreground: member.status == MemberStatus.active
                          ? const Color(0xFF6EFCB8)
                          : Colors.white.withValues(alpha: .7),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
