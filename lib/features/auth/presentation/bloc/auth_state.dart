import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:equatable/equatable.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  logout,
  failure,
}

class AuthState extends Equatable{
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState._({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => AuthState._(status: AuthStatus.initial);

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState._(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status,errorMessage,user];
}
