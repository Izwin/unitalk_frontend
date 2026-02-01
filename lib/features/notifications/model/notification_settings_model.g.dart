// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationSettingsModel _$NotificationSettingsModelFromJson(
  Map<String, dynamic> json,
) => NotificationSettingsModel(
  id: json['_id'] as String,
  userId: json['userId'] as String,
  enabled: json['enabled'] as bool,
  fcmToken: json['fcmToken'] as String?,
  newPosts: json['newPosts'] as bool,
  newComments: json['newComments'] as bool,
  newLikes: json['newLikes'] as bool,
  commentReplies: json['commentReplies'] as bool,
  mentions: json['mentions'] as bool,
  chatMessages: json['chatMessages'] as bool,
  chatMentions: json['chatMentions'] as bool,
  newPostsFilter:
      $enumDecodeNullable(_$NewPostsFilterEnumMap, json['newPostsFilter']) ??
      NewPostsFilter.all,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$NotificationSettingsModelToJson(
  NotificationSettingsModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'userId': instance.userId,
  'enabled': instance.enabled,
  'fcmToken': instance.fcmToken,
  'newPosts': instance.newPosts,
  'newComments': instance.newComments,
  'newLikes': instance.newLikes,
  'commentReplies': instance.commentReplies,
  'mentions': instance.mentions,
  'chatMessages': instance.chatMessages,
  'chatMentions': instance.chatMentions,
  'newPostsFilter': _$NewPostsFilterEnumMap[instance.newPostsFilter]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$NewPostsFilterEnumMap = {
  NewPostsFilter.all: 'all',
  NewPostsFilter.myUniversity: 'myUniversity',
  NewPostsFilter.friends: 'friends',
};
