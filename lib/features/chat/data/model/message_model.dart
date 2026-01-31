import 'package:json_annotation/json_annotation.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel {
  @JsonKey(name: '_id')
  final String id;

  @JsonKey(name: 'userId')
  final UserModel? user;

  final String facultyId;
  final String sector;
  final String content;
  final String? imageUrl;

  // НОВОЕ: Поля для видео
  final String? videoUrl;

  @JsonKey(defaultValue: 'none')
  final String mediaType; // 'none', 'image', 'video'

  final int? videoDuration; // в секундах

  @JsonKey(name: 'replyTo')
  final MessageModel? replyToMessage;

  final bool isEdited;
  final DateTime? editedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional fields from backend
  final bool? isOwnMessage;
  final bool? canEdit;

  MessageModel({
    required this.id,
    this.user,
    required this.facultyId,
    required this.sector,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    this.mediaType = 'none',
    this.videoDuration,
    this.replyToMessage,
    this.isEdited = false,
    this.editedAt,
    this.isDeleted = false,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.isOwnMessage,
    this.canEdit,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  MessageModel copyWith({
    String? id,
    UserModel? user,
    String? facultyId,
    String? sector,
    String? content,
    String? imageUrl,
    String? videoUrl,
    String? mediaType,
    int? videoDuration,
    MessageModel? replyToMessage,
    bool? isEdited,
    DateTime? editedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOwnMessage,
    bool? canEdit,
  }) {
    return MessageModel(
      id: id ?? this.id,
      user: user ?? this.user,
      facultyId: facultyId ?? this.facultyId,
      sector: sector ?? this.sector,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      mediaType: mediaType ?? this.mediaType,
      videoDuration: videoDuration ?? this.videoDuration,
      replyToMessage: replyToMessage ?? this.replyToMessage,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOwnMessage: isOwnMessage ?? this.isOwnMessage,
      canEdit: canEdit ?? this.canEdit,
    );
  }

  // Утилитные геттеры
  bool get hasImage => mediaType == 'image' && imageUrl != null;
  bool get hasVideo => mediaType == 'video' && videoUrl != null;
  bool get hasMedia => hasImage || hasVideo;
}

@JsonSerializable()
class ChatInfoModel {
  final int totalMessages;
  final int participants;
  final MessageModel? lastMessage;
  final String chatRoom;

  ChatInfoModel({
    required this.totalMessages,
    required this.participants,
    this.lastMessage,
    required this.chatRoom,
  });

  factory ChatInfoModel.fromJson(Map<String, dynamic> json) =>
      _$ChatInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatInfoModelToJson(this);
}

@JsonSerializable()
class OnlineUserModel {
  final String userId;
  final String firstName;
  final String lastName;
  final String? photoUrl;

  OnlineUserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
  });

  factory OnlineUserModel.fromJson(Map<String, dynamic> json) =>
      _$OnlineUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$OnlineUserModelToJson(this);
}