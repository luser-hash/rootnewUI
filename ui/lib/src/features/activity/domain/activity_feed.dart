class ActivityFeed {
  const ActivityFeed({
    required this.count,
    required this.events,
  });

  final int count;
  final List<ActivityEvent> events;

  factory ActivityFeed.fromJson(Map<String, dynamic> json) {
    final Object? events = json['events'];
    return ActivityFeed(
      count: json['count'] is int
          ? json['count'] as int
          : int.tryParse('${json['count'] ?? 0}') ?? 0,
      events: events is List<dynamic>
          ? events
                .whereType<Map<String, dynamic>>()
                .map(ActivityEvent.fromJson)
                .toList()
          : <ActivityEvent>[],
    );
  }
}

class ActivityEvent {
  const ActivityEvent({
    required this.eventId,
    required this.eventType,
    required this.title,
    required this.detail,
    required this.amount,
    required this.entityName,
    required this.entityId,
    required this.actor,
    required this.targetUser,
    required this.occurredAt,
  });

  final String eventId;
  final String eventType;
  final String title;
  final String detail;
  final String? amount;
  final String entityName;
  final String entityId;
  final ActivityUser? actor;
  final ActivityUser? targetUser;
  final DateTime? occurredAt;

  factory ActivityEvent.fromJson(Map<String, dynamic> json) {
    final Object? actor = json['actor'];
    final Object? targetUser = json['target_user'];
    return ActivityEvent(
      eventId: '${json['event_id'] ?? ''}',
      eventType: '${json['event_type'] ?? ''}',
      title: '${json['title'] ?? ''}',
      detail: '${json['detail'] ?? ''}',
      amount: json['amount'] == null ? null : '${json['amount']}',
      entityName: '${json['entity_name'] ?? ''}',
      entityId: '${json['entity_id'] ?? ''}',
      actor: actor is Map<String, dynamic>
          ? ActivityUser.fromJson(actor)
          : null,
      targetUser: targetUser is Map<String, dynamic>
          ? ActivityUser.fromJson(targetUser)
          : null,
      occurredAt: DateTime.tryParse('${json['occurred_at'] ?? ''}'),
    );
  }
}

class ActivityUser {
  const ActivityUser({
    required this.userId,
    required this.fullName,
  });

  final String userId;
  final String fullName;

  factory ActivityUser.fromJson(Map<String, dynamic> json) {
    return ActivityUser(
      userId: '${json['user_id'] ?? ''}',
      fullName: '${json['full_name'] ?? ''}',
    );
  }
}
