import 'package:unitalk/features/notifications/model/notification_settings_model.dart';

abstract class NotificationEvent {}

// Settings Events
class GetNotificationSettingsEvent extends NotificationEvent {}

class UpdateNotificationSettingsEvent extends NotificationEvent {
  final bool? enabled;
  final bool? newPosts;
  final bool? newComments;
  final bool? newLikes;
  final bool? commentReplies;
  final bool? mentions;
  final bool? chatMessages;
  final bool? chatMentions;
  final NewPostsFilter? newPostsFilter;

  UpdateNotificationSettingsEvent({
    this.enabled,
    this.newPosts,
    this.newComments,
    this.newLikes,
    this.commentReplies,
    this.mentions,
    this.chatMessages,
    this.chatMentions,
    this.newPostsFilter,
  });
}

class SaveFcmTokenEvent extends NotificationEvent {
  final String fcmToken;

  SaveFcmTokenEvent(this.fcmToken);
}

class RemoveFcmTokenEvent extends NotificationEvent {}

// Notification List Events
class GetNotificationsEvent extends NotificationEvent {
  final int page;
  final bool unreadOnly;
  final bool loadMore;

  GetNotificationsEvent({
    this.page = 1,
    this.unreadOnly = false,
    this.loadMore = false,
  });
}

class MarkNotificationAsReadEvent extends NotificationEvent {
  final String notificationId;

  MarkNotificationAsReadEvent(this.notificationId);
}

class MarkAllNotificationsAsReadEvent extends NotificationEvent {}

class DeleteNotificationEvent extends NotificationEvent {
  final String notificationId;

  DeleteNotificationEvent(this.notificationId);
}

class DeleteAllNotificationsEvent extends NotificationEvent {}

class RefreshNotificationsEvent extends NotificationEvent {}

class GetUnreadCountEvent extends NotificationEvent {}

// Handle incoming notification from FCM
class HandleIncomingNotificationEvent extends NotificationEvent {
  final Map<String, dynamic> data;

  HandleIncomingNotificationEvent(this.data);
}