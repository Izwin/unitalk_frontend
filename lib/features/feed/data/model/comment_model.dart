import 'package:json_annotation/json_annotation.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';

part 'comment_model.g.dart';

@JsonSerializable()
class CommentModel {
  final String id;

  @JsonKey(name: 'displayAuthor')
  final UserModel? author;

  final String postId;
  final String content;

  // Добавляем поле для изображения
  final String? imageUrl;

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
    required this.isAnonymous,
    required this.repliesCount,
    this.parentCommentId,
    this.replyToCommentId,
    this.replyToUser,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);
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