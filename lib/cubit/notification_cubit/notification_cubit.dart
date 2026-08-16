import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studioh_ceramic_cafe_client/model/app_notification.dart';
import 'package:studioh_ceramic_cafe_client/services/api_service.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(const NotificationState());

  /// First page. Also refreshes the unread count that drives the bell badge.
  Future<void> fetchNotifications() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final response = await ApiService.listNotifications();
      final data = response.data['data'] as Map<String, dynamic>;

      emit(state.copyWith(
        notifications: _parse(data['notifications']),
        unreadCount: (data['unread_count'] as num?)?.toInt() ?? 0,
        currentPage: (data['current_page'] as num?)?.toInt() ?? 1,
        lastPage: (data['last_page'] as num?)?.toInt() ?? 1,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Could not load notifications. Pull down to try again.',
      ));
    }
  }

  /// Appends the next page; ignored while already loading or on the last page.
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final response =
          await ApiService.listNotifications(page: state.currentPage + 1);
      final data = response.data['data'] as Map<String, dynamic>;

      emit(state.copyWith(
        notifications: [...state.notifications, ..._parse(data['notifications'])],
        currentPage: (data['current_page'] as num?)?.toInt() ?? state.currentPage,
        lastPage: (data['last_page'] as num?)?.toInt() ?? state.lastPage,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  /// Marks one as read, updating locally first so the list does not flicker.
  Future<void> markAsRead(AppNotification notification) async {
    if (notification.isRead) return;

    emit(state.copyWith(
      notifications: state.notifications
          .map((n) => n.id == notification.id ? _asRead(n) : n)
          .toList(),
      unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
    ));

    try {
      await ApiService.markNotificationRead(notification.id);
    } catch (_) {
      // Put it back if the server rejected it.
      await fetchNotifications();
    }
  }

  Future<void> markAllAsRead() async {
    if (state.unreadCount == 0) return;

    final previous = state.notifications;
    emit(state.copyWith(
      notifications: previous.map(_asRead).toList(),
      unreadCount: 0,
    ));

    try {
      await ApiService.markAllNotificationsRead();
    } catch (_) {
      emit(state.copyWith(notifications: previous));
      await fetchNotifications();
    }
  }

  /// Cheap badge refresh — used when a push arrives while the app is open.
  Future<void> refreshUnreadCount() async {
    try {
      final response = await ApiService.listNotifications(perPage: 1);
      final data = response.data['data'] as Map<String, dynamic>;
      emit(state.copyWith(
        unreadCount: (data['unread_count'] as num?)?.toInt() ?? 0,
      ));
    } catch (_) {
      // Badge accuracy is not worth surfacing an error for.
    }
  }

  void clear() => emit(const NotificationState());

  AppNotification _asRead(AppNotification n) => AppNotification(
        id: n.id,
        type: n.type,
        title: n.title,
        body: n.body,
        readAt: n.readAt ?? DateTime.now(),
        createdAt: n.createdAt,
        data: n.data,
      );

  List<AppNotification> _parse(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => AppNotification.fromJson(e.cast<String, dynamic>()))
        .toList();
  }
}
