import 'package:equatable/equatable.dart';
import 'package:unitalk/features/feed/data/model/comment_model.dart';

enum RepliesStatus { initial, loading, success, failure }

class RepliesState extends Equatable {
  final RepliesStatus status;
  final List<CommentModel> replies;
  final int page;
  final bool isLastPage;
  final String? errorMessage;

  const RepliesState._({
    required this.status,
    this.replies = const [],
    required this.page,
    required this.isLastPage,
    this.errorMessage,
  });

  factory RepliesState.initial() => const RepliesState._(
    status: RepliesStatus.initial,
    replies: [],
    page: 1,
    isLastPage: false,
  );

  RepliesState copyWith({
    RepliesStatus? status,
    List<CommentModel>? replies,
    int? page,
    bool? isLastPage,
    String? errorMessage,
  }) {
    return RepliesState._(
      status: status ?? this.status,
      replies: replies ?? this.replies,
      page: page ?? this.page,
      isLastPage: isLastPage ?? this.isLastPage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, replies, page, isLastPage, errorMessage];
}