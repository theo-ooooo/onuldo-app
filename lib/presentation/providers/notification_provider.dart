import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationState {
  final List<NotificationResponse> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    List<NotificationResponse>? notifications,
    bool? isLoading,
    String? error,
    int? unreadCount,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;

  NotificationNotifier(this._repository) : super(const NotificationState());

  Future<void> loadUnreadCount() async {
    try {
      final count = await _repository.getUnreadCount();
      state = state.copyWith(unreadCount: count);
    } catch (_) {
      // ignore
    }
  }

  Future<void> loadNotifications({bool unreadOnly = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = unreadOnly
          ? await _repository.getUnreadNotifications()
          : await _repository.getNotifications();
      state = state.copyWith(notifications: list, isLoading: false);
      await loadUnreadCount();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markAsRead(NotificationResponse notification) async {
    if (notification.isRead) return;

    // optimistic update
    final updated = state.notifications
        .map((n) => n.id == notification.id ? n.copyWith(isRead: true) : n)
        .toList();
    state = state.copyWith(
      notifications: updated,
      unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
    );

    try {
      await _repository.markAsRead(notification.id);
    } catch (e) {
      // rollback on failure
      final rolledBack = state.notifications
          .map((n) => n.id == notification.id ? n.copyWith(isRead: false) : n)
          .toList();
      state = state.copyWith(
        notifications: rolledBack,
        unreadCount: state.unreadCount + 1,
        error: e.toString(),
      );
    }
  }

  Future<void> markAllAsRead() async {
    // optimistic
    final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updated, unreadCount: 0, error: null);
    try {
      await _repository.markAllAsRead();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      await loadNotifications();
    }
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref.read(notificationRepositoryProvider));
});


