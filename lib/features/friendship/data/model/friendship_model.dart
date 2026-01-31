// lib/features/friendship/data/models/friendship_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';

part 'friendship_model.g.dart';

enum FriendshipStatus {
  @JsonValue('none')
  none,
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('rejected')
  rejected,
}

@JsonSerializable()
class FriendshipModel {
  @JsonKey(name: '_id')
  final String? id;
  final FriendshipStatus status;
  final String? friendshipId;
  final bool? isRequester;
  final DateTime? createdAt;
  final DateTime? acceptedAt;

  FriendshipModel({
    this.id,
    required this.status,
    this.friendshipId,
    this.isRequester,
    this.createdAt,
    this.acceptedAt,
  });

  factory FriendshipModel.fromJson(Map<String, dynamic> json) =>
      _$FriendshipModelFromJson(json);

  Map<String, dynamic> toJson() => _$FriendshipModelToJson(this);

  bool get isPending => status == FriendshipStatus.pending;
  bool get isAccepted => status == FriendshipStatus.accepted;
  bool get isNone => status == FriendshipStatus.none;
}

@JsonSerializable()
class FriendshipStatusResponse {
  final FriendshipStatus status;
  final bool isFriend;
  final String? friendshipId;
  final bool? isRequester;
  final DateTime? createdAt;
  final DateTime? acceptedAt;

  FriendshipStatusResponse({
    required this.status,
    required this.isFriend,
    this.friendshipId,
    this.isRequester,
    this.createdAt,
    this.acceptedAt,
  });

  factory FriendshipStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$FriendshipStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FriendshipStatusResponseToJson(this);
}

@JsonSerializable()
class FriendRequestModel {
  final String friendshipId;
  final UserModel user;
  final DateTime requestedAt;

  FriendRequestModel({
    required this.friendshipId,
    required this.user,
    required this.requestedAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) =>
      _$FriendRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$FriendRequestModelToJson(this);
}