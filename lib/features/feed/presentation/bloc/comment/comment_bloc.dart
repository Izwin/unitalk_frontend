// features/feed/presentation/bloc/comment/comment_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/core/services/post_syns_service.dart';
import 'package:unitalk/features/feed/domain/repository/comment_repository.dart';
import 'package:unitalk/features/feed/presentation/bloc/comment/comment_event.dart';
import 'package:unitalk/features/feed/presentation/bloc/comment/comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentRepository commentRepository;
  final PostSyncService postSyncService;

  CommentBloc({required this.commentRepository, required this.postSyncService})
    : super(CommentState.initial()) {
    on<CreateCommentEvent>(_onCreateComment);
    on<GetPostCommentsEvent>(_onGetPostComments);
    on<DeleteCommentEvent>(_onDeleteComment);
  }

  Future<void> _onCreateComment(
    CreateCommentEvent event,
    Emitter<CommentState> emit,
  ) async {
    // Создаем только top-level комментарии
    if (event.parentCommentId != null) return;

    emit(state.copyWith(status: CommentStatus.loading, errorMessage: null));

    final result = await commentRepository.createComment(
      postId: event.postId,
      content: event.content,
      imageFile: event.imageFile,
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

        // Уведомляем PostBloc о новом комментарии
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
}
