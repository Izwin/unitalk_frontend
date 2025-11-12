// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnnouncementModel _$AnnouncementModelFromJson(Map<String, dynamic> json) =>
    AnnouncementModel(
      id: json['_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      type: json['type'] as String,
      priority: (json['priority'] as num).toInt(),
      linkUrl: json['linkUrl'] as String?,
      linkText: json['linkText'] as String?,
      viewsCount: (json['viewsCount'] as num).toInt(),
      clicksCount: (json['clicksCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AnnouncementModelToJson(AnnouncementModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'type': instance.type,
      'priority': instance.priority,
      'linkUrl': instance.linkUrl,
      'linkText': instance.linkText,
      'viewsCount': instance.viewsCount,
      'clicksCount': instance.clicksCount,
      'createdAt': instance.createdAt.toIso8601String(),
    };
