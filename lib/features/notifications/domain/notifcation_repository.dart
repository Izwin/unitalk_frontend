
import 'package:dartz/dartz.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/notifications/model/notification_model.dart';
import 'package:unitalk/features/notifications/model/notification_response_model.dart';
import 'package:unitalk/features/notifications/model/notification_settings_model.dart';

abstract class NotificationRepository {
  // Settings
  Future<Either<Failure, NotificationSettingsModel>> getSettings();

  Future<Either<Failure, NotificationSettingsModel>> updateSettings({
    bool? enabled,
    bool? newPosts,
    bool? newComments,
    bool? newLikes,
    bool? commentReplies,
    bool? mentions,
    bool? chatMessages,
    bool? chatMentions,
    NewPostsFilter? newPostsFilter,
  });

  Future<Either<Failure, void>> saveFcmToken(String fcmToken);

  Future<Either<Failure, void>> removeFcmToken();

  // Notifications
  Future<Either<Failure, NotificationsResponseModel>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  });

  Future<Either<Failure, NotificationModel>> markAsRead(String notificationId);

  Future<Either<Failure, void>> markAllAsRead();

  Future<Either<Failure, void>> deleteNotification(String notificationId);

  Future<Either<Failure, void>> deleteAllNotifications();

  Future<Either<Failure, int>> getUnreadCount();
}