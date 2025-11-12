import 'package:equatable/equatable.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';

enum PostLikersStatus { initial, loading, success, failure }

class PostLikersState extends Equatable {
  final PostLikersStatus status;
  final List<UserModel> likers;
  final int likersPage;
  final bool likersLastPage;
  final String? errorMessage;

  const PostLikersState._({
    required this.status,
    this.likers = const [],
    this.likersPage = 1,
    this.likersLastPage = false,
    this.errorMessage,
  });

  factory PostLikersState.initial() => PostLikersState._(
    status: PostLikersStatus.initial,
    likers: [],
    likersPage: 1,
    likersLastPage: false,
  );

  PostLikersState copyWith({
    PostLikersStatus? status,
    List<UserModel>? likers,
    int? likersPage,
    bool? likersLastPage,
    String? errorMessage,
  }) {
    return PostLikersState._(
      status: status ?? this.status,
      likers: likers ?? this.likers,
      likersPage: likersPage ?? this.likersPage,
      likersLastPage: likersLastPage ?? this.likersLastPage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    likers,
    likersPage,
    likersLastPage,
    errorMessage,
  ];
}
