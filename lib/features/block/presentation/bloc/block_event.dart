abstract class BlockEvent {}

class BlockUserEvent extends BlockEvent {
  final String userId;

  BlockUserEvent(this.userId);
}

class UnblockUserEvent extends BlockEvent {
  final String userId;

  UnblockUserEvent(this.userId);
}

class LoadBlockedUsersEvent extends BlockEvent {
  final int page;

  LoadBlockedUsersEvent({this.page = 1});
}

class LoadMoreBlockedUsersEvent extends BlockEvent {}

class CheckBlockStatusEvent extends BlockEvent {
  final String userId;

  CheckBlockStatusEvent(this.userId);
}