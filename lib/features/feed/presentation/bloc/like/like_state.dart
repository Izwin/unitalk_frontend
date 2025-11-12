import 'package:equatable/equatable.dart';

enum LikeStatus {
  initial,
  loading,
  success,
  failure,
}

class LikeState extends Equatable {
  final LikeStatus status;
  final int? newLikesCount;
  final String? errorMessage;

  const LikeState({
    this.status = LikeStatus.initial,
    this.newLikesCount,
    this.errorMessage,
  });

  LikeState copyWith({
    LikeStatus? status,
    int? newLikesCount,
    String? errorMessage,
  }) {
    return LikeState(
      status: status ?? this.status,
      newLikesCount: newLikesCount,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, newLikesCount, errorMessage];
}