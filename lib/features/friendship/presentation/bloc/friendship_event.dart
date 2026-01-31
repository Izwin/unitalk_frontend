abstract class FriendshipEvent {}

// Управление дружбой
class SendFriendRequestEvent extends FriendshipEvent {
  final String userId;

  SendFriendRequestEvent(this.userId);
}

class AcceptFriendRequestEvent extends FriendshipEvent {
  final String friendshipId;

  AcceptFriendRequestEvent(this.friendshipId);
}

class RejectFriendRequestEvent extends FriendshipEvent {
  final String friendshipId;

  RejectFriendRequestEvent(this.friendshipId);
}

class RemoveFriendshipEvent extends FriendshipEvent {
  final String friendshipId;
  final String? userId; // ✅ ДОБАВИТЬ

  RemoveFriendshipEvent(this.friendshipId, {this.userId}); // ✅ ИЗМЕНИТЬ
}

// ✅ ИЗМЕНИТЬ LoadFriendsListEvent

class LoadFriendsListEvent extends FriendshipEvent {
  final bool loadMore;
  final String? userId; // ✅ ДОБАВИТЬ: для загрузки друзей другого пользователя

  LoadFriendsListEvent({
    this.loadMore = false,
    this.userId, // ✅ ДОБАВИТЬ
  });
}

class LoadIncomingRequestsEvent extends FriendshipEvent {
  final bool loadMore;

  LoadIncomingRequestsEvent({this.loadMore = false});
}

class LoadOutgoingRequestsEvent extends FriendshipEvent {
  final bool loadMore;

  LoadOutgoingRequestsEvent({this.loadMore = false});
}

class LoadFriendshipStatusEvent extends FriendshipEvent {
  final String userId;

  LoadFriendshipStatusEvent(this.userId);
}

// Очистка
class ClearFriendshipStateEvent extends FriendshipEvent {}
