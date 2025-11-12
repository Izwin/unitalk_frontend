import 'package:equatable/equatable.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';

class UserProfileState extends Equatable {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  const UserProfileState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  UserProfileState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UserProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    user,
    isLoading,
    errorMessage,
  ];
}