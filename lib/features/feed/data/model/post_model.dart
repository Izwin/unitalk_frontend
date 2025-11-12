import 'package:equatable/equatable.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_model.g.dart';

@JsonSerializable()
class PostModel extends Equatable {
  final String id;
  @JsonKey(name: 'authorId')
  final UserModel? author;
  final String content;
  final String? imageUrl;
  final List<UserModel>? topLikers;
  final bool isAnonymous;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByCurrentUser;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostModel({
    required this.id,
    required this.author,
    required this.content,
    this.imageUrl,
    required this.isAnonymous,
    required this.likesCount,
    this.topLikers,
    required this.commentsCount,
    required this.isLikedByCurrentUser,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  PostModel copyWith({
    String? id,
    UserModel? author,
    String? content,
    String? imageUrl,
    bool? isAnonymous,
    int? likesCount,
    int? commentsCount,
    bool? isLikedByCurrentUser,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    author,
    content,
    imageUrl,
    isAnonymous,
    likesCount,
    commentsCount,
    isLikedByCurrentUser,
    createdAt,
    updatedAt,
  ];
}
