import 'package:json_annotation/json_annotation.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';

part 'comment_model.g.dart';

enum CommentMediaType {
  @JsonValue('none')
  none,
  @JsonValue('image')
  image,
  @JsonValue('video')
  video,
}

@JsonSerializable()
class CommentModel {
  @JsonKey(name: '_id')

  final String id;

  @JsonKey(name: 'authorId')
  final UserModel? author;

  final String postId;
  final String content;

  // Медиа поля
  final String? imageUrl;
  final String? videoUrl;
  final CommentMediaType mediaType;
  final int? videoDuration; // в секундах

  final int likesCount; // Добавлено
  final bool isLikedByCurrentUser; // Добавлено
  final List<UserModel>? topLikers;

  final bool isAnonymous;
  final int repliesCount;
  final String? parentCommentId;
  final String? replyToCommentId;
  final ReplyToUserModel? replyToUser;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CommentModel({
    required this.id,
    required this.author,
    required this.postId,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    this.mediaType = CommentMediaType.none,
    this.videoDuration,
    required this.isAnonymous,
    required this.repliesCount,
    this.parentCommentId,
    this.replyToCommentId,
    required this.likesCount,
    required this.isLikedByCurrentUser,
    this.topLikers,
    this.replyToUser,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);

  CommentModel copyWith({
    String? id,
    String? postId,
    UserModel? author,
    String? content,
    String? parentCommentId,
    String? replyToCommentId,
    ReplyToUserModel? replyToUser,
    bool? isAnonymous,
    CommentMediaType? mediaType,
    String? imageUrl,
    String? videoUrl,
    int? repliesCount,
    int? likesCount,
    bool? isLikedByCurrentUser,
    List<UserModel>? topLikers,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      author: author ?? this.author,
      content: content ?? this.content,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      replyToCommentId: replyToCommentId ?? this.replyToCommentId,
      replyToUser: replyToUser ?? this.replyToUser,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      mediaType: mediaType ?? this.mediaType,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      repliesCount: repliesCount ?? this.repliesCount,
      likesCount: likesCount ?? this.likesCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      topLikers: topLikers ?? this.topLikers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class ReplyToUserModel {
  final String? firstName;
  final String? lastName;

  const ReplyToUserModel({
    this.firstName,
    this.lastName,
  });

  factory ReplyToUserModel.fromJson(Map<String, dynamic> json) =>
      _$ReplyToUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReplyToUserModelToJson(this);
}