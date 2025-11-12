import 'package:json_annotation/json_annotation.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/feed/data/model/post_model.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  @JsonKey(name: '_id')
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final String? postId;
  final String? commentId;
  final String? fromUserId;
  final bool isRead;
  final bool isSent;
  final DateTime? sentAt;
  final String language;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated fields
  @JsonKey(includeFromJson: true, includeToJson: false)
  final UserModel? fromUser;
  @JsonKey(includeFromJson: true, includeToJson: false)
  final PostModel? post;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.postId,
    this.commentId,
    this.fromUserId,
    required this.isRead,
    required this.isSent,
    this.sentAt,
    required this.language,
    required this.createdAt,
    required this.updatedAt,
    this.fromUser,
    this.post,
  });


  factory NotificationModel.fromJson(Map<String,dynamic> json) => _$NotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? body,
    String? postId,
    String? commentId,
    String? fromUserId,
    bool? isRead,
    bool? isSent,
    DateTime? sentAt,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? fromUser,
    PostModel? post,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      postId: postId ?? this.postId,
      commentId: commentId ?? this.commentId,
      fromUserId: fromUserId ?? this.fromUserId,
      isRead: isRead ?? this.isRead,
      isSent: isSent ?? this.isSent,
      sentAt: sentAt ?? this.sentAt,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fromUser: fromUser ?? this.fromUser,
      post: post ?? this.post,
    );
  }
}
