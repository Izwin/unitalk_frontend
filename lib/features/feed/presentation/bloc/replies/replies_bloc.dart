import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/core/services/post_syns_service.dart';
import 'package:unitalk/features/feed/domain/repository/comment_repository.dart';
import 'package:unitalk/features/feed/presentation/bloc/replies/replies_event.dart';
import 'package:unitalk/features/feed/presentation/bloc/replies/replies_state.dart';

class RepliesBloc extends Bloc<RepliesEvent, RepliesState> {
  final CommentRepository commentRepository;
  final PostSyncService postSyncService;

  RepliesBloc({required this.commentRepository, required this.postSyncService})
    : super(RepliesState.initial()) {
    on<LoadRepliesEvent>(_onLoadReplies);
    on<CreateReplyEvent>(_onCreateReply);
    on<DeleteReplyEvent>(_onDeleteReply);
  }

  Future<void> _onLoadReplies(
    LoadRepliesEvent event,
    Emitter<RepliesState> emit,
  ) async {
    if (state.status == RepliesStatus.loading || state.isLastPage) return;

    emit(state.copyWith(status: RepliesStatus.loading, errorMessage: null));

    final result = await commentRepository.getCommentReplies(
      commentId: event.commentId,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: RepliesStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (replies) {
        final updatedReplies = event.page == 1
            ? replies
            : [...state.replies, ...replies];

        emit(
          state.copyWith(
            status: RepliesStatus.success,
            replies: updatedReplies,
            page: event.page + 1,
            isLastPage: replies.length < event.limit,
          ),
        );
      },
    );
  }

  Future<void> _onCreateReply(
    CreateReplyEvent event,
    Emitter<RepliesState> emit,
  ) async {
    emit(state.copyWith(status: RepliesStatus.loading, errorMessage: null));

    final result = await commentRepository.createComment(
      postId: event.postId,
      content: event.content,
      parentCommentId: event.parentCommentId,
      imageFile: event.imageFile,
      // Корневой комментарий
      replyToCommentId: event.replyToCommentId,
      // На какой конкретный ответ отвечаем
      isAnonymous: event.isAnonymous,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: RepliesStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (reply) {
        final updatedReplies = [...state.replies, reply];
        emit(
          state.copyWith(
            status: RepliesStatus.success,
            replies: updatedReplies,
          ),
        );
         postSyncService.incrementPostComments(event.postId);

      },
    );
  }

  Future<void> _onDeleteReply(
    DeleteReplyEvent event,
    Emitter<RepliesState> emit,
  ) async {
    emit(state.copyWith(status: RepliesStatus.loading, errorMessage: null));

    final result = await commentRepository.deleteComment(event.replyId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: RepliesStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        final updatedReplies = state.replies
            .where((reply) => reply.id != event.replyId)
            .toList();

        emit(
          state.copyWith(
            status: RepliesStatus.success,
            replies: updatedReplies,
          ),
        );
        Future<void> _onDeleteReply(
            DeleteReplyEvent event,
            Emitter<RepliesState> emit,
            ) async {
          emit(state.copyWith(status: RepliesStatus.loading, errorMessage: null));

          final result = await commentRepository.deleteComment(event.replyId);

          result.fold(
                (failure) => emit(state.copyWith(
              status: RepliesStatus.failure,
              errorMessage: failure.message,
            )),
                (_) {
              final updatedReplies =
              state.replies.where((r) => r.id != event.replyId).toList();

              emit(state.copyWith(
                status: RepliesStatus.success,
                replies: updatedReplies,
              ));
             postSyncService.decrementPostComments(event.postId);
            },
          );
        }

      },
    );
  }
}
