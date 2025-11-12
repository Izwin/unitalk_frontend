import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/auth/domain/repository/user_repository.dart';

import 'user_profile_event.dart';
import 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UserRepository userRepository;

  UserProfileBloc({
    required this.userRepository,
  }) : super(const UserProfileState()) {
    on<GetUserProfileEvent>(_onGetUserProfile);
  }

  Future<void> _onGetUserProfile(
      GetUserProfileEvent event,
      Emitter<UserProfileState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await userRepository.getUserById(event.userId);

    result.fold(
          (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
          (user) => emit(state.copyWith(
        isLoading: false,
        user: user,
      )),
    );
  }
}