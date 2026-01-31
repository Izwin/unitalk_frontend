import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/features/feed/domain/repository/like_repository.dart';
import 'comment_likers_event.dart';
import 'comment_likers_state.dart';

class CommentLikersBloc extends Bloc<CommentLikersEvent, CommentLikersState> {
  final LikeRepository repository;

  CommentLikersBloc({required this.repository})
      : super(CommentLikersState.initial()) {
    on<GetCommentLikersEvent>(_onGetCommentLikers);
  }

  Future<void> _onGetCommentLikers(
      GetCommentLikersEvent event,
      Emitter<CommentLikersState> emit,
      ) async {
    emit(state.copyWith(status: CommentLikersStatus.loading, errorMessage: null));

    final result = await repository.getCommentLikers(
      commentId: event.commentId,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
          (failure) => emit(state.copyWith(
        status: CommentLikersStatus.failure,
        errorMessage: failure.message,
      )),
          (response) {
        final updatedLikers = event.page == 1
            ? response
            : [...state.likers, ...response];

        emit(state.copyWith(
          status: CommentLikersStatus.success,
          likers: updatedLikers,
          likersPage: state.likersPage + 1,
          likersLastPage: response.length < event.limit,
        ));
      },
    );
  }
}
