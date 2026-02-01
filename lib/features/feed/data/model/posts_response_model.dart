// features/feed/data/model/posts_response_model.dart

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:unitalk/features/feed/data/model/post_model.dart';

part 'posts_response_model.g.dart';

@JsonSerializable()
class PaginationModel extends Equatable {
  final int page;
  final int limit;
  final int total;
  final int pages;
  final int pinnedCount;

  const PaginationModel({
    this.page = 1,
    this.limit = 20,
    this.total = 0,
    this.pages = 0,
    this.pinnedCount = 0,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) =>
      _$PaginationModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationModelToJson(this);

  @override
  List<Object?> get props => [page, limit, total, pages, pinnedCount];
}

@JsonSerializable()
class PostsResponseModel extends Equatable {
  final List<PostModel> posts;
  final PaginationModel pagination;

  const PostsResponseModel({
    this.posts = const [],
    required this.pagination,
  });

  factory PostsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PostsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostsResponseModelToJson(this);

  @override
  List<Object?> get props => [posts, pagination];
}