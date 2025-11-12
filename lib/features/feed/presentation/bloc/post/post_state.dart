import 'package:equatable/equatable.dart';
import 'package:unitalk/features/feed/data/model/post_model.dart';
import 'package:unitalk/features/university/data/models/university_model.dart';

enum PostStatus { initial, loading, success, failure, deleted }

class PostState extends Equatable {
  final PostStatus status;
  final List<PostModel> posts;
  final int postsPage;
  final bool postsLastPage;
  final PostModel? currentPost;
  final String? errorMessage;
  final String? uploadUrl;

  // Новые поля для управления лентой
  final UniversityModel? selectedUniversity;
  final bool isLoadingMore;
  final bool isRefreshing;

  const PostState._({
    required this.status,
    this.posts = const [],
    required this.postsPage,
    required this.postsLastPage,
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
    isLoadingMore: false,
    isRefreshing: false,
  );

  PostState copyWith({
    PostStatus? status,
    List<PostModel>? posts,
    int? postsPage,
    bool? postsLastPage,
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
      currentPost: currentPost ?? this.currentPost,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadUrl: uploadUrl ?? this.uploadUrl,
      selectedUniversity: selectedUniversity ?? this.selectedUniversity,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  // Геттеры для удобства
  bool get hasSelectedUniversity => selectedUniversity != null;
  bool get isEmpty => posts.isEmpty;
  bool get isLoading => status == PostStatus.loading && !isLoadingMore && !isRefreshing;
  bool get hasError => status == PostStatus.failure;

  @override
  List<Object?> get props => [
    status,
    posts,
    postsPage,
    postsLastPage,
    currentPost,
    errorMessage,
    uploadUrl,
    selectedUniversity,
    isLoadingMore,
    isRefreshing,
  ];
}