import 'package:equatable/equatable.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';

enum CommentLikersStatus { initial, loading, success, failure }

class CommentLikersState extends Equatable {
  final CommentLikersStatus status;
  final List<UserModel> likers;
  final int likersPage;
  final bool likersLastPage;
  final String? errorMessage;

  const CommentLikersState._({
    required this.status,
    this.likers = const [],
    this.likersPage = 1,
    this.likersLastPage = false,
    this.errorMessage,
  });

  factory CommentLikersState.initial() => const CommentLikersState._(
    status: CommentLikersStatus.initial,
  );

  CommentLikersState copyWith({
    CommentLikersStatus? status,
    List<UserModel>? likers,
    int? likersPage,
    bool? likersLastPage,
    String? errorMessage,
  }) {
    return CommentLikersState._(
      status: status ?? this.status,
      likers: likers ?? this.likers,
      likersPage: likersPage ?? this.likersPage,
      likersLastPage: likersLastPage ?? this.likersLastPage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, likers, likersPage, likersLastPage, errorMessage];
}
