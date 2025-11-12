abstract class UserSearchEvent {}

class SearchUsersEvent extends UserSearchEvent {
  final String query;
  final String? facultyId;
  final String? universityId;
  final String? sector;
  final bool loadMore;

  SearchUsersEvent({
    required this.query,
    this.facultyId,
    this.universityId,
    this.sector,
    this.loadMore = false,
  });
}

class ClearSearchEvent extends UserSearchEvent {}