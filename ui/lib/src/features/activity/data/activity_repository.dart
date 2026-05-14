import '../domain/activity_feed.dart';
import 'activity_api.dart';

abstract class ActivityRepository {
  Future<ActivityFeed> feed();
}

class ApiActivityRepository implements ActivityRepository {
  const ApiActivityRepository({required ActivityApi api}) : _api = api;

  final ActivityApi _api;

  @override
  Future<ActivityFeed> feed() {
    return _api.feed();
  }
}
