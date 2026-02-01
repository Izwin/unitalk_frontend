// features/feed/presentation/bloc/post/post_bloc.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/core/services/post_syns_service.dart';
import 'package:unitalk/features/feed/data/model/post_model.dart';
import 'package:unitalk/features/feed/domain/repository/like_repository.dart';
import 'package:unitalk/features/feed/domain/repository/posts_repository.dart';

import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;
  final LikeRepository likeRepository;
  final PostSyncService postSyncService;
  StreamSubscription? _syncSubscription;

  PostBloc({
    required this.postRepository,
    required this.likeRepository,
    required this.postSyncService,
  }) : super(PostState.initial()) {
    on<CreatePostEvent>(_onCreatePost);
    on<GetPostsEvent>(_onGetPosts);
    on<GetPostEvent>(_onGetPost);
    on<DeletePostEvent>(_onDeletePost);
    on<ToggleLikeEvent>(_onToggleLike);
    on<SyncPostUpdateEvent>(_onSyncPostUpdate);

    // Подписываемся на обновления из PostSyncService
    _syncSubscription = postSyncService.updates.listen((update) {
      print(
        'PostBloc: Received sync update - type: ${update.type}, postId: ${update.postId}',
      );
      add(SyncPostUpdateEvent(update));
    });
  }

  // === Создание поста ===
  Future<void> _onCreatePost(
      CreatePostEvent event,
      Emitter<PostState> emit,
      ) async {
    emit(state.copyWith(status: PostStatus.loading, errorMessage: null));

    final result = await postRepository.createPost(
      content: event.content,
      isAnonymous: event.isAnonymous,
      mediaFile: event.mediaFile,
    );

    result.fold(
          (failure) => emit(state.copyWith(
        status: PostStatus.failure,
        errorMessage: failure.message,
      )),
          (post) {
        final updatedPosts = [post, ...state.posts];
        emit(state.copyWith(
          status: PostStatus.success,
          posts: updatedPosts,
          currentPost: post,
        ));

        postSyncService.notifyPostUpdated(
          PostUpdate(
            postId: post.id,
            type: PostUpdateType.create,
            updatedPost: post,
          ),
        );
      },
    );
  }

  // === Получение списка постов ===
