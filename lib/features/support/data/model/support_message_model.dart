// features/support/data/model/support_message_model.dart
import 'package:equatable/equatable.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'support_message_model.g.dart';

@JsonSerializable()
class SupportMessageModel extends Equatable {
  @JsonKey(name: '_id')
  final String id;

  @JsonKey(name: 'userId')
  final UserModel? user;

  final String subject;
  final String message;
  final String? imageUrl;
  final String status;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupportMessageModel({
    required this.id,
    this.user,
    required this.subject,
    required this.message,
    this.imageUrl,
    required this.status,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) =>
      _$SupportMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$SupportMessageModelToJson(this);

  @override
  List<Object?> get props => [
    id,
    user,
    subject,
    message,
    imageUrl,
    status,
    category,
    createdAt,
    updatedAt,
  ];
}