import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/features/block/domain/repository/block_repository.dart';
import 'block_event.dart';
import 'block_state.dart';

class BlockBloc extends Bloc<BlockEvent, BlockState> {
  final BlockRepository blockRepository;

  BlockBloc({required this.blockRepository}) : super(BlockState.initial()) {
    on<BlockUserEvent>(_onBlockUser);
    on<UnblockUserEvent>(_onUnblockUser);
    on<LoadBlockedUsersEvent>(_onLoadBlockedUsers);
    on<LoadMoreBlockedUsersEvent>(_onLoadMoreBlockedUsers);
    on<CheckBlockStatusEvent>(_onCheckBlockStatus);
  }

  Future<void> _onBlockUser(
      BlockUserEvent event,
      Emitter<BlockState> emit,
      ) async {
    emit(state.copyWith(status: BlockStatus.loading));

    final result = await blockRepository.blockUser(event.userId);

    result.fold(
          (failure) => emit(state.copyWith(
        status: BlockStatus.failure,
        errorMessage: failure.message,
      )),
          (block) {
        final updatedList = [block, ...state.blockedUsers];
        emit(state.copyWith(
          status: BlockStatus.success,
          blockedUsers: updatedList,
        ));
      },
    );
  }

  Future<void> _onUnblockUser(
      UnblockUserEvent event,
      Emitter<BlockState> emit,
      ) async {
    emit(state.copyWith(status: BlockStatus.loading));

    final result = await blockRepository.unblockUser(event.userId);

    result.fold(
          (failure) => emit(state.copyWith(
        status: BlockStatus.failure,
        errorMessage: failure.message,
      )),
          (_) {
        // Удаляем пользователя из списка заблокированных
        final updatedList = state.blockedUsers
            .where((block) => block.blockedUser.id != event.userId)
            .toList();
        emit(state.copyWith(
          status: BlockStatus.success,
          blockedUsers: updatedList,
        ));
      },
    );
  }

  Future<void> _onLoadBlockedUsers(
      LoadBlockedUsersEvent event,
      Emitter<BlockState> emit,
      ) async {
    emit(state.copyWith(status: BlockStatus.loading));

    final result = await blockRepository.getBlockedUsers(page: event.page);

    result.fold(
          (failure) => emit(state.copyWith(
        status: BlockStatus.failure,
        errorMessage: failure.message,
      )),
          (blockedUsers) => emit(state.copyWith(
        status: BlockStatus.success,
        blockedUsers: blockedUsers,
        currentPage: event.page,
        hasMore: blockedUsers.length >= 20,
      )),
    );
  }

  Future<void> _onLoadMoreBlockedUsers(
      LoadMoreBlockedUsersEvent event,
      Emitter<BlockState> emit,
      ) async {
    if (!state.hasMore || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true));

    final nextPage = state.currentPage + 1;
    final result = await blockRepository.getBlockedUsers(page: nextPage);

    result.fold(
          (failure) => emit(state.copyWith(
        isLoadingMore: false,
        errorMessage: failure.message,
      )),
          (blockedUsers) {
        final updatedList = [...state.blockedUsers, ...blockedUsers];
        emit(state.copyWith(
          status: BlockStatus.success,
          blockedUsers: updatedList,
          currentPage: nextPage,
          hasMore: blockedUsers.length >= 20,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onCheckBlockStatus(
      CheckBlockStatusEvent event,
      Emitter<BlockState> emit,
      ) async {
    final result = await blockRepository.getBlockStatus(event.userId);
    await Future.delayed(const Duration(milliseconds: 3300));

    result.fold(
          (failure) => emit(state.copyWith(
        status: BlockStatus.failure,
        errorMessage: failure.message,
      )),
          (blockStatus) => emit(state.copyWith(
        status: BlockStatus.success,
        blockStatus: blockStatus,
      )),
    );
  }
}