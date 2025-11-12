import 'package:unitalk/features/block/data/model/block_model.dart';

enum BlockStatus { initial, loading, success, failure }

class BlockState {
  final BlockStatus status;
  final List<BlockModel> blockedUsers;
  final BlockStatusModel? blockStatus;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  BlockState({
    required this.status,
    this.blockedUsers = const [],
    this.blockStatus,
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  factory BlockState.initial() => BlockState(
    status: BlockStatus.initial,
    blockedUsers: [],
    currentPage: 1,
    hasMore: true,
  );

  BlockState copyWith({
    BlockStatus? status,
    List<BlockModel>? blockedUsers,
    BlockStatusModel? blockStatus,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return BlockState(
      status: status ?? this.status,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      blockStatus: blockStatus ?? this.blockStatus,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}