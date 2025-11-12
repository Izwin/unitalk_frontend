// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerificationModel _$VerificationModelFromJson(Map<String, dynamic> json) =>
    VerificationModel(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      studentCardImageUrl: json['studentCardImageUrl'] as String?,
      status: json['status'] as String,
      rejectionReason: json['rejectionReason'] as String?,
      approvedBy: json['approvedBy'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
    );

Map<String, dynamic> _$VerificationModelToJson(VerificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'studentCardImageUrl': instance.studentCardImageUrl,
      'status': instance.status,
      'rejectionReason': instance.rejectionReason,
      'approvedBy': instance.approvedBy,
      'createdAt': instance.createdAt?.toIso8601String(),
      'approvedAt': instance.approvedAt?.toIso8601String(),
    };
