// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentModel _$CommentModelFromJson(Map<String, dynamic> json) => CommentModel(
  id: json['_id'] as String,
  author: json['authorId'] == null
      ? null
      : UserModel.fromJson(json['authorId'] as Map<String, dynamic>),
  postId: json['postId'] as String,
  content: json['content'] as String,
  imageUrl: json['imageUrl'] as String?,
  videoUrl: json['videoUrl'] as String?,
  mediaType:
      $enumDecodeNullable(_$CommentMediaTypeEnumMap, json['mediaType']) ??
      CommentMediaType.none,
  videoDuration: (json['videoDuration'] as num?)?.toInt(),
  isAnonymous: json['isAnonymous'] as bool,
  repliesCount: (json['repliesCount'] as num).toInt(),
  parentCommentId: json['parentCommentId'] as String?,
  replyToCommentId: json['replyToCommentId'] as String?,
  likesCount: (json['likesCount'] as num).toInt(),
  isLikedByCurrentUser: json['isLikedByCurrentUser'] as bool,
  topLikers: (json['topLikers'] as List<dynamic>?)
      ?.map((e) => UserModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  replyToUser: json['replyToUser'] == null
      ? null
      : ReplyToUserModel.fromJson(json['replyToUser'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CommentModelToJson(CommentModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'authorId': instance.author,
      'postId': instance.postId,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'videoUrl': instance.videoUrl,
      'mediaType': _$CommentMediaTypeEnumMap[instance.mediaType]!,
      'videoDuration': instance.videoDuration,
      'likesCount': instance.likesCount,
      'isLikedByCurrentUser': instance.isLikedByCurrentUser,
      'topLikers': instance.topLikers,
      'isAnonymous': instance.isAnonymous,
      'repliesCount': instance.repliesCount,
      'parentCommentId': instance.parentCommentId,
      'replyToCommentId': instance.replyToCommentId,
      'replyToUser': instance.replyToUser,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$CommentMediaTypeEnumMap = {
  CommentMediaType.none: 'none',
  CommentMediaType.image: 'image',
  CommentMediaType.video: 'video',
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
