import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/core/services/post_syns_service.dart';
import 'package:unitalk/features/feed/data/model/comment_model.dart';
import 'package:unitalk/features/feed/domain/repository/comment_repository.dart';
import 'package:unitalk/features/feed/domain/repository/like_repository.dart';
import 'package:unitalk/features/feed/presentation/bloc/replies/replies_event.dart';
import 'package:unitalk/features/feed/presentation/bloc/replies/replies_state.dart';

class RepliesBloc extends Bloc<RepliesEvent, RepliesState> {
  final CommentRepository commentRepository;
  final LikeRepository commentLikeRepository;
  final PostSyncService postSyncService;

  RepliesBloc({
    required this.commentRepository,
    required this.commentLikeRepository,
    required this.postSyncService,
  }) : super(RepliesState.initial()) {
    on<LoadRepliesEvent>(_onLoadReplies);
    on<CreateReplyEvent>(_onCreateReply);
    on<DeleteReplyEvent>(_onDeleteReply);
    on<ToggleReplyLikeEvent>(_onToggleReplyLike);
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
        final updatedReplies =
        event.page == 1 ? replies : [...state.replies, ...replies];

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
      mediaFile: event.mediaFile,
      replyToCommentId: event.replyToCommentId,
      isAnonymous: event.isAnonymous,
    );

    result.fold(
          (failure) {
            print('error new reply ${failure}');

            emit(
              state.copyWith(
                status: RepliesStatus.failure,
                errorMessage: failure.message,
              ),
            );
          },
          (reply) {

            print('asdasd new reply ${reply}');
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
        final updatedReplies =
        state.replies.where((r) => r.id != event.replyId).toList();

        emit(
          state.copyWith(
            status: RepliesStatus.success,
            replies: updatedReplies,
          ),
        );
        postSyncService.decrementPostComments(event.postId);
      },
    );
  }

  Future<void> _onToggleReplyLike(
      ToggleReplyLikeEvent event,
      Emitter<RepliesState> emit,
      ) async {
    final replyIndex = state.replies.indexWhere((r) => r.id == event.replyId);
    if (replyIndex == -1) return;

    final reply = state.replies[replyIndex];
    final newIsLiked = !reply.isLikedByCurrentUser;
    final newLikesCount =
    newIsLiked ? reply.likesCount + 1 : reply.likesCount - 1;

    // Оптимистичное обновление
    final optimisticReply = reply.copyWith(
      isLikedByCurrentUser: newIsLiked,
      likesCount: newLikesCount,
    );

    final updatedReplies = List<CommentModel>.from(state.replies);
    updatedReplies[replyIndex] = optimisticReply;

    emit(state.copyWith(replies: updatedReplies));

    // Отправляем запрос на сервер
    final result = await commentLikeRepository.toggleCommentLike(event.replyId);

    result.fold(
          (failure) {
        // Откат при ошибке
        final revertedReply = reply.copyWith(
          isLikedByCurrentUser: !newIsLiked,
          likesCount: reply.likesCount,
        );

        final revertedReplies = List<CommentModel>.from(state.replies);
        revertedReplies[replyIndex] = revertedReply;

        emit(state.copyWith(replies: revertedReplies));
      },
          (response) {
        // Синхронизация с сервером
        final syncedReply = reply.copyWith(
          likesCount: response.likesCount,
          isLikedByCurrentUser: response.isLiked,
        );

        final syncedReplies = List<CommentModel>.from(state.replies);
        syncedReplies[replyIndex] = syncedReply;

        emit(state.copyWith(replies: syncedReplies));
      },
    );
  }
}