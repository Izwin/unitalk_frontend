// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_search_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSearchResponseModel _$UserSearchResponseModelFromJson(
  Map<String, dynamic> json,
) => UserSearchResponseModel(
  users: (json['users'] as List<dynamic>)
      .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
);

Map<String, dynamic> _$UserSearchResponseModelToJson(
  UserSearchResponseModel instance,
) => <String, dynamic>{
  'users': instance.users,
  'total': instance.total,
  'offset': instance.offset,
  'limit': instance.limit,
};
