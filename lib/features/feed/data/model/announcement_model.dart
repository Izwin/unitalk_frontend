// features/feed/data/model/announcement_model.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'announcement_model.g.dart';

@JsonSerializable()
class AnnouncementModel extends Equatable {
  @JsonKey(
    name:
      '_id'
  )
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String type; // announcement, advertisement, event, info
  final int priority;
  final String? linkUrl;
  final String? linkText;
  final int viewsCount;
  final int clicksCount;
  final DateTime createdAt;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.type,
    required this.priority,
    this.linkUrl,
    this.linkText,
    required this.viewsCount,
    required this.clicksCount,
    required this.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementModelFromJson(json);

  Map<String, dynamic> toJson() => _$AnnouncementModelToJson(this);

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    imageUrl,
    type,
    priority,
    linkUrl,
    linkText,
    viewsCount,
    clicksCount,
    createdAt,
  ];
}