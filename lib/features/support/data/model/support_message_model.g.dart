// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportMessageModel _$SupportMessageModelFromJson(Map<String, dynamic> json) =>
    SupportMessageModel(
      id: json['_id'] as String,
      user: json['userId'] == null
          ? null
          : UserModel.fromJson(json['userId'] as Map<String, dynamic>),
      subject: json['subject'] as String,
      message: json['message'] as String,
      imageUrl: json['imageUrl'] as String?,
      status: json['status'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SupportMessageModelToJson(
  SupportMessageModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'userId': instance.user,
  'subject': instance.subject,
  'message': instance.message,
  'imageUrl': instance.imageUrl,
  'status': instance.status,
  'category': instance.category,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
