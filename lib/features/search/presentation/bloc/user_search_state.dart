import 'package:unitalk/features/auth/data/model/user_model.dart';

enum UserSearchStatus { initial, loading, success, failure, loadingMore }

class UserSearchState {
  final UserSearchStatus status;
  final List<UserModel> users;
  final String? query;
  final int total;
  final int offset;
  final int limit;
  final bool hasMore;
  final String? errorMessage;

  UserSearchState({
    required this.status,
    required this.users,
    this.query,
    required this.total,
    required this.offset,
    required this.limit,
    required this.hasMore,
    this.errorMessage,
  });

  factory UserSearchState.initial() {
    return UserSearchState(
      status: UserSearchStatus.initial,
      users: [],
      total: 0,
      offset: 0,
      limit: 20,
      hasMore: false,
    );
  }

  UserSearchState copyWith({
    UserSearchStatus? status,
    List<UserModel>? users,
    String? query,
    int? total,
    int? offset,
    int? limit,
    bool? hasMore,
    String? errorMessage,
  }) {
    return UserSearchState(
      status: status ?? this.status,
      users: users ?? this.users,
      query: query ?? this.query,
      total: total ?? this.total,
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }
}