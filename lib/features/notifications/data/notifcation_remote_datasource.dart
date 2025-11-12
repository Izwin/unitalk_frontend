import 'package:dio/dio.dart';
import 'package:unitalk/features/notifications/model/notification_model.dart';
import 'package:unitalk/features/notifications/model/notification_response_model.dart';
import 'package:unitalk/features/notifications/model/notification_settings_model.dart';

class NotificationRemoteDataSource {
  final Dio dio;

  NotificationRemoteDataSource({required this.dio});

  // ============== SETTINGS ==============

  Future<NotificationSettingsModel> getSettings() async {
    final response = await dio.get('/notifications/settings');
    return NotificationSettingsModel.fromJson(response.data);
  }

  Future<NotificationSettingsModel> updateSettings({
    bool? enabled,
    bool? newPosts,
    bool? newComments,
    bool? newLikes,
    bool? commentReplies,
    bool? mentions,
    bool? chatMessages,
    bool? chatMentions,
  }) async {
    final data = <String, dynamic>{};

    if (enabled != null) data['enabled'] = enabled;
    if (newPosts != null) data['newPosts'] = newPosts;
    if (newComments != null) data['newComments'] = newComments;
    if (newLikes != null) data['newLikes'] = newLikes;
    if (commentReplies != null) data['commentReplies'] = commentReplies;
    if (mentions != null) data['mentions'] = mentions;
    if (chatMessages != null) data['chatMessages'] = chatMessages;
    if (chatMentions != null) data['chatMentions'] = chatMentions;

    final response = await dio.put('/notifications/settings', data: data);
    return NotificationSettingsModel.fromJson(response.data);
  }

  Future<void> saveFcmToken(String fcmToken) async {
    await dio.post('/notifications/fcm-token', data: {'fcmToken': fcmToken});
  }

  Future<void> removeFcmToken() async {
    await dio.delete('/notifications/fcm-token');
  }

  // ============== NOTIFICATIONS ==============

  Future<NotificationsResponseModel> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    final response = await dio.get(
      '/notifications',
      queryParameters: {
        'page': page,
        'limit': limit,
        'unreadOnly': unreadOnly,
      },
    );
    return NotificationsResponseModel.fromJson(response.data);
  }

  Future<NotificationModel> markAsRead(String notificationId) async {
    final response = await dio.put('/notifications/$notificationId/read');
    return NotificationModel.fromJson(response.data);
  }

  Future<void> markAllAsRead() async {
    await dio.put('/notifications/read-all');
  }

  Future<void> deleteNotification(String notificationId) async {
    await dio.delete('/notifications/$notificationId');
  }

  Future<void> deleteAllNotifications() async {
    await dio.delete('/notifications');
  }

  Future<int> getUnreadCount() async {
    final response = await dio.get('/notifications/unread-count');
    return response.data['unreadCount'] as int;
  }
}