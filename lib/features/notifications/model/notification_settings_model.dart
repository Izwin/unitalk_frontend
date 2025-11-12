import 'package:json_annotation/json_annotation.dart';
part 'notification_settings_model.g.dart';
@JsonSerializable()
class NotificationSettingsModel {
  @JsonKey(name: '_id')
  final String id;
  final String userId;
  final bool enabled;
  final String? fcmToken;
  final bool newPosts;
  final bool newComments;
  final bool newLikes;
  final bool commentReplies;
  final bool mentions;
  final bool chatMessages;
  final bool chatMentions;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationSettingsModel({
    required this.id,
    required this.userId,
    required this.enabled,
    this.fcmToken,
    required this.newPosts,
    required this.newComments,
    required this.newLikes,
    required this.commentReplies,
    required this.mentions,
    required this.chatMessages,
    required this.chatMentions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationSettingsModelToJson(this);

  NotificationSettingsModel copyWith({
    String? id,
    String? userId,
    bool? enabled,
    String? fcmToken,
    bool? newPosts,
    bool? newComments,
    bool? newLikes,
    bool? commentReplies,
    bool? mentions,
    bool? chatMessages,
    bool? chatMentions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationSettingsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      enabled: enabled ?? this.enabled,
      fcmToken: fcmToken ?? this.fcmToken,
      newPosts: newPosts ?? this.newPosts,
      newComments: newComments ?? this.newComments,
      newLikes: newLikes ?? this.newLikes,
      commentReplies: commentReplies ?? this.commentReplies,
      mentions: mentions ?? this.mentions,
      chatMessages: chatMessages ?? this.chatMessages,
      chatMentions: chatMentions ?? this.chatMentions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}