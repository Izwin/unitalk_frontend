import 'package:equatable/equatable.dart';
import 'package:unitalk/features/feed/data/model/post_model.dart';
import 'package:unitalk/features/university/data/models/university_model.dart';

enum PostStatus { initial, loading, success, failure, deleted }

class PostState extends Equatable {
  final PostStatus status;
  final List<PostModel> posts;
  final int postsPage;
  final bool postsLastPage;
  final int totalPostsCount;  // ✅ Добавлено
  final PostModel? currentPost;
  final String? errorMessage;
  final String? uploadUrl;
  final UniversityModel? selectedUniversity;
  final bool isLoadingMore;
  final bool isRefreshing;

  const PostState._({
    required this.status,
    this.posts = const [],
    required this.postsPage,
    required this.postsLastPage,
    this.totalPostsCount = 0,  // ✅ Добавлено
    this.currentPost,
    this.errorMessage,
    this.uploadUrl,
    this.selectedUniversity,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  });

  factory PostState.initial() => const PostState._(
    status: PostStatus.initial,
    posts: [],
    postsLastPage: false,
    postsPage: 1,
    totalPostsCount: 0,  // ✅ Добавлено
    isLoadingMore: false,
    isRefreshing: false,
  );

  PostState copyWith({
    PostStatus? status,
    List<PostModel>? posts,
    int? postsPage,
    bool? postsLastPage,
    int? totalPostsCount,  // ✅ Добавлено
    PostModel? currentPost,
    String? errorMessage,
    String? uploadUrl,
    UniversityModel? selectedUniversity,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return PostState._(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      postsPage: postsPage ?? this.postsPage,
      postsLastPage: postsLastPage ?? this.postsLastPage,
      totalPostsCount: totalPostsCount ?? this.totalPostsCount,  // ✅ Добавлено
      currentPost: currentPost ?? this.currentPost,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadUrl: uploadUrl ?? this.uploadUrl,
      selectedUniversity: selectedUniversity ?? this.selectedUniversity,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    status,
    posts,
    postsPage,
    postsLastPage,
    totalPostsCount,  // ✅ Добавлено
    currentPost,
    errorMessage,
    uploadUrl,
    selectedUniversity,
    isLoadingMore,
    isRefreshing,
  ];
}