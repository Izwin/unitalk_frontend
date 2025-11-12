// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportModel _$ReportModelFromJson(Map<String, dynamic> json) => ReportModel(
  id: json['_id'] as String,
  reporter: json['reporterId'] == null
      ? null
      : UserModel.fromJson(json['reporterId'] as Map<String, dynamic>),
  targetType: $enumDecode(_$ReportTargetTypeEnumMap, json['targetType']),
  targetId: json['targetId'] as String,
  targetOwner: json['targetOwnerId'] == null
      ? null
      : UserModel.fromJson(json['targetOwnerId'] as Map<String, dynamic>),
  category: $enumDecode(_$ReportCategoryEnumMap, json['category']),
  description: json['description'] as String?,
  status: $enumDecode(_$ReportStatusEnumMap, json['status']),
  resolution: json['resolution'] as String?,
  resolvedBy: json['resolvedBy'] == null
      ? null
      : UserModel.fromJson(json['resolvedBy'] as Map<String, dynamic>),
  resolvedAt: json['resolvedAt'] == null
      ? null
      : DateTime.parse(json['resolvedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ReportModelToJson(ReportModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'reporterId': instance.reporter,
      'targetType': _$ReportTargetTypeEnumMap[instance.targetType]!,
      'targetId': instance.targetId,
      'targetOwnerId': instance.targetOwner,
      'category': _$ReportCategoryEnumMap[instance.category]!,
      'description': instance.description,
      'status': _$ReportStatusEnumMap[instance.status]!,
      'resolution': instance.resolution,
      'resolvedBy': instance.resolvedBy,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ReportTargetTypeEnumMap = {
  ReportTargetType.user: 'user',
  ReportTargetType.post: 'post',
  ReportTargetType.comment: 'comment',
  ReportTargetType.message: 'message',
};

const _$ReportCategoryEnumMap = {
  ReportCategory.spam: 'spam',
  ReportCategory.harassment: 'harassment',
  ReportCategory.hateSpeech: 'hate_speech',
  ReportCategory.violence: 'violence',
  ReportCategory.nudity: 'nudity',
  ReportCategory.falseInformation: 'false_information',
  ReportCategory.impersonation: 'impersonation',
  ReportCategory.other: 'other',
};

const _$ReportStatusEnumMap = {
  ReportStatus.pending: 'pending',
  ReportStatus.underReview: 'under_review',
  ReportStatus.resolved: 'resolved',
  ReportStatus.rejected: 'rejected',
};
