import 'package:unitalk/features/notifications/model/notification_model.dart';
import 'package:unitalk/features/notifications/model/notification_settings_model.dart';

enum NotificationStatus {
  initial,
  loading,
  loadingMore,
  success,
  failure,
}

class NotificationState {
  final NotificationStatus status;
  final List<NotificationModel> notifications;
  final NotificationSettingsModel? settings;
  final int unreadCount;
  final int currentPage;
  final bool hasMore;
  final String? errorMessage;

  NotificationState({
    required this.status,
    required this.notifications,
    this.settings,
    required this.unreadCount,
    required this.currentPage,
    required this.hasMore,
    this.errorMessage,
  });

  factory NotificationState.initial() {
    return NotificationState(
      status: NotificationStatus.initial,
      notifications: [],
      settings: null,
      unreadCount: 0,
      currentPage: 1,
      hasMore: true,
      errorMessage: null,
    );
  }

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationModel>? notifications,
    NotificationSettingsModel? settings,
    int? unreadCount,
    int? currentPage,
    bool? hasMore,
    String? errorMessage,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      settings: settings ?? this.settings,
      unreadCount: unreadCount ?? this.unreadCount,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }
}