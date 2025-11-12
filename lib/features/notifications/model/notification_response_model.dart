import 'package:json_annotation/json_annotation.dart';
import 'package:unitalk/features/notifications/model/notification_model.dart';
part 'notification_response_model.g.dart';

@JsonSerializable()
class NotificationsResponseModel {
  final List<NotificationModel> notifications;
  final int unreadCount;

  NotificationsResponseModel({
    required this.notifications,
    required this.unreadCount,
  });

  factory NotificationsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationsResponseModelToJson(this);
}