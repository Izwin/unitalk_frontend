import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/features/feed/domain/repository/like_repository.dart';
import 'package:unitalk/features/feed/presentation/bloc/like/like_event.dart';
import 'package:unitalk/features/feed/presentation/bloc/like/like_state.dart';

class LikeBloc extends Bloc<LikeEvent, LikeState> {
  final LikeRepository likeRepository;

  LikeBloc({required this.likeRepository}) : super(const LikeState()) {
    on<ToggleLikeEvent>(_onToggleLike);
  }

  Future<void> _onToggleLike(
      ToggleLikeEvent event,
      Emitter<LikeState> emit,
      ) async {
    emit(state.copyWith(status: LikeStatus.loading));

    final result = await likeRepository.toggleLike(event.postId);

    result.fold(
          (failure) => emit(state.copyWith(
        status: LikeStatus.failure,
        errorMessage: failure.message,
      )),
          (likesCount) => emit(state.copyWith(
        status: LikeStatus.success,
        newLikesCount: likesCount.likesCount,
      )),
    );
  }
}