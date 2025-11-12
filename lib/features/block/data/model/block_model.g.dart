// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockModel _$BlockModelFromJson(Map<String, dynamic> json) => BlockModel(
  id: json['_id'] as String,
  blockerId: json['blockerId'] as String,
  blockedUser: UserModel.fromJson(json['blockedId'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$BlockModelToJson(BlockModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'blockerId': instance.blockerId,
      'blockedId': instance.blockedUser,
      'createdAt': instance.createdAt.toIso8601String(),
    };

BlockStatusModel _$BlockStatusModelFromJson(Map<String, dynamic> json) =>
    BlockStatusModel(
      isBlocked: json['isBlocked'] as bool,
      isBlockedBy: json['isBlockedBy'] as bool?,
      canInteract: json['canInteract'] as bool?,
    );

Map<String, dynamic> _$BlockStatusModelToJson(BlockStatusModel instance) =>
    <String, dynamic>{
      'isBlocked': instance.isBlocked,
      'isBlockedBy': instance.isBlockedBy,
      'canInteract': instance.canInteract,
    };
