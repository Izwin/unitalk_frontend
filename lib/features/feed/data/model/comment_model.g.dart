// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentModel _$CommentModelFromJson(Map<String, dynamic> json) => CommentModel(
  id: json['id'] as String,
  author: json['displayAuthor'] == null
      ? null
      : UserModel.fromJson(json['displayAuthor'] as Map<String, dynamic>),
  postId: json['postId'] as String,
  content: json['content'] as String,
  imageUrl: json['imageUrl'] as String?,
  isAnonymous: json['isAnonymous'] as bool,
  repliesCount: (json['repliesCount'] as num).toInt(),
  parentCommentId: json['parentCommentId'] as String?,
  replyToCommentId: json['replyToCommentId'] as String?,
  replyToUser: json['replyToUser'] == null
      ? null
      : ReplyToUserModel.fromJson(json['replyToUser'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CommentModelToJson(CommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayAuthor': instance.author,
      'postId': instance.postId,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'isAnonymous': instance.isAnonymous,
      'repliesCount': instance.repliesCount,
      'parentCommentId': instance.parentCommentId,
      'replyToCommentId': instance.replyToCommentId,
      'replyToUser': instance.replyToUser,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

ReplyToUserModel _$ReplyToUserModelFromJson(Map<String, dynamic> json) =>
    ReplyToUserModel(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
    );

Map<String, dynamic> _$ReplyToUserModelToJson(ReplyToUserModel instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
    };
