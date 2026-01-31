import 'package:equatable/equatable.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_model.g.dart';

enum MediaType {
  @JsonValue('none')
  none,
  @JsonValue('image')
  image,
  @JsonValue('video')
  video,
}

@JsonSerializable()
class PostModel extends Equatable {
  final String id;
  @JsonKey(name: 'authorId')
  final UserModel? author;
  final String content;
  final String? imageUrl;
  final String? videoUrl;
  final MediaType mediaType;
  final int? videoDuration;
  final List<UserModel>? topLikers;
  final bool isAnonymous;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByCurrentUser;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final DateTime? pinnedAt;

  const PostModel({
    required this.id,
    required this.author,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    this.mediaType = MediaType.none,
    this.videoDuration,
    required this.isAnonymous,
    required this.likesCount,
    this.topLikers,
    required this.commentsCount,
    required this.isLikedByCurrentUser,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.pinnedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostModelToJson(this);

  PostModel copyWith({
    String? id,
    UserModel? author,
    String? content,
    String? imageUrl,
    String? videoUrl,
    MediaType? mediaType,
    int? videoDuration,
    bool? isAnonymous,
    int? likesCount,
    int? commentsCount,
    bool? isLikedByCurrentUser,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    DateTime? pinnedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      mediaType: mediaType ?? this.mediaType,
      videoDuration: videoDuration ?? this.videoDuration,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      pinnedAt: pinnedAt ?? this.pinnedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    author,
    content,
    imageUrl,
    videoUrl,
    mediaType,
    videoDuration,
    isAnonymous,
    likesCount,
    commentsCount,
    isLikedByCurrentUser,
    createdAt,
    updatedAt,
    isPinned,
    pinnedAt,
  ];
}