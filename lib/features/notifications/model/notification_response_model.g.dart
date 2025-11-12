// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationsResponseModel _$NotificationsResponseModelFromJson(
  Map<String, dynamic> json,
) => NotificationsResponseModel(
  notifications: (json['notifications'] as List<dynamic>)
      .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  unreadCount: (json['unreadCount'] as num).toInt(),
);

Map<String, dynamic> _$NotificationsResponseModelToJson(
  NotificationsResponseModel instance,
) => <String, dynamic>{
  'notifications': instance.notifications,
  'unreadCount': instance.unreadCount,
};
