import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../models/models.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.read(apiClientProvider));
});

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  Future<List<NotificationResponse>> getNotifications() async {
    return _apiClient.getList(
      '/api/notifications',
      fromJson: NotificationResponse.fromJson,
    );
  }

  Future<List<NotificationResponse>> getUnreadNotifications() async {
    return _apiClient.getList(
      '/api/notifications/unread',
      fromJson: NotificationResponse.fromJson,
    );
  }

  Future<int> getUnreadCount() async {
    return _apiClient.get<int>(
      '/api/notifications/unread/count',
      fromJson: (json) => (json as num).toInt(),
    );
  }

  Future<void> markAsRead(int notificationId) async {
    await _apiClient.putVoid('/api/notifications/$notificationId/read');
  }

  Future<void> markAllAsRead() async {
    await _apiClient.putVoid('/api/notifications/read-all');
  }
}


