import 'package:json_annotation/json_annotation.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';

part 'user_search_response_model.g.dart';

@JsonSerializable()
class UserSearchResponseModel {
  final List<UserModel> users;
  final int total;
  final int offset;
  final int limit;

  UserSearchResponseModel({
    required this.users,
    required this.total,
    required this.offset,
    required this.limit,
  });

  factory UserSearchResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UserSearchResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserSearchResponseModelToJson(this);

  bool get hasMore => (offset + users.length) < total;
}