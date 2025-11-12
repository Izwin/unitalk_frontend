// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      postId: json['postId'] as String?,
      commentId: json['commentId'] as String?,
      fromUserId: json['fromUserId'] as String?,
      isRead: json['isRead'] as bool,
      isSent: json['isSent'] as bool,
      sentAt: json['sentAt'] == null
          ? null
          : DateTime.parse(json['sentAt'] as String),
      language: json['language'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      fromUser: json['fromUser'] == null
          ? null
          : UserModel.fromJson(json['fromUser'] as Map<String, dynamic>),
      post: json['post'] == null
          ? null
          : PostModel.fromJson(json['post'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'userId': instance.userId,
      'type': instance.type,
      'title': instance.title,
      'body': instance.body,
      'postId': instance.postId,
      'commentId': instance.commentId,
      'fromUserId': instance.fromUserId,
      'isRead': instance.isRead,
      'isSent': instance.isSent,
      'sentAt': instance.sentAt?.toIso8601String(),
      'language': instance.language,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
