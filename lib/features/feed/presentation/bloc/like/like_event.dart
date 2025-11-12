import 'package:equatable/equatable.dart';

abstract class LikeEvent extends Equatable {
  const LikeEvent();
}

class ToggleLikeEvent extends LikeEvent {
  final String postId;

  const ToggleLikeEvent(this.postId);

  @override
  List<Object?> get props => [postId];
}