import 'package:json_annotation/json_annotation.dart';
part 'like_response_model.g.dart';
@JsonSerializable()
class LikeResponseModel{
  final bool isLiked;
  final int likesCount;

  LikeResponseModel({required this.isLiked, required this.likesCount});

  factory LikeResponseModel.fromJson(Map<String,dynamic> json) => _$LikeResponseModelFromJson(json);

  Map<String,dynamic> toJson() => _$LikeResponseModelToJson(this);
}