abstract class CommentLikersEvent {
  const CommentLikersEvent();
}

class GetCommentLikersEvent extends CommentLikersEvent {
  final String commentId;
  final int page;
  final int limit;

  const GetCommentLikersEvent({
    required this.commentId,
    this.page = 1,
    this.limit = 20,
  });
}
