part of '../landing_page.dart';

class _MembersCarousel extends StatefulWidget {
  const _MembersCarousel({
    required this.repository,
    required this.onNav,
    required this.onMemberSelect,
  });

  final MemberManagementRepository repository;
  final ValueChanged<String> onNav;
  final void Function(Member member, int memberColorIdx) onMemberSelect;

  @override
  State<_MembersCarousel> createState() => _MembersCarouselState();
}

class _MembersCarouselState extends State<_MembersCarousel> {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Members',
      actionLabel: 'See All →',
      onAction: () => widget.onNav(RouteNames.members),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, _) {
          return _buildBody();
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const SizedBox(
        height: 110,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final String? error = _controller.errorMessage;
    if (error != null) {
      return _MemberCarouselMessage(message: error);
    }

    final List<ManagedUser> users = _controller.users;
    if (users.isEmpty) {
      return const _MemberCarouselMessage(message: 'No members found.');
    }

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: users.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (BuildContext context, int index) {
          final ManagedUser user = users[index];
          final Member member = user.toMember();
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => widget.onMemberSelect(member, index),
            child: Container(
              width: 72,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: <BoxShadow>[
                  AppColors.softShadow(opacity: 0.15, blur: 8),
                ],
              ),
              child: Column(
                children: <Widget>[
                  AppAvatar(
                    initials: member.initials,
                    color: avatarColor(index),
                    size: 44,
                    radius: 14,
                    active: member.status == MemberStatus.active,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _firstName(member.name),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMid,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.role.label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMute,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _firstName(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Member';
    }
    return trimmed.split(RegExp(r'\s+')).first;
  }
}

class _MemberCarouselMessage extends StatelessWidget {
  const _MemberCarouselMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[AppColors.softShadow(opacity: 0.10, blur: 8)],
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: AppColors.textMute),
      ),
    );
  }
}
