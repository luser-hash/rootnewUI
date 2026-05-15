part of '../landing_page.dart';

class _RecentActivitySection extends StatefulWidget {
  const _RecentActivitySection({required this.repository, required this.onNav});

  final ActivityRepository repository;
  final ValueChanged<String> onNav;

  @override
  State<_RecentActivitySection> createState() => _RecentActivitySectionState();
}

class _RecentActivitySectionState extends State<_RecentActivitySection> {
  static const Duration _pollInterval = Duration(seconds: 30);

  ActivityFeed? _feed;
  Object? _error;
  bool _loading = true;
  int _requestId = 0;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    final int requestId = ++_requestId;
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final ActivityFeed feed = await widget.repository.feed();
      if (!mounted || requestId != _requestId) {
        return;
      }
      setState(() {
        _feed = feed;
        _error = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) {
        return;
      }
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Widget _buildActivityContent() {
    if (_loading && _feed == null) {
      return const _RecentActivityMessage(
        message: 'Loading recent activity...',
      );
    }

    if (_error != null && _feed == null) {
      return const _RecentActivityMessage(
        message: 'Unable to load recent activity.',
      );
    }

    final List<ActivityEvent> events = _feed?.events ?? <ActivityEvent>[];
    if (events.isEmpty) {
      return const _RecentActivityMessage(message: 'No recent activity found.');
    }

    return AppCardList(
      children: events.asMap().entries.map((
        MapEntry<int, ActivityEvent> entry,
      ) {
        return _ActivityEventRow(
          event: entry.value,
          isLast: entry.key == events.length - 1,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserRole role = AuthScope.of(context).role;

    return _Section(
      title: 'Recent Activity',
      actionLabel: 'Ledger →',
      onAction: () => widget.onNav(
        role.canViewAllLedger ? RouteNames.ledger : RouteNames.memberLedger,
      ),
      paddingBottom: 24,
      child: _buildActivityContent(),
    );
  }
}

class _ActivityEventRow extends StatelessWidget {
  const _ActivityEventRow({required this.event, required this.isLast});

  final ActivityEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final _ActivityVisual visual = _activityVisual(event);
    final String? amount = _formatActivityAmount(event);
    final String date = _formatActivityDate(event.occurredAt);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: AppColors.border),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: visual.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(visual.icon, size: 20, color: visual.foreground),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  valueOrDash(event.title),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valueOrDash(event.detail),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
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
              if (amount != null)
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: visual.foreground,
                  ),
                ),
              if (amount != null) const SizedBox(height: 2),
              Text(
                date,
                style: const TextStyle(fontSize: 11, color: AppColors.textMute),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityVisual {
  const _ActivityVisual({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
}

_ActivityVisual _activityVisual(ActivityEvent event) {
  final String eventType = event.eventType.toUpperCase();
  final num amount = num.tryParse(event.amount ?? '') ?? 0;
  if (amount < 0 || eventType.contains('REJECTED')) {
    return const _ActivityVisual(
      icon: Icons.north_rounded,
      background: AppColors.redLt,
      foreground: AppColors.red,
    );
  }

  if (eventType.contains('DISTRIBUTION')) {
    return const _ActivityVisual(
      icon: Icons.call_split_rounded,
      background: AppColors.blueLt,
      foreground: AppColors.blue,
    );
  }

  if (eventType.contains('INVESTMENT')) {
    return const _ActivityVisual(
      icon: Icons.account_balance_rounded,
      background: AppColors.blueLt,
      foreground: AppColors.blue,
    );
  }

  if (eventType.contains('MEMBER')) {
    return const _ActivityVisual(
      icon: Icons.person_add_alt_1_rounded,
      background: AppColors.purpleLt,
      foreground: AppColors.primary,
    );
  }

  return const _ActivityVisual(
    icon: Icons.south_rounded,
    background: AppColors.greenLt,
    foreground: AppColors.green,
  );
}

String? _formatActivityAmount(ActivityEvent event) {
  final num? value = num.tryParse(event.amount ?? '');
  if (value == null) {
    return null;
  }
  if (value > 0) {
    return '+${fmt(value)}';
  }
  return formatMoneySigned(value);
}

String _formatActivityDate(DateTime? value) {
  if (value == null) {
    return '-';
  }
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final DateTime local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')} ${months[local.month - 1]}';
}

class _RecentActivityMessage extends StatelessWidget {
  const _RecentActivityMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[AppColors.softShadow()],
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: AppColors.textMute),
      ),
    );
  }
}
