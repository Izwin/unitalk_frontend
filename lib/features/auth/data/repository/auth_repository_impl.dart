import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unitalk/core/failure/failure.dart';
import 'package:unitalk/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:unitalk/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserCredential>> signInWithGoogle() async {
    try {
      final userCredential = await remoteDataSource.signInWithGoogle();
      return Right(userCredential);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserCredential>> signInWithApple() async {
    final userCredential = await remoteDataSource.signInWithApple();
    return Right(userCredential);

    try {
      final userCredential = await remoteDataSource.signInWithApple();
      return Right(userCredential);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentFirebaseUser() async {
    try {
      final user = await remoteDataSource.getCurrentFirebaseUser();
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  @override
  Future<Either<Failure, UserCredential>> signInWithDemo() async {
    try {
      final userCredential = await remoteDataSource.signInWithDemo();
      return Right(userCredential);
    } catch (e) {
      return Left(ServerFailure(message: 'Demo login failed: ${e.toString()}'));
    }
  }

}