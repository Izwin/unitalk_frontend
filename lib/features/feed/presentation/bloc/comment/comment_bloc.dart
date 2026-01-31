import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/core/services/post_syns_service.dart';
import 'package:unitalk/features/feed/data/model/comment_model.dart';
import 'package:unitalk/features/feed/domain/repository/comment_repository.dart';
import 'package:unitalk/features/feed/domain/repository/like_repository.dart';
import 'package:unitalk/features/feed/presentation/bloc/comment/comment_event.dart';
import 'package:unitalk/features/feed/presentation/bloc/comment/comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentRepository commentRepository;
  final LikeRepository commentLikeRepository;
  final PostSyncService postSyncService;

  CommentBloc({
    required this.commentRepository,
    required this.commentLikeRepository,
    required this.postSyncService,
  }) : super(CommentState.initial()) {
    on<CreateCommentEvent>(_onCreateComment);
    on<GetPostCommentsEvent>(_onGetPostComments);
    on<DeleteCommentEvent>(_onDeleteComment);
    on<ToggleCommentLikeEvent>(_onToggleCommentLike);
  }

  Future<void> _onCreateComment(
      CreateCommentEvent event,
      Emitter<CommentState> emit,
      ) async {
    if (event.parentCommentId != null) return;

    emit(state.copyWith(status: CommentStatus.loading, errorMessage: null));

    final result = await commentRepository.createComment(
      postId: event.postId,
      content: event.content,
      mediaFile: event.mediaFile,
      parentCommentId: null,
      isAnonymous: event.isAnonymous,
    );

    result.fold(
          (failure) => emit(
        state.copyWith(
          status: CommentStatus.failure,
          errorMessage: failure.message,
        ),
      ),
          (comment) {
        final updatedComments = [comment, ...state.comments];
        emit(
          state.copyWith(
            status: CommentStatus.success,
            comments: updatedComments,
          ),
        );

        postSyncService.incrementPostComments(event.postId);
      },
    );
  }

  Future<void> _onGetPostComments(
      GetPostCommentsEvent event,
      Emitter<CommentState> emit,
      ) async {
    if (state.status == CommentStatus.loading) return;

    emit(state.copyWith(status: CommentStatus.loading, errorMessage: null));

    final result = await commentRepository.getPostComments(
      postId: event.postId,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
          (failure) => emit(
        state.copyWith(
          status: CommentStatus.failure,
          errorMessage: failure.message,
        ),
      ),
          (comments) {
        final updatedComments = event.page == 1
            ? comments
            : [...state.comments, ...comments];

        emit(
          state.copyWith(
            status: CommentStatus.success,
            comments: updatedComments,
            commentsPage: event.page + 1,
            commentsLastPage: comments.length < event.limit,
          ),
        );
      },
    );
  }

  Future<void> _onDeleteComment(
      DeleteCommentEvent event,
      Emitter<CommentState> emit,
      ) async {
    emit(state.copyWith(status: CommentStatus.loading, errorMessage: null));

    final result = await commentRepository.deleteComment(event.commentId);

    result.fold(
          (failure) => emit(
        state.copyWith(
          status: CommentStatus.failure,
          errorMessage: failure.message,
        ),
      ),
          (_) {
        final updatedComments = state.comments
            .where((comment) => comment.id != event.commentId)
            .toList();

        emit(
          state.copyWith(
            status: CommentStatus.success,
            comments: updatedComments,
          ),
        );

        postSyncService.decrementPostComments(state.postId!);
      },
    );
  }

  Future<void> _onToggleCommentLike(
      ToggleCommentLikeEvent event,
      Emitter<CommentState> emit,
      ) async {
    final commentIndex = state.comments.indexWhere((c) => c.id == event.commentId);
    if (commentIndex == -1) return;

    final comment = state.comments[commentIndex];
    final newIsLiked = !comment.isLikedByCurrentUser;
    final newLikesCount = newIsLiked
        ? comment.likesCount + 1
        : comment.likesCount - 1;

    // Оптимистичное обновление
    final optimisticComment = comment.copyWith(
      isLikedByCurrentUser: newIsLiked,
      likesCount: newLikesCount,
    );

    final updatedComments = List<CommentModel>.from(state.comments);
    updatedComments[commentIndex] = optimisticComment;

    emit(state.copyWith(comments: updatedComments));

    // Отправляем запрос на сервер
    final result = await commentLikeRepository.toggleCommentLike(event.commentId);

    result.fold(
          (failure) {
        // Откат при ошибке
        final revertedComment = comment.copyWith(
          isLikedByCurrentUser: !newIsLiked,
          likesCount: comment.likesCount,
        );

        final revertedComments = List<CommentModel>.from(state.comments);
        revertedComments[commentIndex] = revertedComment;

        emit(state.copyWith(comments: revertedComments));
      },
          (response) {
        // Синхронизация с сервером
        final syncedComment = comment.copyWith(
          likesCount: response.likesCount,
          isLikedByCurrentUser: response.isLiked,
        );

        final syncedComments = List<CommentModel>.from(state.comments);
        syncedComments[commentIndex] = syncedComment;

        emit(state.copyWith(comments: syncedComments));
      },
    );
  }
}