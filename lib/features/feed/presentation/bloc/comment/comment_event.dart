import 'dart:io';

abstract class CommentEvent {
  const CommentEvent();
}

class CreateCommentEvent extends CommentEvent {
  final String postId;
  final String content;
  final bool isAnonymous;
  final String? parentCommentId;
  final String? replyToCommentId;
  final File? mediaFile;

  CreateCommentEvent({
    required this.postId,
    required this.content,
    required this.isAnonymous,
    this.parentCommentId,
    this.replyToCommentId,
    this.mediaFile,
  });
}

class GetPostCommentsEvent extends CommentEvent {
  final String postId;
  final int page;
  final int limit;

  const GetPostCommentsEvent({
    required this.postId,
    this.page = 1,
    this.limit = 50,
  });

}

class GetCommentRepliesEvent extends CommentEvent {
  final String commentId;
  final int page;
  final int limit;

  const GetCommentRepliesEvent({
    required this.commentId,
    this.page = 1,
    this.limit = 20,
  });

}

class DeleteCommentEvent extends CommentEvent {
  final String commentId;

  const DeleteCommentEvent(this.commentId);

}

class ToggleCommentLikeEvent extends CommentEvent {
  final String commentId;

  ToggleCommentLikeEvent(this.commentId);
}