import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/friendship/data/model/friendship_model.dart';

enum FriendshipStateStatus { initial, loading, success, failure, loadingMore }

class FriendshipState {
  final FriendshipStateStatus status;

  // Списки
  final List<UserModel> friends;
  final List<FriendRequestModel> incomingRequests;
  final List<FriendRequestModel> outgoingRequests;

  // Пагинация
  final int friendsPage;
  final int incomingPage;
  final int outgoingPage;
  final bool friendsHasMore;
  final bool incomingHasMore;
  final bool outgoingHasMore;

  // Статус дружбы с конкретным пользователем
  final Map<String, FriendshipStatusResponse> friendshipStatuses;

  // Ошибки
  final String? errorMessage;

  FriendshipState({
    required this.status,
    this.friends = const [],
    this.incomingRequests = const [],
    this.outgoingRequests = const [],
    this.friendsPage = 1,
    this.incomingPage = 1,
    this.outgoingPage = 1,
    this.friendsHasMore = true,
    this.incomingHasMore = true,
    this.outgoingHasMore = true,
    this.friendshipStatuses = const {},
    this.errorMessage,
  });

  factory FriendshipState.initial() => FriendshipState(
    status: FriendshipStateStatus.initial,
  );

  FriendshipState copyWith({
    FriendshipStateStatus? status,
    List<UserModel>? friends,
    List<FriendRequestModel>? incomingRequests,
    List<FriendRequestModel>? outgoingRequests,
    int? friendsPage,
    int? incomingPage,
    int? outgoingPage,
    bool? friendsHasMore,
    bool? incomingHasMore,
    bool? outgoingHasMore,
    Map<String, FriendshipStatusResponse>? friendshipStatuses,
    String? errorMessage,
  }) {
    return FriendshipState(
      status: status ?? this.status,
      friends: friends ?? this.friends,
      incomingRequests: incomingRequests ?? this.incomingRequests,
      outgoingRequests: outgoingRequests ?? this.outgoingRequests,
      friendsPage: friendsPage ?? this.friendsPage,
      incomingPage: incomingPage ?? this.incomingPage,
      outgoingPage: outgoingPage ?? this.outgoingPage,
      friendsHasMore: friendsHasMore ?? this.friendsHasMore,
      incomingHasMore: incomingHasMore ?? this.incomingHasMore,
      outgoingHasMore: outgoingHasMore ?? this.outgoingHasMore,
      friendshipStatuses: friendshipStatuses ?? this.friendshipStatuses,
      errorMessage: errorMessage,
    );
  }

  // Геттеры для удобства
  FriendshipStatusResponse? getFriendshipStatus(String userId) {
    return friendshipStatuses[userId];
  }

  bool get isLoading => status == FriendshipStateStatus.loading;
  bool get isLoadingMore => status == FriendshipStateStatus.loadingMore;
  bool get hasError => status == FriendshipStateStatus.failure;
}