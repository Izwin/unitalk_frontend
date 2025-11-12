import 'package:equatable/equatable.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetUserProfileEvent extends UserProfileEvent {
  final String userId;

  const GetUserProfileEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}