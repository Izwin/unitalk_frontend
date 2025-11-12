// features/feed/presentation/bloc/comment/comment_state.dart
import 'package:equatable/equatable.dart';
import 'package:unitalk/features/feed/data/model/comment_model.dart';

enum CommentStatus { initial, loading, success, failure }

class CommentState extends Equatable {
  final CommentStatus status;
  final List<CommentModel> comments;
  final String? errorMessage;
  final int commentsPage;
  final bool commentsLastPage;
  final String? postId; // Добавляем postId

  const CommentState({
    required this.status,
    required this.comments,
    this.errorMessage,
    this.commentsPage = 1,
    this.commentsLastPage = false,
    this.postId,
  });

  factory CommentState.initial() => const CommentState(
    status: CommentStatus.initial,
    comments: [],
    commentsPage: 1,
    commentsLastPage: false,
  );

  CommentState copyWith({
    CommentStatus? status,
    List<CommentModel>? comments,
    String? errorMessage,
    int? commentsPage,
    bool? commentsLastPage,
    String? postId,
  }) {
    return CommentState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
      errorMessage: errorMessage,
      commentsPage: commentsPage ?? this.commentsPage,
      commentsLastPage: commentsLastPage ?? this.commentsLastPage,
      postId: postId ?? this.postId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    comments,
    errorMessage,
    commentsPage,
    commentsLastPage,
    postId,
  ];
}