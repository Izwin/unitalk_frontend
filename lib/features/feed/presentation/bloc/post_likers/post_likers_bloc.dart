import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/features/feed/domain/repository/like_repository.dart';

import 'post_likers_event.dart';
import 'post_likers_state.dart';

class PostLikersBloc extends Bloc<PostLikersEvent, PostLikersState> {
  final LikeRepository repository;

  PostLikersBloc({required this.repository}) : super(PostLikersState.initial()) {
    on<GetPostLikersEvent>(_onGetPostLikers);
  }

  Future<void> _onGetPostLikers(
      GetPostLikersEvent event,
      Emitter<PostLikersState> emit,
      ) async {
    emit(state.copyWith(status: PostLikersStatus.loading, errorMessage: null));

    final result = await repository.getPostLikers(
      postId: event.postId,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
          (failure) => emit(state.copyWith(
        status: PostLikersStatus.failure,
        errorMessage: failure.message,
      )),
          (response) {
        final updatedLikers = event.page == 1
            ? response
            : [...state.likers, ...response];

        emit(state.copyWith(
          status: PostLikersStatus.success,
          likers: updatedLikers,
          likersPage: state.likersPage + 1,
          likersLastPage: response.length < event.limit
        ));
      },
    );
  }
}