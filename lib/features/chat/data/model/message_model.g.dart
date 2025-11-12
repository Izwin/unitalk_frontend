// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
  id: json['_id'] as String,
  user: json['userId'] == null
      ? null
      : UserModel.fromJson(json['userId'] as Map<String, dynamic>),
  facultyId: json['facultyId'] as String,
  sector: json['sector'] as String,
  content: json['content'] as String,
  imageUrl: json['imageUrl'] as String?,
  replyToMessage: json['replyTo'] == null
      ? null
      : MessageModel.fromJson(json['replyTo'] as Map<String, dynamic>),
  isEdited: json['isEdited'] as bool? ?? false,
  editedAt: json['editedAt'] == null
      ? null
      : DateTime.parse(json['editedAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isOwnMessage: json['isOwnMessage'] as bool?,
  canEdit: json['canEdit'] as bool?,
);

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'userId': instance.user,
      'facultyId': instance.facultyId,
      'sector': instance.sector,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'replyTo': instance.replyToMessage,
      'isEdited': instance.isEdited,
      'editedAt': instance.editedAt?.toIso8601String(),
      'isDeleted': instance.isDeleted,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isOwnMessage': instance.isOwnMessage,
      'canEdit': instance.canEdit,
    };

ChatInfoModel _$ChatInfoModelFromJson(Map<String, dynamic> json) =>
    ChatInfoModel(
      totalMessages: (json['totalMessages'] as num).toInt(),
      participants: (json['participants'] as num).toInt(),
      lastMessage: json['lastMessage'] == null
          ? null
          : MessageModel.fromJson(json['lastMessage'] as Map<String, dynamic>),
      chatRoom: json['chatRoom'] as String,
    );

Map<String, dynamic> _$ChatInfoModelToJson(ChatInfoModel instance) =>
    <String, dynamic>{
      'totalMessages': instance.totalMessages,
      'participants': instance.participants,
      'lastMessage': instance.lastMessage,
      'chatRoom': instance.chatRoom,
    };

OnlineUserModel _$OnlineUserModelFromJson(Map<String, dynamic> json) =>
    OnlineUserModel(
      userId: json['userId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      photoUrl: json['photoUrl'] as String?,
    );

Map<String, dynamic> _$OnlineUserModelToJson(OnlineUserModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'photoUrl': instance.photoUrl,
    };
