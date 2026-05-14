import '../../../../core/network/api_client.dart';
import '../domain/activity_feed.dart';

class ActivityApi {
  const ActivityApi(this._apiClient);

  final ApiClient _apiClient;

  Future<ActivityFeed> feed() async {
    final Map<String, dynamic> response = await _apiClient.get('/activity/');
    final Object? data = response['data'];
    return ActivityFeed.fromJson(
      data is Map<String, dynamic> ? data : response,
    );
  }
}
