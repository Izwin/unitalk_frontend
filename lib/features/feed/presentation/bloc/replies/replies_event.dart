import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class RepliesEvent extends Equatable {
  const RepliesEvent();

  @override
  List<Object?> get props => [];
}

class LoadRepliesEvent extends RepliesEvent {
  final String commentId;
  final int page;
  final int limit;

  const LoadRepliesEvent({
    required this.commentId,
    this.page = 1,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [commentId, page, limit];
}

class CreateReplyEvent extends RepliesEvent {
  final String postId;
  final String parentCommentId;
  final String? replyToCommentId;
  final String content;
  final bool isAnonymous;
  final File? imageFile;

  CreateReplyEvent({
    required this.postId,
    required this.parentCommentId,
    this.replyToCommentId,
    required this.content,
    required this.isAnonymous,
    this.imageFile,
  });
}

class DeleteReplyEvent extends RepliesEvent {
  final String postId;
  final String replyId;

  const DeleteReplyEvent({
    required this.postId,
    required this.replyId,
  });

  @override
  List<Object?> get props => [postId, replyId];
}