// features/feed/presentation/bloc/post/post_bloc.dart

  // features/feed/presentation/bloc/post/post_bloc.dart

  Future<void> _onGetPosts(
      GetPostsEvent event,
      Emitter<PostState> emit,
      ) async {
    // ✅ Разные состояния для первой загрузки и подгрузки
    if (event.page == 1) {
      emit(state.copyWith(
        status: PostStatus.loading,
        errorMessage: null,
        isLoadingMore: false,
      ));
    } else {
      emit(state.copyWith(
        isLoadingMore: true,
        errorMessage: null,
      ));
    }

    final result = await postRepository.getPosts(
      universityId: event.universityId,
      authorId: event.authorId,
      sortBy: event.sortBy,
      sector: event.sector,
      facultyId: event.facultyId,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
          (failure) {
        print('❌ PostBloc failure: ${failure.message}');
        emit(state.copyWith(
          status: PostStatus.failure,
          errorMessage: failure.message,
          isLoadingMore: false,
        ));
      },
          (response) {
        final posts = response.posts;
        final pagination = response.pagination;

        print('📊 Page ${event.page}: received ${posts.length} posts, total: ${pagination.total}');

        // ✅ Для первой страницы заменяем список, для остальных добавляем
        final updatedPosts = event.page == 1
            ? posts
            : [...state.posts, ...posts];

        // ✅ Следующая страница для загрузки
        final nextPage = event.page + 1;

        // ✅ Проверяем достигли ли последней страницы
        final isLastPage = posts.length < event.limit ||
            pagination.page >= pagination.pages;

        emit(state.copyWith(
          status: PostStatus.success,
          posts: updatedPosts,
          postsPage: nextPage,
          postsLastPage: isLastPage,
          totalPostsCount: pagination.total,
          isLoadingMore: false,
        ));

        print('✅ Updated: ${updatedPosts.length} posts, nextPage: $nextPage, isLast: $isLastPage');
      },
    );
  }

  // === Получение одного поста ===
  Future<void> _onGetPost(
      GetPostEvent event,
      Emitter<PostState> emit,
      ) async {
    emit(state.copyWith(status: PostStatus.loading, errorMessage: null));

    final result = await postRepository.getPost(event.postId);

    result.fold(
          (failure) => emit(state.copyWith(
        status: PostStatus.failure,
        errorMessage: failure.message,
      )),
          (post) => emit(state.copyWith(
        status: PostStatus.success,
        currentPost: post,
      )),
    );
  }

  // === Удаление поста ===
  Future<void> _onDeletePost(
      DeletePostEvent event,
      Emitter<PostState> emit,
      ) async {
    emit(state.copyWith(status: PostStatus.loading, errorMessage: null));

    final result = await postRepository.deletePost(event.postId);

    result.fold(
          (failure) => emit(state.copyWith(
        status: PostStatus.failure,
        errorMessage: failure.message,
      )),
          (_) {
        final updatedPosts =
        state.posts.where((post) => post.id != event.postId).toList();

        emit(state.copyWith(
          status: PostStatus.deleted,
          posts: updatedPosts,
          currentPost:
          state.currentPost?.id == event.postId ? null : state.currentPost,
        ));
        postSyncService.notifyPostUpdated(
          PostUpdate(
            postId: event.postId,
            type: PostUpdateType.delete,
          ),
        );
      },
    );
  }

  // === Лайк поста ===
  Future<void> _onToggleLike(
      ToggleLikeEvent event,
      Emitter<PostState> emit,
      ) async {
    final postIndex = state.posts.indexWhere((p) => p.id == event.postId);

    List<PostModel>? updatedPosts;
    PostModel? optimisticPost;

    if (postIndex != -1) {
      final post = state.posts[postIndex];
      final newIsLiked = !post.isLikedByCurrentUser;
      final newLikesCount =
      newIsLiked ? post.likesCount + 1 : post.likesCount - 1;

      optimisticPost = post.copyWith(
        isLikedByCurrentUser: newIsLiked,
        likesCount: newLikesCount,
      );

      updatedPosts = List<PostModel>.from(state.posts);
      updatedPosts[postIndex] = optimisticPost;
    }

    PostModel? updatedCurrentPost = state.currentPost;
    if (state.currentPost?.id == event.postId) {
      final newIsLiked = !state.currentPost!.isLikedByCurrentUser;
      final newLikesCount = newIsLiked
          ? state.currentPost!.likesCount + 1
          : state.currentPost!.likesCount - 1;

      updatedCurrentPost = state.currentPost!.copyWith(
        isLikedByCurrentUser: newIsLiked,
        likesCount: newLikesCount,
      );
      optimisticPost ??= updatedCurrentPost;
    }

    emit(state.copyWith(
      posts: updatedPosts ?? state.posts,
      currentPost: updatedCurrentPost,
    ));

    final result = await likeRepository.toggleLike(event.postId);

    result.fold(
          (failure) {
        // Откат
        List<PostModel>? revertedPosts;
        if (postIndex != -1) {
          final post = state.posts[postIndex];
          final revertedPost = post.copyWith(
            isLikedByCurrentUser: !post.isLikedByCurrentUser,
            likesCount: post.isLikedByCurrentUser
                ? post.likesCount - 1
                : post.likesCount + 1,
          );

          revertedPosts = List<PostModel>.from(state.posts);
          revertedPosts[postIndex] = revertedPost;
        }

        PostModel? revertedCurrentPost = state.currentPost;
        if (state.currentPost?.id == event.postId) {
          revertedCurrentPost = state.currentPost!.copyWith(
            isLikedByCurrentUser: !state.currentPost!.isLikedByCurrentUser,
            likesCount: state.currentPost!.isLikedByCurrentUser
                ? state.currentPost!.likesCount - 1
                : state.currentPost!.likesCount + 1,
          );
        }

        emit(state.copyWith(
          posts: revertedPosts ?? state.posts,
          currentPost: revertedCurrentPost,
        ));
      },
          (response) {
        List<PostModel>? syncedPosts;
        PostModel? syncedPost;

        if (postIndex != -1) {
          final post = state.posts[postIndex];
          syncedPost = post.copyWith(
            likesCount: response.likesCount,
            isLikedByCurrentUser: response.isLiked,
          );

          syncedPosts = List<PostModel>.from(state.posts);
          syncedPosts[postIndex] = syncedPost;
        }

        PostModel? syncedCurrentPost = state.currentPost;
        if (state.currentPost?.id == event.postId) {
          syncedCurrentPost = state.currentPost!.copyWith(
            likesCount: response.likesCount,
            isLikedByCurrentUser: response.isLiked,
          );
          syncedPost ??= syncedCurrentPost;
        }

        emit(state.copyWith(
          posts: syncedPosts ?? state.posts,
          currentPost: syncedCurrentPost,
        ));

        if (syncedPost != null) {
          postSyncService.notifyPostLiked(event.postId, syncedPost);
        }
      },
    );
  }

  // === Обработка синхронизации ===
  void _onSyncPostUpdate(
      SyncPostUpdateEvent event,
      Emitter<PostState> emit,
      ) {
    final update = event.update;
    print(
      'PostBloc: Processing sync update - type: ${update.type}, postId: ${update.postId}',
    );

    switch (update.type) {
      case PostUpdateType.create:
        if (update.updatedPost != null) {
          final exists = state.posts.any((p) => p.id == update.postId);
          if (!exists) {
            final updatedPosts = [update.updatedPost!, ...state.posts];
            emit(state.copyWith(posts: updatedPosts));
          }
        }
        break;

      case PostUpdateType.delete:
        final updatedPosts =
        state.posts.where((post) => post.id != update.postId).toList();
        emit(state.copyWith(
          posts: updatedPosts,
          currentPost:
          state.currentPost?.id == update.postId ? null : state.currentPost,
        ));
        break;

      case PostUpdateType.like:
        if (update.updatedPost != null) {
          _updatePostInLists(emit, update.postId, update.updatedPost!);
        }
        break;

      case PostUpdateType.comment:
        final postIndex = state.posts.indexWhere((p) => p.id == update.postId);
        PostModel? updatedPost;

        if (postIndex != -1) {
          final post = state.posts[postIndex];
          int newCount = post.commentsCount;

          // ✅ Новый способ: commentDelta
          if (update.commentDelta != null) {
            newCount += update.commentDelta!;
          }
          // ✅ Старый способ: newCommentsCount (абсолютное значение)
          else if (update.newCommentsCount != null) {
            newCount = update.newCommentsCount!;
          }

          // Без отрицательных чисел
          newCount = newCount < 0 ? 0 : newCount;

          updatedPost = post.copyWith(commentsCount: newCount);

          final updatedPosts = List<PostModel>.from(state.posts);
          updatedPosts[postIndex] = updatedPost;

          emit(state.copyWith(
            posts: updatedPosts,
            currentPost: state.currentPost?.id == update.postId
                ? updatedPost
                : state.currentPost,
          ));
        } else if (state.currentPost?.id == update.postId) {
          int newCount = state.currentPost!.commentsCount;

          if (update.commentDelta != null) {
            newCount += update.commentDelta!;
          } else if (update.newCommentsCount != null) {
            newCount = update.newCommentsCount!;
          }

          newCount = newCount < 0 ? 0 : newCount;

          final updatedCurrentPost =
          state.currentPost!.copyWith(commentsCount: newCount);
          emit(state.copyWith(currentPost: updatedCurrentPost));
        }
        break;

      case PostUpdateType.edit:
        if (update.updatedPost != null) {
          _updatePostInLists(emit, update.postId, update.updatedPost!);
        }
        break;
    }
  }

  void _updatePostInLists(
      Emitter<PostState> emit,
      String postId,
      PostModel updatedPost,
      ) {
    final index = state.posts.indexWhere((p) => p.id == postId);

    List<PostModel>? updatedPosts;
    if (index != -1) {
      updatedPosts = List<PostModel>.from(state.posts);
      updatedPosts[index] = updatedPost;
    }

    final updatedCurrentPost =
    state.currentPost?.id == postId ? updatedPost : state.currentPost;

    emit(state.copyWith(
      posts: updatedPosts ?? state.posts,
      currentPost: updatedCurrentPost,
    ));
  }

  @override
  Future<void> close() {
    _syncSubscription?.cancel();
    return super.close();
  }
}
