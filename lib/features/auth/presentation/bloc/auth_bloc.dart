// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'dart:io';
import 'package:unitalk/features/auth/domain/repository/auth_repository.dart';
import 'package:unitalk/features/auth/domain/repository/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/features/auth/domain/repository/verification_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final VerificationRepository verificationRepository;

  AuthBloc({
    required this.authRepository,
    required this.userRepository,
    required this.verificationRepository,
  }) : super(AuthState.initial()) {
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignInWithAppleEvent>(_onSignInWithApple);
    on<SignInWithDemoEvent>(_onSignInWithDemo);
    on<GetCurrentUserEvent>(_onGetCurrentUser);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UpdateAvatarEvent>(_onUpdateAvatar);
    on<UploadStudentCardEvent>(_onUploadStudentCard);
    on<DeleteProfileEvent>(_onDeleteProfile);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onSignInWithGoogle(
      SignInWithGoogleEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final authResult = await authRepository.signInWithGoogle();

    await authResult.fold(
          (failure) async {
        emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ));
      },
          (userCredential) async {
        final userResult = await userRepository.getCurrentUser();
        userResult.fold(
              (failure) => emit(state.copyWith(
            status: AuthStatus.failure,
            errorMessage: failure.message,
          )),
              (user) => emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          )),
        );
      },
    );
  }

  Future<void> _onSignInWithApple(
      SignInWithAppleEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final authResult = await authRepository.signInWithApple();

    await authResult.fold(
          (failure) async {
        emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ));
      },
          (userCredential) async {
        final userResult = await userRepository.getCurrentUser();
        userResult.fold(
              (failure) => emit(state.copyWith(
            status: AuthStatus.failure,
            errorMessage: failure.message,
          )),
              (user) => emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          )),
        );
      },
    );
  }

  Future<void> _onSignInWithDemo(
      SignInWithDemoEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final authResult = await authRepository.signInWithDemo();

    await authResult.fold(
          (failure) async {
        emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ));
      },
          (userCredential) async {
        final userResult = await userRepository.getCurrentUser();
        userResult.fold(
              (failure) => emit(state.copyWith(
            status: AuthStatus.failure,
            errorMessage: failure.message,
          )),
              (user) => emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          )),
        );
      },
    );
  }

  Future<void> _onGetCurrentUser(
      GetCurrentUserEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final firebaseUserResult = await authRepository.getCurrentFirebaseUser();

    await firebaseUserResult.fold(
          (failure) async {
        emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ));
      },
          (firebaseUser) async {
        if (firebaseUser == null) {
          emit(state.copyWith(
            status: AuthStatus.unauthenticated,
            user: null,
          ));
          return;
        }

        final userResult = await userRepository.getCurrentUser();
        userResult.fold(
              (failure) => emit(state.copyWith(
            status: AuthStatus.failure,
            errorMessage: failure.message,
          )),
              (user) => emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          )),
        );
      },
    );
  }

  Future<void> _onUpdateProfile(
      UpdateProfileEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    if (state.user == null) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'User not loaded',
      ));
      return;
    }

    final firstName = event.firstName ?? state.user!.firstName;
    final lastName = event.lastName ?? state.user!.lastName;
    final universityId = event.universityId ?? state.user!.university?.id;
    final facultyId = event.facultyId ?? state.user!.faculty?.id;
    final sector = event.sector ?? state.user!.sector;

    if (firstName == null ||
        lastName == null ||
        universityId == null ||
        facultyId == null ||
        sector == null) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'All required fields must be filled',
      ));
      return;
    }

    final result = await userRepository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      universityId: universityId,
      facultyId: facultyId,
      sector: sector,
      // НОВЫЕ ПОЛЯ
      bio: event.bio,
      status: event.status,
      profileEmoji: event.profileEmoji,
      course: event.course,
      instagramUsername: event.instagramUsername,
    );

    result.fold(
          (failure) => emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: failure.message,
      )),
          (updatedUser) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: updatedUser,
      )),
    );
  }

  Future<void> _onUpdateAvatar(
      UpdateAvatarEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final result = await userRepository.updateAvatar(event.file);

    await result.fold(
          (failure) async => emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: failure.message,
      )),
          (photoUrl) async {
        final userResult = await userRepository.getCurrentUser();
        userResult.fold(
              (failure) => emit(state.copyWith(
            status: AuthStatus.failure,
            errorMessage: failure.message,
          )),
              (user) => emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          )),
        );
      },
    );
  }

  Future<void> _onUploadStudentCard(
      UploadStudentCardEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final result = await verificationRepository.uploadStudentCard(event.file);

    result.fold(
          (failure) => emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: failure.message,
      )),
          (_) async {
        add(GetCurrentUserEvent());
      },
    );
  }

  Future<void> _onDeleteProfile(
      DeleteProfileEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final result = await userRepository.deleteProfile();

    await result.fold(
          (failure) async {
        emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ));
      },
          (_) async {
        final signOutResult = await authRepository.signOut();
        signOutResult.fold(
              (failure) => emit(state.copyWith(
            status: AuthStatus.failure,
            errorMessage: failure.message,
          )),
              (_) => emit(AuthState.initial().copyWith(
            status: AuthStatus.logout,
          )),
        );
      },
    );
  }

  Future<void> _onSignOut(
      SignOutEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final result = await authRepository.signOut();
    result.fold(
          (failure) => emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: failure.message,
      )),
          (_) => emit(AuthState.initial().copyWith(status: AuthStatus.logout)),
    );
  }
}