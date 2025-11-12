// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
  id: json['id'] as String,
  author: json['authorId'] == null
      ? null
      : UserModel.fromJson(json['authorId'] as Map<String, dynamic>),
  content: json['content'] as String,
  imageUrl: json['imageUrl'] as String?,
  isAnonymous: json['isAnonymous'] as bool,
  likesCount: (json['likesCount'] as num).toInt(),
  topLikers: (json['topLikers'] as List<dynamic>?)
      ?.map((e) => UserModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  commentsCount: (json['commentsCount'] as num).toInt(),
  isLikedByCurrentUser: json['isLikedByCurrentUser'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
  'id': instance.id,
  'authorId': instance.author,
  'content': instance.content,
  'imageUrl': instance.imageUrl,
  'topLikers': instance.topLikers,
  'isAnonymous': instance.isAnonymous,
  'likesCount': instance.likesCount,
  'commentsCount': instance.commentsCount,
  'isLikedByCurrentUser': instance.isLikedByCurrentUser,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
