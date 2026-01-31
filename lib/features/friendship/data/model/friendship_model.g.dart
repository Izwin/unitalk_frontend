// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendship_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendshipModel _$FriendshipModelFromJson(Map<String, dynamic> json) =>
    FriendshipModel(
      id: json['_id'] as String?,
      status: $enumDecode(_$FriendshipStatusEnumMap, json['status']),
      friendshipId: json['friendshipId'] as String?,
      isRequester: json['isRequester'] as bool?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      acceptedAt: json['acceptedAt'] == null
          ? null
          : DateTime.parse(json['acceptedAt'] as String),
    );

Map<String, dynamic> _$FriendshipModelToJson(FriendshipModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'status': _$FriendshipStatusEnumMap[instance.status]!,
      'friendshipId': instance.friendshipId,
      'isRequester': instance.isRequester,
      'createdAt': instance.createdAt?.toIso8601String(),
      'acceptedAt': instance.acceptedAt?.toIso8601String(),
    };

const _$FriendshipStatusEnumMap = {
  FriendshipStatus.none: 'none',
  FriendshipStatus.pending: 'pending',
  FriendshipStatus.accepted: 'accepted',
  FriendshipStatus.rejected: 'rejected',
};

FriendshipStatusResponse _$FriendshipStatusResponseFromJson(
  Map<String, dynamic> json,
) => FriendshipStatusResponse(
  status: $enumDecode(_$FriendshipStatusEnumMap, json['status']),
  isFriend: json['isFriend'] as bool,
  friendshipId: json['friendshipId'] as String?,
  isRequester: json['isRequester'] as bool?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  acceptedAt: json['acceptedAt'] == null
      ? null
      : DateTime.parse(json['acceptedAt'] as String),
);

Map<String, dynamic> _$FriendshipStatusResponseToJson(
  FriendshipStatusResponse instance,
) => <String, dynamic>{
  'status': _$FriendshipStatusEnumMap[instance.status]!,
  'isFriend': instance.isFriend,
  'friendshipId': instance.friendshipId,
  'isRequester': instance.isRequester,
  'createdAt': instance.createdAt?.toIso8601String(),
  'acceptedAt': instance.acceptedAt?.toIso8601String(),
};

FriendRequestModel _$FriendRequestModelFromJson(Map<String, dynamic> json) =>
    FriendRequestModel(
      friendshipId: json['friendshipId'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      requestedAt: DateTime.parse(json['requestedAt'] as String),
    );

Map<String, dynamic> _$FriendRequestModelToJson(FriendRequestModel instance) =>
    <String, dynamic>{
      'friendshipId': instance.friendshipId,
      'user': instance.user,
      'requestedAt': instance.requestedAt.toIso8601String(),
    };
