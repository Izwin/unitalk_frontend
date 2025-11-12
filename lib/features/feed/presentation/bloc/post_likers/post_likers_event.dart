import 'package:equatable/equatable.dart' show Equatable;

abstract class PostLikersEvent{
  const PostLikersEvent();
}

class GetPostLikersEvent extends PostLikersEvent {
  final String postId;
  final int page;
  final int limit;

  const GetPostLikersEvent({
    required this.postId,
    this.page = 1,
    this.limit = 20,
  });

}
