import 'package:json_annotation/json_annotation.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';

part 'report_model.g.dart';

enum ReportTargetType {
  @JsonValue('user')
  user,
  @JsonValue('post')
  post,
  @JsonValue('comment')
  comment,
  @JsonValue('message')
  message;

  String get displayName {
    switch (this) {
      case ReportTargetType.user:
        return 'User';
      case ReportTargetType.post:
        return 'Post';
      case ReportTargetType.comment:
        return 'Comment';
      case ReportTargetType.message:
        return 'Message';
    }
  }
}

enum ReportCategory {
  @JsonValue('spam')
  spam,
  @JsonValue('harassment')
  harassment,
  @JsonValue('hate_speech')
  hateSpeech,
  @JsonValue('violence')
  violence,
  @JsonValue('nudity')
  nudity,
  @JsonValue('false_information')
  falseInformation,
  @JsonValue('impersonation')
  impersonation,
  @JsonValue('other')
  other;

  String get displayName {
    switch (this) {
      case ReportCategory.spam:
        return 'Spam';
      case ReportCategory.harassment:
        return 'Harassment';
      case ReportCategory.hateSpeech:
        return 'Hate Speech';
      case ReportCategory.violence:
        return 'Violence';
      case ReportCategory.nudity:
        return 'Nudity';
      case ReportCategory.falseInformation:
        return 'False Information';
      case ReportCategory.impersonation:
        return 'Impersonation';
      case ReportCategory.other:
        return 'Other';
    }
  }
}

enum ReportStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('under_review')
  underReview,
  @JsonValue('resolved')
  resolved,
  @JsonValue('rejected')
  rejected;

  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.underReview:
        return 'Under Review';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.rejected:
        return 'Rejected';
    }
  }
}

@JsonSerializable()
class ReportModel {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(name: 'reporterId')
  final UserModel? reporter;
  final ReportTargetType targetType;
  final String targetId;
  @JsonKey(name: 'targetOwnerId')
  final UserModel? targetOwner;
  final ReportCategory category;
  final String? description;
  final ReportStatus status;
  final String? resolution;
  @JsonKey(name: 'resolvedBy')
  final UserModel? resolvedBy;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReportModel({
    required this.id,
    this.reporter,
    required this.targetType,
    required this.targetId,
    this.targetOwner,
    required this.category,
    this.description,
    required this.status,
    this.resolution,
    this.resolvedBy,
    this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) =>
      _$ReportModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReportModelToJson(this);
}