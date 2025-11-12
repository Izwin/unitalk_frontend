import 'package:json_annotation/json_annotation.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';

part 'block_model.g.dart';

@JsonSerializable()
class BlockModel {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(name: 'blockerId')
  final String blockerId;
  @JsonKey(name: 'blockedId')
  final UserModel blockedUser;
  final DateTime createdAt;

  BlockModel({
    required this.id,
    required this.blockerId,
    required this.blockedUser,
    required this.createdAt,
  });

  factory BlockModel.fromJson(Map<String, dynamic> json) =>
      _$BlockModelFromJson(json);

  Map<String, dynamic> toJson() => _$BlockModelToJson(this);
}

@JsonSerializable()
class BlockStatusModel {
  final bool isBlocked;
  final bool? isBlockedBy;
  final bool? canInteract;

  BlockStatusModel({
    required this.isBlocked,
    required this.isBlockedBy,
    required this.canInteract,
  });

  factory BlockStatusModel.fromJson(Map<String, dynamic> json) =>
      _$BlockStatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$BlockStatusModelToJson(this);
}